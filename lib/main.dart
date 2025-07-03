import 'dart:developer';

import 'html_universal.dart' as html;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prompt_master/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/reset_password_screen.dart';
import 'screens/verify_email_screen.dart';
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

    _checkInitialLoginStatus();

    html.window.onStorage.listen((event) {
      if (event.key == 'jwt_token') {
        if (event.newValue != null) {
          setState(() {
            _loggedIn = true;
          });
        } else {
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

    if (kIsWeb && Uri.base.path == '/api/auth/github/callback') {
      final code = Uri.base.queryParameters['code'];
      if (code != null) {
        try {
          await AuthService.completeGitHubLogin(code);
          setState(() {
            _loggedIn = true;
          });
          html.window.history.replaceState(null, '', '/');
          return;
        } catch (e, st) {
          log('Fehler: $e', stackTrace: st);
        }
      }
    }

    setState(() {
      _loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    Widget home;
    if (kIsWeb) {
      if (uri.fragment.startsWith('/reset-password') ||
          uri.path == '/reset-password') {
        home = const ResetPasswordScreen();
      } else if (uri.fragment.startsWith('/verify-email') ||
          uri.path == '/verify-email') {
        home = const VerifyEmailScreen();
      } else {
        home = _loggedIn ? const MainNavigation() : const LoginScreen();
      }
    } else {
      home = _loggedIn ? const MainNavigation() : const LoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptMaster',
      theme: ThemeData(),
      home: home,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}
