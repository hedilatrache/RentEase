import 'dart:io';
import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../services/api_service.dart';
import 'voiture_add_screen.dart';
import 'voiture_edit_screen.dart';

class VoitureListScreen extends StatefulWidget {
  const VoitureListScreen({super.key});

  @override
  State<VoitureListScreen> createState() => _VoitureListScreenState();
}

class _VoitureListScreenState extends State<VoitureListScreen> {
  List<Voiture> voitures = [];
  final ApiService api = ApiService();

  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    loadVoitures();
  }

  void loadVoitures() async {
    voitures = await api.getVoitures();
    setState(() {});
  }

  void deleteVoiture(int id) async {
    await api.deleteVoiture(id);
    loadVoitures();
  }

  void navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoitureAddScreen()),
    );
    if (result == true) loadVoitures();
  }

  void navigateToEdit(Voiture v) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VoitureEditScreen(voiture: v)),
    );
    if (result == true) loadVoitures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisClair,
      appBar: AppBar(
        title: const Text('Nos voitures'),
        backgroundColor: violet,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAdd,
        backgroundColor: violet,
        foregroundColor: jaune,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: voitures.isEmpty
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : GridView.builder(
          itemCount: voitures.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final v = voitures[index];
            return GestureDetector(
              onTap: () => navigateToEdit(v),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: violetClair,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: v.image.isNotEmpty
                            ? Image.file(File(v.image), fit: BoxFit.cover)
                            : Container(
                          color: violetClair.withOpacity(0.3),
                          child: const Icon(Icons.directions_car, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${v.marque} ${v.modele}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${v.categorie.nom} - ${v.prixParJour.toStringAsFixed(0)} DT',
                            style: TextStyle(color: Colors.black.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: v.disponibilite ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              v.disponibilite ? "Disponible" : "Non disponible",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: violet),
                                onPressed: () => navigateToEdit(v),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteVoiture(v.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
