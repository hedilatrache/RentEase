import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentease/screens/voiture_detail_screen1.dart';
import '../database/database_helper.dart';
import '../models/voiture.dart';
import 'ajout_voiture_screen.dart';

import 'modifier_voiture_screen.dart';

class MesVoituresScreen extends StatefulWidget {
  final int userId;

  const MesVoituresScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<MesVoituresScreen> createState() => _MesVoituresScreenState();
}

class _MesVoituresScreenState extends State<MesVoituresScreen> {
  final DB _databaseHelper = DB();
  List<Voiture> _mesVoitures = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadMesVoitures();
    _loadStats();
  }

  Future<void> _loadMesVoitures() async {
    try {
      final voitures = await _databaseHelper.getVoituresByUser(widget.userId);
      setState(() {
        _mesVoitures = voitures;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement mes voitures: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _databaseHelper.getStatsVoituresByUser(widget.userId);
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Erreur chargement stats: $e');
    }
  }

  Future<void> _supprimerVoiture(Voiture voiture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmer la suppression',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${voiture.marque} ${voiture.modele}" ?\nCette action est irréversible.',
          style: GoogleFonts.inter(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Supprimer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseHelper.deleteVoitureWithOwnerCheck(voiture.id!, widget.userId);
        _showSuccessSnackbar('Succès', 'Voiture supprimée avec succès');
        await _loadMesVoitures();
        await _loadStats();
      } catch (e) {
        _showErrorSnackbar('Erreur', 'Impossible de supprimer: $e');
      }
    }
  }

  void _navigateToAjoutVoiture() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjoutVoitureScreen(userId: widget.userId),
      ),
    );

    if (result == true) {
      await _loadMesVoitures();
      await _loadStats();
    }
  }

  void _navigateToModifierVoiture(Voiture voiture) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifierVoitureScreen(
            voiture: voiture,
            userId: widget.userId
        ),
      ),
    );

    if (result == true) {
      await _loadMesVoitures();
      await _loadStats();
    }
  }

  Future<void> _toggleDisponibilite(Voiture voiture) async {
    try {
      final voitureModifiee = voiture.copyWith(disponibilite: !voiture.disponibilite);
      await _databaseHelper.updateVoitureWithOwnerCheck(voitureModifiee, widget.userId);

      _showSuccessSnackbar(
          'Succès',
          'Disponibilité ${voiture.disponibilite ? 'désactivée' : 'activée'}'
      );

      await _loadMesVoitures();
      await _loadStats();
    } catch (e) {
      _showErrorSnackbar('Erreur', 'Impossible de modifier la disponibilité: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mes Voitures',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAjoutVoiture,
        backgroundColor: violet,
        foregroundColor: jaune,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
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

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMesVoitures();
        await _loadStats();
      },
      backgroundColor: Colors.white,
      color: violet,
      child: CustomScrollView(
        slivers: [
          // En-tête avec statistiques
          _buildHeader(),

          // Liste des voitures
          if (_mesVoitures.isEmpty)
            _buildEmptyState()
          else
            _buildVoitureList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: violetClair.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: violetClair, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              'Mes Statistiques',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: violet,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', _stats['total']?.toString() ?? '0'),
                _buildStatItem('Disponibles', _stats['disponibles']?.toString() ?? '0'),
                _buildStatItem('Revenu/j', '${_stats['revenu_potentiel']?.toStringAsFixed(0) ?? '0'}€'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
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
              'Aucune voiture ajoutée',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez par ajouter votre première voiture\npour la proposer à la location',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToAjoutVoiture,
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: jaune,
              ),
              child: Text(
                'Ajouter ma première voiture',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoitureList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final voiture = _mesVoitures[index];
          return _buildVoitureItem(voiture);
        },
        childCount: _mesVoitures.length,
      ),
    );
  }

  Widget _buildVoitureItem(Voiture voiture) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      ),
      child: Column(
        children: [
          // Image et informations
          ListTile(
            leading: _buildVoitureImage(voiture),
            title: Text(
              '${voiture.marque} ${voiture.modele}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${voiture.annee} • ${voiture.categorie.nom}',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${voiture.prixParJour.toStringAsFixed(0)}€/jour',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
              ],
            ),
            trailing: _buildDisponibiliteBadge(voiture.disponibilite),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoitureDetailScreen(voiture: voiture),
                ),
              );
            },
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToModifierVoiture(voiture),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: violet,
                      side: BorderSide(color: violet),
                    ),
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleDisponibilite(voiture),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: voiture.disponibilite ? Colors.orange : Colors.green,
                      side: BorderSide(
                        color: voiture.disponibilite ? Colors.orange : Colors.green,
                      ),
                    ),
                    icon: Icon(
                      voiture.disponibilite ? Icons.pause : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(voiture.disponibilite ? 'Pauser' : 'Activer'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _supprimerVoiture(voiture),
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoitureImage(Voiture voiture) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(12),
      ),
      child: voiture.image.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(voiture.image),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.directions_car, color: Colors.grey[400]);
          },
        ),
      )
          : Icon(Icons.directions_car, color: Colors.grey[400]),
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
            disponible ? 'Dispo' : 'Pausée',
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

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}