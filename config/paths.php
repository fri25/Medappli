<?php
// Définition des chemins de base
if (!defined('BASE_URL')) {
    define('BASE_URL', '/medapp');
}
define('LOGIN_PATH', VIEWS_PATH . '/login.php');

// Fonction pour générer les URLs (compatibilité avec le code existant)
if (!function_exists('url')) {
    function url($path) {
        return app_url($path);
    }
}

// Fonction pour rediriger
if (!function_exists('redirect')) {
    function redirect($path, $params = []) {
        $url = app_url($path);
        if (!empty($params)) {
            $url .= '?' . http_build_query($params);
        }
        header('Location: ' . $url);
        exit;
    }
} 
