<?php
/**
 * Routeur Universel pour Vercel (Version Compatibilité /medapp)
 * Ce fichier capture toutes les requêtes et gère le préfixe de dossier local.
 */
header('Content-Type: text/html; charset=UTF-8');

try {
    $uri = $_SERVER['REQUEST_URI'];
    $path = parse_url($uri, PHP_URL_PATH);

    // 1. SUPPRESSION DU PRÉFIXE /medapp s'il est présent
    // Cela permet aux liens locaux de fonctionner sur Vercel
    if (strpos($path, '/medapp') === 0) {
        $path = substr($path, 7); // Retire les 7 caractères de '/medapp'
    }

    $path = ltrim($path, '/');
    $root = dirname(__DIR__);

    // 2. Cas des fichiers API dans api/
    $base_name = basename($path);
    $handler_path = __DIR__ . '/' . $base_name;
    if (strpos($path, 'api/') === 0 && file_exists($handler_path)) {
        chdir($root);
        require $handler_path;
        exit;
    }

    // 3. Cas des fichiers PHP physiques (ex: views/login.php)
    $physical_file = $root . '/' . $path;
    if (!empty($path) && file_exists($physical_file) && is_file($physical_file) && pathinfo($path, PATHINFO_EXTENSION) === 'php') {
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

    // 5. Comportement par défaut : charger l'index racine déplacé
    chdir($root);
    $default_index = $root . '/root_scripts/index.php';
    if (file_exists($default_index)) {
        require $default_index;
    } else {
        echo "<h1>Erreur Système</h1>";
        echo "<p>Le point d'entrée de l'application est introuvable.</p>";
        if (isset($_SERVER['VERCEL'])) {
            echo "<p>Environnement : Vercel</p>";
        }
    }
} catch (Exception $e) {
    echo "<h1>Exception détectée</h1>";
    echo "<p>" . htmlspecialchars($e->getMessage()) . "</p>";
}
