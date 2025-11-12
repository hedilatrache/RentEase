enum UserRole {
  user,
  carsOwner
}

class User {
  int? id;
  String nom;
  String prenom;
  String email;
  String telephone;
  String password;
  DateTime dateInscription;
  String? imagePath;
  UserRole role;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.password,
    required this.dateInscription,
    this.imagePath,
    required this.role
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
      'image_path': imagePath,
      'role': role.name,
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
      imagePath: map['image_path'],
      role: UserRole.values.firstWhere(
            (role) => role.name == map['role'],
        orElse: () => UserRole.user, // ✅ Valeur par défaut si non trouvé
      ),
    );
  }

  // Méthodes utilitaires pour vérifier le rôle
  bool get isUser => role == UserRole.user;
  bool get isCarsOwner => role == UserRole.carsOwner;

  // Méthode pour obtenir le nom affichable du rôle
  String get roleDisplay {
    switch (role) {
      case UserRole.user:
        return 'Utilisateur';
      case UserRole.carsOwner:
        return 'Propriétaire';
      default:
        return 'Utilisateur';
    }
  }

  @override
  String toString() {
    return 'User{id: $id, nom: $nom, prenom: $prenom, email: $email, telephone: $telephone, dateInscription: $dateInscription, imagePath: $imagePath, role: $role}';
  }

  User copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? password,
    DateTime? dateInscription,
    String? imagePath,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      password: password ?? this.password,
      dateInscription: dateInscription ?? this.dateInscription,
      imagePath: imagePath ?? this.imagePath,
      role: role ?? this.role,
    );
  }
}