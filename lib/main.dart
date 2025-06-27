import 'html_universal.dart' as html;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prompt_master/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/reset_password_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();

    // Initialer Status prüfen (z.B. Token im SharedPreferences oder localStorage)
    _checkInitialLoginStatus();

    html.window.onStorage.listen((event) {
      if (event.key == 'jwt_token') {
        if (event.newValue != null) {
          print('Token gesetzt, Nutzer eingeloggt!');
          setState(() {
            _loggedIn = true;
          });
        } else {
          print('Token gelöscht, Nutzer ausgeloggt!');
          setState(() {
            _loggedIn = false;
          });
        }
      }
    });
  }

  void _checkInitialLoginStatus() async {
    final token = html.window.localStorage['jwt_token'];
    if (token != null) {
      setState(() {
        _loggedIn = true;
      });
      return;
    }

    // Prüfen, ob wir von GitHub mit einem Code zurückgeleitet wurden
    if (kIsWeb && Uri.base.path == '/api/auth/github/callback') {
      final code = Uri.base.queryParameters['code'];
      if (code != null) {
        try {
          await AuthService.completeGitHubLogin(code);
          setState(() {
            _loggedIn = true;
          });
          // Query-Parameter aus der URL entfernen
          html.window.history.replaceState(null, '', '/');
          return;
        } catch (e) {
          print('GitHub Callback Fehler: $e');
        }
      }
    }

    setState(() {
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptMaster',
      theme: ThemeData(),
      initialRoute: _loggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
