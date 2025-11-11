import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyRememberMe = 'rememberMe';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';

  // Sauvegarder l'état de connexion
  static Future<void> saveLoginState({
    required bool rememberMe,
    required int userId,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyRememberMe, rememberMe);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, userEmail);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    // Si Remember Me est activé, l'utilisateur reste connecté
    // Sinon, on le déconnecte
    if (isLoggedIn && !rememberMe) {
      await clearSession();
      return false;
    }

    return isLoggedIn;
  }

  // Récupérer l'ID de l'utilisateur
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // Récupérer l'email de l'utilisateur
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  // Vérifier si Remember Me est activé
  static Future<bool> isRememberMeActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  // Déconnexion - Effacer la session
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    // On ne supprime PAS rememberMe pour qu'il se souvienne du choix
  }

  // Déconnexion complète (y compris Remember Me)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime TOUT
  }
}