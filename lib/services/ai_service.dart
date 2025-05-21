import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class AIService {
  static Future<String?> evaluatePrompt(String task, String prompt) async {
    final url = Uri.parse('${Config.baseUrl}/evaluation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task': task, 'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['feedback'] as String?;
      } else {
        print('❌ Backend-Fehler: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Netzwerkfehler: $e');
      return null;
    }
  }
}
