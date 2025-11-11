class User {
  int? id;
  String nom;
  String prenom;
  String email;
  String telephone;
  String password;
  DateTime dateInscription;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.password,
    required this.dateInscription,
  });

  // Convertir un User en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'password': password,
      'date_inscription': dateInscription.toIso8601String(),
    };
  }

  // Créer un User à partir d'un Map de la base de données
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
      telephone: map['telephone'],
      password: map['password'],
      dateInscription: DateTime.parse(map['date_inscription']),
    );
  }

  @override
  String toString() {
    return 'User{id: $id, nom: $nom, prenom: $prenom, email: $email, telephone: $telephone, dateInscription: $dateInscription}';
  }
  // Ajoutez cette méthode
  User copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? password,
    DateTime? dateInscription,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      password: password ?? this.password,
      dateInscription: dateInscription ?? this.dateInscription,
    );
  }
}