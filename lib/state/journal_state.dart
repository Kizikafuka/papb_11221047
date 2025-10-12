import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/mood.dart';
import '../db/app_db.dart';

class MoodEntry {
  MoodEntry({
    required this.date,
    required this.mood,
    required this.tags,
    required this.note,
  });

  DateTime date;         // midnight for per-day uniqueness
  Mood mood;
  List<String> tags;     // e.g., ['friends','date']
  String note;
}

class JournalState extends ChangeNotifier {
  JournalState({required AppDb db}) : _db = db;

  final AppDb _db;

  final Map<String, MoodEntry> _byDay = {}; // cache: yyyy-MM-dd -> entry

  static DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);
  static String dayKey(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(_atMidnight(d));

  MoodEntry? entryFor(DateTime d) => _byDay[dayKey(d)];

  /// Ensure an entry for a given day is loaded into cache (no-op if present)
  Future<void> ensureLoaded(DateTime d) async {
    final key = dayKey(d);
    if (_byDay.containsKey(key)) return;
    final row = await _db.getEntry(d);
    if (row != null) {
      _byDay[key] = MoodEntry(
        date: row.date,
        mood: row.mood,
        tags: row.tags,
        note: row.note,
      );
      notifyListeners();
    }
  }

  /// Save or update an entry
  Future<void> save(MoodEntry e) async {
    final d0 = _atMidnight(e.date);
    await _db.upsertEntry(
      date: d0,
      mood: e.mood,
      tags: e.tags,
      note: e.note,
    );
    _byDay[dayKey(d0)] =
        MoodEntry(date: d0, mood: e.mood, tags: e.tags, note: e.note);
    notifyListeners();
  }

  /// Subscribe to a month; keeps cache fresh for calendar UI
  void watchMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    _db.watchRange(first, last).listen((rows) {
      final keysInMonth = <String>{};

      for (final r in rows) {
        final k = dayKey(r.date);
        keysInMonth.add(k);
        _byDay[k] = MoodEntry(
          date: r.date,
          mood: r.mood,
          tags: r.tags,
          note: r.note,
        );
      }

      // (Optional) could clear stale days in this month not in keysInMonth.
      notifyListeners();
    });
  }
}
