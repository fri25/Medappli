<?php
/**
 * Page de callback pour l'authentification Google
 * Traite le code d'autorisation retourné par Google
 */

require_once '../vendor/autoload.php';
require_once '../config/config.php';
require_once '../includes/session.php';
require_once 'GoogleAuth.php';

$mode = $_SESSION['google_login_mode'] ?? null;

try {
    if ($mode === 'calendar') {
        // Connexion du calendrier Google pour un patient déjà connecté
        requireLogin();
        requireRole('patient');

        $user_id = $_SESSION['user_id'];
        $config = require '../config/google_config.php';

        $client = new Google_Client();
        $client->setClientId($config['client_id']);
        $client->setClientSecret($config['client_secret']);
        $client->setRedirectUri($config['redirect_uri']);

        if (!isset($_GET['state']) || $_GET['state'] !== $_SESSION['google_auth_state']) {
            throw new Exception('État invalide');
        }

        $token = $client->fetchAccessTokenWithAuthCode($_GET['code']);

        $expires_at = date('Y-m-d H:i:s', time() + $token['expires_in']);

        $existingToken = db()->prepare("SELECT id FROM google_tokens WHERE user_id = ? LIMIT 1");
        $existingToken->execute([$user_id]);
        $tokenRow = $existingToken->fetch(PDO::FETCH_ASSOC);

        if ($tokenRow) {
            $stmt = db()->prepare(
                "UPDATE google_tokens SET access_token = ?, refresh_token = ?, expires_at = ? WHERE id = ?"
            );
            $stmt->execute([
                $token['access_token'],
                $token['refresh_token'],
                $expires_at,
                $tokenRow['id']
            ]);
        } else {
            $nextTokenId = (int) db()->query("SELECT COALESCE(MAX(id), 0) + 1 AS next_id FROM google_tokens")->fetchColumn();
            $stmt = db()->prepare(
                "INSERT INTO google_tokens (id, user_id, access_token, refresh_token, expires_at) VALUES (?, ?, ?, ?, ?)"
            );
            $stmt->execute([
                $nextTokenId,
                $user_id,
                $token['access_token'],
                $token['refresh_token'],
                $expires_at
            ]);
        }

        $_SESSION['success'] = "Votre agenda a été connecté avec succès à Google Calendar.";
        redirect_to('views/patient/rdv.php');
    } else {
        // Authentification Google standard (login / inscription)
        if (!isset($_GET['code'])) {
            throw new Exception('Code d\'autorisation manquant.');
        }

        $googleAuth = new GoogleAuth();
        $user_info = $googleAuth->handleCallback($_GET['code']);
        $googleAuth->loginOrRegisterUser($user_info);

        $redirect = $_SESSION['auth_redirect'] ?? 'index.php';
        unset($_SESSION['auth_redirect'], $_SESSION['google_login_mode'], $_SESSION['google_auth_state']);

        redirect_to(ltrim($redirect, '/'));
    }
} catch (Exception $e) {
    $_SESSION['error'] = "Erreur lors de la connexion Google : " . $e->getMessage();
    redirect_to('views/login.php');
} 
