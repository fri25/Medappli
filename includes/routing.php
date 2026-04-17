<?php
function redirectIfNotLoggedIn() {
    if (!isset($_SESSION['user_id']) || !isset($_SESSION['role'])) {
        header('Location: ' . app_url('index.php'));
        exit();
    }
}

function redirectIfNotAuthorized($requiredRole) {
    if (!isset($_SESSION['role']) || $_SESSION['role'] !== $requiredRole) {
        header('Location: ' . app_url('index.php'));
        exit();
    }
}

function getDashboardUrl() {
    if (!isset($_SESSION['role'])) {
        return app_url('index.php');
    }
    
    switch ($_SESSION['role']) {
        case 'admin':
            return app_url('admin/dashboard.php');
        case 'medecin':
            return app_url('medecin/dashboard.php');
        case 'patient':
            return app_url('patient/dashboard.php');
        default:
            return app_url('index.php');
    }
}

function getRedirectUrl() {
    return getDashboardUrl();
}
?> 
