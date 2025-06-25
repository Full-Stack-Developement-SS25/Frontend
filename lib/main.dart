import 'dart:html' as html;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prompt_master/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

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

  void _checkInitialLoginStatus() {
    final token = html.window.localStorage['jwt_token'];
    setState(() {
      _loggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PromptMaster',
      theme: ThemeData(),
      home: _loggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
