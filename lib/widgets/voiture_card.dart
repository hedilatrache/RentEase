import 'package:flutter/material.dart';
import '../models/voiture.dart';
import '../screens/voiture_details_screen.dart';

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
    Widget buildImage() {
      if (voiture.image.isEmpty) {
        return Center(
          child: Icon(Icons.directions_car, size: 60, color: primaryColor.withOpacity(0.5)),
        );
      } else if (voiture.image.startsWith('http')) {
        return Image.network(voiture.image, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('URL invalide', style: TextStyle(color: Colors.red)));
        });
      } else {
        // Asset local
        return Image.asset(voiture.image, fit: BoxFit.cover);
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Voiture_Details_Screen(voiture: voiture)),
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    color: secondaryColor.withOpacity(0.2),
                    child: buildImage(),
                  ),
                  // Badge catégorie
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(voiture.categorie.nom,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  // Badge disponibilité
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: voiture.disponibilite ? Colors.green : Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(voiture.disponibilite ? "Disponible" : "Indisponible",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${voiture.marque} ${voiture.modele}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${voiture.annee} • ${voiture.couleur}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Text('${voiture.prixParJour.toStringAsFixed(0)} DT/jour',
                              style: TextStyle(color: tertiaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit, color: primaryColor, size: 22), onPressed: onEdit),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22), onPressed: onDelete),
                        ],
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
  }
}
