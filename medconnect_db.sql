-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : ven. 17 avr. 2026 à 11:40
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `medconnect_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `admin`
--

CREATE TABLE `admin` (
  `id` int(11) AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `datenais` date NOT NULL,
  `email` varchar(100) NOT NULL,
  `contact` varchar(20) NOT NULL,
  `password` varchar(500) NOT NULL,
  `role` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `carnetsante`
--

CREATE TABLE `carnetsante` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `groupesanguin` varchar(10) DEFAULT NULL,
  `taille` decimal(5,2) DEFAULT NULL,
  `poids` decimal(5,2) DEFAULT NULL,
  `allergie` text DEFAULT NULL,
  `electrophorese` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `carnetsante`
--

INSERT INTO `carnetsante` (`id`, `id_patient`, `groupesanguin`, `taille`, `poids`, `allergie`, `electrophorese`, `created_at`, `updated_at`) VALUES
(1, 21, '0+', 165.00, 34.00, 'tomate', 'O', '2026-03-31 14:16:37', '2026-03-31 14:16:37'),
(2, 1, '0+', 165.00, 34.00, 'fleur pollen', '+', '2026-03-31 14:16:37', '2026-03-31 14:16:37'),
(3, 26, '0+', 170.00, 65.00, 'Poll├®ne', '+', '2026-03-31 14:16:37', '2026-03-31 14:16:37');

-- --------------------------------------------------------

--
-- Structure de la table `consultation`
--

CREATE TABLE `consultation` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `id_medecin` int(11) NOT NULL,
  `date_consultation` datetime NOT NULL,
  `motif` text NOT NULL,
  `antecedents` text DEFAULT NULL,
  `examen_clinique` text NOT NULL,
  `diagnostic` text NOT NULL,
  `traitement` text DEFAULT NULL,
  `recommandations` text DEFAULT NULL,
  `prochain_rdv` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dossiers_medicaux`
--

CREATE TABLE `dossiers_medicaux` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `antecedents` text DEFAULT NULL,
  `allergies` text DEFAULT NULL,
  `traitements` text DEFAULT NULL,
  `derniere_maj` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `fichemed`
--

CREATE TABLE `fichemed` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `id_profil` int(11) NOT NULL,
  `id_carnet` int(11) NOT NULL,
  `lieu_naissance` varchar(100) DEFAULT NULL,
  `situation_familiale` varchar(20) DEFAULT NULL,
  `enfants` int(11) DEFAULT NULL,
  `grossesses` int(11) DEFAULT NULL,
  `num_secu` varchar(20) DEFAULT NULL,
  `groupe_sanguin` varchar(10) DEFAULT NULL,
  `medecin_traitant` varchar(100) DEFAULT NULL,
  `Assurance` varchar(100) DEFAULT NULL,
  `antecedents_familiaux` text DEFAULT NULL,
  `maladies_infantiles` text DEFAULT NULL,
  `antecedents_medicaux` text DEFAULT NULL,
  `antecedents_chirurgicaux` text DEFAULT NULL,
  `allergies` text DEFAULT NULL,
  `intolerance_medicament` text DEFAULT NULL,
  `traitement_regulier` text DEFAULT NULL,
  `vaccins` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `google_tokens`
--

CREATE TABLE `google_tokens` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `access_token` text NOT NULL,
  `refresh_token` text DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `hopitaux`
--

CREATE TABLE `hopitaux` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) DEFAULT NULL,
  `localisation` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `success` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `medecin`
--

CREATE TABLE `medecin` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `datenais` date NOT NULL,
  `email` varchar(100) NOT NULL,
  `contact` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'medecin',
  `num` varchar(20) NOT NULL,
  `idspecialite` int(11) DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected') DEFAULT 'pending',
  `verification_token` varchar(64) DEFAULT NULL,
  `verification_token_expires` datetime DEFAULT NULL,
  `reset_token` varchar(64) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `remember_token` varchar(64) DEFAULT NULL,
  `remember_token_expires` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `medecin`
--

INSERT INTO `medecin` (`id`, `nom`, `prenom`, `datenais`, `email`, `contact`, `password`, `role`, `num`, `idspecialite`, `verification_status`, `verification_token`, `verification_token_expires`, `reset_token`, `reset_token_expires`, `remember_token`, `remember_token_expires`) VALUES
(1, 'Martin', 'Marc', '2010-04-29', 'test2@gmail.com', '0157866959', '$2y$10$KGG6i8iZhvTrZJkT1sgcg.Lx.Lyc.lvIqzO6kyufWk4IUnmgjHCC2', 'medecin', '12345', 7, 'verified', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'FAFA', 'BAKE', '2000-03-03', 'bake@gmail.com', '0157866959', '$2y$10$PXQbkcvvwbuIfb8UvPa97eBHLlx6xG8VGmNdstu4ipEhKrsc/Y0qm', 'medecin', '1234567890', 10, 'verified', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'BALAAM', 'CHARLESSE', '2006-05-25', 'chao@gmail.com', '0157866959', '$2y$10$alROKemqZ2.dy13g4yGoVukHXEDpisgCXOC37f.UZPoQNP/jwxN3m', 'medecin', '1234567890', 8, 'verified', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 'YEMADJE', 'Elfrida', '2004-06-16', 'elfridayemadje5@gmail.com', '+229 45 56 65 67', '$2y$10$dWLwWtwnCWEyTNB9wHSaeuw50hABulTD5Wcq3qKW4YJFqHuwmxJG6', 'medecin', '948795038', 8, 'verified', 'efd2ede389fcbd77460d6135cc6264c4f402577680d7db2671217276bc09804e', '2026-04-01 19:02:24', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `medicament`
--

CREATE TABLE `medicament` (
  `id` int(11) NOT NULL,
  `id_ordonnance` int(11) NOT NULL,
  `nom_medicament` varchar(255) NOT NULL,
  `dosage` varchar(100) NOT NULL,
  `frequence` varchar(100) NOT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `contenu` text NOT NULL,
  `date_envoi` datetime NOT NULL DEFAULT current_timestamp(),
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `sender_type` enum('patient','medecin') NOT NULL,
  `lu` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `ordonnance`
--

CREATE TABLE `ordonnance` (
  `id` int(11) NOT NULL,
  `idmedecin` int(11) NOT NULL,
  `idpatient` int(11) NOT NULL,
  `date_creation` datetime NOT NULL DEFAULT current_timestamp(),
  `date_validite` date NOT NULL,
  `medicaments` text NOT NULL,
  `posologie` text NOT NULL,
  `quantite` text NOT NULL,
  `duree_medicament` text NOT NULL,
  `duree_traitement` varchar(50) NOT NULL,
  `instructions` text DEFAULT NULL,
  `signature` varchar(255) DEFAULT NULL,
  `renouvellement` tinyint(1) DEFAULT 0,
  `nombre_renouvellements` int(11) DEFAULT 0,
  `statut` enum('active','expiree','annulee') NOT NULL DEFAULT 'active',
  `signature_medecin` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `password_reset`
--

CREATE TABLE `password_reset` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expire_date` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `patient`
--

CREATE TABLE `patient` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `datenais` date NOT NULL,
  `sexe` enum('M','F','A') NOT NULL,
  `email` varchar(100) NOT NULL,
  `contact` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'patient',
  `id_medecin` int(11) DEFAULT NULL,
  `verification_status` enum('pending','verified','rejected') DEFAULT 'pending',
  `verification_token` varchar(64) DEFAULT NULL,
  `verification_token_expires` datetime DEFAULT NULL,
  `reset_token` varchar(64) DEFAULT NULL,
  `reset_token_expires` datetime DEFAULT NULL,
  `remember_token` varchar(64) DEFAULT NULL,
  `remember_token_expires` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `patient`
--

INSERT INTO `patient` (`id`, `nom`, `prenom`, `datenais`, `sexe`, `email`, `contact`, `password`, `role`, `id_medecin`, `verification_status`, `verification_token`, `verification_token_expires`, `reset_token`, `reset_token_expires`, `remember_token`, `remember_token_expires`) VALUES
(1, 'Melvine', 'yem', '2011-03-10', 'M', 'melvineyemadje@gmail.com', '0187879695', '$2y$10$ckZ1icCeMQe9jw2VvI9TKOBralG31EgOZLuEFUbII9ym5aWZeS0Te', 'patient', NULL, 'verified', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `pharmacie`
--

CREATE TABLE `pharmacie` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) DEFAULT NULL,
  `localisation` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `pharmacie`
--

INSERT INTO `pharmacie` (`id`, `nom`, `localisation`) VALUES
(1, 'Pharmacie Saint Michel', 'Cotonou, Carrefour Zogbo, ├á c├┤t├® de l\'├®glise Saint Michel'),
(2, 'Pharmacie de la Paix', 'Abomey-Calavi, Tankp├¿, en face du supermarch├® Leader Price'),
(3, 'Pharmacie des Lagunes', 'Porto-Novo, Rue du march├® central, quartier Dj├¿gan-Kp├¿vi'),
(4, 'Pharmacie Universitaire', 'Cotonou, Campus UAC, Facult├® des Sciences de la Sant├®'),
(5, 'Pharmacie Etoile du Sud', 'Parakou, Quartier Zongo, ├á 200m du rond-point Bio Gu├¿ra'),
(6, 'Pharmacie Soleil', 'Bohicon, Route de Dassa, ├á proximit├® de la station Total'),
(7, 'Pharmacie le Bon Samaritain', 'Djougou, Rue du Lyc├®e, face ├á la mairie'),
(8, 'Pharmacie Centrale de Natitingou', 'Natitingou, Rue principale, ├á c├┤t├® du commissariat'),
(9, 'Pharmacie M├®dicale', 'Ouidah, Quartier Pahou, pr├¿s de l\'h├┤pital Saint Camille'),
(10, 'Pharmacie Renaissance', 'Lokossa, Place de l\'Ind├®pendance, face ├á l\'ancienne poste');

-- --------------------------------------------------------

--
-- Structure de la table `prixconsultation`
--

CREATE TABLE `prixconsultation` (
  `id` int(11) NOT NULL,
  `prix` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `profilmedecin`
--

CREATE TABLE `profilmedecin` (
  `id` int(11) NOT NULL,
  `adresse` text DEFAULT NULL,
  `profession` varchar(100) DEFAULT NULL,
  `imgdiplome` text DEFAULT NULL,
  `disponibilite` text DEFAULT NULL,
  `idmedecin` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `profilpatient`
--

CREATE TABLE `profilpatient` (
  `id` int(11) NOT NULL,
  `adresse` text DEFAULT NULL,
  `profession` varchar(100) DEFAULT NULL,
  `idpatient` int(11) NOT NULL,
  `idcarnetsante` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `profilpatient`
--

INSERT INTO `profilpatient` (`id`, `adresse`, `profession`, `idpatient`, `idcarnetsante`) VALUES
(1, 'porto', 'Etudiante', 1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `rendezvous`
--

CREATE TABLE `rendezvous` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dateheure` datetime NOT NULL,
  `statut` enum('en attente','confirmé','annulé','accepté','refusé') DEFAULT 'en attente',
  `idmedecin` int(11) NOT NULL,
  `idpatient` int(11) NOT NULL,
  `idspecialite` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sessions`
--

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL,
  `session_id` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `specialite`
--

CREATE TABLE `specialite` (
  `id` int(11) NOT NULL,
  `nomspecialite` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `specialite`
--

INSERT INTO `specialite` (`id`, `nomspecialite`) VALUES
(1, 'Cardiologie'),
(10, 'Dermatologie'),
(2, 'Gyn├®cologie'),
(3, 'Neurologie'),
(4, 'Ophtalmologie'),
(5, 'ORL'),
(7, 'Psychiatrie'),
(6, 'P├®diatrie'),
(8, 'Radiologie'),
(9, 'Urologie');

-- --------------------------------------------------------

--
-- Structure de la table `typing_status`
--

CREATE TABLE `typing_status` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `sender_type` enum('patient','medecin') NOT NULL,
  `is_typing` tinyint(1) NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `google_id` varchar(100) DEFAULT NULL,
  `role` enum('patient','medecin','admin') NOT NULL,
  `auth_method` enum('standard','google') DEFAULT 'standard',
  `date_creation` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `vaccins`
--

CREATE TABLE `vaccins` (
  `id` int(11) NOT NULL,
  `id_patient` int(11) NOT NULL,
  `nom_vaccin` varchar(255) NOT NULL,
  `date_vaccination` date DEFAULT NULL,
  `date_rappel` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `carnetsante`
--
ALTER TABLE `carnetsante`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`);

--
-- Index pour la table `consultation`
--
ALTER TABLE `consultation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`),
  ADD KEY `id_medecin` (`id_medecin`);

--
-- Index pour la table `dossiers_medicaux`
--
ALTER TABLE `dossiers_medicaux`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`);

--
-- Index pour la table `fichemed`
--
ALTER TABLE `fichemed`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`),
  ADD KEY `id_profil` (`id_profil`),
  ADD KEY `id_carnet` (`id_carnet`);

--
-- Index pour la table `google_tokens`
--
ALTER TABLE `google_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `hopitaux`
--
ALTER TABLE `hopitaux`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `medecin`
--
ALTER TABLE `medecin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idspecialite` (`idspecialite`);

--
-- Index pour la table `medicament`
--
ALTER TABLE `medicament`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_ordonnance` (`id_ordonnance`);

--
-- Index pour la table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sender` (`sender_id`,`sender_type`),
  ADD KEY `idx_receiver` (`receiver_id`),
  ADD KEY `idx_date` (`date_envoi`);

--
-- Index pour la table `ordonnance`
--
ALTER TABLE `ordonnance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idmedecin` (`idmedecin`),
  ADD KEY `idpatient` (`idpatient`);

--
-- Index pour la table `password_reset`
--
ALTER TABLE `password_reset`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `id_medecin` (`id_medecin`);

--
-- Index pour la table `pharmacie`
--
ALTER TABLE `pharmacie`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `prixconsultation`
--
ALTER TABLE `prixconsultation`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `profilmedecin`
--
ALTER TABLE `profilmedecin`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idmedecin` (`idmedecin`);

--
-- Index pour la table `profilpatient`
--
ALTER TABLE `profilpatient`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idpatient` (`idpatient`),
  ADD KEY `idcarnetsante` (`idcarnetsante`);

--
-- Index pour la table `rendezvous`
--
ALTER TABLE `rendezvous`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idmedecin` (`idmedecin`),
  ADD KEY `idpatient` (`idpatient`),
  ADD KEY `idspecialite` (`idspecialite`);

--
-- Index pour la table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `specialite`
--
ALTER TABLE `specialite`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nomspecialite` (`nomspecialite`);

--
-- Index pour la table `typing_status`
--
ALTER TABLE `typing_status`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_typing_status` (`user_id`,`receiver_id`,`sender_type`),
  ADD KEY `idx_last_updated` (`last_updated`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `vaccins`
--
ALTER TABLE `vaccins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_patient` (`id_patient`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `admin`
--
ALTER TABLE `admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `carnetsante`
--
ALTER TABLE `carnetsante`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `consultation`
--
ALTER TABLE `consultation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dossiers_medicaux`
--
ALTER TABLE `dossiers_medicaux`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `fichemed`
--
ALTER TABLE `fichemed`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `google_tokens`
--
ALTER TABLE `google_tokens`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `hopitaux`
--
ALTER TABLE `hopitaux`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `medecin`
--
ALTER TABLE `medecin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `medicament`
--
ALTER TABLE `medicament`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `ordonnance`
--
ALTER TABLE `ordonnance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `password_reset`
--
ALTER TABLE `password_reset`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `patient`
--
ALTER TABLE `patient`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `pharmacie`
--
ALTER TABLE `pharmacie`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `prixconsultation`
--
ALTER TABLE `prixconsultation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `profilmedecin`
--
ALTER TABLE `profilmedecin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `profilpatient`
--
ALTER TABLE `profilpatient`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `rendezvous`
--
ALTER TABLE `rendezvous`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `specialite`
--
ALTER TABLE `specialite`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `typing_status`
--
ALTER TABLE `typing_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `vaccins`
--
ALTER TABLE `vaccins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `carnetsante`
--
ALTER TABLE `carnetsante`
  ADD CONSTRAINT `carnetsante_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id`);

--
-- Contraintes pour la table `consultation`
--
ALTER TABLE `consultation`
  ADD CONSTRAINT `consultation_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `consultation_ibfk_2` FOREIGN KEY (`id_medecin`) REFERENCES `medecin` (`id`);

--
-- Contraintes pour la table `dossiers_medicaux`
--
ALTER TABLE `dossiers_medicaux`
  ADD CONSTRAINT `dossiers_medicaux_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id`);

--
-- Contraintes pour la table `fichemed`
--
ALTER TABLE `fichemed`
  ADD CONSTRAINT `fichemed_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `fichemed_ibfk_2` FOREIGN KEY (`id_profil`) REFERENCES `profilpatient` (`id`),
  ADD CONSTRAINT `fichemed_ibfk_3` FOREIGN KEY (`id_carnet`) REFERENCES `carnetsante` (`id`);

--
-- Contraintes pour la table `medecin`
--
ALTER TABLE `medecin`
  ADD CONSTRAINT `medecin_ibfk_1` FOREIGN KEY (`idspecialite`) REFERENCES `specialite` (`id`);

--
-- Contraintes pour la table `medicament`
--
ALTER TABLE `medicament`
  ADD CONSTRAINT `medicament_ibfk_1` FOREIGN KEY (`id_ordonnance`) REFERENCES `ordonnance` (`id`);

--
-- Contraintes pour la table `ordonnance`
--
ALTER TABLE `ordonnance`
  ADD CONSTRAINT `ordonnance_ibfk_1` FOREIGN KEY (`idmedecin`) REFERENCES `medecin` (`id`),
  ADD CONSTRAINT `ordonnance_ibfk_2` FOREIGN KEY (`idpatient`) REFERENCES `patient` (`id`);

--
-- Contraintes pour la table `patient`
--
ALTER TABLE `patient`
  ADD CONSTRAINT `patient_ibfk_1` FOREIGN KEY (`id_medecin`) REFERENCES `medecin` (`id`);

--
-- Contraintes pour la table `profilmedecin`
--
ALTER TABLE `profilmedecin`
  ADD CONSTRAINT `profilmedecin_ibfk_1` FOREIGN KEY (`idmedecin`) REFERENCES `medecin` (`id`);

--
-- Contraintes pour la table `profilpatient`
--
ALTER TABLE `profilpatient`
  ADD CONSTRAINT `profilpatient_ibfk_1` FOREIGN KEY (`idpatient`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `profilpatient_ibfk_2` FOREIGN KEY (`idcarnetsante`) REFERENCES `carnetsante` (`id`);

--
-- Contraintes pour la table `rendezvous`
--
ALTER TABLE `rendezvous`
  ADD CONSTRAINT `rendezvous_ibfk_1` FOREIGN KEY (`idmedecin`) REFERENCES `medecin` (`id`),
  ADD CONSTRAINT `rendezvous_ibfk_2` FOREIGN KEY (`idpatient`) REFERENCES `patient` (`id`),
  ADD CONSTRAINT `rendezvous_ibfk_3` FOREIGN KEY (`idspecialite`) REFERENCES `specialite` (`id`);

--
-- Contraintes pour la table `vaccins`
--
ALTER TABLE `vaccins`
  ADD CONSTRAINT `vaccins_ibfk_1` FOREIGN KEY (`id_patient`) REFERENCES `patient` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
