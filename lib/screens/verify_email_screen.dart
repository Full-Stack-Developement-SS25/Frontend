import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late String email;
  late String token;
  String message = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final params = Uri.base.queryParameters;
    if (params.isNotEmpty) {
      email = params['email'] ?? '';
      token = params['token'] ?? '';
    } else {
      final fragment = Uri.base.fragment;
      final idx = fragment.indexOf('?');
      if (idx != -1) {
        var fragPart = fragment.substring(idx + 1);
        final hashIdx = fragPart.indexOf('#');
        if (hashIdx != -1) {
          fragPart = fragPart.substring(0, hashIdx);
        }
        final fragParams = Uri.splitQueryString(fragPart);
        email = fragParams['email'] ?? '';
        token = fragParams['token'] ?? '';
      } else {
        email = '';
        token = '';
      }
    }
    _verify();
  }

  Future<void> _verify() async {
    try {
      final response = await AuthService.verifyEmail(email, token);
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        message = body['message'] ?? 'E-Mail erfolgreich bestätigt';
      } else {
        message = body['error'] ?? body['message'] ?? 'Unbekannter Fehler';
      }
    } catch (e) {
      message = 'Fehler: $e';
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('E-Mail bestätigen'),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
      ),
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(color: AppColors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }
}
