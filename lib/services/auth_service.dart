import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:logging/logging.dart';

class AuthService {
  static final Logger _log = Logger('AuthService');
  static String baseUrl = Config.baseUrl;

  static Future<http.Response> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        final body = json.decode(response.body);
        final errorMsg = body['error'] ?? 'Unbekannter Fehler';
        throw errorMsg;
      }
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<http.Response> register(String email, String password) async {
    try {
      print('Sende Registrierungsanfrage für $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print('Registrierung erfolgreich für $email');
        return response;
      } else {
        print('Registrierung fehlgeschlagen: ${response.statusCode}');
        print('Fehlerdetails: ${response.body}');
        throw Exception('Registrierung fehlgeschlagen');
      }
    } catch (error) {
      print('Fehler bei der Registrierungsanfrage: $error');
      throw Exception('Fehler bei der Registrierungsanfrage');
    }
  }
}
