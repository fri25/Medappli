<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/database.php';

header('Content-Type: application/json');

try {
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        // Tester une requête simple
        $stmt = $db->query("SELECT COUNT(*) as total FROM patient");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'status' => 'success',
            'message' => 'Connexion réussie',
            'patient_count' => $count['total'],
            'db_host' => env('DB_HOST'),
            'app_env' => env('APP_ENV')
        ]);
    } else {
        echo json_encode([
            'status' => 'error',
            'message' => 'La connexion a retourné null'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
