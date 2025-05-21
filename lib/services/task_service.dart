import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  static Future<List<Map<String, dynamic>>> fetchTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("❌ Kein Benutzer angemeldet");
    }

    final url = Uri.parse('${Config.baseUrl}/tasks/$userId'); // ← wichtig!

    final response = await http.get(url);

    print('📡 GET: $url');
    print('🔁 Antwort: ${response.statusCode} – ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((task) => task as Map<String, dynamic>).toList();
    } else {
      throw Exception('❌ Fehler beim Abrufen der Aufgaben: ${response.body}');
    }
  }


  static Future<void> markAsDone(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("❌ Kein Benutzer angemeldet (user_id fehlt)");
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId/task/$taskId/done');

    print('🔁 Aufgabe erledigt markieren: $url');

    final response = await http.post(url);

    print('🔁 Antwortstatus: ${response.statusCode}');
    print('🔁 Antworttext: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        '❌ Fehler beim Markieren der Aufgabe als erledigt: ${response.body}',
      );
    }
  }
}
