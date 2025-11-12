import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../models/categorie.dart';
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

  // Liste d'images prédéfinies (Assets ou URLs)
  Map<String, String> imagesMap = {
    'Voiture 1':   'Assets/image1.png',
    'Voiture 2':   'Assets/image2.png',
    'Voiture 3':   'Assets/image3.png',
    'Voiture 4':   'Assets/image4.png',
    'Voiture 5':   'Assets/image5.png',
    'Voiture 6':   'Assets/image6.png',
    'Voiture 7':   'Assets/image7.png',
    'Voiture 8':   'Assets/image8.png',
    'Voiture 9':   'Assets/image9.png',
    'Voiture 10':  'Assets/image10.png',


  };


  String? selectedImage;

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
    selectedImage = widget.voiture.image;
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
    if (_formKey.currentState!.validate() && selectedCategorie != null && selectedImage != null) {
      widget.voiture.marque = marqueController.text;
      widget.voiture.modele = modeleController.text;
      widget.voiture.annee = int.parse(anneeController.text);
      widget.voiture.immatriculation = immatriculationController.text;
      widget.voiture.couleur = couleurController.text;
      widget.voiture.prixParJour = double.parse(prixController.text);
      widget.voiture.disponibilite = disponibilite;
      widget.voiture.categorie = selectedCategorie!;
      widget.voiture.image = selectedImage!;

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
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget buildImagePreview() {
    if (selectedImage == null || selectedImage!.isEmpty) return const SizedBox.shrink();

    if (selectedImage!.startsWith('http')) {
      return Image.network(
        selectedImage!,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Image non disponible'));
        },
      );
    } else {
      return Image.asset(
        selectedImage!,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Image non trouvée'));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: modeleController,
                decoration: buildInputDecoration('Modèle'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: anneeController,
                decoration: buildInputDecoration('Année'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: immatriculationController,
                decoration: buildInputDecoration('Immatriculation'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: couleurController,
                decoration: buildInputDecoration('Couleur'),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: prixController,
                decoration: buildInputDecoration('Prix par jour'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Categorie>(
                value: selectedCategorie,
                items: categories
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.nom),
                ))
                    .toList(),
                onChanged: (c) => setState(() => selectedCategorie = c),
                decoration: buildInputDecoration('Catégorie'),
                dropdownColor: violetClair,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponible'),
                value: disponibilite,
                onChanged: (val) => setState(() => disponibilite = val),
                activeColor: violet,
              ),
              const SizedBox(height: 16),
              Text('Choisir une image', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedImage,
                items: imagesMap.entries
                    .map((e) => DropdownMenuItem(
                  value: e.value,
                  child: Text(e.key),
                ))
                    .toList(),
                onChanged: (val) => setState(() => selectedImage = val),
                decoration: buildInputDecoration('Image'),
              ),
              const SizedBox(height: 16),
              buildImagePreview(),
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
