import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/mood.dart';
import '../../routes.dart';
import 'package:intl/intl.dart';

class CheckInStartScreen extends StatelessWidget {
  const CheckInStartScreen({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEEE, d MMM yyyy – HH:mm');
    const moods = Mood.values;

    return Scaffold(
      appBar: AppBar(title: const Text('How are you')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How are you?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(fmt.format(date), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                for (final m in moods)
                  _MoodButton(
                    mood: m,
                    onTap: () => context.go(
                      AppRoutes.checkinDetail,
                      extra: {'date': date, 'mood': m},
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({required this.mood, required this.onTap});
  final Mood mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110, height: 110,
        decoration: BoxDecoration(
          color: moodColor(mood).withValues(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: moodColor(mood)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(moodIcon(mood), size: 36, color: moodColor(mood)),
            const SizedBox(height: 8),
            Text(moodLabel(mood)),
          ],
        ),
      ),
    );
  }
}
