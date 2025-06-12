import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
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
  String _username = "User";

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final name = prefs.getString('username');
    setState(() {
      _username = name ?? "User";
    });
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
        title: Text(
          "Hallo, $_username!",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: AppColors.accent,
          ),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Profil"), Tab(text: "Badges")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ProfileTabContent(), BadgesTabContent()],
      ),
    );
  }
}
