import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/voiture.dart';

class VoitureDetailScreen extends StatelessWidget {
  final Voiture voiture;

  const VoitureDetailScreen({Key? key, required this.voiture}) : super(key: key);

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Détails du véhicule',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image principale
            _buildHeroImage(),

            // Informations principales
            _buildMainInfo(),

            // Caractéristiques
            _buildFeatures(),

            // Bouton de réservation
            _buildReservationButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: grisClair,
      ),
      child: voiture.image.isNotEmpty
          ? _buildImageFromPath(voiture.image) // ✅ CORRIGÉ
          : Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE : Afficher l'image depuis le chemin de fichier
  Widget _buildImageFromPath(String imagePath) {
    return Image.file(
      File(imagePath),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback si l'image n'existe pas
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Image non disponible',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${voiture.marque} ${voiture.modele}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${voiture.annee} • ${voiture.categorie.nom}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildDisponibiliteBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Immatriculation: ${voiture.immatriculation}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Couleur: ${voiture.couleur}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisponibiliteBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: voiture.disponibilite ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: voiture.disponibilite ? Colors.green[100]! : Colors.orange[100]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: voiture.disponibilite ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            voiture.disponibilite ? 'Disponible' : 'Indisponible',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: voiture.disponibilite ? Colors.green[800] : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: violet,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('Prix par jour', '${voiture.prixParJour.toStringAsFixed(2)}€ TTC'),
          _buildFeatureItem('Catégorie', voiture.categorie.nom),
          _buildFeatureItem('Année', voiture.annee.toString()),
          _buildFeatureItem('Couleur', voiture.couleur),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: voiture.disponibilite
              ? () {
            _showReservationDialog(context);
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: violet,
            foregroundColor: jaune,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: violet.withOpacity(0.3),
          ),
          child: Text(
            voiture.disponibilite ? 'Réserver maintenant' : 'Indisponible',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Réserver ce véhicule',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fonctionnalité de réservation à venir',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: violetClair.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: violet, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sélection des dates et paiement bientôt disponibles',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Réservation simulée pour ${voiture.marque} ${voiture.modele}',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: violet,
              foregroundColor: jaune,
            ),
            child: Text(
              'Simuler réservation',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}