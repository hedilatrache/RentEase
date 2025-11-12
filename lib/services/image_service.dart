import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Prendre une photo avec la caméra
  static Future<File?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  // Choisir depuis la galerie
  static Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Sauvegarder l'image dans le dossier de l'app
  static Future<String> saveImageToAppDirectory(File imageFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String savedImagePath = join(appDir.path, fileName);

    // Copier le fichier vers le dossier de l'app
    await imageFile.copy(savedImagePath);

    return savedImagePath;
  }

  // Supprimer une image
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
    }
  }
}