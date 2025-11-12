import 'package:sqflite/sqflite.dart';
import '../models/avis.dart';

class AvisService {
  final Database database;

  AvisService(this.database);

  // Créer un nouvel avis
  Future<int> createAvis(Avis avis) async {
    try {
      final id = await database.insert(
        'avis',
        avis.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'avis: $e');
    }
  }

  // Récupérer un avis par son ID
  Future<Avis?> getAvisById(int id) async {
    try {
      final maps = await database.query(
        'avis',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Avis.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'avis: $e');
    }
  }

  // Récupérer tous les avis
  Future<List<Avis>> getAllAvis() async {
    try {
      final maps = await database.query('avis', orderBy: 'date_creation DESC');
      return maps.map((map) => Avis.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des avis: $e');
    }
  }

  // Récupérer les avis d'un utilisateur
  Future<List<Avis>> getAvisByUser(int userId) async {
    try {
      final maps = await database.query(
        'avis',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date_creation DESC',
      );
      return maps.map((map) => Avis.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des avis utilisateur: $e');
    }
  }

  // Récupérer les avis d'une voiture
  Future<List<Avis>> getAvisByVoiture(int voitureId) async {
    try {
      final maps = await database.query(
        'avis',
        where: 'voiture_id = ?',
        whereArgs: [voitureId],
        orderBy: 'date_creation DESC',
      );
      return maps.map((map) => Avis.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des avis voiture: $e');
    }
  }

  // Mettre à jour un avis
  Future<int> updateAvis(Avis avis) async {
    try {
      return await database.update(
        'avis',
        avis.toMap(),
        where: 'id = ?',
        whereArgs: [avis.id],
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'avis: $e');
    }
  }

  // Supprimer un avis
  Future<int> deleteAvis(int id) async {
    try {
      return await database.delete(
        'avis',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'avis: $e');
    }
  }

  // Calculer la note moyenne d'une voiture
  Future<double> getNoteMoyenneVoiture(int voitureId) async {
    try {
      final result = await database.rawQuery(
        'SELECT AVG(note) as moyenne FROM avis WHERE voiture_id = ?',
        [voitureId],
      );

      if (result.isNotEmpty && result.first['moyenne'] != null) {
        return (result.first['moyenne'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      throw Exception('Erreur lors du calcul de la note moyenne: $e');
    }
  }

  // Compter le nombre d'avis pour une voiture
  Future<int> getNombreAvisVoiture(int voitureId) async {
    try {
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM avis WHERE voiture_id = ?',
        [voitureId],
      );

      if (result.isNotEmpty) {
        return result.first['count'] as int;
      }
      return 0;
    } catch (e) {
      throw Exception('Erreur lors du comptage des avis: $e');
    }
  }

}