import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../routes.dart';
import '../../state/journal_state.dart';


// === SCREEN DETAIL ===
// di sini user bisa nambah detail seperti tag (apa yang dilakukan) dan catatan
class CheckInDetailScreen extends StatefulWidget {
  const CheckInDetailScreen({
    super.key,
    required this.date,   // tanggal mood
    required this.mood,   // mood yang dipilih
  });

  final DateTime date;
  final Mood mood;

  @override
  State<CheckInDetailScreen> createState() => _CheckInDetailScreenState();
}

class _CheckInDetailScreenState extends State<CheckInDetailScreen> {
  // Controller untuk textfield catatan
  final _noteCtrl = TextEditingController();

  // List tag yang dipilih user (misalnya: "friends", "work")
  final List<String> _selected = [];

  // Daftar preset tag + icon-nya
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
    _noteCtrl.dispose(); // hapus controller biar ga memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood; // ambil mood dari widget parent

    return Scaffold(
      appBar: AppBar(title: const Text('Tell us more')),
      body: Padding(
        padding: const EdgeInsets.all(24), // beri jarak biar gak mepet layar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Bagian atas: mood icon + label =====
            Row(children: [
              Icon(moodIcon(mood), color: moodColor(mood)), // icon & warna sesuai mood
              const SizedBox(width: 8),
              Text(
                moodLabel(mood),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ]),

            const SizedBox(height: 16),

            // ===== Judul bagian tag =====
            Text(
              'What have you been up to?',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            // ===== List tag dalam bentuk chip (bisa scroll) =====
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,        // jarak antar chip secara horizontal
                  runSpacing: 8,     // jarak antar chip secara vertikal
                  children: _presets.map((p) {
                    final label = p.$1; // nama tag (misal "friends")
                    final icon = p.$2;  // icon-nya
                    final isSel = _selected.contains(label); // apakah tag ini dipilih?

                    // setiap tag = 1 FilterChip
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 18),
                          const SizedBox(width: 6),
                          Text(label),
                        ],
                      ),
                      selected: isSel, // true kalau dipilih
                      onSelected: (v) {
                        setState(() {
                          // kalau dipilih, tambahkan ke list; kalau batal, hapus
                          v ? _selected.add(label) : _selected.remove(label);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ===== Input catatan =====
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Quick note (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Tombol SAVE =====
            SizedBox(
              width: double.infinity, // lebar penuh
              child: ElevatedButton(
                onPressed: () {
                  // ambil state global JournalState (pakai provider)
                  final state = context.read<JournalState>();

                  // simpan data mood ke database via state
                  state.save(
                    MoodEntry(
                      date: widget.date,
                      mood: mood,
                      tags: List.of(_selected),     // duplikat list biar aman
                      note: _noteCtrl.text.trim(),  // hapus spasi kosong
                    ),
                  );

                  // setelah disimpan, kembali ke halaman home
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
