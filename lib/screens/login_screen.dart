import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'main_navigation.dart';
import './/utils/app_colors.dart';
import './/services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isLoginMode = true;
  bool showResendButton = false;
  int resendCooldown = 0;
  Timer? resendTimer;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'reset-success') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwort erfolgreich gesetzt.')),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    AuthService.jwtTokenNotifier.removeListener(_onTokenChanged);
    resendTimer?.cancel();

    super.dispose();
  }

  Future<void> handleSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();

    if (!_formKey.currentState!.validate()) return;
    setState(() {
      showResendButton = false;
    });

    try {
      if (isLoginMode) {
        final response = await AuthService.login(email, password);

        if (response.statusCode == 200) {
          final userId = await _waitForUserId();

          if (userId == null) {
            throw Exception(
              "❌ Login erfolgreich, aber userId wurde nicht gespeichert.",
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erfolgreich eingeloggt als $email")),
            );
            _navigateToDashboard(context);
          }
        } else {
          final responseBody = jsonDecode(response.body);
          final errorMsg =
              responseBody['error'] ??
              responseBody['message'] ??
              "Unbekannter Fehler";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Fehler: $errorMsg")));
          if (errorMsg.contains('E-Mail noch nicht bestätigt')) {
            setState(() {
              showResendButton = true;
            });
          }
        }
      } else {
        final response = await AuthService.register(email, password, username);

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrierung erfolgreich. Bitte einloggen.'),
              ),
            );
            setState(() {
              isLoginMode = true;
            });
          }
        } else {
          final responseBody = jsonDecode(response.body);
          final errorMsg =
              responseBody['error'] ??
              responseBody['message'] ??
              "Unbekannter Fehler";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Fehler: $errorMsg")));
        }
      }
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception:')) {
        message = message.replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message.trim())));
      if (message.contains('E-Mail noch nicht bestätigt')) {
        setState(() {
          showResendButton = true;
        });
      }
    }
  }

  Future<String?> _waitForUserId({int retries = 10}) async {
    for (var i = 0; i < retries; i++) {
      final userId = await AuthService.getUserId();
      if (userId != null) return userId;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return null;
  }

  void _startResendCooldown() {
    resendTimer?.cancel();
    setState(() {
      resendCooldown = 60;
    });
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        resendCooldown--;
      });
      if (resendCooldown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> handleResendVerification() async {
    final email = emailController.text.trim();
    try {
      await AuthService.resendVerification(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bestätigungs-E-Mail erneut gesendet.')),
        );
      }
      _startResendCooldown();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  Future<void> handleForgotPassword() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                ForgotPasswordScreen(initialEmail: emailController.text.trim()),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-Mail zum Zurücksetzen wurde gesendet.'),
        ),
      );
    }
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

                      final userId = await _waitForUserId();

                      if (userId == null) {
                        throw Exception(
                          "❌ Google Login erfolgreich, aber userId wurde nicht gespeichert.",
                        );
                      }

                      if (!mounted) return;
                      _navigateToDashboard(context);
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
                if (showResendButton)
                  TextButton(
                    onPressed:
                        resendCooldown > 0 ? null : handleResendVerification,
                    child: Text(
                      resendCooldown > 0
                          ? 'Erneut senden ($resendCooldown)'
                          : 'Bestätigungs-E-Mail erneut senden',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
