import 'package:flutter/material.dart';
import 'package:rentease/models/garage.dart';
import 'package:rentease/services/garage_service.dart';
import 'package:rentease/database/database_helper.dart';
import 'add_garage_screen.dart';

class GarageListScreen extends StatefulWidget {
  const GarageListScreen({Key? key}) : super(key: key);

  @override
  _GarageListScreenState createState() => _GarageListScreenState();
}

class _GarageListScreenState extends State<GarageListScreen> {
  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  late GarageService _garageService;
  List<Garage> _garages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final database = await DB.database;
    _garageService = GarageService(database);
    await _loadGarages();
  }

  Future<void> _loadGarages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final garages = await _garageService.getGarages();
      setState(() {
        _garages = garages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Erreur lors du chargement des garages');
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToAddGarage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGarageScreen()),
    );

    if (result == true) {
      await _loadGarages();
      _showSuccessSnackbar('Garage ajouté avec succès!');
    }
  }

  void _showGarageDetails(Garage garage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          garage.nom,
          style: TextStyle(color: violet, fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailItem('Adresse', garage.adresse),
            _buildDetailItem('Téléphone', garage.telephone),
            if (garage.email != null) _buildDetailItem('Email', garage.email!),
            if (garage.specialite != null) _buildDetailItem('Spécialité', garage.specialite!),
            if (garage.horaires != null) _buildDetailItem('Horaires', garage.horaires!),
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
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        title: const Text(
          'Gestion des Garages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(violet),
        ),
      )
          : _garages.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_car_wash,
              size: 80,
              color: violetClair,
            ),
            SizedBox(height: 20),
            Text(
              'Aucun garage trouvé',
              style: TextStyle(
                fontSize: 18,
                color: violet,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez votre premier garage',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _garages.length,
        itemBuilder: (context, index) {
          final garage = _garages[index];
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
                  Icons.local_car_wash,
                  color: violet,
                  size: 24,
                ),
              ),
              title: Text(
                garage.nom,
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
                    garage.adresse,
                    style: TextStyle(color: Colors.black87),
                  ),
                  Text(
                    garage.telephone,
                    style: TextStyle(
                      color: jaune,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: violet,
                size: 16,
              ),
              onTap: () => _showGarageDetails(garage),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGarage,
        child: Icon(Icons.add, size: 28),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}