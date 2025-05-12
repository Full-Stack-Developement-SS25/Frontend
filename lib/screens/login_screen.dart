import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'main_navigation.dart';
import './/utils/app_colors.dart';
import './/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false; // Zum Anzeigen/Ausblenden des Passworts
  bool isLoginMode =
      true; // Zur Unterscheidung zwischen Login und Registrierung

  // Methode zur Überprüfung der E-Mail
  bool isEmailValid(String email) {
    return EmailValidator.validate(email);
  }

  // Methode zur Überprüfung des Passworts
  bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  // Methode zur Registrierung/Login
  void handleSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    try {
      final response =
          isLoginMode
              ? await AuthService.login(email, password)
              : await AuthService.register(email, password);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLoginMode
                  ? "Erfolgreich eingeloggt als $email"
                  : "Registrierung erfolgreich. Willkommen $email!",
            ),
          ),
        );

        // TODO: Token speichern, falls nötig: responseData["token"]
        _navigateToDashboard(context);
      } else {
        final errorMsg =
            jsonDecode(response.body)['message'] ?? "Unbekannter Fehler";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fehler: $errorMsg")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Netzwerkfehler oder ungültige Antwort: $e")),
      );
    }
  }

  // Methode für Passwort vergessen
  void handleForgotPassword() {
    final email = emailController.text.trim();
    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitte eine gültige E-Mail-Adresse eingeben!")),
      );
      return;
    }

    // Hier sollte die Logik für das Zurücksetzen des Passworts (z.B. per E-Mail) implementiert werden
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Ein Link zum Zurücksetzen des Passworts wurde an Ihre E-Mail gesendet.",
        ),
      ),
    );
    Navigator.pop(context); // Zurück zum Login-Bildschirm
  }

  // Navigation zum Dashboard
  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Willkommen bei PromptMaster',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.g_mobiledata, size: 32),
                  label: const Text(
                    'Mit Google anmelden',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () => _navigateToDashboard(context),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.apple, size: 28),
                  label: const Text(
                    'Mit Apple anmelden',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () => _navigateToDashboard(context),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Oder registriere dich mit deiner E-Mail:',
                  style: TextStyle(color: AppColors.accent, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          hintText: 'E-Mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte eine E-Mail eingeben.';
                          } else if (!isEmailValid(value)) {
                            return 'Bitte eine gültige E-Mail-Adresse eingeben.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.white,
                          hintText: 'Passwort',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte ein Passwort eingeben.';
                          } else if (!isPasswordValid(value)) {
                            return 'Das Passwort muss mindestens 6 Zeichen lang sein.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(isLoginMode ? 'Anmelden' : 'Registrieren'),
                        onPressed: handleSubmit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLoginMode = !isLoginMode;
                    });
                  },
                  child: Text(
                    isLoginMode
                        ? 'Noch keinen Account? Registrieren'
                        : 'Bereits einen Account? Einloggen',
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoginMode)
                  TextButton(
                    onPressed: handleForgotPassword,
                    child: const Text("Passwort vergessen?"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
