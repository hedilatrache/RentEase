import '../models/voiture.dart';
import '../models/categorie.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  List<Categorie> categories = [
    Categorie(id: 1, nom: 'SUV', description: 'Sport Utility Vehicle'),
    Categorie(id: 2, nom: 'Berline', description: 'Voiture berline'),
  ];

  List<Voiture> voitures = [
    Voiture(
      id: 1,
      marque: 'Toyota',
      modele: 'Corolla',
      annee: 2022,
      immatriculation: '123-ABC',
      couleur: 'Blanc',
      prixParJour: 6000,
      disponibilite: true,
      categorie: Categorie(id: 2, nom: 'Berline', description: 'Voiture berline'),
      image: 'assets/image1.png',
    ),

    Voiture(
      id: 2,
      marque: 'Toyota',
      modele: 'Corolla',
      annee: 2022,
      immatriculation: '123-ABC',
      couleur: 'Blanc',
      prixParJour: 5000,
      disponibilite: true,
      categorie: Categorie(id: 2, nom: 'Berline', description: 'Voiture berline'),
      image: 'assets/image2.png',
    ),

    Voiture(
      id: 3,
      marque: 'Toyota',
      modele: 'Corolla',
      annee: 2022,
      immatriculation: '123-ABC',
      couleur: 'Blanc',
      prixParJour: 2000,
      disponibilite: true,
      categorie: Categorie(id: 2, nom: 'Berline', description: 'Voiture berline'),
      image: 'assets/image3.png',
    ),

    Voiture(
      id: 4,
      marque: 'Toyota',
      modele: 'Corolla',
      annee: 2022,
      immatriculation: '123-ABC',
      couleur: 'Blanc',
      prixParJour: 1900,
      disponibilite: true,
      categorie: Categorie(id: 2, nom: 'Berline', description: 'Voiture berline'),
      image: 'assets/image4.png',
    ),
  ];

  Future<List<Voiture>> getVoitures() async => voitures;

  Future<void> addVoiture(Voiture v) async {
    v.id = voitures.length + 1;
    voitures.add(v);
  }

  Future<void> deleteVoiture(int id) async {
    voitures.removeWhere((v) => v.id == id);
  }

  Future<void> editVoiture(Voiture voiture) async {
    int index = voitures.indexWhere((v) => v.id == voiture.id);
    if (index != -1) voitures[index] = voiture;
  }
}
