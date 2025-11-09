import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/mood.dart';
import '../db/app_db.dart';

/// Model sederhana yang dipakai di layer UI/state
class MoodEntry {
  MoodEntry({
    required this.date,
    required this.mood,
    required this.tags,
    required this.note,
  });

  DateTime date;         // diset ke midnight (00:00) agar unik per-hari
  Mood mood;
  List<String> tags;     // contoh: ['friends','date']
  String note;
}

/// State app untuk jurnal harian (provider: ChangeNotifier)
class JournalState extends ChangeNotifier {
  JournalState({required AppDb db}) : _db = db;

  final AppDb _db;

  // Cache lokal: key = 'yyyy-MM-dd' → value = MoodEntry
  // Tujuan: cepat render UI tanpa query DB terus-terusan
  final Map<String, MoodEntry> _byDay = {};

  // Utility: normalisasi tanggal ke 00:00 (hapus jam/menit/detik)
  static DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

  // Utility: buat key string stabil dari tanggal (dipakai untuk _byDay)
  static String dayKey(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(_atMidnight(d));

  // Ambil entry dari cache untuk suatu tanggal (bisa null)
  MoodEntry? entryFor(DateTime d) => _byDay[dayKey(d)];

  /// Pastikan entry suatu hari sudah ada di cache.
  /// - Jika sudah ada → no-op.
  /// - Jika belum → fetch 1 row dari DB, lalu masukin ke cache.
  Future<void> ensureLoaded(DateTime d) async {
    final key = dayKey(d);
    if (_byDay.containsKey(key)) return; // sudah ada di cache → selesai

    final row = await _db.getEntry(d);   // query sekali (Future, non-stream)
    if (row != null) {
      _byDay[key] = MoodEntry(
        date: row.date,
        mood: row.mood,
        tags: row.tags,
        note: row.note,
      );
      notifyListeners(); // kasih tau widget: data berubah
    }
  }

  /// Simpan/Update entry (upsert) lalu sinkronkan cache.
  Future<void> save(MoodEntry e) async {
    final d0 = _atMidnight(e.date); // konsisten simpan pada 00:00
    await _db.upsertEntry(
      date: d0,
      mood: e.mood,
      tags: e.tags,
      note: e.note,
    );

    // Update cache lokal supaya UI langsung ke-refresh tanpa nunggu stream
    _byDay[dayKey(d0)] =
        MoodEntry(date: d0, mood: e.mood, tags: e.tags, note: e.note);

    notifyListeners();
  }

  void watchMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    _db.watchRange(first, last).listen((rows) {
      // Set opsional: bisa dipakai untuk menandai key2 yang aktif bulan ini
      final keysInMonth = <String>{};

      for (final r in rows) {
        final k = dayKey(r.date);
        keysInMonth.add(k);

        // Update/insert ke cache setiap ada row di bulan tsb
        _byDay[k] = MoodEntry(
          date: r.date,
          mood: r.mood,
          tags: r.tags,
          note: r.note,
        );
      }


      notifyListeners();
    });
  }
}
