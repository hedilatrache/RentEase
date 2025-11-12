import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rentease/screens/edit_reservation_screen.dart';
import 'package:rentease/screens/reservation_detail_screen.dart';
import '../models/reservation.dart';
import '../models/voiture.dart';
import '../services/reservation_service.dart';
import '../services/session_manager.dart'; // Add this import
import '../database/database_helper.dart';

class MesReservationsScreen extends StatefulWidget {
  final int userId;

  const MesReservationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MesReservationsScreenState createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  bool _isCarOwner = false;

  final Color violet = const Color(0xFF7201FE);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      // Check if user is car owner
      _isCarOwner = await SessionManager.isUserCarsOwner();

      // Load reservations based on user role
      final reservations = _isCarOwner
          ? await _reservationService.getReservationsForCarOwner(widget.userId)
          : await _reservationService.getReservationsWithDetails(widget.userId);

      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Erreur lors du chargement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isCarOwner ? 'Réservations de mes véhicules' : 'Mes Réservations',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
          ? _buildEmptyState()
          : _buildReservationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              _isCarOwner ? Icons.car_rental : Icons.receipt_long,
              size: 80,
              color: Colors.grey[300]
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isCarOwner
                ? 'Les réservations de vos véhicules apparaîtront ici'
                : 'Vos réservations apparaîtront ici',
            style: GoogleFonts.inter(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return _buildReservationCard(reservation);
      },
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    final dateDebut = DateTime.parse(reservation['date_debut']);
    final dateFin = DateTime.parse(reservation['date_fin']);
    final statut = reservation['statut'];
    final nombreJours = dateFin.difference(dateDebut).inDays + 1;

    Color statutColor;
    String statutText;
    IconData statutIcon;

    switch (statut) {
      case 'confirmed':
        statutColor = Colors.green;
        statutText = 'Confirmée';
        statutIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statutColor = Colors.red;
        statutText = 'Annulée';
        statutIcon = Icons.cancel;
        break;
      default:
        statutColor = Colors.orange;
        statutText = 'En attente';
        statutIcon = Icons.pending;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationDetailScreen(
              reservationId: reservation['id'],
              userId: widget.userId,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec véhicule et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reservation['marque']} ${reservation['modele']}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation['categorie_nom'] ?? 'Catégorie inconnue',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        // Show client info for car owners
                        if (_isCarOwner && reservation['user_nom'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Client: ${reservation['user_prenom']} ${reservation['user_nom']}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: violet,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statutColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statutColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statutIcon, size: 14, color: statutColor),
                        const SizedBox(width: 6),
                        Text(
                          statutText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statutColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Image du véhicule (si disponible)
              if (reservation['image'] != null && reservation['image'].toString().isNotEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(reservation['image'])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Informations de réservation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: grisClair,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildReservationInfo(
                      icon: Icons.calendar_today,
                      label: 'Du',
                      value: DateFormat('dd/MM/yyyy').format(dateDebut),
                    ),
                    _buildReservationInfo(
                      icon: Icons.calendar_today,
                      label: 'Au',
                      value: DateFormat('dd/MM/yyyy').format(dateFin),
                    ),
                    _buildReservationInfo(
                      icon: Icons.access_time,
                      label: 'Durée',
                      value: '$nombreJours jour${nombreJours > 1 ? 's' : ''}',
                    ),
                    const Divider(height: 16),
                    _buildReservationInfo(
                      icon: Icons.euro_symbol,
                      label: 'Prix total',
                      value: '${reservation['prix_total']?.toStringAsFixed(2) ?? '0.00'}€',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Informations supplémentaires
              Row(
                children: [
                  Icon(Icons.confirmation_number, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Référence #${reservation['id']}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.directions_car, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    reservation['immatriculation'] ?? 'Immat. inconnue',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Boutons d'action
                _buildActionButtons(reservation, statut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationInfo({
    required IconData icon,
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isTotal ? violet : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? violet : Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: isTotal ? violet : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> reservation, String statut) {
    return Column(
      children: [
        const Divider(height: 20),
        Row(
          children: [
            // Bouton Voir détails
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailScreen(
                        reservationId: reservation['id'],
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: violet,
                  side: BorderSide(color: violet),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.visibility, size: 18),
                label: Text(
                  'Détails',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),


          ],
        ),
      ],
    );
  }


  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }
}