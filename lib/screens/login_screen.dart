import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'main_navigation.dart';
import './/utils/app_colors.dart';
import './/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isLoginMode = true;

  bool isEmailValid(String email) {
    return EmailValidator.validate(email);
  }

  bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  @override
  void initState() {
    super.initState();

    // Listener auf Token-Änderungen setzen
    AuthService.jwtTokenNotifier.addListener(_onTokenChanged);
  }

  void _onTokenChanged() {
    final token = AuthService.jwtTokenNotifier.value;
    print("Token geändert: $token");
    if (token != null) {
      _navigateToDashboard(context);
    }
  }

  @override
  void dispose() {
    AuthService.jwtTokenNotifier.removeListener(_onTokenChanged);
    // Controller dispose etc.
    super.dispose();
  }

  Future<void> handleSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    try {
      final response =
          isLoginMode
              ? await AuthService.login(email, password)
              : await AuthService.register(email, password, username);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLoginMode
                  ? "Erfolgreich eingeloggt als $email"
                  : "Registrierung erfolgreich. Willkommen $username!",
            ),
          ),
        );
      } else {
        // Fehler aus Backend lesen (hier 'error' oder 'message' prüfen)
        final responseBody = jsonDecode(response.body);
        final errorMsg =
            responseBody['error'] ??
            responseBody['message'] ??
            "Unbekannter Fehler";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Fehler: $errorMsg")));
      }
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception:')) {
        message = message.replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.trim())));
    }
  }

  void handleForgotPassword() {
    final email = emailController.text.trim();
    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bitte eine gültige E-Mail-Adresse eingeben!"),
        ),
      );
      return;
    }

    // Hier könntest du noch eine Funktion im AuthService aufrufen für Passwort zurücksetzen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Ein Link zum Zurücksetzen des Passworts wurde an Ihre E-Mail gesendet.",
        ),
      ),
    );
    Navigator.pop(context);
  }

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
                  onPressed: () async {
                    try {
                      await AuthService().signInWithGoogle();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Google Anmeldung fehlgeschlagen: $e'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Image.asset(
                    'lib/assets/github-mark.png',
                    height: 24,
                    width: 24,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Mit GitHub anmelden',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () async {
                    try {
                      await AuthService.signInWithGitHub(context);
                      // Navigation entfällt, Listener übernimmt das
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('GitHub Anmeldung fehlgeschlagen: $e'),
                        ),
                      );
                    }
                  },
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
                      if (!isLoginMode) ...[
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.white,
                            hintText: 'Benutzername',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte einen Benutzernamen eingeben.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
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
                        onPressed: handleSubmit,
                        child: Text(isLoginMode ? 'Anmelden' : 'Registrieren'),
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
