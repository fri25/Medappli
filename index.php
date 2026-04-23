<?php
/**
 * Routeur Universel pour Vercel & XAMPP
 * Ce fichier est le point d'entrée unique de l'application.
 */
header('Content-Type: text/html; charset=UTF-8');

try {
    $uri = $_SERVER['REQUEST_URI'];
    $path = parse_url($uri, PHP_URL_PATH);

    // 1. SUPPRESSION DU PRÉFIXE /medapp s'il est présent
    if (strpos($path, '/medapp') === 0) {
        $path = substr($path, 7);
    }

    $path = ltrim($path, '/');
    $root = __DIR__;

    // 2. Cas des fichiers API dans api/
    $base_name = basename($path);
    $handler_path = $root . '/api/' . $base_name;
    if (strpos($path, 'api/') === 0 && file_exists($handler_path)) {
        chdir($root);
        require $handler_path;
        exit;
    }

    // 3. Cas des fichiers PHP physiques (ex: views/login.php)
    $physical_file = $root . '/' . $path;
    if (!empty($path) && file_exists($physical_file) && is_file($physical_file) && pathinfo($path, PATHINFO_EXTENSION) === 'php' && $path !== 'index.php') {
        chdir($root);
        require $physical_file;
        exit;
    }

    // 4. Cas des fichiers déplacés dans root_scripts/
    $root_script_path = $root . '/root_scripts/' . $path;
    if (!empty($path) && file_exists($root_script_path) && is_file($root_script_path)) {
        chdir($root);
        require $root_script_path;
        exit;
    }

    // 5. Comportement par défaut : charger l'index racine réel
    chdir($root);
    $default_index = $root . '/root_scripts/index.php';
    if (file_exists($default_index)) {
        require $default_index;
    } else {
        echo "<h1>Erreur Système</h1>";
        echo "<p>Le point d'entrée de l'application est introuvable.</p>";
    }
} catch (Exception $e) {
    echo "<h1>Exception détectée</h1>";
    echo "<p>" . htmlspecialchars($e->getMessage()) . "</p>";
}
