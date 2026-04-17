<?php
ob_start();
require_once '../../includes/session.php';
require_once '../../config/database.php';

$isAjax = !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest';

if (!isLoggedIn()) {
    if ($isAjax) {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => false, 'message' => 'Authentification requise'], JSON_UNESCAPED_UNICODE);
        exit;
    }
    requireLogin();
}

if (!hasRole('medecin')) {
    if ($isAjax) {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => false, 'message' => 'Accès refusé'], JSON_UNESCAPED_UNICODE);
        exit;
    }
    requireRole('medecin');
}

// Vérifier si le formulaire a été soumis
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Valider le token CSRF
        if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
            throw new Exception("Erreur de sécurité CSRF");
        }

        $rdv_id = filter_input(INPUT_POST, 'rdv_id', FILTER_VALIDATE_INT);
        $statut = filter_input(INPUT_POST, 'statut', FILTER_SANITIZE_STRING);
        // Correction : forcer une valeur par défaut si vide ou invalide
        $statuts_valides = ['en attente', 'confirmé', 'annulé', 'accepté', 'refusé'];
        if (!$statut || !in_array($statut, $statuts_valides)) {
            $statut = 'en attente';
        }

        // Valider les entrées
        if (!$rdv_id || !$statut) {
            throw new Exception("Données du formulaire invalides");
        }

        // Valider que le statut est parmi les valeurs autorisées
        $statutsAutorises = ['en attente', 'confirmé', 'annulé'];
        if (!in_array($statut, $statutsAutorises)) {
            throw new Exception("Statut invalide");
        }

        // Initialiser la connexion à la base de données
        $database = new Database();
        $db = $database->getConnection();
        $db->beginTransaction();

        // Vérifier que le médecin peut modifier ce rendez-vous et récupérer l'identifiant du patient
        $queryCheck = "SELECT idmedecin, idpatient FROM rendezvous WHERE id = :rdv_id";
        $stmtCheck = $db->prepare($queryCheck);
        $stmtCheck->bindParam(':rdv_id', $rdv_id, PDO::PARAM_INT);
        $stmtCheck->execute();
        
        $rdv = $stmtCheck->fetch(PDO::FETCH_ASSOC);
        
        if (!$rdv || $rdv['idmedecin'] != $_SESSION['user_id']) {
            throw new Exception("Vous n'êtes pas autorisé à modifier ce rendez-vous");
        }

        // Mettre à jour le statut du rendez-vous
        $query = "UPDATE rendezvous SET statut = :statut WHERE id = :rdv_id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':statut', $statut, PDO::PARAM_STR);
        $stmt->bindParam(':rdv_id', $rdv_id, PDO::PARAM_INT);
        
        if (!$stmt->execute()) {
            throw new Exception("Échec de la mise à jour du rendez-vous");
        }

        // Si le rendez-vous est confirmé, inscrire le patient dans la liste du médecin
        if ($statut === 'confirmé') {
            $updatePatientQuery = "UPDATE patient SET id_medecin = :medecin_id WHERE id = :patient_id";
            $updatePatientStmt = $db->prepare($updatePatientQuery);
            $updatePatientStmt->bindParam(':medecin_id', $_SESSION['user_id'], PDO::PARAM_INT);
            $updatePatientStmt->bindParam(':patient_id', $rdv['idpatient'], PDO::PARAM_INT);

            if (!$updatePatientStmt->execute()) {
                throw new Exception("Échec de l'inscription du patient au médecin");
            }
        }

        $db->commit();

        // Journaliser la modification
        error_log("Mise à jour réussie pour le rendez-vous ID: " . $rdv_id . " par le médecin ID: " . $_SESSION['user_id']);

        // Message de succès
        $_SESSION['flash_message'] = [
            'type' => 'success',
            'message' => 'Le statut du rendez-vous a été mis à jour avec succès'
        ];

        $response = [
            'success' => true,
            'message' => 'Le statut du rendez-vous a été mis à jour avec succès'
        ];
    } catch (Exception $e) {
        if (isset($db) && $db->inTransaction()) {
            $db->rollBack();
        }

        // Journaliser l'erreur
        error_log("Erreur lors de la mise à jour du rendez-vous: " . $e->getMessage());
        
        // Message d'erreur
        $_SESSION['flash_message'] = [
            'type' => 'error',
            'message' => $e->getMessage()
        ];

        $response = [
            'success' => false,
            'message' => $e->getMessage()
        ];
    }
}

if ($isAjax) {
    if (ob_get_length()) {
        ob_clean();
    }
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($response ?? ['success' => false, 'message' => 'Réponse invalide'], JSON_UNESCAPED_UNICODE);
    exit;
}

// Rediriger vers la page de l'agenda
header('Location: rdv.php');
exit;