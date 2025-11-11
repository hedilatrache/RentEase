import 'package:sqflite/sqflite.dart';
import '../models/entretien.dart';
import '../database/database_helper.dart';

class EntretienService {
  final Database db;

  EntretienService(this.db);

  // Ajouter un entretien
  Future<int> addEntretien(Entretien entretien) async {
    return await db.insert('entretien', entretien.toMap());
  }

  // Récupérer tous les entretiens
  Future<List<Entretien>> getEntretiens() async {
    final List<Map<String, dynamic>> maps = await db.query('entretien');
    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }

  // Récupérer les entretiens d'une voiture
  Future<List<Entretien>> getEntretiensByVoiture(int voitureId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'entretien',
      where: 'voiture_id = ?',
      whereArgs: [voitureId],
      orderBy: 'date_entretien DESC',
    );
    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }

  // Récupérer un entretien par ID
  Future<Entretien?> getEntretienById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'entretien',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Entretien.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un entretien
  Future<int> updateEntretien(Entretien entretien) async {
    return await db.update(
      'entretien',
      entretien.toMap(),
      where: 'id = ?',
      whereArgs: [entretien.id],
    );
  }

  // Supprimer un entretien
  Future<int> deleteEntretien(int id) async {
    return await db.delete(
      'entretien',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer les entretiens par statut
  Future<List<Entretien>> getEntretiensByStatut(String statut) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'entretien',
      where: 'statut = ?',
      whereArgs: [statut],
      orderBy: 'date_entretien DESC',
    );
    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }

  // Récupérer les entretiens à venir
  Future<List<Entretien>> getEntretiensProchains() async {
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM entretien 
      WHERE date_entretien >= ? 
      ORDER BY date_entretien ASC
    ''', [now.toIso8601String()]);

    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }
}