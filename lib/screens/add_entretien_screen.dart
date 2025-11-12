import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rentease/models/entretien.dart';
import 'package:rentease/models/garage.dart';
import 'package:rentease/models/voiture.dart';
import 'package:rentease/services/entretien_service.dart';
import 'package:rentease/services/garage_service.dart';
import 'package:rentease/database/database_helper.dart';
import 'garage_list_screen.dart';

class AddEntretienScreen extends StatefulWidget {
  final Voiture voiture; // ✅ Voiture obligatoire passée depuis le détail
  final int userId;

  const AddEntretienScreen({Key? key, required this.voiture,required this.userId}) : super(key: key);

  @override
  _AddEntretienScreenState createState() => _AddEntretienScreenState();
}

class _AddEntretienScreenState extends State<AddEntretienScreen> {
  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  final _formKey = GlobalKey<FormState>();
  late EntretienService _entretienService;
  late GarageService _garageService;

  // Contrôleurs pour les champs d'entretien
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _coutController = TextEditingController();
  final TextEditingController _kilometrageController = TextEditingController();

  // Variables pour les sélecteurs
  Garage? _selectedGarage;
  String _selectedStatut = "planifié";
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedProchainEntretien;

  // Variables pour le toggle garage
  bool _showGarageSelection = false;

  // Données
  List<Garage> _garages = [];
  final List<String> _statuts = ["planifié", "en_cours", "terminé", "annulé"];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final database = await DB.database;
    _entretienService = EntretienService(database);
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
        if (_garages.isNotEmpty) {
          _selectedGarage = _garages.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('Erreur lors du chargement des garages');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isProchain) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isProchain ? DateTime.now().add(const Duration(days: 30)) : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: violet,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: violet,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isProchain) {
          _selectedProchainEntretien = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _navigateToGarageList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GarageListScreen()),
    );

    if (result == true) {
      await _loadGarages(); // Recharger la liste des garages
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Déterminer l'ID du garage à utiliser
        int garageId;

        if (_showGarageSelection && _selectedGarage != null) {
          // Utiliser le garage sélectionné
          garageId = _selectedGarage!.id!;
        } else {
          // Utiliser un garage par défaut (le premier de la liste)
          if (_garages.isNotEmpty) {
            garageId = _garages.first.id!;
          } else {
            _showErrorSnackbar('Aucun garage disponible. Veuillez d\'abord ajouter un garage.');
            return;
          }
        }

        // Ajouter l'entretien avec la voiture pré-sélectionnée
        final entretien = Entretien(
          voitureId: widget.voiture.id!, // ✅ Utiliser l'ID de la voiture passée en paramètre
          garageId: garageId,
          userId: widget.userId,
          typeEntretien: _typeController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          dateEntretien: _selectedDate,
          prochainEntretien: _selectedProchainEntretien,
          cout: double.parse(_coutController.text),
          kilometrage: _kilometrageController.text.isEmpty ? null : int.parse(_kilometrageController.text),
          statut: _selectedStatut,
          createdAt: DateTime.now(),
        );

        await _entretienService.addEntretien(entretien);

        _showSuccessSnackbar('Entretien ajouté avec succès!');

        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pop(context, true);
      } catch (e) {
        _showErrorSnackbar('Erreur lors de l\'ajout: $e');
      }
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

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    bool isRequired = true,
    int maxLines = 1,
    TextInputType? keyboardType,
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
            keyboardType: keyboardType ?? (isNumber ? TextInputType.number : TextInputType.text),
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
              if (isNumber && value != null && value.isNotEmpty) {
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                if (number <= 0) {
                  return 'Le nombre doit être positif';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, bool isProchain) {
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
        GestureDetector(
          onTap: () => _selectDate(context, isProchain),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: grisClair,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: violetClair, width: 1.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, color: violet, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGarageDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Garage *',
              style: TextStyle(
                color: violet,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _navigateToGarageList,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: violetClair,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_car_wash, color: violet, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Gérer',
                      style: TextStyle(
                        color: violet,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isLoading)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: grisClair,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: violetClair, width: 1.5),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(violet),
                strokeWidth: 2,
              ),
            ),
          )
        else if (_garages.isEmpty)
          GestureDetector(
            onTap: _navigateToGarageList,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: grisClair,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: violetClair, width: 1.5),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aucun garage disponible',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Cliquez pour ajouter un garage',
                      style: TextStyle(
                        color: violet,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: grisClair,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: violetClair, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<Garage>(
                value: _selectedGarage,
                icon: Icon(Icons.arrow_drop_down, color: violet),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
                style: TextStyle(color: Colors.black87, fontSize: 14),
                underline: const SizedBox(),
                onChanged: (Garage? newValue) {
                  setState(() {
                    _selectedGarage = newValue;
                  });
                },
                items: _garages.map<DropdownMenuItem<Garage>>((Garage garage) {
                  return DropdownMenuItem<Garage>(
                    value: garage,
                    child: Text(
                      garage.nom,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        if (_selectedGarage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: violet.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: violetClair),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garage sélectionné:',
                  style: TextStyle(
                    color: violet,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedGarage!.nom,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_selectedGarage!.adresse} • ${_selectedGarage!.telephone}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: value,
              icon: Icon(Icons.arrow_drop_down, color: violet),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.black87, fontSize: 14),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                String displayText;
                switch (value) {
                  case "planifié":
                    displayText = "Planifié";
                    break;
                  case "en_cours":
                    displayText = "En cours";
                    break;
                  case "terminé":
                    displayText = "Terminé";
                    break;
                  case "annulé":
                    displayText = "Annulé";
                    break;
                  default:
                    displayText = value;
                }

                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(displayText),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ✅ NOUVELLE MÉTHODE : Afficher les informations de la voiture
  Widget _buildVoitureInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: violet.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: violet, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: violetClair,
              borderRadius: BorderRadius.circular(8),
              image: widget.voiture.image.isNotEmpty
                  ? DecorationImage(
                image: FileImage(File(widget.voiture.image)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: widget.voiture.image.isEmpty
                ? Icon(Icons.directions_car, color: Colors.white, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Véhicule concerné',
                  style: TextStyle(
                    color: violet,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.voiture.marque} ${widget.voiture.modele}',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.voiture.immatriculation} • ${widget.voiture.annee}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Entretien - ${widget.voiture.marque} ${widget.voiture.modele}',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ SECTION VÉHICULE - Affichage de la voiture pré-sélectionnée
                _buildVoitureInfo(),
                const SizedBox(height: 24),

                // Type d'entretien
                _buildFormField(
                  label: 'Type d\'entretien *',
                  controller: _typeController,
                  isRequired: true,
                ),

                // Description
                _buildFormField(
                  label: 'Description',
                  controller: _descriptionController,
                  isRequired: false,
                  maxLines: 3,
                ),

                // Section Garage avec toggle
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: violet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: violet, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_car_wash,
                        color: violet,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Information du Garage',
                              style: TextStyle(
                                color: violet,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _showGarageSelection
                                  ? 'Choisir un garage spécifique'
                                  : 'Utiliser le garage par défaut',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showGarageSelection,
                        onChanged: (value) {
                          setState(() {
                            _showGarageSelection = value;
                          });
                        },
                        activeColor: violet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Afficher le dropdown seulement si le switch est activé
                if (_showGarageSelection)
                  _buildGarageDropdown(),

                // Date d'entretien
                _buildDateField('Date d\'entretien *', _selectedDate, false),

                // Prochain entretien
                _buildDateField(
                  'Prochain entretien',
                  _selectedProchainEntretien ?? DateTime.now().add(const Duration(days: 30)),
                  true,
                ),

                // Coût
                _buildFormField(
                  label: 'Coût (DH) *',
                  controller: _coutController,
                  isNumber: true,
                  isRequired: true,
                ),

                // Kilométrage
                _buildFormField(
                  label: 'Kilométrage',
                  controller: _kilometrageController,
                  isNumber: true,
                  isRequired: false,
                ),

                // Statut
                _buildDropdownField(
                  label: 'Statut *',
                  value: _selectedStatut,
                  items: _statuts,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatut = newValue!;
                    });
                  },
                ),

                const SizedBox(height: 30),

                // Bouton de soumission
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
                      'Ajouter l\'entretien',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    _coutController.dispose();
    _kilometrageController.dispose();
    super.dispose();
  }
}