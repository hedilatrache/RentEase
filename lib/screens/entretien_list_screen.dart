import 'package:flutter/material.dart';
import 'package:rentease/models/entretien.dart';
import 'package:rentease/services/entretien_service.dart';
import 'package:rentease/database/database_helper.dart';

import '../models/user.dart';
import 'add_entretien_screen.dart';

class EntretienListScreen extends StatefulWidget {
  final User? user;

  const EntretienListScreen({Key? key, this.user}) : super(key: key);

  @override
  _EntretienListScreenState createState() => _EntretienListScreenState();
}

class _EntretienListScreenState extends State<EntretienListScreen> {
  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  late EntretienService _entretienService;
  List<Entretien> _entretiens = [];
  bool _isLoading = true;
  String _filterStatut = 'Tous';

  @override
  void initState() {
    super.initState();
    _initDatabase();
    if (widget.user != null) {
      print('Utilisateur connecté: ${widget.user!.prenom} ${widget.user!.nom}');
    }
  }

  Future<void> _initDatabase() async {
    final database = await DB.database;
    _entretienService = EntretienService(database);
    await _loadEntretiens();
  }

  Future<void> _loadEntretiens() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entretiens = await _entretienService.getEntretiens();
      setState(() {
        _entretiens = entretiens;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Erreur lors du chargement des entretiens');
    }
  }

  // ✅ NOUVELLE MÉTHODE : Supprimer un entretien
  Future<void> _deleteEntretien(Entretien entretien) async {
    final confirmed = await _showDeleteConfirmationDialog(entretien);

    if (confirmed == true) {
      try {
        await _entretienService.deleteEntretien(entretien.id!);

        // Supprimer de la liste locale
        setState(() {
          _entretiens.removeWhere((e) => e.id == entretien.id);
        });

        _showSuccessSnackbar('Entretien supprimé avec succès');
      } catch (e) {
        _showErrorSnackbar('Erreur lors de la suppression: $e');
      }
    }
  }

  // ✅ NOUVELLE MÉTHODE : Dialogue de confirmation de suppression
  Future<bool?> _showDeleteConfirmationDialog(Entretien entretien) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 30),
            const SizedBox(width: 8),
            Text(
              'Supprimer l\'entretien',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cet entretien ?',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: grisClair,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails de l\'entretien:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: violet,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${entretien.typeEntretien}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Date: ${entretien.dateEntretien.toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Coût: ${entretien.cout} DH',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '⚠️ Cette action est irréversible.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: Text(
              'Annuler',
              style: TextStyle(fontWeight: FontWeight.w600),
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
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case "planifié":
        return jaune;
      case "en_cours":
        return violet;
      case "terminé":
        return Colors.green;
      case "annulé":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Entretien> get _filteredEntretiens {
    if (_filterStatut == 'Tous') return _entretiens;
    return _entretiens.where((e) => e.statut == _filterStatut).toList();
  }

  void _showEntretienDetails(Entretien entretien) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Détails de l\'entretien',
          style: TextStyle(color: violet, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Type', entretien.typeEntretien),
              _buildDetailItem('Date', entretien.dateEntretien.toString().split(' ')[0]),
              _buildDetailItem('Coût', '${entretien.cout} DH'),
              _buildDetailItem('Statut', entretien.statutDisplay),
              if (entretien.description != null)
                _buildDetailItem('Description', entretien.description!),
              if (entretien.kilometrage != null)
                _buildDetailItem('Kilométrage', '${entretien.kilometrage} km'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: violet, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID: ${entretien.id}',
                        style: TextStyle(
                          color: violet,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // ✅ AJOUT DU BOUTON SUPPRIMER DANS LES DÉTAILS
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialogue
              _deleteEntretien(entretien); // Ouvrir la confirmation de suppression
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Supprimer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: violet,
            ),
            child: Text(
              'Fermer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: violet,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filtrer par statut',
          style: TextStyle(color: violet),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Tous'),
            _buildFilterOption('planifié'),
            _buildFilterOption('en_cours'),
            _buildFilterOption('terminé'),
            _buildFilterOption('annulé'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String statut) {
    return ListTile(
      leading: Icon(
        _filterStatut == statut ? Icons.radio_button_checked : Icons.radio_button_off,
        color: violet,
      ),
      title: Text(
        statut == 'Tous' ? 'Tous les entretiens' : Entretien.fromMap({'statut': statut}).statutDisplay,
        style: TextStyle(
          color: _filterStatut == statut ? violet : Colors.black87,
          fontWeight: _filterStatut == statut ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _filterStatut = statut;
        });
        Navigator.pop(context);
      },
    );
  }

  // ✅ NOUVELLE MÉTHODE : Menu contextuel pour chaque entretien
  void _showContextMenu(Entretien entretien, BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Options pour l\'entretien',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildContextMenuOption(
              icon: Icons.visibility,
              title: 'Voir les détails',
              onTap: () {
                Navigator.pop(context);
                _showEntretienDetails(entretien);
              },
            ),
            _buildContextMenuOption(
              icon: Icons.edit,
              title: 'Modifier',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Modification d\'entretien');
              },
            ),
            _buildContextMenuOption(
              icon: Icons.delete,
              title: 'Supprimer',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _deleteEntretien(entretien);
              },
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text('Annuler'),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? violet,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Bientôt disponible!'),
        backgroundColor: violet,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        title: Text(
          'Gestion des Entretiens',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet),
        ),
      )
          : _filteredEntretiens.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_repair,
              size: 80,
              color: violetClair,
            ),
            SizedBox(height: 20),
            Text(
              _filterStatut == 'Tous'
                  ? 'Aucun entretien trouvé'
                  : 'Aucun entretien ${_filterStatut}',
              style: TextStyle(
                fontSize: 18,
                color: violet,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _filterStatut == 'Tous'
                  ? 'Ajoutez votre premier entretien'
                  : 'Aucun entretien avec ce statut',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: violet, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_filteredEntretiens.length} entretien(s) ${_filterStatut == 'Tous' ? 'au total' : _filterStatut}',
                        style: TextStyle(
                          color: violet,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // ✅ INDICATEUR DE SUPPRESSION DISPONIBLE
                    Icon(Icons.swipe, color: violetClair, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Glisser pour supprimer',
                      style: TextStyle(
                        color: violetClair,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEntretiens.length,
              itemBuilder: (context, index) {
                final entretien = _filteredEntretiens[index];
                return Dismissible(
                  // ✅ WIDGET DISMISSIBLE POUR LA SUPPRESSION PAR GLISSEMENT
                  key: Key(entretien.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmationDialog(entretien);
                  },
                  onDismissed: (direction) {
                    _deleteEntretien(entretien);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: violetClair,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          Icons.car_repair,
                          color: violet,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        entretien.typeEntretien,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: violet,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Date: ${entretien.dateEntretien.toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.black87),
                          ),
                          Text(
                            'Coût: ${entretien.cout} DH',
                            style: TextStyle(
                              color: jaune,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatutColor(entretien.statut).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatutColor(entretien.statut),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          entretien.statutDisplay,
                          style: TextStyle(
                            color: _getStatutColor(entretien.statut),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => _showEntretienDetails(entretien),
                      onLongPress: () => _showContextMenu(entretien, context),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}