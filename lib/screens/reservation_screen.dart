import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/voiture.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationScreen extends StatefulWidget {
  final Voiture voiture;
  final int userId;

  const ReservationScreen({
    Key? key,
    required this.voiture,
    required this.userId,
  }) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final ReservationService _reservationService = ReservationService();

  DateTime? _dateDebut;
  DateTime? _dateFin;
  int _nombreJours = 0;
  double _prixTotal = 0.0;
  bool _isLoading = false;

  // ✅ CHARTE GRAPHIQUE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Réserver le véhicule',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête véhicule
            _buildVehicleHeader(),

            const SizedBox(height: 24),

            // Sélection des dates
            _buildDateSelection(),

            const SizedBox(height: 24),

            // Récapitulatif prix
            _buildPriceSummary(),

            const SizedBox(height: 32),

            // Bouton de réservation
            _buildReservationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: violetClair,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.voiture.marque} ${widget.voiture.modele}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.voiture.annee} • ${widget.voiture.categorie.nom}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.voiture.prixParJour.toStringAsFixed(2)}€/jour',
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
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période de location',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        const SizedBox(height: 16),

        // Date de début
        _buildDateField(
          label: 'Date de début',
          date: _dateDebut,
          onTap: () => _selectDateDebut(),
        ),

        const SizedBox(height: 16),

        // Date de fin
        _buildDateField(
          label: 'Date de fin',
          date: _dateFin,
          onTap: () => _selectDateFin(),
        ),

        if (_dateDebut != null && _dateFin != null) ...[
          const SizedBox(height: 16),
          _buildDateValidation(),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: violet,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : 'Sélectionner une date',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: date != null ? Colors.black : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateValidation() {
    String message = '';
    Color color = Colors.green;

    if (_dateFin!.isBefore(_dateDebut!)) {
      message = 'La date de fin doit être après la date de début';
      color = Colors.red;
    } else if (_dateDebut!.isBefore(DateTime.now())) {
      message = 'La date de début ne peut pas être dans le passé';
      color = Colors.red;
    } else {
      message = 'Période valide';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            color == Colors.green ? Icons.check_circle : Icons.error,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    if (_nombreJours == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: violetClair.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: violetClair),
      ),
      child: Column(
        children: [
          _buildPriceLine('Prix par jour', '${widget.voiture.prixParJour.toStringAsFixed(2)}€'),
          _buildPriceLine('Nombre de jours', '$_nombreJours jours'),
          const Divider(),
          _buildPriceLine(
            'Total TTC',
            '${_prixTotal.toStringAsFixed(2)}€',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? violet : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? violet : Colors.black,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationButton() {
    final bool isFormValid = _dateDebut != null &&
        _dateFin != null &&
        _dateFin!.isAfter(_dateDebut!) &&
        _dateDebut!.isAfter(DateTime.now().subtract(const Duration(days: 1)));

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormValid ? _createReservation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: jaune,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Confirmer la réservation',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateDebut() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dateDebut = picked;
        // Réinitialiser la date de fin si elle est avant la nouvelle date de début
        if (_dateFin != null && _dateFin!.isBefore(picked)) {
          _dateFin = null;
        }
        _calculatePrice();
      });
    }
  }

  Future<void> _selectDateFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFin ?? (_dateDebut ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: _dateDebut ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dateFin = picked;
        _calculatePrice();
      });
    }
  }

  void _calculatePrice() {
    if (_dateDebut != null && _dateFin != null) {
      _nombreJours = _dateFin!.difference(_dateDebut!).inDays + 1;
      _prixTotal = _nombreJours * widget.voiture.prixParJour;
    } else {
      _nombreJours = 0;
      _prixTotal = 0.0;
    }
  }

  Future<void> _createReservation() async {
    setState(() => _isLoading = true);

    try {
      final reservation = Reservation(
        userId: widget.userId,
        voitureId: widget.voiture.id!,
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
        prixTotal: _prixTotal,
        statut: StatutRes.pending,
      );

      final reservationId = await _reservationService.insertReservation(reservation);

      if (reservationId > 0) {
        _showSuccessDialog();
      } else {
        throw Exception('Erreur lors de la création de la réservation');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Réservation confirmée !',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: violet,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Votre réservation a été enregistrée avec succès. '
                  'Vous recevrez une confirmation par email.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: grisClair,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt, color: violet, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Référence: #${DateTime.now().millisecondsSinceEpoch}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer la dialog
              Navigator.pop(context); // Retour à l'écran précédent
            },
            child: Text(
              'Retour à l\'accueil',
              style: GoogleFonts.inter(
                color: violet,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        content: Text(
          'Erreur: $error',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.inter(
                color: violet,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}