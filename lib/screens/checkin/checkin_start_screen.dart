import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/mood.dart'; // enum Mood + helper (label/icon/color)
import '../../routes.dart'; // definisi path/route app
import 'package:intl/intl.dart'; // format tanggal

class CheckInStartScreen extends StatelessWidget {
  const CheckInStartScreen({super.key, required this.date});
  final DateTime date; // tanggal/waktu saat check-in dimulai

  @override
  Widget build(BuildContext context) {
    // Formatter tanggal, contoh: Monday, 13 Oct 2025 – 18:20
    final fmt = DateFormat('EEEE, d MMM yyyy – HH:mm');

    // Ambil semua opsi mood dari enum
    const moods = Mood.values;

    return Scaffold(
      appBar: AppBar(title: const Text('How are you')),
      body: Padding(
        padding: const EdgeInsets.all(24), // padding global
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul besar
            Text(
              'How are you?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Tanggal/waktu check-in
            Text(
              fmt.format(date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Grid responsif tombol mood (Wrap = auto pindah baris)
            Wrap(
              spacing: 12, // jarak horizontal antar tombol
              runSpacing: 12, // jarak vertikal antar baris tombol
              children: [
                for (final m in moods)
                  _MoodButton(
                    mood: m,
                    // Navigasi ke halaman detail
                    // Bawa data 'date' dan 'mood' via 'extra'
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

// Widget tombol satuan untuk tiap mood
class _MoodButton extends StatelessWidget {
  const _MoodButton({required this.mood, required this.onTap});
  final Mood mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        moodColor(mood); // warna sesuai mood (helper dari models/mood.dart)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // ripple mengikuti border radius
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          // Background tipis bernuansa color mood
          color: color.withValues(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color), // outline pakai warna mood
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon sesuai mood
            Icon(moodIcon(mood), size: 36, color: color),
            const SizedBox(height: 8),
            // Label mood (Very Good / Good / dst.)
            Text(moodLabel(mood)),
          ],
        ),
      ),
    );
  }
}
