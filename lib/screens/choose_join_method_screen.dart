import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'join_event_qr_screen.dart';
import 'join_event_code_screen.dart';
import '../widgets/section_header.dart';



class ChooseJoinMethodScreen extends StatelessWidget {
  const ChooseJoinMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SectionHeader("Event beitreten"),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("QR-Code scannen", style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinEventQRScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                padding: const EdgeInsets.symmetric(vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.keyboard),
              label: const Text("Code manuell eingeben", style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinEventCodeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
