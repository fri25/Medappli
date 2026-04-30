<?php
/**
 * Gestion des sessions et de l'authentification
 * Utilise la variable SESSION_SECRET du fichier .env pour renforcer la sécurité
 */

// Charger la configuration si ce n'est pas déjà fait
if (!function_exists('env')) {
    require_once __DIR__ . '/../config/config.php';
}

// Configurer les options de session avant de la démarrer
$session_name = 'MEDSESSID';
$appUrl = env('APP_URL', 'http://localhost');
$secure = parse_url($appUrl, PHP_URL_SCHEME) === 'https';
$httponly = true;
$samesite = 'Lax';

// Définir le chemin de sauvegarde des sessions
// Sur Vercel, on utilise impérativement /tmp car le système est en lecture seule
$is_vercel = isset($_SERVER['VERCEL']) || (isset($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'vercel.app') !== false);
$session_path = $is_vercel ? '/tmp' : __DIR__ . '/../storage/sessions';

if (!$is_vercel && !is_dir($session_path)) {
    @mkdir($session_path, 0755, true);
}

// On ne définit session.save_path que si on peut écrire ou si on est sur Vercel
if (is_writable($session_path) || $is_vercel) {
    ini_set('session.save_path', $session_path);
}

// Définir les options de cookie
ini_set('session.use_strict_mode', 1);
ini_set('session.use_cookies', 1);
ini_set('session.use_only_cookies', 1);
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', $secure ? 1 : 0);
ini_set('session.cookie_samesite', $samesite);
ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);

// Configurer la durée de vie du cookie (2 heures en développement)
$session_lifetime = 7200; // 2 heures
ini_set('session.gc_maxlifetime', $session_lifetime);
ini_set('session.cookie_lifetime', $session_lifetime);

// Paramétrer le cookie
session_set_cookie_params([
    'lifetime' => $session_lifetime,
    'path' => '/', // Chemin spécifique à l'application
    'domain' => env('SESSION_COOKIE_DOMAIN', ''),
    'secure' => $secure,
    'httponly' => $httponly,
    'samesite' => $samesite
]);

if (empty(env('SESSION_SECRET'))) {
    error_log('SESSION_SECRET est manquant. Les empreintes de session ne seront pas activées.');
}

// Démarrer la session si elle n'est pas déjà active
if (session_status() == PHP_SESSION_NONE) {
    session_name($session_name);
    session_start();
}

/**
 * Vérifie si l'utilisateur est connecté
 * 
 * @return bool True si l'utilisateur est connecté
 */
function isLoggedIn() {
    return isset($_SESSION['user_id']) && isset($_SESSION['role']);
}

/**
 * Vérifie si l'utilisateur a le rôle requis
 * 
 * @param string|array $role Le rôle ou les rôles requis (admin, medecin, patient)
 * @return bool True si l'utilisateur a le rôle requis
 */
function hasRole($role) {
    if (!isset($_SESSION['role'])) {
        return false;
    }
    return $_SESSION['role'] === $role;
}

/**
 * Exige que l'utilisateur soit connecté
 * Redirige vers la page de connexion si ce n'est pas le cas
 */
function requireLogin() {
    if (!isLoggedIn()) {
        redirect_to('views/login.php');
    }
}

/**
 * Exige que l'utilisateur ait un rôle spécifique
 * Redirige vers la page d'accueil si ce n'est pas le cas
 * 
 * @param string|array $role Le rôle ou les rôles requis (admin, medecin, patient)
 */
function requireRole($role) {
    requireLogin();
    if (!hasRole($role)) {
        redirect_to('index.php');
    }
}

/**
 * Déconnecte l'utilisateur
 */
function logout() {
    $_SESSION = array();
    if (isset($_COOKIE[session_name()])) {
        setcookie(session_name(), '', time() - 3600, '/');
    }
    session_destroy();
    
    redirect_to('views/login.php');
}

/**
 * Initialise la session utilisateur
 */
function initSession($user_id, $role, $nom, $prenom, $email, $auth_method = 'standard') {
    $_SESSION['user_id'] = $user_id;
    $_SESSION['role'] = $role;
    $_SESSION['nom'] = $nom;
    $_SESSION['prenom'] = $prenom;
    $_SESSION['email'] = $email;
    $_SESSION['auth_method'] = $auth_method;
    $_SESSION['last_activity'] = time();
}

/**
 * Génère une empreinte du navigateur pour renforcer la sécurité des sessions
 */
function generateBrowserFingerprint() {
    $secret = env('SESSION_SECRET');
    if (empty($secret)) {
        error_log('SESSION_SECRET est manquant. Empreinte du navigateur non créée.');
        return;
    }

    $user_agent = $_SERVER['HTTP_USER_AGENT'];
    $ip = $_SERVER['REMOTE_ADDR'];
    $fingerprint = hash_hmac('sha256', $user_agent . $ip, $secret);
    $_SESSION['browser_fingerprint'] = $fingerprint;
}

/**
 * Vérifie l'empreinte du navigateur
 * 
 * @return bool True si l'empreinte est valide
 */
function verifyBrowserFingerprint() {
    if (!isset($_SESSION['browser_fingerprint'])) {
        return false;
    }

    $secret = env('SESSION_SECRET');
    if (empty($secret)) {
        error_log('SESSION_SECRET est manquant. Vérification de l\'empreinte impossible.');
        return false;
    }

    $user_agent = $_SERVER['HTTP_USER_AGENT'];
    $ip = $_SERVER['REMOTE_ADDR'];
    $expected = hash_hmac('sha256', $user_agent . $ip, $secret);

    return hash_equals($_SESSION['browser_fingerprint'], $expected);
}

/**
 * Régénère l'ID de session
 * À utiliser après une élévation de privilèges
 */
function regenerateSession() {
    session_regenerate_id(true);
    $_SESSION['created'] = time();
    generateBrowserFingerprint();
} 

/**
 * Redirige vers une URL absolue ou un chemin interne de l'application.
 *
 * @param string $path Chemin relatif ou URL absolue
 * @param bool $permanent True pour une redirection 301, false pour 302
 */
function redirect_to($path = 'index.php', $permanent = false) {
    if (empty($path)) {
        $path = 'index.php';
    }

    // Si c'est déjà une URL absolue
    if (preg_match('#^https?://#i', $path)) {
        $location = $path;
    } else {
        // Chemin commençant par / -> racine du host
        if (strpos($path, '/') === 0) {
            $location = $path;
        } else {
            if (function_exists('app_url')) {
                $location = rtrim(app_url(''), '/') . '/' . ltrim($path, '/');
            } else {
                $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') || (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] == 443) ? 'https' : 'http';
                $host = $_SERVER['HTTP_HOST'] ?? '127.0.0.1:8000';
                $location = $scheme . '://' . $host . '/' . ltrim($path, '/');
            }
        }
    }

    header('Location: ' . $location, true, $permanent ? 301 : 302);
    exit();
}
