<?php
header('Content-Type: application/json');

// Récupère le message envoyé depuis le frontend
$input = json_decode(file_get_contents('php://input'), true);
$message = $input['message'] ?? '';

if (!$message) {
    echo json_encode(['reply' => "Je n'ai pas reçu de message."]);
    exit;
}

// Prépare la requête à l'API Ollama
$data = [
    "model" => "mistral:latest",
    "prompt" => $message,
    "stream" => false // temporairement désactivé pour simplifier
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "http://localhost:11434/api/generate");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_TIMEOUT, 2); // Timeout court pour ne pas bloquer
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Content-Type: application/json"
]);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

// Vérifie et renvoie la réponse
if ($response && $http_code == 200) {
    $json = json_decode($response, true);
    echo json_encode(['reply' => $json['response'] ?? "Réponse vide."]);
} else {
    // Fallback si Ollama n'est pas disponible (cas typique sur Vercel sans tunnel)
    echo json_encode(['reply' => "Désolé, le service d'IA (Ollama) n'est pas accessible actuellement sur le serveur de production. Veuillez contacter l'administrateur pour activer le support de l'IA locale."]);
}
