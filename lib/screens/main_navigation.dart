import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'scoreboard_screen.dart';
import 'task_list_screen.dart';
import 'profile_screen.dart';
import './/utils/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const TaskListScreen(),
    const ScoreboardScreen(),
    const ProfileScreen(),
  ];

   @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: AppColors.primaryBackground,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textPrimary,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 50),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task, size: 40),
              label: "Aufgaben",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded, size: 42),
              label: "Scoreboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 50),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
