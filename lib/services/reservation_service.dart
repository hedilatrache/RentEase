import 'package:sqflite/sqflite.dart';
import '../models/reservation.dart';
import '../database/database_helper.dart'; // Adjust path as needed

class ReservationService {
  // Singleton (optional but common)
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  Future<Database> get _db async => DB.database;

  // Insert reservation
  Future<int> insertReservation(Reservation reservation) async {
    final db = await _db;
    return await db.insert('reservation', reservation.toMap());
  }

  // Get all reservations
  Future<List<Reservation>> getReservations() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query('reservation');
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  // Get reservations by user ID
  Future<List<Reservation>> getReservationsByUserId(int userId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservation',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  // Get reservations by car (voiture) ID
  Future<List<Reservation>> getReservationsByCarId(int voitureId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservation',
      where: 'voiture_id = ?',
      whereArgs: [voitureId],
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  // Delete reservation by ID
  Future<int> deleteReservation(int id) async {
    final db = await _db;
    return await db.delete('reservation', where: 'id = ?', whereArgs: [id]);
  }

  // Update reservation dates and price (used by user)
  Future<int> updateUserReservationDates({
    required int reservationId,
    required DateTime newDateDebut,
    required DateTime newDateFin,
    required double newPrixTotal,
  }) async {
    final db = await _db;
    return await db.update(
      'reservation',
      {
        'date_debut': newDateDebut.toIso8601String(),
        'date_fin': newDateFin.toIso8601String(),
        'prix_total': newPrixTotal,
      },
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // Update reservation status (used by car owner or admin)
  Future<int> updateReservationStatus({
    required int reservationId,
    required StatutRes newStatus,
  }) async {
    final db = await _db;
    return await db.update(
      'reservation',
      {
        'statut': newStatus.name,
      },
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }


// Vérifier la disponibilité d'une voiture pour une période
  // Ajoutez cette méthode dans votre ReservationService
  Future<bool> checkDisponibiliteForEdit({
    required int voitureId,
    required DateTime dateDebut,
    required DateTime dateFin,
    required int currentReservationId,
  }) async {
    final db = await _db;

    final List<Map<String, dynamic>> conflicts = await db.rawQuery('''
    SELECT COUNT(*) as count 
    FROM reservation 
    WHERE voiture_id = ? 
      AND id != ?
      AND statut IN ('pending', 'confirmed')
      AND (
        (date_debut BETWEEN ? AND ?) OR
        (date_fin BETWEEN ? AND ?) OR
        (date_debut <= ? AND date_fin >= ?)
      )
  ''', [
      voitureId,
      currentReservationId,
      dateDebut.toIso8601String(),
      dateFin.toIso8601String(),
      dateDebut.toIso8601String(),
      dateFin.toIso8601String(),
      dateDebut.toIso8601String(),
      dateFin.toIso8601String(),
    ]);

    return (conflicts.first['count'] as int) == 0;
  }

// Récupérer les réservations avec les détails des voitures
  Future<List<Map<String, dynamic>>> getReservationsWithDetails(int userId) async {
    final db = await _db;

    return await db.rawQuery('''
    SELECT 
      r.*,
      v.marque,
      v.modele,
      v.immatriculation,
      v.image,
      c.nom as categorie_nom
    FROM reservation r
    LEFT JOIN voiture v ON r.voiture_id = v.id
    LEFT JOIN categorie c ON v.categorieId = c.id
    WHERE r.user_id = ?
    ORDER BY r.date_debut DESC
  ''', [userId]);
  }
}