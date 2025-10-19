import 'package:flutter/material.dart';
import '../models/voiture.dart';

class VoitureCard extends StatelessWidget {
  final Voiture voiture;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  // Nouvelles couleurs optionnelles pour la charte graphique
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color textColor;

  const VoitureCard({
    super.key,
    required this.voiture,
    required this.onDelete,
    required this.onEdit,
    this.primaryColor = const Color(0xFF7201FE),
    this.secondaryColor = const Color(0xFFD9B9FF),
    this.tertiaryColor = const Color(0xFFFFBB00),
    this.textColor = const Color(0xFF1E1E1E),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              if (voiture.image != null && voiture.image!.isNotEmpty)
                Image.asset(
                  voiture.image!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    voiture.categorie.nom,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tertiaryColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${voiture.prixParJour.toStringAsFixed(0)} DT / jour',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${voiture.marque} ${voiture.modele}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: onEdit,
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
