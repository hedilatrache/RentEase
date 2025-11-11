import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../services/password_reset_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final DB _db = DB();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  void _resetPassword() async {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      _showErrorSnackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    if (pass.length < 6) {
      _showErrorSnackbar('Erreur', 'Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    if (pass != confirm) {
      _showErrorSnackbar('Erreur', 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _db.updatePassword(widget.email, pass);
      await PasswordResetService.clear();

      _showSuccessSnackbar('Succès', 'Mot de passe mis à jour avec succès');

      await Future.delayed(const Duration(milliseconds: 1500));

      Navigator.popUntil(context, (route) => route.isFirst);
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

  void _showSuccessSnackbar(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green,
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
          'Nouveau mot de passe',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Icône de sécurité
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: violetClair,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security_outlined,
                    size: 40,
                    color: violet,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre principal
              Text(
                'Nouveau mot de passe',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              Text(
                'Créez un nouveau mot de passe sécurisé pour votre compte',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Champ nouveau mot de passe
              _buildPasswordField(),
              const SizedBox(height: 20),

              // Champ confirmation mot de passe
              _buildConfirmPasswordField(),
              const SizedBox(height: 32),

              // Bouton de confirmation
              _buildConfirmButton(),
              const SizedBox(height: 20),

              // Indications de sécurité
              _buildSecurityTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nouveau mot de passe',
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
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: 'Entrez votre nouveau mot de passe',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.lock_outline, color: violet),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: violet,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmer le mot de passe',
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
            controller: _confirmController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: 'Confirmez votre mot de passe',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.lock_outline, color: violet),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: violet,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
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
            Icon(Icons.check_circle_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              'Confirmer le mot de passe',
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

  Widget _buildSecurityTips() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: violet,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseils de sécurité',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: violet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Au moins 6 caractères\n• Évitez les mots de passe courants\n• Utilisez des chiffres et des lettres',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}