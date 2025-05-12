import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'package:logging/logging.dart';

class AuthService {
  static final Logger _log = Logger('AuthService');
  static String baseUrl = Config.baseUrl;

  static Future<http.Response> login(String email, String password) async {
    try {
      _log.info('Sende Login-Anfrage für $email');
      print("Base URL: $baseUrl");
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _log.info('Login erfolgreich für $email');
        return response;
      } else {
        _log.warning('Login fehlgeschlagen: ${response.statusCode}');
        _log.warning('Fehlerdetails: ${response.body}');
        throw Exception('Login fehlgeschlagen');
      }
    } catch (error) {
      _log.severe('Fehler bei der Login-Anfrage: $error');
      throw Exception('Fehler bei der Login-Anfrage');
    }
  }

  static Future<http.Response> register(String email, String password) async {
    try {
      _log.info('Sende Registrierungsanfrage für $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _log.info('Registrierung erfolgreich für $email');
        return response;
      } else {
        _log.warning('Registrierung fehlgeschlagen: ${response.statusCode}');
        _log.warning('Fehlerdetails: ${response.body}');
        throw Exception('Registrierung fehlgeschlagen');
      }
    } catch (error) {
      _log.severe('Fehler bei der Registrierungsanfrage: $error');
      throw Exception('Fehler bei der Registrierungsanfrage');
    }
  }
}
