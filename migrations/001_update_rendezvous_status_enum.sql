-- Migration: Ajouter les statuts confirmé et annulé à la colonne statut de la table rendezvous
ALTER TABLE rendezvous
MODIFY statut ENUM('en attente', 'confirmé', 'annulé', 'accepté', 'refusé') DEFAULT 'en attente';
