import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:prompt_master/utils/xp_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:prompt_master/models/badge.dart' as model;
import 'badge_service.dart';
import 'auth_service.dart';

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

  static Future<List<model.Badge>> fetchUserBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception("❌ Kein user_id gefunden.");
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

  /// Prüft, ob der aktuell eingeloggte Nutzer Premium ist
  static Future<bool> isPremiumUser() async {
    final userId = await AuthService.getUserId();
    final token = await AuthService.getToken();

    developer.log('[isPremiumUser] userId: $userId', name: 'UserService');
    developer.log('[isPremiumUser] token: $token', name: 'UserService');

    if (userId == null || token == null) {
      developer.log('❌ Kein userId oder Token gefunden', name: 'UserService');
      throw Exception('❌ Fehlende Anmeldedaten.');
    }

    final url = Uri.parse('${Config.baseUrl}/user/$userId/premium');
    developer.log('[isPremiumUser] Request URL: $url', name: 'UserService');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      developer.log(
        '[isPremiumUser] Response Status: ${response.statusCode}',
        name: 'UserService',
      );
      developer.log(
        '[isPremiumUser] Response Body: ${response.body}',
        name: 'UserService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log(
          '[isPremiumUser] Parsed Data: $data',
          name: 'UserService',
        );

        final isPremium = data['isPremium'] as bool? ?? false;
        developer.log(
          '[isPremiumUser] isPremium: $isPremium',
          name: 'UserService',
        );

        return isPremium;
      } else {
        developer.log(
          '❌ Fehler beim Abrufen des Premium-Status: ${response.body}',
          name: 'UserService',
        );
        return false;
      }
    } catch (e) {
      developer.log('❌ Fehler in isPremiumUser(): $e', name: 'UserService');
      return false;
    }
  }


}
