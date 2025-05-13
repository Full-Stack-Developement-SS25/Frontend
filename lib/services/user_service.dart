import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class UserService {
  static Future<Map<String, dynamic>> fetchUserStats(String userId) async {
    final url = Uri.parse('${Config.baseUrl}/user/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'xp': data['xp'] ?? 0, 'level': data['level'] ?? 0};
    } else {
      throw Exception('Fehler beim Abrufen der User-Daten: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchScoreboard() async {
    final url = Uri.parse('${Config.baseUrl}/user');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) {
        return {
          'id': user['id'],
          'username': user['username'],
          'level': user['level'],
          'xp': user['xp'],
        };
      }).toList();
    } else {
      throw Exception('Fehler beim Abrufen des Scoreboards: ${response.body}');
    }
  }
}
