import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/journal_state.dart';
import '../models/mood.dart';
import 'app_shell.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, this.initialDate});
  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    final dateListenable = context.shellDate;

    // If we arrived with an initial date, set it once after first frame
    if (initialDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppShell.of(context)?.setViewDate(initialDate!);
      });
    }

    return ValueListenableBuilder<DateTime>(
      valueListenable: dateListenable,
      builder: (context, date, _) {
        final state = context.watch<JournalState>();
        state.ensureLoaded(date);
        final entry = state.entryFor(date);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry != null)
                Card(
                  child: ListTile(
                    leading: Icon(
                      moodIcon(entry.mood),
                      color: moodColor(entry.mood),
                      size: 36,
                    ),
                    title: Text(moodLabel(entry.mood)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.tags.isNotEmpty)
                          Text('Tags: ${entry.tags.join(', ')}'),
                        if (entry.note.isNotEmpty)
                          Text('Note: ${entry.note}'),
                      ],
                    ),
                  ),
                )
              else
                const Text('No entry for this day yet.'),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
