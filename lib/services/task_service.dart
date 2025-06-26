import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'config.dart';
import 'auth_service.dart';

class TaskService {
  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception("❌ Kein Benutzer angemeldet");
    }

    final url = Uri.parse('${Config.baseUrl}/tasks/$userId'); // ← wichtig!

    final response = await http.get(url);

    developer.log('GET: $url', name: 'TaskService');
    developer.log('Antwort: ${response.statusCode} – ${response.body}', name: 'TaskService');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((task) => task as Map<String, dynamic>).toList();
    } else {
      throw Exception('❌ Fehler beim Abrufen der Aufgaben: ${response.body}');
    }
  }


  static Future<void> markAsDone(String taskId) async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception("❌ Kein Benutzer angemeldet (user_id fehlt)");
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId/task/$taskId/done');

    developer.log('Aufgabe erledigt markieren: $url', name: 'TaskService');

    final response = await http.post(url);

    developer.log('Antwortstatus: ${response.statusCode}', name: 'TaskService');
    developer.log('Antworttext: ${response.body}', name: 'TaskService');

    if (response.statusCode != 200) {
      throw Exception(
        '❌ Fehler beim Markieren der Aufgabe als erledigt: ${response.body}',
      );
    }
  }
}
