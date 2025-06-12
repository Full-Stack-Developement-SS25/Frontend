import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prompt_master/utils/xp_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:prompt_master/models/badge.dart';

class UserService {
  /// Holt XP + Level für ein bestimmtes User-ID (wird z. B. vom Dashboard genutzt)
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

  /// Holt die Topliste aller Nutzer:innen
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

  /// Holt immer aktuelle Daten des eingeloggten Nutzers (für Profilseite)
  static Future<Map<String, dynamic>> getFreshUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("❌ Kein user_id in SharedPreferences gefunden.");
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'username': data['username'] ?? prefs.getString('username'),
        'xp': data['xp'] ?? 0,
        'level': data['level'] ?? 0,
      };
    } else {
      throw Exception(
        'Fehler beim Abrufen des Live-User-Stats: ${response.body}',
      );
    }
  }

  static Future<List<Badge>> fetchUserBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception("❌ Kein user_id gefunden.");
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/user/$userId/badges'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Badge.fromJson(e)).toList();
    } else {
      throw Exception('Fehler beim Abrufen der Badges: ${response.body}');
    }
  }

  static Future<void> addXP({
    required String userId,
    required String difficulty,
    required int stars,
  }) async {
    final int xp = XPLogic.calculateTotalXP(difficulty, stars);

    final url = Uri.parse('http://localhost:3001/api/user/$userId/xp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'xp': xp}),
    );

    if (response.statusCode != 200) {
      throw Exception('XP konnte nicht gesendet werden: ${response.body}');
    }

    print('✅ $xp XP erfolgreich gesendet.');
  }
}
