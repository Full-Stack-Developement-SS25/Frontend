import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ProfileTabContent extends StatefulWidget {
  const ProfileTabContent({super.key});

  @override
  State<ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<ProfileTabContent> {
  late Future<Map<String, dynamic>> _profileDataFuture;
  late Future<String?> _usernameFuture;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData();
    _usernameFuture = AuthService.getUsername();
  }

  Future<Map<String, dynamic>> _loadProfileData() async {
    final stats = await UserService.getFreshUserStats();
    final summary = await UserService.fetchUserStatsSummary();
    final isPremium = await UserService.isPremiumUser();

    setState(() {
      _isPremium = isPremium;
    });

    return {
      ...stats,
      'badgeCount': summary['badgeCount'],
      'completedTasks': summary['completedTasks'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Fehler: ${snapshot.error}",
              style: const TextStyle(color: AppColors.white),
            ),
          );
        } else {
          final data = snapshot.data!;
          final level = data["level"];
          final xp = data["xp"];
          final completedTasks = data["completedTasks"] ?? 0;
          final badgeCount = data["badgeCount"] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accent,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),

                /// Username als Future
                FutureBuilder<String?>(
                  future: _usernameFuture,
                  builder: (context, snapshot) {
                    final username = snapshot.data ?? "Unbekannt";
                    return Text(
                      username,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                if (_isPremium) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Premium Nutzer",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
                _infoCard("Level", "$level"),
                _infoCard("XP", "$xp"),
                _infoCard("Abgeschlossene Aufgaben", "$completedTasks"),
                _infoCard("Abzeichen", "$badgeCount"),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isPremium
                            ? Colors.grey
                            : AppColors.accent, // Grau wenn Premium
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _isPremium
                          ? null
                          : () async {
                            try {
                              await UserService.buyPremium();

                              if (!mounted) return;

                              // Erfolgsdialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor:
                                        AppColors.primaryBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 60,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Kauf erfolgreich!",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            "Du bist jetzt Premium und hast alle Funktionen freigeschaltet.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("Super!"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );

                              setState(() {
                                _profileDataFuture = _loadProfileData();
                              });
                            } catch (e) {
                              // Fehlerdialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor:
                                        AppColors.primaryBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 60,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Kauf fehlgeschlagen",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Beim Kauf ist ein Fehler aufgetreten:\n$e",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("Schließen"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                  child: Text(
                    _isPremium
                        ? "Premium freigeschaltet"
                        : "Premium freischalten",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          value,
          style: const TextStyle(color: AppColors.white, fontSize: 16),
        ),
      ),
    );
  }
}
