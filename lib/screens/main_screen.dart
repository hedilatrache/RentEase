import 'package:flutter/material.dart';
import '../models/user.dart';
import 'entretien_list_screen.dart';
import 'garage_list_screen.dart';
import 'home_screen.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  final User? user;

  const MainScreen({Key? key, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      // ✅ CORRIGÉ : Passez l'utilisateur à tous les écrans qui en ont besoin
      HomeScreen(user: widget.user),
      EntretienListScreen(user: widget.user), // ⬅️ PLUS de const, et passez user
      const GarageListScreen(), // Si GarageListScreen n'a pas besoin de user
      // ✅ CORRIGÉ : Gestion du user nullable
      if (widget.user != null)
        ProfilePage(user: widget.user!)
      else
        _buildErrorScreen(), // Écran de fallback si user est null
    ];
  }

  // Écran de fallback si user est null
  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Utilisateur non connecté',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              'Veuillez vous reconnecter',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: violet,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.car_repair),
              label: 'Entretien',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_car_wash),
              label: 'Garages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}