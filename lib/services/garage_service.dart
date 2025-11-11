import 'package:sqflite/sqflite.dart';
import '../models/garage.dart';

class GarageService {
  final Database db;

  GarageService(this.db);

  // Ajouter un garage
  Future<int> addGarage(Garage garage) async {
    return await db.insert('garage', garage.toMap());
  }

  // Récupérer tous les garages
  Future<List<Garage>> getGarages() async {
    final List<Map<String, dynamic>> maps = await db.query('garage');
    return List.generate(maps.length, (i) {
      return Garage.fromMap(maps[i]);
    });
  }

  // Récupérer un garage par ID
  Future<Garage?> getGarageById(int id) async {
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
}