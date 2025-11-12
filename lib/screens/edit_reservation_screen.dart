import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/reservation.dart';
import '../models/voiture.dart';
import '../services/reservation_service.dart';

class EditReservationScreen extends StatefulWidget {
  final Reservation reservation;
  final Voiture voiture;
  final int userId;

  const EditReservationScreen({
    Key? key,
    required this.reservation,
    required this.voiture,
    required this.userId,
  }) : super(key: key);

  @override
  _EditReservationScreenState createState() => _EditReservationScreenState();
}

class _EditReservationScreenState extends State<EditReservationScreen> {
  final ReservationService _reservationService = ReservationService();

  late DateTime _dateDebut;
  late DateTime _dateFin;
  int _nombreJours = 0;
  double _prixTotal = 0.0;
  double _prixInitial = 0.0;
  bool _isLoading = false;
  bool _hasChanges = false;

  // ✅ CHARTE GRAPHIQUE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _dateDebut = widget.reservation.dateDebut;
    _dateFin = widget.reservation.dateFin;
    _prixInitial = widget.reservation.prixTotal;
    _calculatePrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Modifier la réservation',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveChanges,
              tooltip: 'Sauvegarder',
            ),
        ],
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

            // Dates actuelles
            _buildCurrentDates(),

            const SizedBox(height: 24),

            // Nouvelle sélection de dates
            _buildDateSelection(),

            const SizedBox(height: 24),

            // Comparaison des prix
            _buildPriceComparison(),

            const SizedBox(height: 32),

            // Boutons d'action
            _buildActionButtons(),
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
              image: widget.voiture.image.isNotEmpty
                  ? DecorationImage(
                image: FileImage(File(widget.voiture.image)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: widget.voiture.image.isEmpty
                ? const Icon(Icons.directions_car, color: Colors.white)
                : null,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.voiture.annee} • ${widget.voiture.categorie.nom}',
                  style: GoogleFonts.inter(
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

  Widget _buildCurrentDates() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Dates actuelles',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDateInfo('Début', dateFormat.format(widget.reservation.dateDebut)),
          _buildDateInfo('Fin', dateFormat.format(widget.reservation.dateFin)),
          _buildDateInfo('Prix initial', '${_prixInitial.toStringAsFixed(2)}€'),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
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
          'Nouvelles dates',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        const SizedBox(height: 16),

        // Date de début
        _buildDateField(
          label: 'Nouvelle date de début',
          date: _dateDebut,
          onTap: () => _selectDateDebut(),
        ),

        const SizedBox(height: 16),

        // Date de fin
        _buildDateField(
          label: 'Nouvelle date de fin',
          date: _dateFin,
          onTap: () => _selectDateFin(),
        ),

        // Validation des dates
        ..._buildDateValidation(),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: violet.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: violet.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: violet, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(Icons.edit, color: violet, size: 18),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDateValidation() {
    final List<Widget> widgets = [];
    String message = '';
    Color color = Colors.green;
    bool isValid = true;

    if (_dateFin.isBefore(_dateDebut)) {
      message = 'La date de fin doit être après la date de début';
      color = Colors.red;
      isValid = false;
    } else if (_dateDebut.isBefore(DateTime.now())) {
      message = 'La date de début ne peut pas être dans le passé';
      color = Colors.red;
      isValid = false;
    } else if (_dateDebut.isBefore(widget.reservation.dateDebut)) {
      message = 'Vous ne pouvez pas avancer la date de début';
      color = Colors.orange;
      isValid = false;
    } else if (_dateDebut == widget.reservation.dateDebut && _dateFin == widget.reservation.dateFin) {
      message = 'Aucun changement de dates';
      color = Colors.grey;
    } else {
      message = 'Nouvelle période valide';
      color = Colors.green;
    }

    widgets.addAll([
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ]);

    return widgets;
  }

  Widget _buildPriceComparison() {
    final difference = _prixTotal - _prixInitial;
    final isMoreExpensive = difference > 0;
    final isLessExpensive = difference < 0;
    final hasPriceChange = difference != 0;

    if (!hasPriceChange && !_hasChanges) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: violetClair.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: violetClair),
      ),
      child: Column(
        children: [
          _buildPriceLine('Ancien prix', '${_prixInitial.toStringAsFixed(2)}€'),
          _buildPriceLine('Nouveau prix', '${_prixTotal.toStringAsFixed(2)}€'),
          const Divider(),
          _buildPriceLine(
            isMoreExpensive ? 'Supplément' : isLessExpensive ? 'Économie' : 'Aucun changement',
            '${difference.abs().toStringAsFixed(2)}€',
            isTotal: true,
            color: isMoreExpensive ? Colors.red : isLessExpensive ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              color: color ?? (isTotal ? violet : Colors.grey[600]),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              color: color ?? (isTotal ? violet : Colors.black),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final bool hasDateChanges = _dateDebut != widget.reservation.dateDebut ||
        _dateFin != widget.reservation.dateFin;
    final bool isFormValid = hasDateChanges &&
        _dateFin.isAfter(_dateDebut) &&
        !_dateDebut.isBefore(DateTime.now().subtract(const Duration(days: 1))) &&
        !_dateDebut.isBefore(widget.reservation.dateDebut);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isFormValid && !_isLoading ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: violet,
              foregroundColor: jaune,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(
              'Sauvegarder les modifications',
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
          height: 56,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateDebut() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: widget.reservation.dateDebut,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dateDebut = picked;
        if (_dateFin.isBefore(picked) || _dateFin.isAtSameMomentAs(picked)) {
          _dateFin = picked.add(const Duration(days: 1));
        }
        _calculatePrice();
        _checkChanges();
      });
    }
  }

  Future<void> _selectDateFin() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFin,
      firstDate: _dateDebut.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _dateFin = picked;
        _calculatePrice();
        _checkChanges();
      });
    }
  }

  void _calculatePrice() {
    _nombreJours = _dateFin.difference(_dateDebut).inDays + 1;
    _prixTotal = _nombreJours * widget.voiture.prixParJour;
  }

  void _checkChanges() {
    final hasDateChanges = _dateDebut != widget.reservation.dateDebut ||
        _dateFin != widget.reservation.dateFin;
    setState(() => _hasChanges = hasDateChanges);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      // Vérifier si les dates ont changé
      final datesChanged = _dateDebut != widget.reservation.dateDebut ||
          _dateFin != widget.reservation.dateFin;

      if (datesChanged) {
        // Vérifier la disponibilité pour les nouvelles dates en excluant la réservation actuelle
        final isAvailable = await _reservationService.checkDisponibiliteForEdit(
          voitureId: widget.voiture.id!,
          dateDebut: _dateDebut,
          dateFin: _dateFin,
          currentReservationId: widget.reservation.id!,
        );

        if (!isAvailable) {
          throw Exception('Le véhicule n\'est pas disponible pour ces dates');
        }
      }

      // Mettre à jour la réservation
      await _reservationService.updateUserReservationDates(
        reservationId: widget.reservation.id!,
        newDateDebut: _dateDebut,
        newDateFin: _dateFin,
        newPrixTotal: _prixTotal,
      );

      // Retour à l'écran précédent avec un message de succès
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Réservation modifiée avec succès',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Erreur: $e');
      }
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 30),
            const SizedBox(width: 8),
            Text(
              'Erreur',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(
          message,
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