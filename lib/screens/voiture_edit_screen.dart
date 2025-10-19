import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../models/categorie.dart';
import '../services/api_service.dart';

class VoitureEditScreen extends StatefulWidget {
  const VoitureEditScreen({super.key, required this.voiture});
  final Voiture voiture;

  @override
  State<VoitureEditScreen> createState() => _VoitureEditScreenState();
}

class _VoitureEditScreenState extends State<VoitureEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late String marque;
  late String modele;
  late int annee;
  late String immatriculation;
  late String couleur;
  late double prixParJour;
  String? image;
  Categorie? selectedCategorie;
  late List<Categorie> categories;

  final List<String> images = [
    'assets/image1',
    'assets/image2',
    'assets/image3',
    'assets/image4',
  ];

  // Couleurs
  final Color primaryColor = const Color(0xFF7201FE);
  final Color backgroundColor = const Color(0xFFD9B9FF);

  @override
  void initState() {
    super.initState();
    final v = widget.voiture;

    marque = v.marque;
    modele = v.modele;
    annee = v.annee;
    immatriculation = v.immatriculation;
    couleur = v.couleur;
    prixParJour = v.prixParJour;
    image = images.contains(v.image) ? v.image : images.first;

    // Charger les catégories depuis le service
    categories = apiService.categories;

    // ✅ Trouver la catégorie correspondante par ID pour éviter l'erreur du dropdown
    selectedCategorie = categories.firstWhere(
          (c) => c.id == v.categorie.id,
      orElse: () => categories.first,
    );
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedVoiture = Voiture(
        id: widget.voiture.id,
        marque: marque,
        modele: modele,
        annee: annee,
        immatriculation: immatriculation,
        couleur: couleur,
        prixParJour: prixParJour,
        disponibilite: widget.voiture.disponibilite,
        categorie: selectedCategorie!,
        image: image!,
      );

      apiService.editVoiture(updatedVoiture);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Modifier la voiture'),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Marque', marque, (v) => marque = v!),
              buildTextField('Modèle', modele, (v) => modele = v!),
              buildTextField('Année', annee.toString(), (v) => annee = int.parse(v!), isNumber: true),
              buildTextField('Immatriculation', immatriculation, (v) => immatriculation = v!),
              buildTextField('Couleur', couleur, (v) => couleur = v!),
              buildTextField('Prix par jour', prixParJour.toString(), (v) => prixParJour = double.parse(v!), isNumber: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<Categorie>(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                value: selectedCategorie,
                items: categories
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.nom),
                ))
                    .toList(),
                onChanged: (c) => setState(() => selectedCategorie = c),
                validator: (v) => v == null ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Image',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                value: image,
                items: images
                    .map((img) => DropdownMenuItem(
                  value: img,
                  child: Text(img.split('/').last),
                ))
                    .toList(),
                onChanged: (v) => setState(() => image = v),
                validator: (v) => v == null ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: submit,
                  child: const Text(
                    'Modifier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour créer les champs de texte stylés
  Widget buildTextField(String label, String initialValue, Function(String?) onSaved, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
        onSaved: onSaved,
      ),
    );
  }
}
