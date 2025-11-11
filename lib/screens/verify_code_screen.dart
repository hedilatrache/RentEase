import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/password_reset_service.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  void _verifyCode() async {
    final enteredCode = _codeController.text.trim();

    if (enteredCode.isEmpty || enteredCode.length != 6) {
      _showErrorSnackbar('Code invalide', 'Veuillez entrer un code à 6 chiffres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await PasswordResetService.verifyCode(widget.email, enteredCode);

      if (isValid) {
        _showSuccessSnackbar('Succès', 'Code vérifié avec succès');
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: widget.email),
          ),
        );
      } else {
        _showErrorSnackbar('Erreur', 'Code incorrect. Veuillez réessayer.');
      }
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
          'Vérification du code',
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

              // Icône de vérification
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: violetClair,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: 40,
                    color: violet,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre principal
              Text(
                'Vérification du code',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: violet,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre avec email
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Entrez le code à 6 chiffres envoyé à ',
                    ),
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: violet,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Champ code
              _buildCodeField(),
              const SizedBox(height: 32),

              // Bouton de vérification
              _buildVerifyButton(),
              const SizedBox(height: 20),

              // Informations supplémentaires
              _buildInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code de vérification',
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
            controller: _codeController,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: '123456',
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.lock_outline, color: violet),
            ),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: violet,
              letterSpacing: 2,
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Code à 6 chiffres',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyCode,
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
            Icon(Icons.verified_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              'Vérifier le code',
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
            Icons.timer_outlined,
            color: violet,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Code temporaire',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ce code est valable pendant 15 minutes pour des raisons de sécurité.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}