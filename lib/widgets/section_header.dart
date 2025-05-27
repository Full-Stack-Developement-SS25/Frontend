import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        backgroundColor: Color.fromARGB(255, 34, 21, 53),
        fontWeight: FontWeight.bold,
        fontSize: 40,
        color: Color.fromARGB(255, 221, 115, 45),
      ),
    );
  }
}
