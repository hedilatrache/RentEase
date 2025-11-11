import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/email_service.dart';
import '../services/password_reset_service.dart';
import '../database/database_helper.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final EmailService _emailService = EmailService();
  final DB _databaseHelper = DB();

  bool _isLoading = false;

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  String generateCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  void _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackbar('Erreur', 'Veuillez entrer votre email');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackbar('Erreur', 'Veuillez entrer un email valide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _databaseHelper.getUserByEmail(email);
      if (user == null) {
        _showErrorSnackbar('Erreur', 'Aucun compte trouvé avec cet email');
        return;
      }

      final code = generateCode();
      await PasswordResetService.saveResetCode(email, code);

      await _emailService.sendEmail(
        to: email,
        subject: 'Réinitialisation de mot de passe RentEase',
        body:
        'Bonjour,\n\nVoici votre code de vérification : $code\n\nEntrez-le dans l\'application pour réinitialiser votre mot de passe.',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyCodeScreen(email: email),
        ),
      );
    } catch (e) {
      _showErrorSnackbar('Erreur', 'Une erreur est survenue: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mot de passe oublié',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Icône et titre
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: violetClair,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 40,
                    color: violet,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre principal
              Text(
                'Réinitialisation du mot de passe',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              Text(
                'Entrez votre adresse email pour recevoir un code de vérification',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Champ email
              _buildEmailField(),
              const SizedBox(height: 32),

              // Bouton d'envoi
              _buildSendButton(),
              const SizedBox(height: 20),

              // Informations supplémentaires
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse email',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: violet,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: grisClair,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: violetClair,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: 'exemple@email.com',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.email_outlined, color: violet),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendResetLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: jaune,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: violet.withOpacity(0.3),
        ),
        child: _isLoading
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(jaune),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Envoyer le code',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: violetClair.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: violetClair,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: violet,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Un code de vérification à 6 chiffres vous sera envoyé par email.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}