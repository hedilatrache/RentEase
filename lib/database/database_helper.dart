import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/categorie.dart';
import '../models/entretien.dart';
import '../models/garage.dart';
import '../models/reset_token.dart';
import '../models/user.dart';
import '../models/voiture.dart';

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
      version: 11 , // Augmenter la version
      onCreate: (db, version) async {
        // ✅ NOUVELLE TABLE : Catégorie
        await db.execute('''
        CREATE TABLE categorie(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL
        )
      ''');

        // Dans _initDb() - modifiez la table voiture :
        await db.execute('''
  CREATE TABLE voiture(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    marque TEXT NOT NULL,
    modele TEXT NOT NULL,
    annee INTEGER NOT NULL,
    immatriculation TEXT NOT NULL,
    couleur TEXT NOT NULL,
    prixParJour REAL NOT NULL,
    disponibilite INTEGER NOT NULL,
    categorieId INTEGER NOT NULL,
    image TEXT,
    user_id INTEGER, -- ✅ NOUVEAU : ID du propriétaire
    FOREIGN KEY (categorieId) REFERENCES categorie(id),
    FOREIGN KEY (user_id) REFERENCES users(id) -- ✅ Lien vers la table users
  )
''');
        // ✅ INSÉRER DES CATÉGORIES PAR DÉFAUT
        await db.insert('categorie', {'nom': 'Économique'});
        await db.insert('categorie', {'nom': 'Compacte'});
        await db.insert('categorie', {'nom': 'SUV'});
        await db.insert('categorie', {'nom': 'Luxe'});
        await db.insert('categorie', {'nom': 'Sport'});

        // Table users
        await db.execute('''
  CREATE TABLE users(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    prenom TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    telephone TEXT NOT NULL,
    password TEXT NOT NULL,
    date_inscription TEXT NOT NULL,
    image_path TEXT  -- ✅ Nouvelle colonne pour l'image
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
        await db.execute('''
  CREATE TABLE reset_tokens(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    created_at TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    is_used INTEGER DEFAULT 0,
    FOREIGN KEY (email) REFERENCES users (email)
  )
''');

// Créer un index pour les recherches par token
        await db.execute('CREATE INDEX idx_reset_tokens_token ON reset_tokens(token)');
        await db.execute('CREATE INDEX idx_reset_tokens_email ON reset_tokens(email)');
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
          // Dans la méthode _createDatabase, ajoutez cette table :


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
// ✅ CORRIGÉ : Ajouter une voiture avec l'entité Voiture
  Future<int> addVoiture(Voiture voiture) async {
    final db = await database;
    return await db.insert('voiture', voiture.toMap());
  }

// ✅ CORRIGÉ : Récupérer toutes les voitures avec jointure sur catégorie
  Future<List<Voiture>> getVoitures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      v.*,
      c.nom as catNom
    FROM voiture v
    LEFT JOIN categorie c ON v.categorieId = c.id
  ''');

    return List.generate(maps.length, (i) {
      return Voiture.fromMap(maps[i]);
    });
  }

// ✅ CORRIGÉ : Récupérer une voiture par ID
  Future<Voiture?> getVoitureById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      v.*,
      c.nom as catNom
    FROM voiture v
    LEFT JOIN categorie c ON v.categorieId = c.id
    WHERE v.id = ?
  ''', [id]);

    if (maps.isNotEmpty) {
      return Voiture.fromMap(maps.first);
    }
    return null;
  }

// ✅ CORRIGÉ : Mettre à jour une voiture
  Future<int> updateVoiture(Voiture voiture) async {
    final db = await database;
    return await db.update(
      'voiture',
      voiture.toMap(),
      where: 'id = ?',
      whereArgs: [voiture.id],
    );
  }

// ✅ CORRIGÉ : Supprimer une voiture
  Future<int> deleteVoiture(int id) async {
    final db = await database;
    return await db.delete(
      'voiture',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// ✅ NOUVELLE MÉTHODE : Récupérer toutes les catégories
  Future<List<Categorie>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categorie');
    return List.generate(maps.length, (i) {
      return Categorie.fromMap(maps[i]);
    });
  }

// ✅ NOUVELLE MÉTHODE : Récupérer une catégorie par ID
  Future<Categorie?> getCategorieById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categorie',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Categorie.fromMap(maps.first);
    }
    return null;
  }

  // ✅ Récupérer toutes les voitures d'un utilisateur spécifique
  Future<List<Voiture>> getVoituresByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      v.*,
      c.nom as catNom
    FROM voiture v
    LEFT JOIN categorie c ON v.categorieId = c.id
    WHERE v.user_id = ?
    ORDER BY v.id DESC
  ''', [userId]);

    return List.generate(maps.length, (i) {
      return Voiture.fromMap(maps[i]);
    });
  }

// ✅ Récupérer les voitures disponibles d'un utilisateur spécifique
  Future<List<Voiture>> getVoituresDisponiblesByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      v.*,
      c.nom as catNom
    FROM voiture v
    LEFT JOIN categorie c ON v.categorieId = c.id
    WHERE v.user_id = ? AND v.disponibilite = 1
    ORDER BY v.id DESC
  ''', [userId]);

    return List.generate(maps.length, (i) {
      return Voiture.fromMap(maps[i]);
    });
  }

// ✅ Récupérer le nombre de voitures d'un utilisateur
  Future<int> getCountVoituresByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT COUNT(*) as count FROM voiture WHERE user_id = ?',
        [userId]
    );

    return maps.first['count'] as int;
  }

// ✅ Vérifier si l'utilisateur est propriétaire d'une voiture
  Future<bool> isUserOwnerOfVoiture(int voitureId, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voiture',
      where: 'id = ? AND user_id = ?',
      whereArgs: [voitureId, userId],
    );
    return maps.isNotEmpty;
  }

// ✅ Mettre à jour une voiture avec vérification de propriété
  Future<int> updateVoitureWithOwnerCheck(Voiture voiture, int userId) async {
    final db = await database;

    // Vérifier d'abord si l'utilisateur est propriétaire
    final isOwner = await isUserOwnerOfVoiture(voiture.id!, userId);
    if (!isOwner) {
      throw Exception('Vous n\'êtes pas propriétaire de cette voiture');
    }

    return await db.update(
      'voiture',
      voiture.toMap(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [voiture.id, userId],
    );
  }

// ✅ Supprimer une voiture avec vérification de propriété
  Future<int> deleteVoitureWithOwnerCheck(int voitureId, int userId) async {
    final db = await database;

    // Vérifier d'abord si l'utilisateur est propriétaire
    final isOwner = await isUserOwnerOfVoiture(voitureId, userId);
    if (!isOwner) {
      throw Exception('Vous n\'êtes pas propriétaire de cette voiture');
    }

    return await db.delete(
      'voiture',
      where: 'id = ? AND user_id = ?',
      whereArgs: [voitureId, userId],
    );
  }

// ✅ Récupérer les statistiques des voitures d'un utilisateur
  Future<Map<String, dynamic>> getStatsVoituresByUser(int userId) async {
    final db = await database;

    final totalMaps = await db.rawQuery(
        'SELECT COUNT(*) as total FROM voiture WHERE user_id = ?',
        [userId]
    );

    final disponiblesMaps = await db.rawQuery(
        'SELECT COUNT(*) as disponibles FROM voiture WHERE user_id = ? AND disponibilite = 1',
        [userId]
    );

    final revenuMaps = await db.rawQuery(
        'SELECT SUM(prixParJour) as revenu_potentiel FROM voiture WHERE user_id = ? AND disponibilite = 1',
        [userId]
    );

    return {
      'total': totalMaps.first['total'] as int,
      'disponibles': disponiblesMaps.first['disponibles'] as int,
      'revenu_potentiel': (revenuMaps.first['revenu_potentiel'] as num?)?.toDouble() ?? 0.0,
    };
  }


  //ENDGESTION VOITURE


// Méthodes pour la gestion des tokens de reset
  Future<int> insertResetToken(ResetToken token) async {
    final db = await database;
    return await db.insert('reset_tokens', token.toMap());
  }

  Future<ResetToken?> getResetToken(String token) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reset_tokens',
      where: 'token = ?',
      whereArgs: [token],
    );

    if (maps.isNotEmpty) {
      return ResetToken.fromMap(maps.first);
    }
    return null;
  }

  Future<void> markTokenAsUsed(String token) async {
    final db = await database;
    await db.update(
      'reset_tokens',
      {'is_used': 1},
      where: 'token = ?',
      whereArgs: [token],
    );
  }

  Future<void> cleanupExpiredTokens() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      'reset_tokens',
      where: 'expires_at < ? OR is_used = 1',
      whereArgs: [now],
    );
  }



  Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
// Ajoutez cette méthode pour mettre à jour l'image
  Future<int> updateUserImage(int userId, String imagePath) async {
    final db = await database;
    return await db.update(
      'users',
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Dans database_helper.dart - CORRIGEZ la méthode findOrCreateUser
  Future<User?> findOrCreateUser(String email, String nom, String prenom) async {
    final db = await database;

    // Vérifier si l'utilisateur existe déjà
    final existingUser = await getUserByEmail(email);

    if (existingUser != null) {
      return existingUser;
    } else {
      // Créer un nouvel utilisateur
      final newUser = User(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: '', // Pas de téléphone pour les connexions sociales
        password: _generateSocialPassword(email), // Générer un mot de passe unique
        dateInscription: DateTime.now(),
      );

      final userId = await insertUser(newUser);
      return newUser.copyWith(id: userId);
    }
  }

// Méthode pour générer un mot de passe pour les utilisateurs sociaux
  String _generateSocialPassword(String email) {
    return 'social_${email}_${DateTime.now().millisecondsSinceEpoch}';
  }

}



