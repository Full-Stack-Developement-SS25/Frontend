import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/section_header.dart';

class PromptHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> entry;
  const PromptHistoryDetailScreen({super.key, required this.entry});

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  Widget _buildStars(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: AppColors.accent,
          size: 32,
        );
      }),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = entry['title'] ?? 'Aufgabe';
    final description = entry['description'] ?? '';
    final difficulty = entry['difficulty']?.toString() ?? '';
    final type = entry['type'] ?? '';
    final created = entry['created_at'] ?? '';
    final content = entry['content'] ?? '';
    final score = entry['score'];
    final feedback = entry['feedback'];
    final keywordHits = entry['keyword_hits'];

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const SectionHeader('Prompt Details'),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (score != null) ...[
              Center(
                child: _buildStars(
                  score is int ? score : int.tryParse('$score') ?? 0,
                ),
              ),
              const SizedBox(height: 20),
            ],
            _sectionTitle('Titel der Aufgabe:'),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 20),
            _sectionTitle('Aufgabenbeschreibung:'),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 20),
            _sectionTitle('Schwierigkeit:'),
            const SizedBox(height: 8),
            Text(difficulty, style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 20),
            _sectionTitle('Typ:'),
            const SizedBox(height: 8),
            Text(type, style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 20),
            _sectionTitle('Datum:'),
            const SizedBox(height: 8),
            Text(_formatDate(created),
                style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 20),
            _sectionTitle('Der eingegebene Prompt:'),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(color: AppColors.white)),
            const SizedBox(height: 20),
            if (feedback != null && feedback.toString().trim().isNotEmpty) ...[
              _sectionTitle('Feedback:'),
              const SizedBox(height: 8),
              Text('$feedback', style: const TextStyle(color: AppColors.white)),
              const SizedBox(height: 20),
            ],
            if (keywordHits != null && keywordHits.toString().isNotEmpty) ...[
              _sectionTitle('Keyword Treffer:'),
              const SizedBox(height: 8),
              Text('$keywordHits',
                  style: const TextStyle(color: AppColors.white)),
            ],
          ],
        ),
      ),
    );
  }
}
