class Reservation {
  int? id;
  int userId;
  int voitureId;
  DateTime dateDebut; // e.g. '2025-11-15'
  DateTime dateFin;
  StatutRes statut;
  double prixTotal;


  Reservation({
    this.id,
    required this.userId,
    required this.voitureId,
    required this.dateDebut,
    required this.dateFin,
    this.statut = StatutRes.pending,
    required this.prixTotal,
  }): assert(dateDebut.isBefore(dateFin) || dateDebut.isAtSameMomentAs(dateFin),
  'Date de début must be before or equal to date de fin');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'voiture_id': voitureId,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'statut': statut.name,
      'prix_total': prixTotal,
    }..removeWhere((key, value) => value == null);
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      userId: map['user_id'],
      voitureId: map['voiture_id'],
      dateDebut: DateTime.parse(map['date_debut']),
      dateFin: DateTime.parse(map['date_fin']),
      statut: StatutRes.values.firstWhere(
            (e) => e.name == map['statut'],
        orElse: () => StatutRes.pending,
      ),
      prixTotal: map['prix_total'],
    );
  }
}
enum StatutRes
{
  pending,confirmed,cancelled
}