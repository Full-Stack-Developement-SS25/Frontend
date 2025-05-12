import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../widgets/section_header.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  late Future<List<Map<String, dynamic>>> _scoreboard;

  @override
  void initState() {
    super.initState();
    _scoreboard = fetchScoreboard();
  }

  Future<List<Map<String, dynamic>>> fetchScoreboard() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/user'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) {
        return {
          'id': user['id'],
          'username': user['username'], // 👈 NEU
          'level': user['level'],
          'xp': user['xp'],
        };
      }).toList();

    } else {
      throw Exception('Fehler beim Abrufen der Benutzer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 21, 53),
      appBar: AppBar(
        title: const SectionHeader("Leaderboard"),
        backgroundColor: const Color.fromARGB(255, 34, 21, 53),
        foregroundColor: const Color.fromARGB(255, 221, 115, 45),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _scoreboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Daten verfügbar'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final rank = index + 1;
                final emoji = switch (rank) {
                  1 => '🥇',
                  2 => '🥈',
                  3 => '🥉',
                  _ => '🏅',
                };

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$emoji $rank.',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['username'] ?? 'Spieler $rank',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${user['level']} | XP ${user['xp']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
