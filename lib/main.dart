import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation FFI pour Desktop
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const RenteaseApp());
}

class RenteaseApp extends StatelessWidget {
  const RenteaseApp({super.key});

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
          foregroundColor: Color(0xFFFFBB00),
        ),

        // Scaffold
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // Utiliser Material 3 (plus récent)
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}