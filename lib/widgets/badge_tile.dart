import 'package:flutter/material.dart';
import 'package:prompt_master/models/badge.dart' as model;

class BadgeTile extends StatelessWidget {
  final model.Badge badge;

  const BadgeTile({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(badge.iconUrl, width: 40, height: 40),
      title: Text(badge.title),
      subtitle: Text(badge.description),
      trailing: Text(
        badge.awardedAt.split('T').first, // Datum ohne Uhrzeit
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
