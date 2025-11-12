class Avis {
  int? id;
  int userId;
  int? voitureId;
  String commentaire;
  double note; // Note de 1 à 5
  DateTime dateCreation;

  Avis({
    this.id,
    required this.userId,
    this.voitureId,
    required this.commentaire,
    required this.note,
    required this.dateCreation,
  });

  // Convertir un Avis en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'voiture_id': voitureId,
      'commentaire': commentaire,
      'note': note,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  // Créer un Avis à partir d'un Map
  factory Avis.fromMap(Map<String, dynamic> map) {
    return Avis(
      id: map['id'],
      userId: map['user_id'],
      voitureId: map['voiture_id'],
      commentaire: map['commentaire'],
      note: map['note'] is int ? (map['note'] as int).toDouble() : map['note'],
      dateCreation: DateTime.parse(map['date_creation']),
    );
  }

  @override
  String toString() {
    return 'Avis{id: $id, userId: $userId, voitureId: $voitureId, note: $note, commentaire: $commentaire, dateCreation: $dateCreation}';
  }
  String get dateCreationFormatee {
    return '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}';
  }
}