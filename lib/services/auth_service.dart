import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:prompt_master/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import '../html_universal.dart' as html;
import 'package:flutter/material.dart';

class AuthService {
  static final Logger _log = Logger('AuthService');
  static final String _baseUrl = Config.baseUrl;

  /// ValueNotifier für den JWT Token
  static final ValueNotifier<String?> jwtTokenNotifier = ValueNotifier(null);

  /// Intern: Token in Notifier und persistent speichern
  static Future<void> _saveToken(String? token) async {
    jwtTokenNotifier.value = token;
    if (kIsWeb) {
      if (token == null) {
        html.window.localStorage.remove('jwt_token');
      } else {
        html.window.localStorage['jwt_token'] = token;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      if (token == null) {
        await prefs.remove('jwt_token');
      } else {
        await prefs.setString('jwt_token', token);
      }
    }
  }

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
          await _saveToken(token);
          _log.info('✅ JWT-Token gespeichert.');

          try {
            final userProfile = await fetchUserProfile();
            final userId = userProfile['user']?['id'];

            if (userId != null) {
              if (kIsWeb) {
                html.window.localStorage['user_id'] = userId;
              } else {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_id', userId);
              }
              _log.info('✅ user_id gespeichert: $userId');
            } else {
              _log.warning('⚠️ user_id fehlt im Profil.');
            }
          } catch (e) {
            _log.warning('⚠️ Fehler beim Abrufen des Profils: $e');
          }
        }
      } else {
        final errorMsg =
            body['error'] ?? body['message'] ?? 'Unbekannter Fehler';
        throw Exception('Backend Fehler: $errorMsg');
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
    if (jwtTokenNotifier.value != null) {
      return jwtTokenNotifier.value;
    }
    if (kIsWeb) {
      return html.window.localStorage['jwt_token'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    }
  }

  /// Token & user_id löschen → Logout
  static Future<void> logout() async {
    await _saveToken(null);
    if (kIsWeb) {
      html.window.localStorage.remove('user_id');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
    }
    _log.info('✅ Benutzer abgemeldet, Daten gelöscht.');
  }

  /// Prüfen, ob Benutzer eingeloggt ist
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Optional: user_id direkt abrufen
  static Future<String?> getUserId() async {
    if (kIsWeb) {
      return html.window.localStorage['user_id'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    }
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
        await _saveToken(backendToken);
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

  static const String _githubClientIdWeb = 'Ov23licXnBkr2GAOsSEQ';
  static const String _redirectUriGithubWeb =
      'http://localhost:52141/api/auth/github/callback';

  static const String _githubClientIdAndroid = 'Ov23lihyDNWv2856JvJI';
  static const String _redirectUriGithubAndroid =
      'com.example.promptmaster://callback';

  /// GitHub OAuth Login (dynamisch für Web und Android)
  static Future<void> signInWithGitHub(BuildContext context) async {
    try {
      final String clientId;
      final String redirectUri;
      final String callbackScheme;

      if (kIsWeb) {
        clientId = _githubClientIdWeb;
        redirectUri = _redirectUriGithubWeb;
        callbackScheme = Uri.parse(redirectUri).scheme; // z.B. 'http'
      } else {
        clientId = _githubClientIdAndroid;
        redirectUri = _redirectUriGithubAndroid;
        callbackScheme = 'com.example.promptmaster';
      }

      final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'read:user user:email',
        'allow_signup': 'true',
      });

      print(
        'Starte FlutterWebAuth.authenticate mit URL: ${authUrl.toString()} und Scheme: $callbackScheme',
      );

      if (kIsWeb) {
        // Auf Web-Plattformen leiten wir den Browser direkt zu GitHub um.
        // Nach erfolgreichem Login wird unsere Anwendung mit dem
        // "code"-Parameter neu geladen.
        html.window.location.assign(authUrl.toString());
        return;
      }

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: callbackScheme,
      );
      print('FlutterWebAuth.authenticate erfolgreich, Ergebnis: $result');

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Kein Code von GitHub erhalten');
      }
      print('GitHub Auth Code erhalten: $code');

      await completeGitHubLogin(code);
      print('Navigator-Aufruf wird ausgeführt, token gespeichert.');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
      // Optional: Token aus Notifier prüfen
      if (jwtTokenNotifier.value == null) {
        print('Warnung: JWT Token Notifier hat keinen Wert nach Speicherung');
      } else {
        print('JWT Token Notifier Wert: ${jwtTokenNotifier.value}');
      }
    } catch (e, stacktrace) {
      print('GitHub Login Fehler: $e');
      print(stacktrace);
      rethrow;
    }
  }

  /// Verarbeitet den von GitHub erhaltenen Code (Web-Callback)
  static Future<void> completeGitHubLogin(String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/github-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code, 'platform': 'web'}),
    );

    print('Backend Response Status: ${response.statusCode}');
    print('Backend Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final token = body['token'];

      if (token == null || token.isEmpty) {
        throw Exception('Kein JWT Token vom Backend erhalten');
      }

      await _saveToken(token);
      print('✅ JWT Token gespeichert: $token');
    } else {
      final body = json.decode(response.body);
      throw Exception(
        'Backend Fehler: ${body['error'] ?? body['message'] ?? 'Unbekannter Fehler'}',
      );
    }
  }
}
