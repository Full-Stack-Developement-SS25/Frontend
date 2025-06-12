import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AIService {
  static Future<Map<String, dynamic>?> evaluatePrompt(
    String taskText,
    String prompt,
    String taskId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      developer.log('Kein User angemeldet', name: 'AIService');
      return null;
    }

    final url = Uri.parse('${Config.baseUrl}/evaluation');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'task': taskText,
          'prompt': prompt,
          'userId': userId,
          'taskId': taskId,
        }),
      );

      developer.log('Bewertung senden: ${response.statusCode}', name: 'AIService');
      developer.log('Antworttext: ${response.body}', name: 'AIService');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      developer.log('Netzwerkfehler: $e', name: 'AIService');
      return null;
    }
  }
}
