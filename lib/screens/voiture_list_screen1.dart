import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../models/voiture.dart';
import 'ajout_voiture_screen.dart';
import 'voiture_detail_screen1.dart';
import 'mes_voitures_screen.dart'; // ✅ IMPORT DU NOUVEL ÉCRAN

class VoitureListScreen extends StatefulWidget {
  final int userId;

  const VoitureListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<VoitureListScreen> createState() => _VoitureListScreenState();
}

class _VoitureListScreenState extends State<VoitureListScreen> {
  final DB _databaseHelper = DB();
  List<Voiture> _voitures = [];
  bool _isLoading = true;

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadVoitures();
  }

  Future<void> _loadVoitures() async {
    try {
      final voitures = await _databaseHelper.getVoitures();
      setState(() {
        _voitures = voitures;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement voitures: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ NAVIGATION VERS L'AJOUT DE VOITURE
  void _navigateToAjoutVoiture() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjoutVoitureScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      _loadVoitures();
    }
  }

  // ✅ NOUVELLE MÉTHODE : NAVIGATION VERS MES VÉHICULES
  void _navigateToMesVoitures() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MesVoituresScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Nos Véhicules',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Rechercher',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ✅ BOUTON MES VÉHICULES EN FLOATING ACTION BUTTON AUSSI
          FloatingActionButton(
            onPressed: _navigateToMesVoitures,
            backgroundColor: jaune,
            foregroundColor: violet,
            elevation: 4,
            mini: true,
            heroTag: "mes_voitures", // Important pour éviter les conflits
            child: const Icon(Icons.directions_car, size: 20),
          ),
          const SizedBox(height: 16),
          // BOUTON AJOUTER EXISTANT
          FloatingActionButton(
            onPressed: _navigateToAjoutVoiture,
            backgroundColor: violet,
            foregroundColor: jaune,
            elevation: 4,
            heroTag: "ajouter_voiture", // Important pour éviter les conflits
            child: const Icon(Icons.add, size: 28),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_voitures.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadVoitures,
      backgroundColor: Colors.white,
      color: violet,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec compteur
            _buildHeader(),
            const SizedBox(height: 16),

            // ✅ BOUTON MES VÉHICULES DANS LE CORPS
            _buildMesVoituresButton(),

            const SizedBox(height: 16),

            // Liste des voitures
            Expanded(
              child: _buildVoitureList(),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE : BOUTON MES VÉHICULES DANS LE CORPS
  Widget _buildMesVoituresButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _navigateToMesVoitures,
        style: ElevatedButton.styleFrom(
          backgroundColor: jaune,
          foregroundColor: violet,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 20),
            const SizedBox(width: 8),
            Text(
              'Voir mes véhicules',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Découvrez notre flotte',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_voitures.length} véhicule${_voitures.length > 1 ? 's' : ''} disponible${_voitures.length > 1 ? 's' : ''}',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun véhicule disponible',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revenez plus tard pour découvrir\nnotre collection de véhicules',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),

          // ✅ BOUTON MES VÉHICULES DANS L'ÉTAT VIDE
          ElevatedButton(
            onPressed: _navigateToMesVoitures,
            style: ElevatedButton.styleFrom(
              backgroundColor: jaune,
              foregroundColor: violet,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Mes véhicules',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _loadVoitures,
            style: ElevatedButton.styleFrom(
              backgroundColor: violet,
              foregroundColor: jaune,
            ),
            child: Text(
              'Actualiser',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _navigateToAjoutVoiture,
            style: ElevatedButton.styleFrom(
              backgroundColor: jaune,
              foregroundColor: violet,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ajouter une voiture',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (le reste de votre code reste inchangé)
  Widget _buildVoitureList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _voitures.length,
      itemBuilder: (context, index) {
        final voiture = _voitures[index];
        return _buildVoitureCard(voiture);
      },
    );
  }

  Widget _buildVoitureCard(Voiture voiture) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoitureDetailScreen(voiture: voiture),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVoitureImage(voiture),
            _buildVoitureInfo(voiture),
          ],
        ),
      ),
    );
  }

  Widget _buildVoitureImage(Voiture voiture) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: voiture.image.isNotEmpty
          ? _buildImageFromPath(voiture.image)
          : Center(
        child: Icon(
          Icons.directions_car,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildImageFromPath(String imagePath) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Image.file(
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
                  size: 30,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 4),
                Text(
                  'Image non trouvée',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoitureInfo(Voiture voiture) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${voiture.marque} ${voiture.modele}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${voiture.annee} • ${voiture.categorie.nom}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              voiture.immatriculation,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${voiture.prixParJour.toStringAsFixed(0)}€/jour',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: violet,
                      ),
                    ),
                    Text(
                      'TTC',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                _buildDisponibiliteBadge(voiture.disponibilite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisponibiliteBadge(bool disponible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: disponible ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: disponible ? Colors.green[100]! : Colors.orange[100]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: disponible ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            disponible ? 'Dispo' : 'Indispo',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: disponible ? Colors.green[800] : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Rechercher un véhicule',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fonctionnalité de recherche à venir',
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
                  Icon(Icons.info_outline, color: violet, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtres par marque, prix et catégorie bientôt disponibles',
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
        ],
      ),
    );
  }
}