import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../models/categorie.dart';
import '../services/api_service.dart';

class VoitureAddScreen extends StatefulWidget {
  const VoitureAddScreen({super.key});

  @override
  State<VoitureAddScreen> createState() => _VoitureAddScreenState();
}

class _VoitureAddScreenState extends State<VoitureAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  String marque = '';
  String modele = '';
  int annee = DateTime.now().year;
  String immatriculation = '';
  String couleur = '';
  double prixParJour = 0.0;
  String? image;
  Categorie? selectedCategorie;
  late List<Categorie> categories;

  final List<String> images = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
    'assets/image4.png',
  ];

  // 🎨 Couleurs de la charte graphique
  final Color primaryColor = const Color(0xFF7201FE);
  final Color lightViolet = const Color(0xFFF3E9FF);
  final Color textColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    categories = apiService.categories;
    if (categories.isNotEmpty) selectedCategorie = categories[0];
    image = images[0];
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newVoiture = Voiture(
        id: 0,
        marque: marque,
        modele: modele,
        annee: annee,
        immatriculation: immatriculation,
        couleur: couleur,
        prixParJour: prixParJour,
        disponibilite: true,
        categorie: selectedCategorie!,
        image: image,
      );
      apiService.addVoiture(newVoiture);
      Navigator.pop(context, true);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: lightViolet,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightViolet,
      appBar: AppBar(
        title: const Text('Ajouter une voiture'),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Card(
          elevation: 8,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: _inputDecoration('Marque'),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                    onSaved: (v) => marque = v!,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    decoration: _inputDecoration('Modèle'),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                    onSaved: (v) => modele = v!,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    decoration: _inputDecoration('Année'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                    onSaved: (v) => annee = int.parse(v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    decoration: _inputDecoration('Immatriculation'),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                    onSaved: (v) => immatriculation = v!,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    decoration: _inputDecoration('Couleur'),
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                    onSaved: (v) => couleur = v!,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    decoration: _inputDecoration('Prix par jour'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
                    onSaved: (v) => prixParJour = double.parse(v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Categorie>(
                    decoration: _inputDecoration('Catégorie'),
                    value: selectedCategorie,
                    items: categories
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.nom, style: const TextStyle(fontFamily: 'Poppins')),
                    ))
                        .toList(),
                    onChanged: (c) => setState(() => selectedCategorie = c),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Image'),
                    value: image,
                    items: images
                        .map((img) => DropdownMenuItem(
                      value: img,
                      child: Text(img.split('/').last,
                          style: const TextStyle(fontFamily: 'Poppins')),
                    ))
                        .toList(),
                    onChanged: (v) => setState(() => image = v),
                    validator: (v) => v == null ? 'Obligatoire' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Ajouter la voiture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
