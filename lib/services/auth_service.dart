import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AuthService {
  static final Logger _log = Logger('AuthService');
  static final String _baseUrl = Config.baseUrl;

  /// Login-Methode: sendet Login-Request, speichert JWT-Token bei Erfolg
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = body['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          _log.info('JWT-Token erfolgreich gespeichert.');
        } else {
          _log.warning('Token nicht in der Antwort enthalten.');
        }
      } else {
        final errorMsg = body['error'] ?? 'Unbekannter Fehler beim Login';
        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      _log.severe('Login fehlgeschlagen: $e');
      rethrow;
    }
  }

  /// Registrierungsmethode: sendet Registrierungs-Request
  static Future<http.Response> register(
      String email,
      String password,
      String username,
      ) async {
    final url = Uri.parse('$_baseUrl/auth/register');

    try {
      _log.info('Registrierung für $email wird gestartet.');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        _log.info('Registrierung erfolgreich für $email.');
      } else {
        final body = json.decode(response.body);
        final errorMsg = body['error'] ?? 'Registrierung fehlgeschlagen';
        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      _log.severe('Fehler bei der Registrierung: $e');
      rethrow;
    }
  }

  /// Nutzerprofil abrufen
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Kein Token vorhanden. Benutzer nicht eingeloggt.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Fehler beim Abrufen des Profils: ${response.body}');
    }
  }

  /// Token abrufen
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Token löschen und Logout durchführen
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _log.info('JWT-Token gelöscht. Benutzer abgemeldet.');
  }

  /// Prüfen, ob Benutzer eingeloggt ist
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
