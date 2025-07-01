import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:prompt_master/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import '../html_universal.dart' as html;
import 'package:flutter/material.dart';

class AuthService {
  static final String _baseUrl = Config.baseUrl;
  static final ValueNotifier<String?> jwtTokenNotifier = ValueNotifier(null);

  /// Speichert das JWT-Token im lokalen Speicher (SharedPreferences oder LocalStorage)
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

  /// Loggt den Nutzer ein und speichert das JWT-Token
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('unlocked_badges');
          _log.info('✅ JWT-Token gespeichert.');

          try {
            final userProfile = await fetchUserProfile();
            final userId = userProfile['user']?['id'];
            final username = userProfile['user']?['username'];

            if (userId != null) {
              if (kIsWeb) {
                html.window.localStorage['user_id'] = userId;
              } else {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_id', userId);
              }
            }
            if (username != null) {
              if (kIsWeb) {
                html.window.localStorage['username'] = username;
              } else {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', username);
              }
            }
          } catch (e) {}
        }
      } else {
        final errorMsg =
            body['error'] ?? body['message'] ?? 'Unbekannter Fehler';
        throw Exception('Backend Fehler: $errorMsg');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Registriert einen neuen Nutzer und speichert das JWT-Token
  static Future<http.Response> register(
    String email,
    String password,
    String username,
  ) async {
    final url = Uri.parse('$_baseUrl/auth/register');

    try {
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
      } else {
        final body = json.decode(response.body);
        final errorMsg = body['error'] ?? 'Registrierung fehlgeschlagen';
        throw Exception(errorMsg);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Ruft das Profil des aktuell eingeloggten Nutzers ab
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

  /// Gibt das gespeicherte JWT-Token zurück oder null, wenn nicht vorhanden
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

  /// Löscht das JWT-Token und entfernt Nutzerinformationen aus dem lokalen Speicher
  static Future<void> logout() async {
    await _saveToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlocked_badges');
    if (kIsWeb) {
      html.window.localStorage.remove('user_id');
      html.window.localStorage.remove('username');
    } else {
      await prefs.remove('user_id');
      await prefs.remove('username');
    }
  }

  /// Prüft, ob der Nutzer eingeloggt ist (Token vorhanden)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Gibt die Nutzer-ID des aktuell eingeloggten Nutzers zurück
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

  /// Meldet den Nutzer mit Google an und speichert das JWT-Token
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception("Kein Firebase ID Token erhalten.");
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': firebaseIdToken}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final backendToken = body['token'];
        await _saveToken(backendToken);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('unlocked_badges');
        _log.info('✅ Backend JWT-Token gespeichert.');
        try {
          final profile = await fetchUserProfile();
          final userId = profile['user']?['id'];
          final username = profile['user']?['username'];
          if (userId != null) {
            if (kIsWeb) {
              html.window.localStorage['user_id'] = userId;
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_id', userId);
            }
          }
          if (username != null) {
            if (kIsWeb) {
              html.window.localStorage['username'] = username;
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', username);
            }
          }
        } catch (e) {}
      } else {
        final body = json.decode(response.body);
        throw Exception('Backend Login Fehler: ${body['message']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static const String _githubClientIdWeb = 'Ov23licXnBkr2GAOsSEQ';
  static const String _redirectUriGithubWeb =
      'http://localhost:52141/api/auth/github/callback';

  static const String _githubClientIdAndroid = 'Ov23lihyDNWv2856JvJI';
  static const String _redirectUriGithubAndroid =
      'com.example.promptmaster://callback';

  /// Meldet den Nutzer mit GitHub an und speichert das JWT-Token
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

      if (kIsWeb) {
        html.window.location.assign(authUrl.toString());
        return;
      }

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: callbackScheme,
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Kein Code von GitHub erhalten');
      }

      await completeGitHubLogin(code);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
    } catch (e, stacktrace) {
      rethrow;
    }
  }

  /// Vervollständigt den GitHub Login-Prozess und speichert das JWT-Token
  static Future<void> completeGitHubLogin(String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/github-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code, 'platform': 'web'}),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final token = body['token'];

      if (token == null || token.isEmpty) {
        throw Exception('Kein JWT Token vom Backend erhalten');
      }

      await _saveToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('unlocked_badges');
      print('✅ JWT Token gespeichert: $token');
      try {
        final profile = await fetchUserProfile();
        final userId = profile['user']?['id'];
        final username = profile['user']?['username'];
        if (userId != null) {
          if (kIsWeb) {
            html.window.localStorage['user_id'] = userId;
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_id', userId);
          }
        }
        if (username != null) {
          if (kIsWeb) {
            html.window.localStorage['username'] = username;
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username);
          }
        }
      } catch (e) {}
    } else {
      final body = json.decode(response.body);
      throw Exception(
        'Backend Fehler: ${body['error'] ?? body['message'] ?? 'Unbekannter Fehler'}',
      );
    }
  }

  /// Sendet eine E-Mail zum Zurücksetzen des Passworts
  static Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/auth/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (response.statusCode != 200) {
        String errorMsg = 'Unbekannter Fehler';
        try {
          final body = json.decode(response.body);
          errorMsg = body['error'] ?? body['message'] ?? errorMsg;
        } catch (_) {
          errorMsg = 'Fehler: ${response.statusCode}';
        }
        throw Exception(errorMsg);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Setzt das Passwort zurück
  static Future<http.Response> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/auth/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'token': token,
          'newPassword': newPassword,
        }),
      );
      if (response.statusCode != 200) {
        String errorMsg = 'Unbekannter Fehler';
        try {
          final body = json.decode(response.body);
          errorMsg = body['error'] ?? body['message'] ?? errorMsg;
        } catch (_) {
          errorMsg = 'Fehler: ${response.statusCode}';
        }
        throw Exception(errorMsg);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Verifiziert die E-Mail-Adresse des Nutzers
  static Future<http.Response> verifyEmail(String email, String token) async {
    final uri = Uri.parse(
      '$_baseUrl/auth/verify-email',
    ).replace(queryParameters: {'email': email, 'token': token});
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        String errorMsg = 'Unbekannter Fehler';
        try {
          final body = json.decode(response.body);
          errorMsg = body['error'] ?? body['message'] ?? errorMsg;
        } catch (_) {
          errorMsg = 'Fehler: ${response.statusCode}';
        }
        throw Exception(errorMsg);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sendet eine E-Mail zur erneuten Verifizierung der E-Mail-Adresse
  static Future<http.Response> resendVerification(String email) async {
    final url = Uri.parse('$_baseUrl/auth/resend-verification');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (response.statusCode != 200) {
        String errorMsg = 'Unbekannter Fehler';
        try {
          final body = json.decode(response.body);
          errorMsg = body['error'] ?? body['message'] ?? errorMsg;
        } catch (_) {
          errorMsg = 'Fehler: ${response.statusCode}';
        }
        throw Exception(errorMsg);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Gibt den Benutzernamen des aktuell eingeloggten Nutzers zurück
  static Future<String?> getUsername() async {
    if (kIsWeb) {
      return html.window.localStorage['username'];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    }
  }
}
