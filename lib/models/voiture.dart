import 'categorie.dart';

class Voiture {
  int id;
  String marque;
  String modele;
  int annee;
  String immatriculation;
  String couleur;
  double prixParJour;
  bool disponibilite;
  Categorie categorie;
  String? image; // chemin local, ex: 'assets/images/car1.jpg'

  Voiture({
    required this.id,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.immatriculation,
    required this.couleur,
    required this.prixParJour,
    required this.disponibilite,
    required this.categorie,
    this.image,
  });
}
