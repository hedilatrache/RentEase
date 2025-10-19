import 'package:flutter/material.dart';
import 'voiture_list_screen.dart';
import 'voiture_add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // index de l'écran actif

  final Color primaryColor = const Color(0xFF7201FE);    // violet foncé
  final Color backgroundColor = const Color(0xFFF3E6FF); // violet très clair

  // Liste des écrans
  final List<Widget> _screens = const [
    VoitureListScreen(),
    VoitureAddScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ajouter',
          ),
        ],
      ),
    );
  }
}
