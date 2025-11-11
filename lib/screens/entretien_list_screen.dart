import 'package:flutter/material.dart';
import 'package:rentease/models/entretien.dart';
import 'package:rentease/services/entretien_service.dart';
import 'package:rentease/database/database_helper.dart';

import '../models/user.dart';
import 'add_entretien_screen.dart';

class EntretienListScreen extends StatefulWidget {

  final User? user; // ⬅️ AJOUTEZ CE PARAMÈTRE

  const EntretienListScreen({Key? key, this.user}) : super(key: key); // ⬅️ MODIFIEZ LE CONSTRUCTEUR


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
    // ✅ OPTIONNEL: Afficher les infos de l'utilisateur connecté
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
        title: Text(
          'Détails de l\'entretien',
          style: TextStyle(color: violet, fontWeight: FontWeight.bold),
        ),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(color: violet),
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

  void _navigateToAddEntretien() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEntretienScreen()),
    ).then((value) {
      // Recharger la liste si un nouvel entretien a été ajouté
      if (value == true) {
        _loadEntretiens();
      }
    });
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
                return Card(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEntretien,
        child: Icon(Icons.add, size: 28),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}