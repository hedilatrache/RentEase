import 'package:flutter/material.dart';
import 'screens/voiture_list_screen.dart';
import 'screens/voiture_add_screen.dart';
import 'screens/voiture_edit_screen.dart';
import 'models/voiture.dart';

void main() => runApp(const RenteaseApp());

class RenteaseApp extends StatelessWidget {
  const RenteaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentease',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const VoitureListScreen(),
        '/add': (context) => const VoitureAddScreen(),
        '/edit': (context) => Builder(
          builder: (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Voiture;
            return VoitureEditScreen(voiture: args);
          },
        ),
      },
    );
  }
}
