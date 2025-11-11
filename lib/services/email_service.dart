import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    // ⚠️ Mets ici ton adresse Gmail et ton mot de passe d’application
    final username = 'stakwa336@gmail.com';
    final password = 'iabspyodwscbunll';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'RentEase Support')
      ..recipients.add(to)
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
      print('✅ Email envoyé à $to');
    } on MailerException catch (e) {
      print('❌ Erreur lors de l’envoi de l’email: $e');
      rethrow;
    }
  }
}
