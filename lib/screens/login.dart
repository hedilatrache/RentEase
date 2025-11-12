import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentease/screens/inscription.dart';
import 'package:rentease/database/database_helper.dart';
import '../models/user.dart';
import '../services/session_manager.dart';
import 'forgot_password_screen.dart';
import 'main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final DB _databaseHelper = DB();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Welcome back text
                Text(
                  'Welcome back,',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: violet,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Discover Limitless Choices and Unmatched Convergence.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Email Field
                _buildEmailField(),

                const SizedBox(height: 20),

                // Password Field
                _buildPasswordField(),

                const SizedBox(height: 16),

                // Remember Me and Forgot Password
                _buildRememberAndForgot(),

                const SizedBox(height: 40),

                // Sign In Button
                _buildSignInButton(context),

                const SizedBox(height: 30),

                // Create Account
                _buildCreateAccount(context),

                const SizedBox(height: 30),

                // Ligne de séparation "or sign in with"
                _buildOrSignInWith(),

                const SizedBox(height: 30),

                // Boutons de connexion sociale
                _buildSocialLoginButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrSignInWith() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or sign in with',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton Google
        _buildSocialButton(
          iconPath: 'Assets/images/google.png', // ✅ Corrigé le chemin
          onPressed: _signInWithGoogle,
          color: Colors.white,
        ),
        const SizedBox(width: 20),

        // Bouton Facebook
        _buildSocialButton(
          iconPath: 'Assets/images/facebook.png', // ✅ Corrigé le chemin
          onPressed: _signInWithFacebook,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                iconPath.contains('google') ? Icons.g_mobiledata : Icons.facebook,
                size: 24,
                color: iconPath.contains('google') ? const Color(0xFF4285F4) : const Color(0xFF1877F2),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ CORRIGÉ : Connexion avec Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _showErrorSnackbar('Annulé', 'Connexion Google annulée');
        return;
      }

      // Récupérer les informations de base
      final email = googleUser.email;
      final displayName = googleUser.displayName ?? 'Utilisateur Google';

      // Séparer le nom complet en prénom et nom
      String prenom = displayName;
      String nom = '';
      final nameParts = displayName.split(' ');
      if (nameParts.length > 1) {
        prenom = nameParts.first;
        nom = nameParts.sublist(1).join(' ');
      }

      // Trouver ou créer l'utilisateur
      final User? user = await _databaseHelper.findOrCreateUser(email, nom, prenom);

      if (user != null) {
        await _handleSocialLoginSuccess(user, 'Google');
      } else {
        _showErrorSnackbar('Erreur', 'Impossible de créer le compte');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur Google', 'Une erreur est survenue: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ CORRIGÉ : Connexion avec Facebook
  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final userData = await _facebookAuth.getUserData(
          fields: "email,name,first_name,last_name",
        );

        // Récupérer les informations
        final email = userData['email'] as String?;
        final firstName = userData['first_name'] as String? ?? '';
        final lastName = userData['last_name'] as String? ?? '';
        final fullName = userData['name'] as String? ?? 'Utilisateur Facebook';

        // Utiliser l'email ou générer un email basé sur le nom
        final userEmail = email ?? '${fullName.replaceAll(' ', '').toLowerCase()}@facebook.com';

        // Déterminer prénom et nom
        String prenom = firstName.isNotEmpty ? firstName : fullName;
        String nom = lastName.isNotEmpty ? lastName : '';

        if (firstName.isEmpty && lastName.isEmpty) {
          final nameParts = fullName.split(' ');
          prenom = nameParts.isNotEmpty ? nameParts.first : 'Utilisateur';
          nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Facebook';
        }

        // Trouver ou créer l'utilisateur
        final User? user = await _databaseHelper.findOrCreateUser(userEmail, nom, prenom);

        if (user != null) {
          await _handleSocialLoginSuccess(user, 'Facebook');
        } else {
          _showErrorSnackbar('Erreur', 'Impossible de créer le compte');
        }
      } else {
        _showErrorSnackbar('Erreur Facebook', 'Connexion annulée ou échouée');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur Facebook', 'Une erreur est survenue: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ NOUVELLE MÉTHODE : Gérer le succès de la connexion sociale
  Future<void> _handleSocialLoginSuccess(User user, String platform) async {
    // Sauvegarder la session
    await SessionManager.saveLoginState(
      rememberMe: true, // Toujours se souvenir pour les connexions sociales
      userId: user.id!,
      userEmail: user.email,
    );

    _showSuccessSnackbar('Succès', 'Bienvenue ${user.prenom} via $platform!');

    await Future.delayed(const Duration(milliseconds: 1500));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(user: user),
      ),
    );
  }

  // ... Les autres méthodes restent inchangées ...
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-Mail',
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
              hintText: 'Enter your email',
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
              hintText: 'Enter your password',
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

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: violet,
                    width: 2,
                  ),
                  color: _rememberMe ? violet : Colors.transparent,
                ),
                child: _rememberMe
                    ? Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Text(
                'Remember Me',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: violet,
                ),
              ),
            ),
          ],
        ),

        // Forget Password?
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(),
              ),
            );
          },
          child: Text(
            'Forget Password?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: violet,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
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
            : Text(
          'Sign in',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccount(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InscriptionPage(),
            ),
          );
        },
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Don't have an account? ",
                style: GoogleFonts.inter(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: 'Create Account',
                style: GoogleFonts.inter(
                  color: violet,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation basique
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Error', 'Please fill in all fields');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackbar('Error', 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _databaseHelper.authenticateUser(email, password);

      if (user != null) {
        await SessionManager.saveLoginState(
          rememberMe: _rememberMe,
          userId: user.id!,
          userEmail: user.email,
        );

        _showSuccessSnackbar('Success', 'Welcome back, ${user.prenom}!');

        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScreen(user: user),
          ),
        );
      } else {
        _showErrorSnackbar('Error', 'Invalid email or password');
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}