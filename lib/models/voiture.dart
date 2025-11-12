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
  int? userId; // ✅ NOUVEAU : ID du propriétaire

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
    this.userId, // ✅ NOUVEAU
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
      'user_id': userId, // ✅ NOUVEAU
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
      prixParJour: (map['prixParJour'] as num).toDouble(),
      disponibilite: (map['disponibilite'] as int) == 1,
      categorie: Categorie(
        id: map['categorieId'] as int,
        nom: map['catNom'] as String? ?? 'Non catégorisé',
      ),
      image: map['image'] as String? ?? '',
      userId: map['user_id'] as int?, // ✅ NOUVEAU
    );
  }
  // ✅ MÉTHODE COPYWITH POUR LA MODIFICATION
  Voiture copyWith({
    int? id,
    String? marque,
    String? modele,
    int? annee,
    String? immatriculation,
    String? couleur,
    double? prixParJour,
    bool? disponibilite,
    Categorie? categorie,
    String? image,
    int? userId,
  }) {
    return Voiture(
      id: id ?? this.id,
      marque: marque ?? this.marque,
      modele: modele ?? this.modele,
      annee: annee ?? this.annee,
      immatriculation: immatriculation ?? this.immatriculation,
      couleur: couleur ?? this.couleur,
      prixParJour: prixParJour ?? this.prixParJour,
      disponibilite: disponibilite ?? this.disponibilite,
      categorie: categorie ?? this.categorie,
      image: image ?? this.image,
      userId: userId ?? this.userId,
    );
  }
}