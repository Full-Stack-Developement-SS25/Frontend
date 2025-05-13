import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class UserService {
  static Future<Map<String, dynamic>> fetchUserStats(String userId) async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/user/$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'xp': data['xp'] ?? 0,
        'level': data['level'] ?? 0,
      };
    } else {
      throw Exception('Fehler beim Abrufen der User-Daten');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchScoreboard() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/user'));

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
      throw Exception('Fehler beim Abrufen des Scoreboards');
    }
  }
}