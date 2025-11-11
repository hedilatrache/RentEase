import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentease/models/user.dart';
import 'package:rentease/database/database_helper.dart';
import 'package:rentease/screens/login.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DB _databaseHelper = DB();
  late User _currentUser;
  bool _isEditing = false;

  // Contrôleurs pour l'édition
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  // ✅ CHARTE GRAPHIQUE DE RENTEASE
  final Color violet = const Color(0xFF7201FE);
  final Color violetClair = const Color(0xFFD9B9FF);
  final Color jaune = const Color(0xFFFFBB00);
  final Color grisClair = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nomController.text = _currentUser.nom;
    _prenomController.text = _currentUser.prenom;
    _emailController.text = _currentUser.email;
    _telephoneController.text = _currentUser.telephone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: violet,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _toggleEditing,
              tooltip: 'Modifier le profil',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section Avatar et Nom
            _buildProfileHeader(),
            const SizedBox(height: 32),

            // Section Informations
            _buildInfoSection(),
            const SizedBox(height: 24),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: violetClair,
            shape: BoxShape.circle,
            border: Border.all(
              color: violet,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: violet,
          ),
        ),
        const SizedBox(height: 16),

        // Nom et Prénom
        Text(
          '${_currentUser.prenom} ${_currentUser.nom}',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        const SizedBox(height: 8),

        // Email
        Text(
          _currentUser.email,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),

        // Date d'inscription
        Text(
          'Membre depuis ${_formatDate(_currentUser.dateInscription)}',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: grisClair,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: violetClair,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations Personnelles',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: violet,
            ),
          ),
          const SizedBox(height: 20),

          // Nom - ✅ CORRIGÉ : Toujours passer un Widget
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Nom',
            value: _isEditing
                ? _buildEditableField(_nomController, 'Nom')
                : _buildStaticField(_currentUser.nom), // ✅ Utilise _buildStaticField
          ),
          const SizedBox(height: 16),

          // Prénom - ✅ CORRIGÉ
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Prénom',
            value: _isEditing
                ? _buildEditableField(_prenomController, 'Prénom')
                : _buildStaticField(_currentUser.prenom), // ✅ Utilise _buildStaticField
          ),
          const SizedBox(height: 16),

          // Email - ✅ CORRIGÉ
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _isEditing
                ? _buildEditableField(_emailController, 'Email')
                : _buildStaticField(_currentUser.email), // ✅ Utilise _buildStaticField
          ),
          const SizedBox(height: 16),

          // Téléphone - ✅ CORRIGÉ
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: _isEditing
                ? _buildEditableField(_telephoneController, 'Téléphone')
                : _buildStaticField(_currentUser.telephone), // ✅ Utilise _buildStaticField
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget value, // ✅ Déjà correct - attend un Widget
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: violet,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              value, // ✅ Ici on utilise le Widget directement
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: violetClair,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: hintText,
          border: InputBorder.none,
        ),
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildStaticField(String value) {
    return Text(
      value,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing) ...[
          // Boutons Sauvegarder et Annuler en mode édition
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: violet,
                foregroundColor: jaune,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Sauvegarder',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _cancelEditing,
              style: OutlinedButton.styleFrom(
                foregroundColor: violet,
                side: BorderSide(color: violet),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Annuler',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ] else ...[
          // Bouton Déconnexion en mode visualisation
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _showLogoutDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Déconnexion',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEditing() {
    _initializeControllers(); // Réinitialiser les valeurs
    setState(() {
      _isEditing = false;
    });
  }

  void _saveProfile() async {
    // Validation
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telephoneController.text.isEmpty) {
      _showErrorSnackbar('Erreur', 'Veuillez remplir tous les champs');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showErrorSnackbar('Erreur', 'Veuillez entrer un email valide');
      return;
    }

    try {
      // Vérifier si l'email existe déjà (sauf pour l'utilisateur actuel)
      if (_emailController.text != _currentUser.email) {
        final emailExists = await _databaseHelper.emailExists(_emailController.text);
        if (emailExists) {
          _showErrorSnackbar('Erreur', 'Cet email est déjà utilisé');
          return;
        }
      }

      // Mettre à jour l'utilisateur
      final updatedUser = User(
        id: _currentUser.id,
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        password: _currentUser.password, // Garder le même mot de passe
        dateInscription: _currentUser.dateInscription,
      );

      final result = await _databaseHelper.updateUser(updatedUser);

      if (result > 0) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
        });
        _showSuccessSnackbar('Succès', 'Profil mis à jour avec succès!');
      } else {
        _showErrorSnackbar('Erreur', 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur', 'Une erreur est survenue: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Déconnexion',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: violet,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: GoogleFonts.inter(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: violet,
              foregroundColor: jaune,
            ),
            child: Text(
              'Déconnexion',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }
}