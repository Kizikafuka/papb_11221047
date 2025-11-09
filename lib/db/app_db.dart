import 'dart:io';                            // buat akses file lokal (SQLite file)
import 'package:drift/drift.dart';           // package utama untuk ORM (Object Relational Mapping)
import 'package:drift/native.dart';          // driver untuk database lokal (SQLite)
import 'package:path_provider/path_provider.dart'; // buat dapetin direktori aplikasi
import 'package:path/path.dart' as p;        // bantu gabungin path file (misal "folder/namafile.sqlite")

import '../models/mood.dart';                // enum Mood (VeryGood, Good, dll)

// ini penting biar Drift bisa generate kode otomatis (part file)
part 'app_db.g.dart';


// === KONVERTER ===
// Konversi enum Mood <-> int biar bisa disimpan di database
class MoodConverter extends TypeConverter<Mood, int> {
  const MoodConverter();

  // dari database (int) -> ke enum Mood
  @override
  Mood fromSql(int fromDb) => Mood.values[fromDb];

  // dari enum Mood -> ke int (buat disimpan)
  @override
  int toSql(Mood value) => value.index;
}

/// Konverter untuk List<String> <-> String (disimpan sebagai teks dipisah koma)
class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return fromDb
        .split(',')                      // pisah berdasarkan koma
        .map((e) => e.trim())            // hapus spasi di pinggir
        .where((e) => e.isNotEmpty)      // buang yang kosong
        .toList();
  }

  @override
  String toSql(List<String> value) => value.join(','); // gabung lagi jadi string
}


// === DEFINISI TABEL ===
@DataClassName('DbMoodEntry') // nama class data hasil query
class MoodEntries extends Table {
  // kolom tanggal (jadi primary key)
  DateTimeColumn get date => dateTime()();

  // kolom mood
  IntColumn get mood => integer().map(const MoodConverter())();

  // kolom tags
  TextColumn get tags =>
      text().map(const TagsConverter()).withDefault(const Constant(''))();

  // kolom note opsional
  TextColumn get note => text().withDefault(const Constant(''))();

  // set primary key-nya adalah kolom date (1 hari 1 data)
  @override
  Set<Column> get primaryKey => {date};
}


// === DATABASE ===
@DriftDatabase(tables: [MoodEntries])
class AppDb extends _$AppDb {
  AppDb() : super(_openDb()); // panggil fungsi buat buka database

  // versi skema (naik kalau ubah tabel/kolom)
  @override
  int get schemaVersion => 1;

  // strategi migrasi (buat update versi database nanti)
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),  // saat pertama kali dibuat -> buat semua tabel
    onUpgrade: (m, from, to) async {
      // kalau nanti versi berubah bisa tambah alter table di sini
    },
  );


  // Tambah / update data mood (kalau tanggal udah ada -> update)
  Future<void> upsertEntry({
    required DateTime date,
    required Mood mood,
    required List<String> tags,
    required String note,
  }) async {
    final d0 = DateTime(date.year, date.month, date.day); // reset ke tengah malam
    await into(moodEntries).insertOnConflictUpdate(
      MoodEntriesCompanion(
        date: Value(d0),
        mood: Value(mood),
        tags: Value(tags),
        note: Value(note),
      ),
    );
  }

  // Ambil satu entry berdasarkan tanggal
  Future<DbMoodEntry?> getEntry(DateTime date) {
    final d0 = DateTime(date.year, date.month, date.day);
    return (select(moodEntries)..where((t) => t.date.equals(d0)))
        .getSingleOrNull();
  }

  // Stream untuk terus "memantau" 1 tanggal (biar UI auto update)
  Stream<DbMoodEntry?> watchEntry(DateTime date) {
    final d0 = DateTime(date.year, date.month, date.day);
    return (select(moodEntries)..where((t) => t.date.equals(d0)))
        .watchSingleOrNull();
  }

  // Stream untuk "memantau" banyak tanggal sekaligus (misal sebulan)
  Stream<List<DbMoodEntry>> watchRange(DateTime start, DateTime end) {
    final s0 = DateTime(start.year, start.month, start.day);
    final e0 = DateTime(end.year, end.month, end.day);
    return (select(moodEntries)
      ..where((t) => t.date.isBetweenValues(s0, e0))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }
}


// === FUNGSI BUKA DATABASE ===
LazyDatabase _openDb() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory(); // direktori aplikasi
    final file = File(p.join(dir.path, 'coowdi.sqlite')); // nama file db
    return NativeDatabase.createInBackground(file); // buat database di background
  });
}
