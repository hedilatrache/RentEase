import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentease/screens/reservation_screen.dart';
import 'package:rentease/screens/add_entretien_screen.dart'; // ✅ Ajouter cet import
import '../models/voiture.dart';

class VoitureDetailScreen extends StatelessWidget {
  final Voiture voiture;
  final int userId;

  const VoitureDetailScreen({Key? key, required this.voiture, required this.userId}) : super(key: key);

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
        actions: [
          // ✅ BOUTON ENTRETIEN DANS L'APPBAR
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () => _navigateToEntretien(context),
            tooltip: 'Ajouter un entretien',
          ),
        ],
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

            // ✅ NOUVELLE SECTION : Maintenance
            _buildMaintenanceSection(context),

            // Bouton de réservation
            _buildReservationButton(context),
          ],
        ),
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE : Section Maintenance
  Widget _buildMaintenanceSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maintenance',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: violetClair,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.build, color: violet, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Entretien',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: violet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gérez la maintenance de votre véhicule',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ BOUTONS D'ACTION MAINTENANCE
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEntretien(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: violet,
                      side: BorderSide(color: violet),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(
                      'Nouvel entretien',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: violet,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _showEntretienOptions(context),
                  icon: Icon(Icons.more_horiz, color: jaune),
                  tooltip: 'Plus d\'options',
                ),
              ),
            ],
          ),

          // ✅ INFORMATIONS SUPPLEMENTAIRES
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: violet.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: violetClair),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: violet, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Suivez l\'entretien régulier pour maintenir la valeur de votre véhicule',
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
    );
  }

  // ✅ NOUVELLE MÉTHODE : Navigation vers l'écran d'entretien
  void _navigateToEntretien(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntretienScreen(
          voiture: voiture,
          userId: userId,// ✅ Passage de la voiture actuelle
        ),
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE : Options d'entretien
  void _showEntretienOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Options de maintenance',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: violet,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              icon: Icons.history,
              title: 'Historique des entretiens',
              subtitle: 'Voir tous les entretiens passés',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Historique des entretiens');
              },
            ),
            _buildOptionItem(
              icon: Icons.schedule,
              title: 'Entretiens programmés',
              subtitle: 'Voir les entretiens à venir',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Entretiens programmés');
              },
            ),
            _buildOptionItem(
              icon: Icons.notifications,
              title: 'Rappels d\'entretien',
              subtitle: 'Configurer les notifications',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Rappels d\'entretien');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE : Item d'option
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: violetClair,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: violet, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: violet, size: 16),
      onTap: onTap,
    );
  }

  // ✅ NOUVELLE MÉTHODE : Message "Bientôt disponible"
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Bientôt disponible!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: violet,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // === MÉTHODES EXISTANTES (inchangées) ===

  Widget _buildHeroImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: grisClair,
      ),
      child: voiture.image.isNotEmpty
          ? _buildImageFromPath(voiture.image)
          : Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildImageFromPath(String imagePath) {
    return Image.file(
      File(imagePath),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(
          voiture: voiture,
          userId: userId,
        ),
      ),
    );
  }
}