import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user.dart';

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
        await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        telephone TEXT NOT NULL,
        password TEXT NOT NULL,
        date_inscription TEXT NOT NULL
      )
    ''');


      },
    );
  }

  //GESTION UTULISATEUR
  // Insérer un utilisateur
  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'insertion: $e');
    }
  }

  // Récupérer un utilisateur par email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer un utilisateur par ID
  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Vérifier si un email existe déjà
  Future<bool> emailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  // Fermer la base de données
  Future<void> close() async {
    final db = await database;
    db.close();
  }
  //END GESTION UTILISATEUR








  //GESTION VOITURE


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
  //ENDGESTION VOITURE



}
