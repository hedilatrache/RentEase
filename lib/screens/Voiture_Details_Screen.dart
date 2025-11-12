import 'package:flutter/material.dart';
import '../models/voiture.dart';
import 'dart:io';

class Voiture_Details_Screen extends StatelessWidget {
  final Voiture voiture;

  const Voiture_Details_Screen({super.key, required this.voiture});

  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);

  @override
  Widget build(BuildContext context) {
    Widget buildImage() {
      if (voiture.image.isEmpty) {
        return const Center(child: Text('Pas d\'image'));
      } else if (voiture.image.startsWith('http')) {
        return Image.network(
          voiture.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Image non disponible'));
          },
        );
      } else {
        // Image locale (Assets ou file)
        return Image.asset(
          voiture.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Text('Image non disponible'));
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${voiture.marque} ${voiture.modele}'),
        backgroundColor: violet,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de la voiture
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: violetClair),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: buildImage(),
                ),
              ),
              const SizedBox(height: 16),

              // Marque & Modèle
              Text(
                '${voiture.marque} ${voiture.modele}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: violet,
                ),
              ),
              const SizedBox(height: 8),

              // Catégorie
              Text(
                'Catégorie : ${voiture.categorie.nom}',
                style: TextStyle(
                  fontSize: 16,
                  color: violet.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),

              // Année
              Text(
                'Année : ${voiture.annee}',
                style: TextStyle(
                  fontSize: 16,
                  color: violet.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),

              // Immatriculation
              Text(
                'Immatriculation : ${voiture.immatriculation}',
                style: TextStyle(
                  fontSize: 16,
                  color: violet.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),

              // Couleur
              Text(
                'Couleur : ${voiture.couleur}',
                style: TextStyle(
                  fontSize: 16,
                  color: violet.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),

              // Prix par jour
              Text(
                'Prix par jour : ${voiture.prixParJour.toStringAsFixed(2)} DT',
                style: TextStyle(
                  fontSize: 16,
                  color: violet.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),

              // Disponibilité
              Row(
                children: [
                  const Text('Disponible : ', style: TextStyle(fontSize: 16)),
                  Icon(
                    voiture.disponibilite ? Icons.check_circle : Icons.cancel,
                    color: voiture.disponibilite ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bouton réserver (optionnel)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logique pour réserver la voiture
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: jaune,
                    foregroundColor: violet,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Réserver cette voiture',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
