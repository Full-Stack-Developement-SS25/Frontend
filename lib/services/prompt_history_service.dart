import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prompt_master/services/auth_service.dart';
import 'package:prompt_master/services/config.dart';

class PromptHistoryService {
  /// Holt die Prompt-Historie des Users
  static Future<List<Map<String, dynamic>>> fetchPromptHistory() async {
    final userId = await AuthService.getUserId();
    final token = await AuthService.getToken();

    if (userId == null) {
      throw Exception("❌ Kein user_id gefunden.");
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId/prompt-history');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception(
        '❌ Fehler beim Abrufen der Prompt-Historie: ${response.body}',
      );
    }
  }

  /// Löscht einen Prompt aus der Historie
  static Future<void> deletePrompt(String promptId) async {
    final userId = await AuthService.getUserId();
    final token = await AuthService.getToken();

    if (userId == null) {
      throw Exception("❌ Kein user_id gefunden.");
    }

    final url = Uri.parse(
      '${Config.baseUrl}/user/$userId/prompt-history/$promptId',
    );
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('❌ Fehler beim Löschen des Prompts: ${response.body}');
    }
  }
}
