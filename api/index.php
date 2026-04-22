<?php
/**
 * Routeur Universel pour Vercel (Version Compatibilité /medapp)
 * Ce fichier capture toutes les requêtes et gère le préfixe de dossier local.
 */
header('Content-Type: text/html; charset=UTF-8');

$uri = $_SERVER['REQUEST_URI'];
$path = parse_url($uri, PHP_URL_PATH);

// 1. SUPPRESSION DU PRÉFIXE /medapp s'il est présent
// Cela permet aux liens locaux de fonctionner sur Vercel
if (strpos($path, '/medapp') === 0) {
    $path = substr($path, 7); // Retire les 7 caractères de '/medapp'
}

$path = ltrim($path, '/');
$root = __DIR__ . '/..';

// 2. Cas des fichiers API dans handlers/
$base_name = basename($path);
if (strpos($path, 'api/') === 0 && file_exists(__DIR__ . '/handlers/' . $base_name)) {
    chdir($root);
    require __DIR__ . '/handlers/' . $base_name;
    exit;
}

// 3. Cas des fichiers PHP physiques (ex: views/login.php)
if (!empty($path) && file_exists($root . '/' . $path) && is_file($root . '/' . $path) && pathinfo($path, PATHINFO_EXTENSION) === 'php') {
    chdir($root);
    require $root . '/' . $path;
    exit;
}

// 4. Cas des fichiers déplacés dans root_scripts/
if (!empty($path) && file_exists($root . '/root_scripts/' . $path) && is_file($root . '/root_scripts/' . $path)) {
    chdir($root);
    require $root . '/root_scripts/' . $path;
    exit;
}

// 5. Comportement par défaut : charger l'index racine déplacé
chdir($root);
if (file_exists('root_scripts/index.php')) {
    require 'root_scripts/index.php';
} else {
    echo "Page non trouvée : " . htmlspecialchars($path);
}
