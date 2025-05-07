import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class AuthService {
  static const String baseUrl = Config.baseUrl;

  static Future<http.Response> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return response; // Erfolgreiche Antwort
      } else {
        // Fehlerbehandlung für den Fall, dass der Statuscode nicht 200 ist
        print('Login fehlgeschlagen: ${response.statusCode}');
        print('Fehlerdetails: ${response.body}');
        throw Exception('Login fehlgeschlagen');
      }
    } catch (error) {
      print('Fehler bei der Anfrage: $error');
      throw Exception('Fehler bei der Anfrage');
    }
  }

  static Future<http.Response> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return response; // Erfolgreiche Antwort
      } else {
        // Fehlerbehandlung für den Fall, dass der Statuscode nicht 200 ist
        print('Registrierung fehlgeschlagen: ${response.statusCode}');
        print('Fehlerdetails: ${response.body}');
        throw Exception('Registrierung fehlgeschlagen');
      }
    } catch (error) {
      print('Fehler bei der Anfrage: $error');
      throw Exception('Fehler bei der Anfrage');
    }
  }
}
