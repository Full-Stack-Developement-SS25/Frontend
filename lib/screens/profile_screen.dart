import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_tab_content.dart';
import 'badges_tab_content.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: FutureBuilder<String?>(
          future: AuthService.getUsername(),
          builder: (context, snapshot) {
            final username = snapshot.data ?? "User";
            return Text(
              "Hallo, $username!",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: AppColors.accent,
              ),
            );
          },
        ),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: FutureBuilder<String?>(
            future: AuthService.getUsername(),
            builder: (context, snapshot) {
              final username = snapshot.data ?? "Profil";
              return TabBar(
                controller: _tabController,
                tabs: [Tab(text: username), const Tab(text: "Badges")],
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ProfileTabContent(), BadgesTabContent()],
      ),
    );
  }
}
