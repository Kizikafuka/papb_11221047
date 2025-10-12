import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/mood.dart';

part 'app_db.g.dart';

class MoodConverter extends TypeConverter<Mood, int> {
  const MoodConverter();

  @override
  Mood fromSql(int fromDb) => Mood.values[fromDb];

  @override
  int toSql(Mood value) => value.index;
}

/// Convert List<String> <-> comma-separated string
class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return fromDb
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  String toSql(List<String> value) => value.join(',');
}

@DataClassName('DbMoodEntry')
class MoodEntries extends Table {
  DateTimeColumn get date => dateTime()();


  IntColumn get mood => integer().map(const MoodConverter())();


  TextColumn get tags =>
      text().map(const TagsConverter()).withDefault(const Constant(''))();

  /// Optional note
  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(tables: [MoodEntries])
class AppDb extends _$AppDb {
  AppDb() : super(_openDb());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // handle future migrations here
    },
  );

  // ===== CRUD helpers =====

  Future<void> upsertEntry({
    required DateTime date,
    required Mood mood,
    required List<String> tags,
    required String note,
  }) async {
    final d0 = DateTime(date.year, date.month, date.day);
    await into(moodEntries).insertOnConflictUpdate(
      // Use default companion + Value(...)
      MoodEntriesCompanion(
        date: Value(d0),
        mood: Value(mood),
        tags: Value(tags),
        note: Value(note),
      ),
    );
  }

  Future<DbMoodEntry?> getEntry(DateTime date) {
    final d0 = DateTime(date.year, date.month, date.day);
    return (select(moodEntries)..where((t) => t.date.equals(d0)))
        .getSingleOrNull();
  }

  Stream<DbMoodEntry?> watchEntry(DateTime date) {
    final d0 = DateTime(date.year, date.month, date.day);
    return (select(moodEntries)..where((t) => t.date.equals(d0)))
        .watchSingleOrNull();
  }

  /// Watch entries in [start, end] inclusive – handy for calendar months
  Stream<List<DbMoodEntry>> watchRange(DateTime start, DateTime end) {
    final s0 = DateTime(start.year, start.month, start.day);
    final e0 = DateTime(end.year, end.month, end.day);
    return (select(moodEntries)
      ..where((t) => t.date.isBetweenValues(s0, e0))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }
}

LazyDatabase _openDb() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'coowdi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
