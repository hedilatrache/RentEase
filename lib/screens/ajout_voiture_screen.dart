import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../models/voiture.dart';
import '../models/categorie.dart';
import '../services/voiture_image_service.dart';

class AjoutVoitureScreen extends StatefulWidget {
  final int userId; // ✅ NOUVEAU : Recevoir l'ID utilisateur

  const AjoutVoitureScreen({Key? key, required this.userId}) : super(key: key);


  @override
  State<AjoutVoitureScreen> createState() => _AjoutVoitureScreenState();
}

class _AjoutVoitureScreenState extends State<AjoutVoitureScreen> {
  final DB _databaseHelper = DB();
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _immatriculationController = TextEditingController();
  final TextEditingController _couleurController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  // Variables d'état
  List<Categorie> _categories = [];
  Categorie? _categorieSelectionnee;
  bool _disponibilite = true;
  bool _isLoading = false;
  File? _imageSelectionnee;
  String _cheminImageSauvegardee = '';

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _databaseHelper.getCategories();
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _categorieSelectionnee = _categories.first;
        }
      });
    } catch (e) {
      print('Erreur chargement catégories: $e');
    }
  }

  // ✅ NOUVELLE MÉTHODE : Sélectionner une image
  Future<void> _selectImage() async {
    try {
      final File? imageFile = await VoitureImageService.pickImageFromGallery();

      if (imageFile != null) {
        setState(() {
          _imageSelectionnee = imageFile;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Erreur', 'Impossible de sélectionner l\'image: $e');
    }
  }

  // ✅ NOUVELLE MÉTHODE : Supprimer l'image sélectionnée
  void _removeImage() {
    setState(() {
      _imageSelectionnee = null;
      _cheminImageSauvegardee = '';
    });
  }

  Future<void> _ajouterVoiture() async {
    if (_formKey.currentState!.validate() && _categorieSelectionnee != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String imagePath = '';
        if (_imageSelectionnee != null) {
          imagePath = await VoitureImageService.saveVoitureImage(_imageSelectionnee!);
          _cheminImageSauvegardee = imagePath;
        }

        final nouvelleVoiture = Voiture(
          marque: _marqueController.text.trim(),
          modele: _modeleController.text.trim(),
          annee: int.parse(_anneeController.text.trim()),
          immatriculation: _immatriculationController.text.trim().toUpperCase(),
          couleur: _couleurController.text.trim(),
          prixParJour: double.parse(_prixController.text.trim()),
          disponibilite: _disponibilite,
          categorie: _categorieSelectionnee!,
          image: imagePath,
          userId: widget.userId, // ✅ ASSOCIER À L'UTILISATEUR
        );

        final result = await _databaseHelper.addVoiture(nouvelleVoiture);

        if (result > 0) {
          _showSuccessSnackbar('Succès', 'Voiture ajoutée avec succès!');
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackbar('Erreur', 'Erreur lors de l\'ajout');
        }
      } catch (e) {
        _showErrorSnackbar('Erreur', 'Une erreur est survenue: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Ajouter une voiture',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Section image
            _buildImageSection(),
            const SizedBox(height: 20),

            // Formulaire
            _buildFormulaire(),
            const SizedBox(height: 30),

            // Bouton d'ajout
            _buildAjoutButton(),
          ],
        ),
      ),
    );
  }

  // ✅ NOUVELLE MÉTHODE : Section de sélection d'image
  Widget _buildImageSection() {
    return Column(
      children: [
        Text(
          'Photo du véhicule',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: grisClair,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: violetClair,
              width: 2,
            ),
          ),
          child: _imageSelectionnee != null
              ? _buildImagePreview()
              : _buildImagePlaceholder(),
        ),
        const SizedBox(height: 8),

        if (_imageSelectionnee != null)
          _buildImageActions()
        else
          _buildSelectImageButton(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        // Image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            _imageSelectionnee!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          ),
        ),

        // Bouton de suppression
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.photo_camera,
          size: 50,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Ajouter une photo',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Appuyez pour sélectionner',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectImageButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: violetClair,
          foregroundColor: violet,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(Icons.photo_library),
        label: Text(
          'Choisir depuis la galerie',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildImageActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _selectImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: violet,
              side: BorderSide(color: violet),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.swap_horiz),
            label: Text(
              'Changer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _removeImage,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.delete),
            label: Text(
              'Supprimer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaire() {
    return Column(
      children: [
        // Marque
        _buildTextField(
          controller: _marqueController,
          label: 'Marque *',
          hintText: 'ex: Toyota',
          icon: Icons.branding_watermark,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer la marque';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Modèle
        _buildTextField(
          controller: _modeleController,
          label: 'Modèle *',
          hintText: 'ex: Corolla',
          icon: Icons.directions_car,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le modèle';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Année
        _buildTextField(
          controller: _anneeController,
          label: 'Année *',
          hintText: 'ex: 2023',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer l\'année';
            }
            final annee = int.tryParse(value);
            if (annee == null || annee < 1900 || annee > DateTime.now().year + 1) {
              return 'Année invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Immatriculation
        _buildTextField(
          controller: _immatriculationController,
          label: 'Immatriculation *',
          hintText: 'ex: AB-123-CD',
          icon: Icons.confirmation_number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer l\'immatriculation';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Couleur
        _buildTextField(
          controller: _couleurController,
          label: 'Couleur *',
          hintText: 'ex: Blanc',
          icon: Icons.color_lens,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer la couleur';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Prix par jour
        _buildTextField(
          controller: _prixController,
          label: 'Prix par jour (€) *',
          hintText: 'ex: 45.00',
          icon: Icons.euro,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le prix';
            }
            final prix = double.tryParse(value);
            if (prix == null || prix <= 0) {
              return 'Prix invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Catégorie
        _buildCategorieDropdown(),
        const SizedBox(height: 16),

        // Disponibilité
        _buildDisponibiliteSwitch(),
      ],
    );
  }

  // ... Les méthodes _buildTextField, _buildCategorieDropdown, _buildDisponibiliteSwitch
  // restent identiques à votre code précédent ...

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: violet,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: grisClair,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: violetClair,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: violet),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorieDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: violet,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: grisClair,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: violetClair,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<Categorie>(
              value: _categorieSelectionnee,
              items: _categories.map((Categorie categorie) {
                return DropdownMenuItem<Categorie>(
                  value: categorie,
                  child: Text(
                    categorie.nom,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (Categorie? nouvelleCategorie) {
                setState(() {
                  _categorieSelectionnee = nouvelleCategorie;
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(Icons.arrow_drop_down, color: violet),
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner une catégorie';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisponibiliteSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: violetClair,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available, color: violet),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Disponible à la location',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Switch(
            value: _disponibilite,
            onChanged: (bool value) {
              setState(() {
                _disponibilite = value;
              });
            },
            activeColor: violet,
            activeTrackColor: violetClair,
          ),
        ],
      ),
    );
  }

  Widget _buildAjoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _ajouterVoiture,
        style: ElevatedButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: jaune,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: violet.withOpacity(0.3),
        ),
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(jaune),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              'Ajouter la voiture',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _anneeController.dispose();
    _immatriculationController.dispose();
    _couleurController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}