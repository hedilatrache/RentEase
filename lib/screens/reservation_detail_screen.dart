import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../models/voiture.dart';
import '../database/database_helper.dart'; // Import de la DB
import 'edit_reservation_screen.dart';

class ReservationDetailScreen extends StatefulWidget {
  final int reservationId;
  final int userId;

  const ReservationDetailScreen({
    Key? key,
    required this.reservationId,
    required this.userId,
  }) : super(key: key);

  @override
  _ReservationDetailScreenState createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final ReservationService _reservationService = ReservationService();

  Reservation? _reservation;
  Voiture? _voiture;
  bool _isLoading = true;
  bool _isCancelling = false;

  // ✅ CHARTE GRAPHIQUE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadReservationDetails();
  }

  Future<void> _loadReservationDetails() async {
    try {
      // Charger la réservation
      final reservations = await _reservationService.getReservationsByUserId(widget.userId);
      _reservation = reservations.firstWhere(
            (r) => r.id == widget.reservationId,
        orElse: () => throw Exception('Réservation non trouvée'),
      );

      // Charger les détails de la voiture directement depuis la DB
      _voiture = await DB().getVoitureById(_reservation!.voitureId);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Erreur lors du chargement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Détails de la réservation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _buildAppBarActions(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservation == null || _voiture == null
          ? _buildErrorState()
          : _buildReservationDetails(),
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (_isLoading || _reservation == null) return null;

    // Afficher les actions seulement si la réservation est en attente ou confirmée
    if (_reservation!.statut == StatutRes.pending || _reservation!.statut == StatutRes.confirmed) {
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEditScreen(),
          tooltip: 'Modifier la réservation',
        ),
      ];
    }
    return null;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Réservation non trouvée',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: violet,
              foregroundColor: jaune,
            ),
            child: Text(
              'Retour',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // En-tête avec statut
          _buildStatusHeader(),

          const SizedBox(height: 24),

          // Informations véhicule
          _buildVehicleInfo(),

          const SizedBox(height: 24),

          // Dates et prix
          _buildDatesAndPrice(),

          const SizedBox(height: 24),

          // Actions
          if (_reservation!.statut == StatutRes.pending || _reservation!.statut == StatutRes.confirmed)
            _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_reservation!.statut) {
      case StatutRes.confirmed:
        statusColor = Colors.green;
        statusText = 'Confirmée';
        statusIcon = Icons.check_circle;
        break;
      case StatutRes.cancelled:
        statusColor = Colors.red;
        statusText = 'Annulée';
        statusIcon = Icons.cancel;
        break;
      case StatutRes.pending:
        statusColor = Colors.orange;
        statusText = 'En attente';
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Inconnu';
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Réservation $statusText',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Référence #${_reservation!.id}',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Véhicule réservé',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: violet,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: violetClair,
                  borderRadius: BorderRadius.circular(12),
                  image: _voiture!.image.isNotEmpty
                      ? DecorationImage(
                    image: FileImage(File(_voiture!.image)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _voiture!.image.isEmpty
                    ? Icon(Icons.directions_car, color: Colors.white, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_voiture!.marque} ${_voiture!.modele}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_voiture!.annee} • ${_voiture!.categorie.nom}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Immatriculation: ${_voiture!.immatriculation}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_voiture!.prixParJour.toStringAsFixed(2)}€/jour',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: violet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatesAndPrice() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final nombreJours = _reservation!.dateFin.difference(_reservation!.dateDebut).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: violetClair.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: violetClair),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date de début',
            value: dateFormat.format(_reservation!.dateDebut),
          ),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Date de fin',
            value: dateFormat.format(_reservation!.dateFin),
          ),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Durée',
            value: '$nombreJours jour${nombreJours > 1 ? 's' : ''}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.euro_symbol,
            label: 'Prix total',
            value: '${_reservation!.prixTotal.toStringAsFixed(2)}€ TTC',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: isTotal ? violet : Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? violet : Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w700,
              color: isTotal ? violet : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isCancelling ? null : _showCancelConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCancelling
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              'Annuler la réservation',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _navigateToEditScreen,
            style: OutlinedButton.styleFrom(
              foregroundColor: violet,
              side: BorderSide(color: violet),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Modifier les dates',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Annuler la réservation',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler cette réservation ? '
              'Cette action est irréversible.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Non, garder',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelReservation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Oui, annuler',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelReservation() async {
    setState(() => _isCancelling = true);

    try {
      await _reservationService.updateReservationStatus(
        reservationId: widget.reservationId,
        newStatus: StatutRes.cancelled,
      );

      // Recharger les données
      await _loadReservationDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Réservation annulée avec succès',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de l\'annulation: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  void _navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReservationScreen(
          reservation: _reservation!,
          voiture: _voiture!,
          userId: widget.userId,
        ),
      ),
    ).then((_) {
      if (mounted) {
        _loadReservationDetails();
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text('Erreur', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.inter(color: violet)),
          ),
        ],
      ),
    );
  }
}