import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../routes.dart';
import '../../state/journal_state.dart';

class CheckInDetailScreen extends StatefulWidget {
  const CheckInDetailScreen({super.key, required this.date, required this.mood});
  final DateTime date;
  final Mood mood;

  @override
  State<CheckInDetailScreen> createState() => _CheckInDetailScreenState();
}

class _CheckInDetailScreenState extends State<CheckInDetailScreen> {
  final _noteCtrl = TextEditingController();
  final List<String> _selected = [];

  final _presets = const [
    ('friends', Icons.group),
    ('date', Icons.favorite),
    ('study', Icons.menu_book),
    ('work', Icons.work),
    ('family', Icons.home),
    ('gaming', Icons.sports_esports),
    ('exercise', Icons.fitness_center),
    ('music', Icons.music_note),
    ('travel', Icons.flight),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;
    return Scaffold(
      appBar: AppBar(title: const Text('Tell us more')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(moodIcon(mood), color: moodColor(mood)),
              const SizedBox(width: 8),
              Text(moodLabel(mood), style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 16),
            Text('What have you been up to?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _presets.map((p) {
                    final label = p.$1; final icon = p.$2;
                    final isSel = _selected.contains(label);
                    return FilterChip(
                      label: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 18),
                        const SizedBox(width: 6),
                        Text(label),
                      ]),
                      selected: isSel,
                      onSelected: (v) {
                        setState(() {
                          v ? _selected.add(label) : _selected.remove(label);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Quick note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final state = context.read<JournalState>();
                  state.save(MoodEntry(
                    date: widget.date,
                    mood: mood,
                    tags: List.of(_selected),
                    note: _noteCtrl.text.trim(),
                  ));
                  context.go(AppRoutes.home);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
