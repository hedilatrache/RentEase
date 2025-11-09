class Categorie {
  final int id;
  final String nom;

  Categorie({required this.id, required this.nom});

  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      id: map['id'] as int,
      nom: map['nom'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
