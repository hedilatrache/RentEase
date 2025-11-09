import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {
  static Database? _db;

  // Getter pour récupérer la DB
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // Initialisation de la DB
  static Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'rentease.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE voiture(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            marque TEXT,
            modele TEXT,
            annee INTEGER,
            immatriculation TEXT,
            couleur TEXT,
            prixParJour REAL,
            disponibilite INTEGER,
            image TEXT
          )
        ''');
      },
    );
  }

  // Ajouter une voiture
  static Future<void> addVoiture(Map<String, dynamic> voiture) async {
    final db = await database;
    await db.insert('voiture', voiture);
  }

  // Récupérer toutes les voitures
  static Future<List<Map<String, dynamic>>> getVoitures() async {
    final db = await database;
    return await db.query('voiture');
  }

  // Supprimer une voiture
  static Future<void> deleteVoiture(int id) async {
    final db = await database;
    await db.delete('voiture', where: 'id = ?', whereArgs: [id]);
  }

  // Mettre à jour une voiture
  static Future<void> editVoiture(int id, Map<String, dynamic> voiture) async {
    final db = await database;
    await db.update('voiture', voiture, where: 'id = ?', whereArgs: [id]);
  }
}
