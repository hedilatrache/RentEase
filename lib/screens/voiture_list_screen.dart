import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../services/api_service.dart';
import '../widgets/voiture_card.dart';

class VoitureListScreen extends StatefulWidget {
  const VoitureListScreen({super.key});

  @override
  State<VoitureListScreen> createState() => _VoitureListScreenState();
}

class _VoitureListScreenState extends State<VoitureListScreen> {
  final ApiService apiService = ApiService();
  late List<Voiture> voitures;

  @override
  void initState() {
    super.initState();
    voitures = apiService.voitures;
  }

  void refresh() => setState(() {});

  // Couleurs charte
  final Color primaryColor = const Color(0xFF7201FE);    // violet cards / appbar
  final Color backgroundColor = const Color(0xFFF3E6FF); // violet très clair
  final Color secondaryColor = const Color(0xFFD9B9FF);  // badges
  final Color tertiaryColor = const Color(0xFFFFBB00);   // prix
  final Color textColor = const Color(0xFF1E1E1E);       // texte

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // <-- violet très clair
      appBar: AppBar(
        title: const Text('Rentease - Voitures'),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossCount = constraints.maxWidth > 600 ? 3 : 2;
            double spacing = 12;
            double width = (constraints.maxWidth - (crossCount - 1) * spacing) / crossCount;
            double itemHeight = 220;
            double aspectRatio = width / itemHeight;

            return GridView.builder(
              itemCount: voitures.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                return VoitureCard(
                  voiture: voitures[index],
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                  tertiaryColor: tertiaryColor,
                  textColor: textColor,
                  onDelete: () {
                    apiService.deleteVoiture(voitures[index].id);
                    refresh();
                  },
                  onEdit: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/edit',
                      arguments: voitures[index],
                    );
                    if (result == true) refresh();
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add');
          if (result == true) refresh();
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Ajouter une voiture',
      ),
    );
  }
}
