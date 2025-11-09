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
  final ApiService api = ApiService();

  String marque = '';
  String modele = '';
  int annee = 2023;
  String immatriculation = '';
  String couleur = '';
  double prixParJour = 0;
  bool disponibilite = true;
  Categorie? selectedCategorie;
  String image = '';

  List<Categorie> categories = [];

  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    categories = await api.getCategories();
    if (categories.isNotEmpty) selectedCategorie = categories[0];
    setState(() {});
  }

  void saveVoiture() async {
    if (_formKey.currentState!.validate() && selectedCategorie != null) {
      _formKey.currentState!.save();
      Voiture voiture = Voiture(
        marque: marque,
        modele: modele,
        annee: annee,
        immatriculation: immatriculation,
        couleur: couleur,
        prixParJour: prixParJour,
        disponibilite: disponibilite,
        categorie: selectedCategorie!,
        image: image,
      );
      await api.addVoiture(voiture);
      Navigator.pop(context, true);
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: violet),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: violet, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: violetClair, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fond blanc
      appBar: AppBar(
        title: const Text('Ajouter une voiture'),
        backgroundColor: violet,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: buildInputDecoration('Marque'),
                style: TextStyle(color: Colors.black),
                onSaved: (v) => marque = v!,
                validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: buildInputDecoration('Modèle'),
                style: TextStyle(color: Colors.black),
                onSaved: (v) => modele = v!,
                validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: buildInputDecoration('Année'),
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                onSaved: (v) => annee = int.parse(v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: buildInputDecoration('Immatriculation'),
                style: TextStyle(color: Colors.black),
                onSaved: (v) => immatriculation = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: buildInputDecoration('Couleur'),
                style: TextStyle(color: Colors.black),
                onSaved: (v) => couleur = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: buildInputDecoration('Prix par jour'),
                style: TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                onSaved: (v) => prixParJour = double.parse(v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Categorie>(
                value: selectedCategorie,
                items: categories
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.nom, style: TextStyle(color: Colors.black)),
                ))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategorie = v),
                decoration: buildInputDecoration('Catégorie'),
                dropdownColor: violetClair,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Disponible',
                  style: TextStyle(color: Colors.black),
                ),
                value: disponibilite,
                onChanged: (val) => setState(() => disponibilite = val),
                activeColor: violet,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: buildInputDecoration('Image (chemin local)'),
                style: TextStyle(color: Colors.black),
                onSaved: (v) => image = v ?? '',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveVoiture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: violet,
                  foregroundColor: jaune,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
