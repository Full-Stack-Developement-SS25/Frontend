import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'auth_service.dart';
import 'config.dart';

class PromptHistoryService {
  static Future<List<Map<String, dynamic>>> fetchPromptHistory() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('❌ Kein Benutzer angemeldet');
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId/prompt-history');
    final response = await http.get(url);

    developer.log('GET: $url', name: 'PromptHistoryService');
    developer.log('Antwort: ${response.statusCode} – ${response.body}', name: 'PromptHistoryService');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Fehler beim Abrufen der Prompt-Historie: ${response.body}');
    }
  }

  static Future<void> deletePrompt(String promptId) async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('❌ Kein Benutzer angemeldet');
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId/prompt-history/$promptId');
    final response = await http.delete(url);

    developer.log('DELETE: $url', name: 'PromptHistoryService');
    developer.log('Antwort: ${response.statusCode} – ${response.body}', name: 'PromptHistoryService');

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Löschen des Prompts: ${response.body}');
    }
  }
}
