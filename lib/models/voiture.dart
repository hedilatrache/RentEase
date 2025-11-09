import 'categorie.dart';

class Voiture {
  int? id;
  String marque;
  String modele;
  int annee;
  String immatriculation;
  String couleur;
  double prixParJour;
  bool disponibilite;
  Categorie categorie;
  String image;

  Voiture({
    this.id,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.immatriculation,
    required this.couleur,
    required this.prixParJour,
    required this.disponibilite,
    required this.categorie,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marque': marque,
      'modele': modele,
      'annee': annee,
      'immatriculation': immatriculation,
      'couleur': couleur,
      'prixParJour': prixParJour,
      'disponibilite': disponibilite ? 1 : 0,
      'categorieId': categorie.id,
      'image': image,
    };
  }

  factory Voiture.fromMap(Map<String, dynamic> map) {
    return Voiture(
      id: map['id'] as int?,
      marque: map['marque'] as String,
      modele: map['modele'] as String,
      annee: map['annee'] as int,
      immatriculation: map['immatriculation'] as String,
      couleur: map['couleur'] as String,
      prixParJour: map['prixParJour'] as double,
      disponibilite: (map['disponibilite'] as int) == 1,
      categorie: Categorie(
        id: map['categorieId'] as int,
        nom: map['catNom'] as String,
      ),
      image: map['image'] as String,
    );
  }
}
