import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:prompt_master/models/badge.dart';
import 'auth_service.dart';

class BadgeService {
  static Future<List<Badge>> fetchBadges(String userId) async {
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

  static Future<List<Badge>> fetchCurrentUserBadges() async {
    final userId = await AuthService.getUserId();

    if (userId == null) {
      throw Exception('❌ Kein user_id gefunden.');
    }

    return fetchBadges(userId);
  }

    /// Gibt die Anzahl der aktuell freigeschalteten Badges des eingeloggten
  /// Nutzers zurück.
  static Future<int> fetchCurrentUserBadgeCount() async {
    final badges = await fetchCurrentUserBadges();
    return badges.length;
  }


  /// Prüft, ob neue Badges freigeschaltet wurden.
  /// Gibt eine Liste neu freigeschalteter Badges zurück und
  /// speichert diese lokal, um mehrfache Benachrichtigungen zu vermeiden.
  static Future<List<Badge>> checkForNewBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final known = prefs.getStringList('unlocked_badges') ?? <String>[];

    final badges = await fetchCurrentUserBadges();
    final newlyUnlocked = badges
        .where((b) => b.awardedAt.isNotEmpty && !known.contains(b.id))
        .toList();

    if (newlyUnlocked.isNotEmpty) {
      final updated = [...known, ...newlyUnlocked.map((b) => b.id)];
      await prefs.setStringList('unlocked_badges', updated);
    }

    return newlyUnlocked;
  }
}
