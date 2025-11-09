import 'package:flutter/material.dart';
import '../models/voiture.dart';
import 'dart:io'; // Ajouter pour File

class VoitureCard extends StatelessWidget {
  final Voiture voiture;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  const VoitureCard({
    super.key,
    required this.voiture,
    required this.onDelete,
    required this.onEdit,
    this.primaryColor = const Color(0xFF7201FE),
    this.secondaryColor = const Color(0xFFD9B9FF),
    this.tertiaryColor = const Color(0xFFFFBB00),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Image de la voiture
                Container(
                  color: secondaryColor.withOpacity(0.3),
                  child: voiture.image.isNotEmpty
                      ? Image.file(
                    File(voiture.image), // CHANGEMENT: Utiliser File au lieu de Image.asset
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                      : Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 60,
                      color: primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),

                // Badge de disponibilité
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: voiture.disponibilite ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      voiture.disponibilite ? "Disponible" : "Indisponible",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Badge de catégorie
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      voiture.categorie.nom,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${voiture.marque} ${voiture.modele}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${voiture.annee} • ${voiture.couleur}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${voiture.prixParJour.toStringAsFixed(0)} DT/jour',
                        style: TextStyle(
                          color: tertiaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: primaryColor, size: 20),
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}