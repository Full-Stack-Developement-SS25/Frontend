import 'package:flutter/material.dart';

class InlineTitle extends StatelessWidget {
  final String text;

  const InlineTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 221, 115, 45),
      ),
    );
  }
}
