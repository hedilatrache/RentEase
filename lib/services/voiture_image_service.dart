import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class VoitureImageService {
  static final ImagePicker _picker = ImagePicker();

  // Choisir une image depuis la galerie
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 600,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Erreur sélection image: $e');
      return null;
    }
  }

  // Sauvegarder l'image dans le dossier de l'app
  static Future<String> saveVoitureImage(File imageFile) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'voiture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedImagePath = join(appDir.path, 'voitures', fileName);

      // Créer le dossier voitures s'il n'existe pas
      final Directory voitureDir = Directory(dirname(savedImagePath));
      if (!voitureDir.existsSync()) {
        voitureDir.createSync(recursive: true);
      }

      // Copier le fichier vers le dossier de l'app
      await imageFile.copy(savedImagePath);

      return savedImagePath;
    } catch (e) {
      print('Erreur sauvegarde image: $e');
      throw Exception('Impossible de sauvegarder l\'image');
    }
  }

  // Vérifier si un fichier image existe
  static bool imageExists(String imagePath) {
    try {
      final file = File(imagePath);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }
}