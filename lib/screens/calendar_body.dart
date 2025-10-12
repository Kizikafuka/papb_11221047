// lib/screens/calendar_body.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../state/journal_state.dart';
import '../models/mood.dart';
import '../routes.dart';
import 'app_shell.dart';

class CalendarBody extends StatefulWidget {
  const CalendarBody({super.key, this.initialMonth});
  final DateTime? initialMonth;

  @override
  State<CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<CalendarBody> {
  late DateTime _month; // first day of the month at midnight

  @override
  void initState() {
    super.initState();
    final m = widget.initialMonth ?? DateTime.now();
    _month = DateTime(m.year, m.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<JournalState>();
      state.watchMonth(_month);
    });

  }



  // Monday-first helpers
  DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _lastOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);
  // 0=Mon…6=Sun
  int _startPadMonFirst(DateTime first) => (first.weekday + 6) % 7;

  void _prevMonth() => setState(() {
    _month = DateTime(_month.year, _month.month - 1, 1);
    context.read<JournalState>().watchMonth(_month);
  });

  void _nextMonth() => setState(() {
    _month = DateTime(_month.year, _month.month + 1, 1);
    context.read<JournalState>().watchMonth(_month);
  });

  @override
  Widget build(BuildContext context) {
    final shell = AppShell.of(context)!;
    final state = context.watch<JournalState>();
    final fmtHeader = DateFormat('MMMM yyyy');

    final first = _firstOfMonth(_month);
    final last = _lastOfMonth(_month);
    final startPad = _startPadMonFirst(first);
    final totalDays = last.day;

    // Build day cells (Mon-first)
    final cells = <Widget>[];
    for (int i = 0; i < startPad; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final entry = state.entryFor(date);
      final bool hasEntry = entry != null;

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
              shell.setViewDate(date);
              context.go(AppRoutes.home, extra: {'date': date});
            } else {
              context.go(AppRoutes.checkinStart, extra: {'date': date});
            }
          },
          child: Container(
            // tighter padding so small phones don’t overflow
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // slightly smaller circle to avoid overflow on compact screens
                CircleAvatar(
                  radius: 14, // was 16
                  backgroundColor: bgColor,
                  child: Icon(icon, size: 16, color: fgColor), // was 18
                ),
                const SizedBox(height: 4), // was 6
                // clamp text size/line-height to avoid pixel spill
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

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: true, // Calendar has no AppBar
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
        child: Column(
          children: [
            // Month selector (header inside the body)
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

            // 👉 Removed the “emoji 1×” top bar you didn’t want

            // Calendar card container (rounded)
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
                    const _WeekdaysMonFirst(), // Mon..Sun
                    const SizedBox(height: 6), // slightly tighter
                    // Scrollable grid so it never overflows on small phones
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 7,
                        // make cells a bit taller (smaller ratio) to prevent
                        // “bottom overflowed by 2–3 pixels” on compact devices
                        childAspectRatio: 0.78, // was 0.86
                        mainAxisSpacing: 6,     // was 8
                        crossAxisSpacing: 6,    // was 8
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

// — UI bits — //

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
          border:
          Border.all(color: Theme.of(context).dividerColor.withOpacity(.3)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

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
