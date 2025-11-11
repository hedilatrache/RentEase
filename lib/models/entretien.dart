class Entretien {
  int? id;
  int voitureId;
  int garageId;
  String typeEntretien;
  String? description;
  DateTime dateEntretien;
  DateTime? prochainEntretien;
  double cout;
  int? kilometrage;
  String statut; // "planifié", "en_cours", "terminé", "annulé"
  DateTime createdAt;

  Entretien({
    this.id,
    required this.voitureId,
    required this.garageId,
    required this.typeEntretien,
    this.description,
    required this.dateEntretien,
    this.prochainEntretien,
    required this.cout,
    this.kilometrage,
    required this.statut,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voiture_id': voitureId,
      'garage_id': garageId,
      'type_entretien': typeEntretien,
      'description': description,
      'date_entretien': dateEntretien.toIso8601String(),
      'prochain_entretien': prochainEntretien?.toIso8601String(),
      'cout': cout,
      'kilometrage': kilometrage,
      'statut': statut,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Entretien.fromMap(Map<String, dynamic> map) {
    return Entretien(
      id: map['id'],
      voitureId: map['voiture_id'],
      garageId: map['garage_id'],
      typeEntretien: map['type_entretien'],
      description: map['description'],
      dateEntretien: DateTime.parse(map['date_entretien']),
      prochainEntretien: map['prochain_entretien'] != null
          ? DateTime.parse(map['prochain_entretien'])
          : null,
      cout: map['cout']?.toDouble() ?? 0.0,
      kilometrage: map['kilometrage'],
      statut: map['statut'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Méthodes utilitaires
  bool get estPlanifie => statut == "planifié";
  bool get estEnCours => statut == "en_cours";
  bool get estTermine => statut == "terminé";
  bool get estAnnule => statut == "annulé";

  String get statutDisplay {
    switch (statut) {
      case "planifié": return "Planifié";
      case "en_cours": return "En cours";
      case "terminé": return "Terminé";
      case "annulé": return "Annulé";
      default: return statut;
    }
  }

  @override
  String toString() {
    return 'Entretien{id: $id, voitureId: $voitureId, type: $typeEntretien, date: $dateEntretien, statut: $statut}';
  }
}