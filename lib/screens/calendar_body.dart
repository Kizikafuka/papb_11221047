// lib/screens/calendar_body.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../state/journal_state.dart';
import '../models/mood.dart';
import '../routes.dart';
import '../widgets/weekly_stats_card.dart';
import 'app_shell.dart';

class CalendarBody extends StatefulWidget {
  const CalendarBody({super.key, this.initialMonth});
  final DateTime? initialMonth; // opsional: bulan awal yang mau ditampilkan

  @override
  State<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<CalendarBody> {
  // _month selalu diset ke tanggal 1 di bulan itu (jam 00:00)
  late DateTime _month; // first day of the month at midnight

  @override
  void initState() {
    super.initState();
    // Tentukan bulan awal (dari param atau hari ini)
    final m = widget.initialMonth ?? DateTime.now();
    _month = DateTime(m.year, m.month, 1);

    // Setelah frame pertama, minta JournalState mulai "mengamati" bulan ini
    // (biasanya akan membuka stream watchRange ke DB lewat Drift)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<JournalState>();
      state.watchMonth(_month);
    });
  }

  // ===== Helper tanggal: Monday-first =====
  DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _lastOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);
  // Konversi weekday ke index Mon=0..Sun=6 (Flutter: Mon=1..Sun=7)
  int _startPadMonFirst(DateTime first) => (first.weekday + 6) % 7;

  // Pindah ke bulan sebelumnya
  void _prevMonth() => setState(() {
        _month = DateTime(_month.year, _month.month - 1, 1);
        context.read<JournalState>().watchMonth(_month); // update stream
      });

  // Pindah ke bulan berikutnya
  void _nextMonth() => setState(() {
        _month = DateTime(_month.year, _month.month + 1, 1);
        context.read<JournalState>().watchMonth(_month); // update stream
      });

  /// Get the Monday of the week containing the given date
  DateTime _getMondayOfWeek(DateTime date) {
    final weekday = date.weekday; // 1=Monday, 7=Sunday
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Get the current week's Monday based on displayed month
  DateTime get _currentWeekStart {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    return _getMondayOfWeek(todayMidnight);
  }

  @override
  Widget build(BuildContext context) {
    final shell = AppShell.of(context)!; // akses shell buat set viewDate
    final state =
        context.watch<JournalState>(); // observe state (biar grid update)
    final fmtHeader = DateFormat('MMMM yyyy'); // contoh: October 2025

    final first = _firstOfMonth(_month);
    final last = _lastOfMonth(_month);
    final startPad =
        _startPadMonFirst(first); // jumlah sel kosong sebelum tgl 1
    final totalDays = last.day; // total hari dlm bulan

    // === Bangun sel hari (Mon-first) ===
    final cells = <Widget>[];

    // Isi padding di awal (mis. jika 1-nya jatuh di Kamis, isi 3 kosong dulu)
    for (int i = 0; i < startPad; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Untuk tiap tanggal, bikin sel kalender
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final entry = state.entryFor(date); // cek apakah ada data mood hari itu
      final bool hasEntry = entry != null;

      // Icon & warna sesuai ada/tidaknya entry
      final IconData icon = hasEntry ? moodIcon(entry.mood) : Icons.add;
      final Color bgColor = hasEntry
          ? moodColor(entry.mood).withOpacity(.18)
          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(.22);
      final Color fgColor = hasEntry
          ? moodColor(entry.mood)
          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(.85);

      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (hasEntry) {
              // Kalau sudah ada entry, set viewDate di AppShell & balik ke Home
              shell.setViewDate(date);
              context.go(AppRoutes.home, extra: {'date': date});
            } else {
              // Belum ada entry → mulai check-in di tanggal tsb
              context.go(AppRoutes.checkinStart, extra: {'date': date});
            }
          },
          child: Container(
            // Padding agak ketat supaya aman di layar kecil
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lingkaran kecil berisi ikon mood (atau ikon tambah)
                CircleAvatar(
                  radius: 14, // diperkecil dari 16 → anti overflow
                  backgroundColor: bgColor,
                  child: Icon(icon,
                      size: 16, color: fgColor), // diperkecil dari 18
                ),
                const SizedBox(height: 4), // diperkecil dari 6
                // Teks tanggal (clamp line-height biar rapi)
                Text(
                  '$day',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600, height: 1.0),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bottomInset =
        MediaQuery.of(context).padding.bottom; // aman dari gesture bar

    return SafeArea(
      top: true, // halaman ini nggak punya AppBar sendiri
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
        child: Column(
          children: [
            // ===== Header selector bulan (di dalam body) =====
            Row(
              children: [
                _RoundIconBtn(icon: Icons.chevron_left, onTap: _prevMonth),
                Expanded(
                  child: Text(
                    fmtHeader.format(_month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _RoundIconBtn(icon: Icons.chevron_right, onTap: _nextMonth),
              ],
            ),
            const SizedBox(height: 12),

            // ===== Weekly Statistics Card =====
            WeeklyStatsCard(weekStart: _currentWeekStart),

            const SizedBox(height: 12),

            // ===== Kartu kalender (rounded container) =====
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Column(
                  children: [
                    const _WeekdaysMonFirst(), // label Mon..Sun
                    const SizedBox(height: 6),
                    // Grid scrollable → anti overflow di HP kecil
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 7,
                        // Aspect ratio sedikit lebih kecil biar sel lebih tinggi
                        childAspectRatio: 0.78,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        padding: const EdgeInsets.only(bottom: 8),
                        children: cells,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// — UI kecil: tombol bulat panah kiri/kanan —
class _RoundIconBtn extends StatelessWidget {
  const _RoundIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(.3),
          ),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

// Label hari (Mon-first)
class _WeekdaysMonFirst extends StatelessWidget {
  const _WeekdaysMonFirst();

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: labels
          .map(
            (t) => Expanded(
              child: Center(
                child: Text(
                  t,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
