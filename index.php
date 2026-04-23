<?php
/**
 * Point d'entrée principal pour Apache/XAMPP
 * Le fichier .htaccess redirige normalement tout vers api/index.php
 * Ce fichier sert de fallback.
 */
require_once __DIR__ . '/api/index.php';
