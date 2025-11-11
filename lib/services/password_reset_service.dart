import 'package:shared_preferences/shared_preferences.dart';

class PasswordResetService {
  static Future<void> saveResetCode(String email, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reset_email', email);
    await prefs.setString('reset_code', code);
  }

  static Future<bool> verifyCode(String email, String enteredCode) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('reset_email');
    final savedCode = prefs.getString('reset_code');

    return savedEmail == email && savedCode == enteredCode;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reset_email');
    await prefs.remove('reset_code');
  }
}
