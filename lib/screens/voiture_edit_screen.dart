import 'package:flutter/material.dart';
import '../models/categorie.dart';
import '../models/voiture.dart';
import '../services/api_service.dart';

class VoitureEditScreen extends StatefulWidget {
  final Voiture voiture;
  const VoitureEditScreen({super.key, required this.voiture});

  @override
  State<VoitureEditScreen> createState() => _VoitureEditScreenState();
}

class _VoitureEditScreenState extends State<VoitureEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  late TextEditingController marqueController;
  late TextEditingController modeleController;
  late TextEditingController anneeController;
  late TextEditingController immatriculationController;
  late TextEditingController couleurController;
  late TextEditingController prixController;
  bool disponibilite = true;
  Categorie? selectedCategorie;
  List<Categorie> categories = [];

  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);

  @override
  void initState() {
    super.initState();
    marqueController = TextEditingController(text: widget.voiture.marque);
    modeleController = TextEditingController(text: widget.voiture.modele);
    anneeController = TextEditingController(text: widget.voiture.annee.toString());
    immatriculationController = TextEditingController(text: widget.voiture.immatriculation);
    couleurController = TextEditingController(text: widget.voiture.couleur);
    prixController = TextEditingController(text: widget.voiture.prixParJour.toString());
    disponibilite = widget.voiture.disponibilite;
    loadCategories();
  }

  void loadCategories() async {
    categories = await api.getCategories();
    selectedCategorie = categories.firstWhere(
          (c) => c.id == widget.voiture.categorie.id,
      orElse: () => categories.first,
    );
    setState(() {});
  }

  void save() async {
    if (_formKey.currentState!.validate() && selectedCategorie != null) {
      widget.voiture.marque = marqueController.text;
      widget.voiture.modele = modeleController.text;
      widget.voiture.annee = int.parse(anneeController.text);
      widget.voiture.immatriculation = immatriculationController.text;
      widget.voiture.couleur = couleurController.text;
      widget.voiture.prixParJour = double.parse(prixController.text);
      widget.voiture.disponibilite = disponibilite;
      widget.voiture.categorie = selectedCategorie!;

      await api.editVoiture(widget.voiture);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Modifier voiture'),
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
                controller: marqueController,
                decoration: buildInputDecoration('Marque'),
                style: const TextStyle(color: Colors.black),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: modeleController,
                decoration: buildInputDecoration('Modèle'),
                style: const TextStyle(color: Colors.black),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: anneeController,
                decoration: buildInputDecoration('Année'),
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: immatriculationController,
                decoration: buildInputDecoration('Immatriculation'),
                style: const TextStyle(color: Colors.black),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: couleurController,
                decoration: buildInputDecoration('Couleur'),
                style: const TextStyle(color: Colors.black),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: prixController,
                decoration: buildInputDecoration('Prix par jour'),
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Categorie>(
                value: selectedCategorie,
                items: categories
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.nom, style: const TextStyle(color: Colors.black)),
                ))
                    .toList(),
                onChanged: (c) => setState(() => selectedCategorie = c),
                decoration: buildInputDecoration('Catégorie'),
                dropdownColor: violetClair,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponible', style: TextStyle(color: Colors.black)),
                value: disponibilite,
                onChanged: (val) => setState(() => disponibilite = val),
                activeColor: violet,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: save,
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
