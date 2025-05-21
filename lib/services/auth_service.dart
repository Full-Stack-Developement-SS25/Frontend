import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AuthService {
  static final Logger _log = Logger('AuthService');
  static final String _baseUrl = Config.baseUrl;

  /// Login-Methode: sendet Login-Request, speichert JWT-Token & user_id bei Erfolg
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
          _log.info('✅ JWT-Token gespeichert.');

          // ⬇ Jetzt: User-Profil abrufen, um user_id zu speichern
          try {
            final userProfile = await fetchUserProfile();
            final userId = userProfile['user']?['id'];

            if (userId != null) {
              await prefs.setString('user_id', userId);
              _log.info('✅ user_id gespeichert: $userId');
            } else {
              _log.warning('⚠️ user_id fehlt im Profil.');
            }
          } catch (e) {
            _log.warning('⚠️ Fehler beim Abrufen des Profils: $e');
          }
        } else {
          _log.warning('⚠️ Token fehlt in Login-Antwort.');
        }
      } else {
        final errorMsg = body['error'] ?? 'Unbekannter Fehler beim Login';
        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      _log.severe('❌ Login fehlgeschlagen: $e');
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
        _log.info('✅ Registrierung erfolgreich für $email.');
      } else {
        final body = json.decode(response.body);
        final errorMsg = body['error'] ?? 'Registrierung fehlgeschlagen';
        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      _log.severe('❌ Fehler bei der Registrierung: $e');
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

  /// Token & user_id löschen → Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    _log.info('✅ Benutzer abgemeldet, Daten gelöscht.');
  }

  /// Prüfen, ob Benutzer eingeloggt ist
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Optional: user_id direkt abrufen
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? '815351996637-7726jkhsk9ib1n2f1frgn2i3ejvmfmq4.apps.googleusercontent.com'
            : null,
  );

  Future<void> signInWithGoogle() async {
    try {
      // Google Sign-In starten
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _log.info('Google Sign-In abgebrochen');
        return;
      }

      // Authentifizierungsdetails holen
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase Credential erstellen
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase Login mit Credential
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Firebase ID Token holen
      String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception("Kein Firebase ID Token erhalten.");
      }

      _log.info('Firebase ID Token erhalten: $firebaseIdToken');

      // Backend mit Firebase Token anfragen (zur eigenen JWT-Erstellung)
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': firebaseIdToken}),
      );

      print('Statuscode: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final backendToken = body['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', backendToken);
        _log.info('✅ Backend JWT-Token gespeichert.');
      } else {
        final body = json.decode(response.body);
        throw Exception('Backend Login Fehler: ${body['message']}');
      }
    } catch (e) {
      _log.severe('Fehler bei Google Sign-In: $e');
      rethrow;
    }
  }
}
