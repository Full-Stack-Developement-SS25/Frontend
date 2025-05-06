import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'scoreboard_screen.dart';
import 'task_list_screen.dart';
import 'profile_screen.dart';




class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const TaskListScreen(),
    const ScoreboardScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 34, 21, 53),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: const Color.fromARGB(
            255,
            213,
            111,
            15,
          ), // 🧡 DEIN ORANGE
          unselectedItemColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.task), label: "Aufgaben"),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: "Scoreboard",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          ],
        ),
      ),
    );
  }
}
