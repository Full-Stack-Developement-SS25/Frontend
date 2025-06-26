import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:prompt_master/utils/xp_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'auth_service.dart';
import 'package:prompt_master/models/badge.dart' as model;
import 'badge_service.dart';

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
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('❌ Kein user_id gefunden.');
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

  static Future<List<model.Badge>> fetchUserBadges() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('❌ Kein user_id gefunden.');
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/user/$userId/badges'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => model.Badge.fromJson(e)).toList();
    } else {
      throw Exception('Fehler beim Abrufen der Badges: ${response.body}');
    }
  }

   /// Gibt eine Zusammenfassung der Nutzerstatistiken zurueck
  /// (z.B. Anzahl freigeschalteter Badges und erledigter Aufgaben).
  static Future<Map<String, int>> fetchUserStatsSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('❌ Kein user_id gefunden.');
    }

    final badgeCount = await BadgeService.fetchCurrentUserBadgeCount();

    final completedUrl = Uri.parse(
      '${Config.baseUrl}/user/$userId/completed-count',
    );
    final completedResponse = await http.get(completedUrl);

    if (completedResponse.statusCode == 200) {
      final completedData = jsonDecode(completedResponse.body);
      final int completedTasks = completedData['completedTasks'] ?? 0;

      return {'badgeCount': badgeCount, 'completedTasks': completedTasks};
    } else {
      throw Exception(
        'Fehler beim Abrufen der erledigten Aufgaben: ${completedResponse.body}',
      );
    }
  }

  static Future<void> addXP({
    required String userId,
    required String difficulty,
    required int stars,
  }) async {
    final int xp = XPLogic.calculateTotalXP(difficulty, stars);

    final url = Uri.parse('http://localhost:3000/api/user/$userId/xp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'xp': xp}),
    );

    if (response.statusCode != 200) {
      throw Exception('XP konnte nicht gesendet werden: ${response.body}');
    }

    developer.log('XP erfolgreich gesendet: $xp', name: 'UserService');
  }

  static Future<void> updateLevel(String userId, int level) async {
    final url = Uri.parse('${Config.baseUrl}/user/$userId/level');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'level': level}),
    );

    if (response.statusCode != 200) {
      throw Exception('Level konnte nicht aktualisiert werden: ${response.body}');
    }

    developer.log('Level erfolgreich aktualisiert: $level', name: 'UserService');
  }

}
