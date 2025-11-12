import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentease/screens/reservation_screen.dart';
import 'package:rentease/screens/add_entretien_screen.dart';
import 'package:rentease/models/voiture.dart';
import 'package:rentease/models/avis.dart';
import 'package:rentease/services/avis_service.dart';
import 'package:rentease/database/database_helper.dart';

class VoitureDetailScreen extends StatefulWidget {
  final Voiture voiture;
  final int userId;

  const VoitureDetailScreen({Key? key, required this.voiture, required this.userId}) : super(key: key);

  @override
  State<VoitureDetailScreen> createState() => _VoitureDetailScreenState();
}

class _VoitureDetailScreenState extends State<VoitureDetailScreen> {
  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  late AvisService _avisService;
  List<Avis> _avisList = [];
  bool _isLoadingAvis = true;
  double _noteMoyenne = 0.0;
  int _nombreAvis = 0;

  @override
  void initState() {
    super.initState();
    _initAvisService();
  }

  Future<void> _initAvisService() async {
    final database = await DB.database;
    _avisService = AvisService(database);
    await _loadAvis();
  }

  Future<void> _loadAvis() async {
    setState(() {
      _isLoadingAvis = true;
    });

    try {
      final avis = await _avisService.getAvisByVoiture(widget.voiture.id!);
      final moyenne = await _avisService.getNoteMoyenneVoiture(widget.voiture.id!);
      final nombre = await _avisService.getNombreAvisVoiture(widget.voiture.id!);

      setState(() {
        _avisList = avis;
        _noteMoyenne = moyenne;
        _nombreAvis = nombre;
        _isLoadingAvis = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAvis = false;
      });
      _showErrorSnackbar('Erreur lors du chargement des avis');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Détails du véhicule',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () => _navigateToEntretien(context),
            tooltip: 'Ajouter un entretien',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image principale
            _buildHeroImage(),

            // Informations principales
            _buildMainInfo(),

            // Caractéristiques
            _buildFeatures(),

            // Bouton de réservation
            _buildReservationButton(context),

            // ✅ SECTION : Avis et Notes
            _buildAvisSection(),

            // ✅ SECTION : Formulaire d'ajout d'avis
            _buildAddAvisForm(),

            // ✅ SECTION : Liste des avis
            _buildAvisList(),

            // Section Maintenance
            _buildMaintenanceSection(context),
          ],
        ),
      ),
    );
  }

  //SECTION : Avis et Notes
  Widget _buildAvisSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avis et Notes',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: violetClair,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: jaune, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _noteMoyenne.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: violet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStarRating(_noteMoyenne),
              const SizedBox(width: 8),
              Text(
                '($_nombreAvis avis)',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Partagez votre expérience avec cette voiture',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // SECTION : Formulaire d'ajout d'avis
  Widget _buildAddAvisForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: violetClair, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Donnez votre avis',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: violet,
            ),
          ),
          const SizedBox(height: 16),
          _buildRatingSelector(),
          const SizedBox(height: 16),
          _buildCommentForm(),
          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  double _selectedRating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: violet,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final rating = index + 1.0;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = rating;
                });
              },
              child: Icon(
                _selectedRating >= rating ? Icons.star : Icons.star_border,
                color: jaune,
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedRating == 0 ? 'Sélectionnez une note' : 'Note: $_selectedRating/5',
          style: GoogleFonts.inter(
            color: _selectedRating == 0 ? Colors.grey : violet,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commentaire',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: violet,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: grisClair,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: violetClair, width: 1),
          ),
          child: TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience avec cette voiture...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.inter(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _selectedRating == 0 ? null : _submitAvis,
        style: ElevatedButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Publier mon avis',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _submitAvis() async {
    try {
      final nouvelAvis = Avis(
        userId: widget.userId,
        voitureId: widget.voiture.id!,
        commentaire: _commentController.text.trim(),
        note: _selectedRating,
        dateCreation: DateTime.now(),
      );

      await _avisService.createAvis(nouvelAvis);

      // Réinitialiser le formulaire
      setState(() {
        _selectedRating = 0.0;
        _commentController.clear();
      });

      // Recharger les avis
      await _loadAvis();

      _showSuccessSnackbar('Votre avis a été publié avec succès!');
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la publication de l\'avis: $e');
    }
  }

  // SECTION : Liste des avis
  Widget _buildAvisList() {
    if (_isLoadingAvis) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: violet),
        ),
      );
    }

    if (_avisList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: grisClair,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.reviews, size: 50, color: violetClair),
            const SizedBox(height: 12),
            Text(
              'Aucun avis pour le moment',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: violet,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soyez le premier à donner votre avis!',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avis des utilisateurs',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: violet,
            ),
          ),
          const SizedBox(height: 12),
          ..._avisList.map((avis) => _buildAvisItem(avis)).toList(),
        ],
      ),
    );
  }

  Widget _buildAvisItem(Avis avis) {
    final isOwner = _isAvisOwner(avis);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStarRating(avis.note),
                // Boutons d'action (seulement pour le propriétaire)
                if (isOwner)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 18, color: violet),
                        onPressed: () => _editAvis(avis),
                        tooltip: 'Modifier',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 18, color: Colors.red),
                        onPressed: () => _deleteAvis(avis),
                        tooltip: 'Supprimer',
                      ),
                    ],
                  )
                else
                  Text(
                    avis.dateCreationFormatee,
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (avis.commentaire.isNotEmpty)
              Text(
                avis.commentaire,
                style: GoogleFonts.inter(
                  color: Colors.black87,
                ),
              ),
            // Date pour le propriétaire (affichée en dessous)
            if (isOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Publié le ${avis.dateCreationFormatee}',
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          color: jaune,
          size: 20,
        );
      }),
    );
  }


  Widget _buildHeroImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: grisClair,
      ),
      child: widget.voiture.image.isNotEmpty
          ? _buildImageFromPath(widget.voiture.image)
          : Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildImageFromPath(String imagePath) {
    return Image.file(
      File(imagePath),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Image non disponible',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.voiture.marque} ${widget.voiture.modele}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.voiture.annee} • ${widget.voiture.categorie.nom}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildDisponibiliteBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Immatriculation: ${widget.voiture.immatriculation}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Couleur: ${widget.voiture.couleur}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisponibiliteBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.voiture.disponibilite ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.voiture.disponibilite ? Colors.green[100]! : Colors.orange[100]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.voiture.disponibilite ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.voiture.disponibilite ? 'Disponible' : 'Indisponible',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.voiture.disponibilite ? Colors.green[800] : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: violet,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('Prix par jour', '${widget.voiture.prixParJour.toStringAsFixed(2)}€ TTC'),
          _buildFeatureItem('Catégorie', widget.voiture.categorie.nom),
          _buildFeatureItem('Année', widget.voiture.annee.toString()),
          _buildFeatureItem('Couleur', widget.voiture.couleur),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maintenance',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: violetClair,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.build, color: violet, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Entretien',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: violet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gérez la maintenance de votre véhicule',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEntretien(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: violet,
                      side: BorderSide(color: violet),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(
                      'Nouvel entretien',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: violet,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _showEntretienOptions(context),
                  icon: Icon(Icons.more_horiz, color: jaune),
                  tooltip: 'Plus d\'options',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: violet.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: violetClair),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: violet, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Suivez l\'entretien régulier pour maintenir la valeur de votre véhicule',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEntretien(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEntretienScreen(
          voiture: widget.voiture,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _showEntretienOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Options de maintenance',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: violet,
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              icon: Icons.history,
              title: 'Historique des entretiens',
              subtitle: 'Voir tous les entretiens passés',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Historique des entretiens');
              },
            ),
            _buildOptionItem(
              icon: Icons.schedule,
              title: 'Entretiens programmés',
              subtitle: 'Voir les entretiens à venir',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Entretiens programmés');
              },
            ),
            _buildOptionItem(
              icon: Icons.notifications,
              title: 'Rappels d\'entretien',
              subtitle: 'Configurer les notifications',
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Rappels d\'entretien');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: violetClair,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: violet, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: violet, size: 16),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Bientôt disponible!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: violet,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildReservationButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: widget.voiture.disponibilite
              ? () {
            _showReservationDialog(context);
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: violet,
            foregroundColor: jaune,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadowColor: violet.withOpacity(0.3),
          ),
          child: Text(
            widget.voiture.disponibilite ? 'Réserver maintenant' : 'Indisponible',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(
          voiture: widget.voiture,
          userId: widget.userId,
        ),
      ),
    );
  }

  // Vérifier si l'utilisateur est le propriétaire de l'avis
  bool _isAvisOwner(Avis avis) {
    return avis.userId == widget.userId;
  }

// Supprimer un avis
  Future<void> _deleteAvis(Avis avis) async {
    if (!_isAvisOwner(avis)) {
      _showErrorSnackbar('Vous ne pouvez supprimer que vos propres avis');
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog(avis);
    if (confirmed == true) {
      try {
        await _avisService.deleteAvis(avis.id!);
        await _loadAvis(); // Recharger la liste
        _showSuccessSnackbar('Avis supprimé avec succès');
      } catch (e) {
        _showErrorSnackbar('Erreur lors de la suppression: $e');
      }
    }
  }

// Éditer un avis
  Future<void> _editAvis(Avis avis) async {
    if (!_isAvisOwner(avis)) {
      _showErrorSnackbar('Vous ne pouvez modifier que vos propres avis');
      return;
    }

    // Ouvrir le formulaire d'édition avec les données existantes
    _showEditAvisDialog(avis);
  }

// Dialogue de confirmation de suppression
  Future<bool?> _showDeleteConfirmationDialog(Avis avis) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Supprimer l\'avis'),
          ],
        ),
        content: Text('Êtes-vous sûr de vouloir supprimer cet avis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }

// Dialogue d'édition d'avis
  void _showEditAvisDialog(Avis avis) {
    final editCommentController = TextEditingController(text: avis.commentaire);
    double editRating = avis.note;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Modifier votre avis'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sélecteur de note
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Note *', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        final rating = index + 1.0;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              editRating = rating;
                            });
                          },
                          child: Icon(
                            editRating >= rating ? Icons.star : Icons.star_border,
                            color: jaune,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Text('Note: $editRating/5', style: TextStyle(color: violet)),
                  ],
                ),
                SizedBox(height: 16),
                // Champ de commentaire
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commentaire', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    TextField(
                      controller: editCommentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Modifiez votre commentaire...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => _updateAvis(avis, editCommentController.text, editRating),
              style: ElevatedButton.styleFrom(backgroundColor: violet),
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

// Mettre à jour l'avis
  Future<void> _updateAvis(Avis avis, String newComment, double newRating) async {
    try {
      final avisModifie = Avis(
        id: avis.id,
        userId: avis.userId,
        voitureId: avis.voitureId,
        commentaire: newComment.trim(),
        note: newRating,
        dateCreation: avis.dateCreation,
      );

      await _avisService.updateAvis(avisModifie);
      Navigator.pop(context); // Fermer le dialogue
      await _loadAvis(); // Recharger la liste
      _showSuccessSnackbar('Avis modifié avec succès');
    } catch (e) {
      _showErrorSnackbar('Erreur lors de la modification: $e');
    }
  }

}