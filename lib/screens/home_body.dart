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
    // Ambil ValueNotifier<DateTime> dari AppShell
    final dateListenable = context.shellDate;

    if (initialDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppShell.of(context)?.setViewDate(initialDate!);
      });
    }

    // Dengarkan perubahan tanggal dari shell → rebuild isi body ketika berubah
    return ValueListenableBuilder<DateTime>(
      valueListenable: dateListenable,
      builder: (context, date, _) {
        // Ambil state global (Provider)
        final state = context.watch<JournalState>();

        // Pastikan data untuk tanggal ini sudah dimuat
        state.ensureLoaded(date);

        // Ambil entry mood untuk tanggal ini (null kalau belum ada)
        final entry = state.entryFor(date);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry != null)
              // Kalau sudah ada mood hari ini → tampilkan card ringkasan
                Card(
                  child: ListTile(
                    leading: Icon(
                      moodIcon(entry.mood),             // ikon sesuai mood
                      color: moodColor(entry.mood),     // warna sesuai mood
                      size: 36,
                    ),
                    title: Text(moodLabel(entry.mood)), // label mood (Good, etc.)
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
              // Belum ada catatan untuk tanggal ini
                const Text('No entry for this day yet.'),
              const Spacer(), // dorong konten ke atas (ruang kosong di bawah)
            ],
          ),
        );
      },
    );
  }
}
