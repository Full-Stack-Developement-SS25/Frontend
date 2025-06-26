import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/section_header.dart';
import '../services/prompt_history_service.dart';

class PromptHistoryScreen extends StatefulWidget {
  const PromptHistoryScreen({super.key});

  @override
  State<PromptHistoryScreen> createState() => _PromptHistoryScreenState();
}

class _PromptHistoryScreenState extends State<PromptHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _historyFuture = PromptHistoryService.fetchPromptHistory();
  }

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso)?.toLocal();
    if (date == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} ${two(date.hour)}:${two(date.minute)}';
  }

  Widget _buildStars(int count) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: AppColors.accent,
          size: 20,
        );
      }),
    );
  }

  Future<void> _deletePrompt(String id, int index) async {
    try {
      await PromptHistoryService.deletePrompt(id);
      setState(() {
        _history.removeAt(index);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const SectionHeader('Prompt-Historie'),
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Fehler: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Daten verfügbar'));
          } else {
            if (_history.isEmpty) {
              _history = List<Map<String, dynamic>>.from(snapshot.data!);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final id = item['id'] ?? item['promptId'];
                final prompt = item['prompt'] ?? '';
                final created = item['created_at'] ?? '';
                final rating = item['rating'];
                final feedback = item['feedback'];

                return Dismissible(
                  key: Key('$id'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: AppColors.white),
                  ),
                  onDismissed: (_) => _deletePrompt('$id', index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(created),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (rating != null) ...[
                          const SizedBox(height: 8),
                          _buildStars(rating is int ? rating : int.tryParse('$rating') ?? 0),
                        ],
                        if (feedback != null && feedback.toString().isNotEmpty)
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: const Text(
                              'Mehr anzeigen',
                              style: TextStyle(color: AppColors.white),
                            ),
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    feedback,
                                    style: const TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
