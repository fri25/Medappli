<?php
/**
 * Configuration générale de l'application - Version Vercel & Aiven
 */

// Définition des constantes de chemins
define('ROOT_PATH', dirname(__DIR__));
define('CONFIG_PATH', __DIR__);
define('INCLUDES_PATH', ROOT_PATH . '/includes');
define('LOGS_PATH', ROOT_PATH . '/logs');
define('UPLOADS_PATH', ROOT_PATH . '/uploads');
define('VIEWS_PATH', ROOT_PATH . '/views');

// Charger l'autoloader de Composer
if (file_exists(ROOT_PATH . '/vendor/autoload.php')) {
    require_once ROOT_PATH . '/vendor/autoload.php';
}

// Charger les variables d'environnement (via votre bypass ou $_ENV de Vercel)
if (file_exists(INCLUDES_PATH . '/env_loader_bypass.php')) {
    require_once INCLUDES_PATH . '/env_loader_bypass.php';
}

/**
 * Helper simple pour récupérer les variables d'environnement
 */
if (!function_exists('env')) {
    function env($key, $default = null) {
        $value = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
        return $value !== false && $value !== null ? $value : $default;
    }
}

/**
 * Génère une URL absolue ou relative pour l'application
 * Gère automatiquement le préfixe /medapp si nécessaire
 */
if (!function_exists('app_url')) {
    function app_url($path = '') {
        $baseUrl = env('APP_URL');
        
        // Si on est sur Vercel et que APP_URL n'est pas défini ou est localhost
        $isVercel = isset($_SERVER['VERCEL']) || (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'vercel.app') !== false);
        
        if ($isVercel && (empty($baseUrl) || strpos($baseUrl, 'localhost') !== false)) {
            $baseUrl = '/medapp';
        }
        
        if (empty($baseUrl)) {
            $baseUrl = '/medapp';
        }
        
        return rtrim($baseUrl, '/') . '/' . ltrim($path, '/');
    }
}

// Activation de la gestion des erreurs
error_reporting(E_ALL);
ini_set('display_errors', env('APP_ENV') === 'development' ? 1 : 0);

class Config {
    private static $config = [];

    public static function init() {
        // Paramètres requis
        self::$config['database'] = [
            'host'     => env('DB_HOST'),
            'dbname'   => env('DB_NAME'),
            'username' => env('DB_USER'),
            'password' => env('DB_PASS'), // Assurez-vous que c'est DB_PASS sur Vercel
            'port'     => env('DB_PORT', '24733'),
            'charset'  => 'utf8mb4'
        ];

        self::$config['app'] = [
            'env'   => env('APP_ENV', 'production'),
            'debug' => env('APP_DEBUG', false)
        ];

        self::createRequiredDirectories();
    }

    private static function createRequiredDirectories() {
        // Sur Vercel, seul /tmp est en écriture, mais on garde la structure pour la compatibilité
        $directories = [LOGS_PATH, UPLOADS_PATH];
        foreach ($directories as $dir) {
            if (!file_exists($dir) && is_writable(dirname($dir))) {
                mkdir($dir, 0755, true);
            }
        }
    }

    public static function get($key, $default = null) {
        $keys = explode('.', $key);
        $value = self::$config;
        foreach ($keys as $segment) {
            if (!isset($value[$segment])) return $default;
            $value = $value[$segment];
        }
        return $value;
    }

    public static function isProduction() {
        return self::get('app.env') === 'production';
    }

    public static function logError($message) {
        error_log($message);
    }

    /**
     * Connexion PDO compatible Aiven SSL
     */
    public static function getDbConnection() {
        try {
            $host = self::get('database.host');
            $dbname = self::get('database.dbname');
            $user = self::get('database.username');
            $pass = self::get('database.password');
            $port = self::get('database.port');

            $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";

            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_TIMEOUT            => 5
            ];

            // GESTION DU SSL POUR AIVEN
            $ssl_ca = __DIR__ . '/ca.pem';
            if (file_exists($ssl_ca)) {
                // Compatibilité PHP 8.5+ pour les constantes SSL
                if (defined('Pdo\Mysql::ATTR_SSL_CA')) {
                    $options[constant('Pdo\Mysql::ATTR_SSL_CA')] = $ssl_ca;
                    $options[constant('Pdo\Mysql::ATTR_SSL_VERIFY_SERVER_CERT')] = false;
                } else {
                    $options[PDO::MYSQL_ATTR_SSL_CA] = $ssl_ca;
                    $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = false;
                }
            }

            return new PDO($dsn, $user, $pass, $options);

        } catch (PDOException $e) {
            self::logError('Erreur DB : ' . $e->getMessage());
            
            if (!self::isProduction()) {
                die("Erreur de connexion : " . $e->getMessage());
            } else {
                die("Une erreur de connexion est survenue. Veuillez vérifier la configuration réseau.");
            }
        }
    }
}

// Initialisation immédiate
Config::init();

// Helper global pour obtenir la connexion PDO (singleton)
if (!function_exists('db')) {
    function db() {
        static $pdo = null;
        if ($pdo === null) {
            $pdo = Config::getDbConnection();
        }
        return $pdo;
    }
}
