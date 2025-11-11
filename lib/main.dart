import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rentease/screens/login.dart';
import 'package:rentease/screens/main_screen.dart';
import 'package:rentease/services/session_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database/database_helper.dart';
import 'models/user.dart';
import 'screens/home_screen.dart';
import 'screens/entretien_list_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ TEMPORAIRE - DÉCOMMENTEZ POUR SUPPRIMER L'ANCIENNE BASE
  // await deleteDatabase(join(await getDatabasesPath(), 'rentease.db'));

  // Initialisation FFI pour Desktop
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ VÉRIFICATION DE LA SESSION AU DÉMARRAGE
  final bool isLoggedIn = await SessionManager.isLoggedIn();
  User? currentUser;

  if (isLoggedIn) {
    // Récupérer l'utilisateur depuis la base de données
    final db = DB();
    final userId = await SessionManager.getUserId();
    if (userId != null) {
      currentUser = await db.getUserById(userId);
    }
  }

  runApp(RenteaseApp(
    isLoggedIn: isLoggedIn,
    currentUser: currentUser,
  ));
}

class RenteaseApp extends StatelessWidget {
  final bool isLoggedIn;
  final User? currentUser;

  const RenteaseApp({
    super.key,
    required this.isLoggedIn,
    this.currentUser
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentease - Location de Voitures',
      theme: ThemeData(
        // Couleurs principales
        primaryColor: const Color(0xFF7201FE),
        hintColor: const Color(0xFFFFBB00),

        // Scheme de couleurs
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7201FE),
          secondary: Color(0xFFFFBB00),
          background: Color(0xFFF5F5F5),
          surface: Colors.white,
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7201FE),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Bouton flottant
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF7201FE),
          foregroundColor: Colors.white,
        ),

        // Scaffold
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // Boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7201FE),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Utiliser Material 3 (plus récent)
        useMaterial3: true,
      ),
      // ✅ REDIRECTION AUTOMATIQUE SI DÉJÀ CONNECTÉ
      // ✅ REDIRECTION AUTOMATIQUE SI DÉJÀ CONNECTÉ
      home: isLoggedIn && currentUser != null
          ? MainScreen(user: currentUser) // ⬅️ UTILISEZ MainScreen AU LIEU DE EntretienListScreen
          : const LoginPage(),
    );
  }
}