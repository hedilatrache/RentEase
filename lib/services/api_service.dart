import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/voiture.dart';
import '../models/categorie.dart';

class ApiService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'rentease.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categorie(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT
          )
        ''');
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
            categorieId INTEGER,
            image TEXT,
            FOREIGN KEY (categorieId) REFERENCES categorie(id)
          )
        ''');
        await db.insert('categorie', {'nom': 'Sportive'});
        await db.insert('categorie', {'nom': 'Familiale'});
        await db.insert('categorie', {'nom': 'Luxe'});
        await db.insert('categorie', {'nom': 'Cabriolet'});
        await db.insert('categorie', {'nom': 'SUV'});

      },
    );
  }

  Future<List<Categorie>> getCategories() async {
    final db = await database;
    final res = await db.query('categorie');
    return res.map((c) => Categorie(id: c['id'] as int, nom: c['nom'] as String)).toList();
  }

  Future<List<Voiture>> getVoitures() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT v.*, c.nom as catNom
      FROM voiture v
      LEFT JOIN categorie c ON v.categorieId = c.id
    ''');
    return res.map((v) => Voiture.fromMap(v)).toList();
  }

  Future<void> addVoiture(Voiture voiture) async {
    final db = await database;
    await db.insert('voiture', voiture.toMap());
  }

  Future<void> editVoiture(Voiture voiture) async {
    final db = await database;
    await db.update('voiture', voiture.toMap(), where: 'id = ?', whereArgs: [voiture.id]);
  }

  Future<void> deleteVoiture(int id) async {
    final db = await database;
    await db.delete('voiture', where: 'id = ?', whereArgs: [id]);
  }
}
