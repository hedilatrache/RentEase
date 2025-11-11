import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/entretien.dart';
import '../models/garage.dart';
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
      version: 3, // Augmenter la version
      onCreate: (db, version) async {
        // Table voiture
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

        // Table users
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

        // Table garage
        await db.execute('''
          CREATE TABLE garage(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            adresse TEXT NOT NULL,
            telephone TEXT NOT NULL,
            email TEXT,
            specialite TEXT,
            horaires TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        // Table entretien
        await db.execute('''
          CREATE TABLE entretien(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            voiture_id INTEGER NOT NULL,
            garage_id INTEGER NOT NULL,
            type_entretien TEXT NOT NULL,
            description TEXT,
            date_entretien TEXT NOT NULL,
            prochain_entretien TEXT,
            cout REAL NOT NULL,
            kilometrage INTEGER,
            statut TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (voiture_id) REFERENCES voiture(id) ON DELETE CASCADE,
            FOREIGN KEY (garage_id) REFERENCES garage(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE garage(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nom TEXT NOT NULL,
              adresse TEXT NOT NULL,
              telephone TEXT NOT NULL,
              email TEXT,
              specialite TEXT,
              horaires TEXT,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE entretien(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              voiture_id INTEGER NOT NULL,
              garage_id INTEGER NOT NULL,
              type_entretien TEXT NOT NULL,
              description TEXT,
              date_entretien TEXT NOT NULL,
              prochain_entretien TEXT,
              cout REAL NOT NULL,
              kilometrage INTEGER,
              statut TEXT NOT NULL,
              created_at TEXT NOT NULL,
              FOREIGN KEY (voiture_id) REFERENCES voiture(id) ON DELETE CASCADE,
              FOREIGN KEY (garage_id) REFERENCES garage(id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }


  // GESTION GARAGE

  // Ajouter un garage
  static Future<int> addGarage(Garage garage) async {
    final db = await database;
    return await db.insert('garage', garage.toMap());
  }

  // Récupérer tous les garages
  static Future<List<Garage>> getGarages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('garage');
    return List.generate(maps.length, (i) {
      return Garage.fromMap(maps[i]);
    });
  }

  // Récupérer un garage par ID
  static Future<Garage?> getGarageById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'garage',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Garage.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un garage
  static Future<int> updateGarage(Garage garage) async {
    final db = await database;
    return await db.update(
      'garage',
      garage.toMap(),
      where: 'id = ?',
      whereArgs: [garage.id],
    );
  }

  // Supprimer un garage
  static Future<int> deleteGarage(int id) async {
    final db = await database;
    return await db.delete(
      'garage',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // GESTION ENTRETIEN

  // Ajouter un entretien
  static Future<int> addEntretien(Entretien entretien) async {
    final db = await database;
    return await db.insert('entretien', entretien.toMap());
  }

  // Récupérer tous les entretiens
  static Future<List<Entretien>> getEntretiens() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('entretien');
    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }

  // Récupérer les entretiens d'une voiture
  static Future<List<Entretien>> getEntretiensByVoiture(int voitureId) async {
    final db = await database;
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

  // Récupérer les entretiens par garage
  static Future<List<Entretien>> getEntretiensByGarage(int garageId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'entretien',
      where: 'garage_id = ?',
      whereArgs: [garageId],
      orderBy: 'date_entretien DESC',
    );
    return List.generate(maps.length, (i) {
      return Entretien.fromMap(maps[i]);
    });
  }

  // Récupérer un entretien par ID
  static Future<Entretien?> getEntretienById(int id) async {
    final db = await database;
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
  static Future<int> updateEntretien(Entretien entretien) async {
    final db = await database;
    return await db.update(
      'entretien',
      entretien.toMap(),
      where: 'id = ?',
      whereArgs: [entretien.id],
    );
  }

  // Supprimer un entretien
  static Future<int> deleteEntretien(int id) async {
    final db = await database;
    return await db.delete(
      'entretien',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer l'historique d'entretien complet avec jointures
  static Future<List<Map<String, dynamic>>> getHistoriqueEntretienComplet() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        e.*,
        v.marque,
        v.modele,
        v.immatriculation,
        g.nom as garage_nom,
        g.adresse as garage_adresse
      FROM entretien e
      LEFT JOIN voiture v ON e.voiture_id = v.id
      LEFT JOIN garage g ON e.garage_id = g.id
      ORDER BY e.date_entretien DESC
    ''');
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


  // Authentifier un utilisateur
  Future<User?> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un utilisateur
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Supprimer un utilisateur
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Récupérer tous les utilisateurs (pour l'admin plus tard)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
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
