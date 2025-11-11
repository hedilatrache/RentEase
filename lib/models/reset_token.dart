class ResetToken {
  final int? id;
  final String token;
  final String email;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  ResetToken({
    this.id,
    required this.token,
    required this.email,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
  });

  // Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_used': isUsed ? 1 : 0,
    };
  }

  // Créer un ResetToken à partir d'un Map
  factory ResetToken.fromMap(Map<String, dynamic> map) {
    return ResetToken(
      id: map['id'],
      token: map['token'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
      expiresAt: DateTime.parse(map['expires_at']),
      isUsed: map['is_used'] == 1,
    );
  }

  // Vérifier si le token est expiré
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Vérifier si le token est valide
  bool get isValid => !isExpired && !isUsed;

  @override
  String toString() {
    return 'ResetToken{id: $id, token: $token, email: $email, expiresAt: $expiresAt, isUsed: $isUsed}';
  }
}