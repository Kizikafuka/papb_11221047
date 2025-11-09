import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood.dart';
import '../state/journal_state.dart';

/// Widget showing weekly mood statistics
class WeeklyStatsCard extends StatelessWidget {
  const WeeklyStatsCard({super.key, required this.weekStart});

  final DateTime weekStart; // First day of the week (Monday)

  /// Get the last 7 days from weekStart
  List<DateTime> get _weekDates {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<JournalState>();

    // Collect mood entries for the week
    final weekEntries = _weekDates
        .map((date) => state.entryFor(date))
        .where((entry) => entry != null)
        .toList();

    // Calculate statistics
    final totalEntries = weekEntries.length;
    final moodCounts = <Mood, int>{};

    for (final entry in weekEntries) {
      moodCounts[entry!.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    // Find most frequent mood
    Mood? dominantMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });

    // Calculate average mood score (VeryGood=5, Good=4, Neutral=3, Bad=2, Awful=1)
    double avgScore = 0;
    if (totalEntries > 0) {
      final totalScore = weekEntries.fold<int>(
        0,
        (sum, entry) =>
            sum + (5 - entry!.mood.index), // Reverse index for higher=better
      );
      avgScore = totalScore / totalEntries;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (totalEntries == 0)
              // No data for this week
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No entries this week yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Check-in count
                  _StatRow(
                    icon: Icons.check_circle_outline,
                    label: 'Check-ins',
                    value: '$totalEntries/7 days',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),

                  // Dominant mood
                  if (dominantMood != null)
                    _StatRow(
                      icon: moodIcon(dominantMood!),
                      label: 'Most Common',
                      value: moodLabel(dominantMood!),
                      color: moodColor(dominantMood!),
                    ),
                  const SizedBox(height: 12),

                  // Average mood score
                  _StatRow(
                    icon: Icons.trending_up,
                    label: 'Average Mood',
                    value: _getScoreLabel(avgScore),
                    color: _getScoreColor(avgScore),
                  ),
                  const SizedBox(height: 16),

                  // Mood distribution bar chart
                  _MoodDistributionChart(moodCounts: moodCounts),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Convert average score to label
  String _getScoreLabel(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 3.5) return 'Good';
    if (score >= 2.5) return 'Fair';
    if (score >= 1.5) return 'Poor';
    return 'Difficult';
  }

  /// Get color based on score
  Color _getScoreColor(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 3.5) return Colors.lightGreen;
    if (score >= 2.5) return Colors.amber;
    if (score >= 1.5) return Colors.orange;
    return Colors.red;
  }
}

/// Row displaying a single statistic
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

/// Horizontal bar chart showing mood distribution
class _MoodDistributionChart extends StatelessWidget {
  const _MoodDistributionChart({required this.moodCounts});

  final Map<Mood, int> moodCounts;

  @override
  Widget build(BuildContext context) {
    final total = moodCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Distribution',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 8),
        ...Mood.values.map((mood) {
          final count = moodCounts[mood] ?? 0;
          if (count == 0) return const SizedBox.shrink();

          final percentage = (count / total * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                // Mood icon
                Icon(
                  moodIcon(mood),
                  size: 16,
                  color: moodColor(mood),
                ),
                const SizedBox(width: 6),
                // Mood label
                SizedBox(
                  width: 80,
                  child: Text(
                    moodLabel(mood),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count / total,
                      backgroundColor: moodColor(mood).withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(moodColor(mood)),
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Percentage label
                SizedBox(
                  width: 35,
                  child: Text(
                    '$percentage%',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
