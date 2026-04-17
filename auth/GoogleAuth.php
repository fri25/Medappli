<?php
/**
 * Classe de gestion de l'authentification Google
 */

// Charger les dépendances
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/session.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../models/Patient.php';

class GoogleAuth {
    private $client;
    private $db;
    
    /**
     * Constructeur
     * Initialise le client Google
     */
    public function __construct() {
        // Charger l'autoloader de Composer si nécessaire
        $autoloadPath = __DIR__ . '/../vendor/autoload.php';
        if (file_exists($autoloadPath)) {
            require_once $autoloadPath;
        } else {
            throw new Exception("Les dépendances ne sont pas installées. Exécutez 'composer install'.");
        }
        
        // Initialiser le client Google
        $this->client = new Google_Client();
        $this->client->setClientId(config('auth.google.client_id'));
        $this->client->setClientSecret(config('auth.google.client_secret'));
        $this->client->setRedirectUri(config('auth.google.redirect_uri'));
        $this->client->addScope('email');
        $this->client->addScope('profile');

        // Connexion à la base de données
        $this->db = db();
    }
    
    /**
     * Génère l'URL de connexion Google
     * 
     * @return string URL de connexion
     */
    public function getAuthUrl() {
        return $this->client->createAuthUrl();
    }
    
    /**
     * Traite le code d'autorisation retourné par Google
     * 
     * @param string $code Code d'autorisation
     * @return array Informations de l'utilisateur
     */
    public function handleCallback($code) {
        try {
            // Échanger le code contre un token d'accès
            $token = $this->client->fetchAccessTokenWithAuthCode($code);
            $this->client->setAccessToken($token);
            
            // Obtenir les informations de l'utilisateur
            $google_oauth = new Google_Service_Oauth2($this->client);
            $user_info = $google_oauth->userinfo->get();
            
            return [
                'email' => $user_info->getEmail(),
                'name' => $user_info->getName(),
                'given_name' => $user_info->getGivenName(),
                'family_name' => $user_info->getFamilyName(),
                'picture' => $user_info->getPicture(),
                'google_id' => $user_info->getId()
            ];
        } catch (Exception $e) {
            Config::logError("Erreur d'authentification Google: " . $e->getMessage());
            throw new Exception("Échec de l'authentification Google. Veuillez réessayer.");
        }
    }
    
    /**
     * Connexion ou inscription d'un utilisateur via Google
     * 
     * @param array $user_info Informations de l'utilisateur Google
     * @return int ID de l'utilisateur
     */
    public function loginOrRegisterUser($user_info) {
        $email = $user_info['email'];

        // Chercher l'utilisateur d'abord dans la table users
        $stmt = $this->db->prepare("SELECT * FROM users WHERE email = :email");
        $stmt->bindParam(':email', $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if (empty($user['google_id'])) {
                $update = $this->db->prepare("UPDATE users SET google_id = :google_id WHERE id = :id");
                $update->bindParam(':google_id', $user_info['google_id']);
                $update->bindParam(':id', $user['id']);
                $update->execute();
            }

            initSession($user['id'], $user['role'], $user['nom'], $user['prenom'], $user['email'], 'google');
            $_SESSION['auth_redirect'] = $this->getRoleRedirect($user['role']);
            return $user['id'];
        }

        // Si l'utilisateur n'existe pas dans users, vérifier les tables patient/medecin/admin
        $query = "SELECT 'patient' as role, id, nom, prenom, email FROM patient WHERE email = ? " .
                 "UNION ALL SELECT 'medecin' as role, id, nom, prenom, email FROM medecin WHERE email = ? " .
                 "UNION ALL SELECT 'admin' as role, id, nom, prenom, email FROM admin WHERE email = ?";

        $stmt = $this->db->prepare($query);
        $stmt->bindParam(1, $email);
        $stmt->bindParam(2, $email);
        $stmt->bindParam(3, $email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            initSession($user['id'], $user['role'], $user['nom'], $user['prenom'], $user['email'], 'google');
            $_SESSION['auth_redirect'] = $this->getRoleRedirect($user['role']);

            return $user['id'];
        }

        // Nouvel utilisateur : créer un patient Google
        try {
            $this->db->beginTransaction();

            $nextId = $this->getNextUserId();
            $creationColumn = $this->getCreationColumn();
            $columns = "id, nom, prenom, email, google_id, role, auth_method";
            $values = ":id, :nom, :prenom, :email, :google_id, 'patient', 'google'";

            if ($creationColumn) {
                $columns .= ", {$creationColumn}";
                $values .= ", NOW()";
            }

            $insert = $this->db->prepare(
                "INSERT INTO users ({$columns}) VALUES ({$values})"
            );
            $insert->bindParam(':id', $nextId, PDO::PARAM_INT);
            $insert->bindParam(':nom', $user_info['family_name']);
            $insert->bindParam(':prenom', $user_info['given_name']);
            $insert->bindParam(':email', $user_info['email']);
            $insert->bindParam(':google_id', $user_info['google_id']);
            $insert->execute();

            $user_id = $nextId;

            $patientInsert = $this->db->prepare(
                "INSERT INTO patient (id, nom, prenom, email, role) VALUES (:id, :nom, :prenom, :email, 'patient')"
            );
            $patientInsert->bindParam(':id', $user_id);
            $patientInsert->bindParam(':nom', $user_info['family_name']);
            $patientInsert->bindParam(':prenom', $user_info['given_name']);
            $patientInsert->bindParam(':email', $user_info['email']);
            $patientInsert->execute();

            $this->db->commit();

            initSession($user_id, 'patient', $user_info['family_name'], $user_info['given_name'], $user_info['email'], 'google');
            $_SESSION['auth_redirect'] = 'views/patient/dashboard.php';
            return $user_id;
        } catch (Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }

    private function getRoleRedirect($role) {
        switch ($role) {
            case 'admin':
                return 'views/admin/dashboard.php';
            case 'medecin':
                return 'views/medecin/dashboard.php';
            default:
                return 'views/patient/dashboard.php';
        }
    }

    private function getNextUserId() {
        $stmt = $this->db->query('SELECT COALESCE(MAX(id), 0) + 1 AS next_id FROM users');
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return (int) ($row['next_id'] ?? 1);
    }

    private function getCreationColumn() {
        $dbName = env('DB_NAME');
        $stmt = $this->db->prepare(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS " .
            "WHERE TABLE_SCHEMA = :db AND TABLE_NAME = 'users' AND COLUMN_NAME IN ('created_at','date_creation') " .
            "ORDER BY FIELD(COLUMN_NAME, 'created_at', 'date_creation') LIMIT 1"
        );
        $stmt->bindParam(':db', $dbName);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['COLUMN_NAME'] ?? null;
    }
    
    /**
     * Configure la session utilisateur
     * 
     * @param int $user_id ID de l'utilisateur
     * @param string $role Rôle de l'utilisateur
     * @param array $user_info Informations supplémentaires
     */
    private function setupSession($user_id, $role, $user_info) {
        // Utiliser la fonction initSession du fichier session.php
        if (function_exists('initSession')) {
            initSession(
                $user_id,
                $role,
                $user_info['family_name'],
                $user_info['given_name'],
                $user_info['email'],
                'google'
            );
        } else {
            // Fallback si la fonction n'existe pas (pour compatibilité)
            $_SESSION['user_id'] = $user_id;
            $_SESSION['role'] = $role;
            $_SESSION['nom'] = $user_info['family_name'];
            $_SESSION['prenom'] = $user_info['given_name'];
            $_SESSION['email'] = $user_info['email'];
            $_SESSION['auth_method'] = 'google';
            $_SESSION['last_activity'] = time();
        }
    }
} 
