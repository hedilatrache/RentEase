class Garage {
  int? id;
  String nom;
  String adresse;
  String telephone;
  String? email;
  String? specialite;
  String? horaires;
  DateTime createdAt;

  Garage({
    this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    this.email,
    this.specialite,
    this.horaires,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'specialite': specialite,
      'horaires': horaires,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Garage.fromMap(Map<String, dynamic> map) {
    return Garage(
      id: map['id'],
      nom: map['nom'],
      adresse: map['adresse'],
      telephone: map['telephone'],
      email: map['email'],
      specialite: map['specialite'],
      horaires: map['horaires'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'Garage{id: $id, nom: $nom, adresse: $adresse}';
  }
}