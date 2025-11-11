import 'package:flutter/material.dart';
import 'package:rentease/models/garage.dart';
import 'package:rentease/services/garage_service.dart';
import 'package:rentease/database/database_helper.dart';

class AddGarageScreen extends StatefulWidget {
  const AddGarageScreen({Key? key}) : super(key: key);

  @override
  _AddGarageScreenState createState() => _AddGarageScreenState();
}

class _AddGarageScreenState extends State<AddGarageScreen> {
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  final _formKey = GlobalKey<FormState>();
  late GarageService _garageService;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();
  final TextEditingController _horairesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final database = await DB.database;
    _garageService = GarageService(database);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final garage = Garage(
          nom: _nomController.text,
          adresse: _adresseController.text,
          telephone: _telephoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          specialite: _specialiteController.text.isEmpty ? null : _specialiteController.text,
          horaires: _horairesController.text.isEmpty ? null : _horairesController.text,
          createdAt: DateTime.now(),
        );

        await _garageService.addGarage(garage);

        Navigator.pop(context, true); // Retour avec succès
      } catch (e) {
        _showErrorSnackbar('Erreur lors de l\'ajout: $e');
      }
    }
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isRequired = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: violet,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: grisClair,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: violetClair, width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Entrez $label',
              hintStyle: TextStyle(color: Colors.grey[500]),
            ),
            style: TextStyle(color: Colors.black87),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nouveau Garage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildFormField(
                  label: 'Nom du garage *',
                  controller: _nomController,
                ),
                _buildFormField(
                  label: 'Adresse *',
                  controller: _adresseController,
                  maxLines: 2,
                ),
                _buildFormField(
                  label: 'Téléphone *',
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                ),
                _buildFormField(
                  label: 'Email',
                  controller: _emailController,
                  isRequired: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildFormField(
                  label: 'Spécialité',
                  controller: _specialiteController,
                  isRequired: false,
                ),
                _buildFormField(
                  label: 'Horaires',
                  controller: _horairesController,
                  isRequired: false,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: violet,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ajouter le garage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _specialiteController.dispose();
    _horairesController.dispose();
    super.dispose();
  }
}