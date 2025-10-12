// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $MoodEntriesTable extends MoodEntries
    with TableInfo<$MoodEntriesTable, DbMoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<Mood, int> mood =
      GeneratedColumn<int>('mood', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<Mood>($MoodEntriesTable.$convertermood);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant(''))
          .withConverter<List<String>>($MoodEntriesTable.$convertertags);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [date, mood, tags, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DbMoodEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DbMoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbMoodEntry(
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      mood: $MoodEntriesTable.$convertermood.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mood'])!),
      tags: $MoodEntriesTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $MoodEntriesTable createAlias(String alias) {
    return $MoodEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<Mood, int> $convertermood = const MoodConverter();
  static TypeConverter<List<String>, String> $convertertags =
      const TagsConverter();
}

class DbMoodEntry extends DataClass implements Insertable<DbMoodEntry> {
  /// Store the date at midnight; use as primary key
  final DateTime date;

  /// Store Mood as int via converter
  final Mood mood;

  /// CSV tags via converter
  final List<String> tags;

  /// Optional note
  final String note;
  const DbMoodEntry(
      {required this.date,
      required this.mood,
      required this.tags,
      required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    {
      map['mood'] = Variable<int>($MoodEntriesTable.$convertermood.toSql(mood));
    }
    {
      map['tags'] =
          Variable<String>($MoodEntriesTable.$convertertags.toSql(tags));
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  MoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoodEntriesCompanion(
      date: Value(date),
      mood: Value(mood),
      tags: Value(tags),
      note: Value(note),
    );
  }

  factory DbMoodEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbMoodEntry(
      date: serializer.fromJson<DateTime>(json['date']),
      mood: serializer.fromJson<Mood>(json['mood']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'mood': serializer.toJson<Mood>(mood),
      'tags': serializer.toJson<List<String>>(tags),
      'note': serializer.toJson<String>(note),
    };
  }

  DbMoodEntry copyWith(
          {DateTime? date, Mood? mood, List<String>? tags, String? note}) =>
      DbMoodEntry(
        date: date ?? this.date,
        mood: mood ?? this.mood,
        tags: tags ?? this.tags,
        note: note ?? this.note,
      );
  DbMoodEntry copyWithCompanion(MoodEntriesCompanion data) {
    return DbMoodEntry(
      date: data.date.present ? data.date.value : this.date,
      mood: data.mood.present ? data.mood.value : this.mood,
      tags: data.tags.present ? data.tags.value : this.tags,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbMoodEntry(')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('tags: $tags, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, mood, tags, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbMoodEntry &&
          other.date == this.date &&
          other.mood == this.mood &&
          other.tags == this.tags &&
          other.note == this.note);
}

class MoodEntriesCompanion extends UpdateCompanion<DbMoodEntry> {
  final Value<DateTime> date;
  final Value<Mood> mood;
  final Value<List<String>> tags;
  final Value<String> note;
  final Value<int> rowid;
  const MoodEntriesCompanion({
    this.date = const Value.absent(),
    this.mood = const Value.absent(),
    this.tags = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodEntriesCompanion.insert({
    required DateTime date,
    required Mood mood,
    this.tags = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : date = Value(date),
        mood = Value(mood);
  static Insertable<DbMoodEntry> custom({
    Expression<DateTime>? date,
    Expression<int>? mood,
    Expression<String>? tags,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (mood != null) 'mood': mood,
      if (tags != null) 'tags': tags,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodEntriesCompanion copyWith(
      {Value<DateTime>? date,
      Value<Mood>? mood,
      Value<List<String>>? tags,
      Value<String>? note,
      Value<int>? rowid}) {
    return MoodEntriesCompanion(
      date: date ?? this.date,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (mood.present) {
      map['mood'] =
          Variable<int>($MoodEntriesTable.$convertermood.toSql(mood.value));
    }
    if (tags.present) {
      map['tags'] =
          Variable<String>($MoodEntriesTable.$convertertags.toSql(tags.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntriesCompanion(')
          ..write('date: $date, ')
          ..write('mood: $mood, ')
          ..write('tags: $tags, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $MoodEntriesTable moodEntries = $MoodEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [moodEntries];
}

typedef $$MoodEntriesTableCreateCompanionBuilder = MoodEntriesCompanion
    Function({
  required DateTime date,
  required Mood mood,
  Value<List<String>> tags,
  Value<String> note,
  Value<int> rowid,
});
typedef $$MoodEntriesTableUpdateCompanionBuilder = MoodEntriesCompanion
    Function({
  Value<DateTime> date,
  Value<Mood> mood,
  Value<List<String>> tags,
  Value<String> note,
  Value<int> rowid,
});

class $$MoodEntriesTableFilterComposer
    extends Composer<_$AppDb, $MoodEntriesTable> {
  $$MoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Mood, Mood, int> get mood =>
      $composableBuilder(
          column: $table.mood,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<List<String>, List<String>, String> get tags =>
      $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$MoodEntriesTableOrderingComposer
    extends Composer<_$AppDb, $MoodEntriesTable> {
  $$MoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$MoodEntriesTableAnnotationComposer
    extends Composer<_$AppDb, $MoodEntriesTable> {
  $$MoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Mood, int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MoodEntriesTableTableManager extends RootTableManager<
    _$AppDb,
    $MoodEntriesTable,
    DbMoodEntry,
    $$MoodEntriesTableFilterComposer,
    $$MoodEntriesTableOrderingComposer,
    $$MoodEntriesTableAnnotationComposer,
    $$MoodEntriesTableCreateCompanionBuilder,
    $$MoodEntriesTableUpdateCompanionBuilder,
    (DbMoodEntry, BaseReferences<_$AppDb, $MoodEntriesTable, DbMoodEntry>),
    DbMoodEntry,
    PrefetchHooks Function()> {
  $$MoodEntriesTableTableManager(_$AppDb db, $MoodEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> date = const Value.absent(),
            Value<Mood> mood = const Value.absent(),
            Value<List<String>> tags = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MoodEntriesCompanion(
            date: date,
            mood: mood,
            tags: tags,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime date,
            required Mood mood,
            Value<List<String>> tags = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MoodEntriesCompanion.insert(
            date: date,
            mood: mood,
            tags: tags,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MoodEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDb,
    $MoodEntriesTable,
    DbMoodEntry,
    $$MoodEntriesTableFilterComposer,
    $$MoodEntriesTableOrderingComposer,
    $$MoodEntriesTableAnnotationComposer,
    $$MoodEntriesTableCreateCompanionBuilder,
    $$MoodEntriesTableUpdateCompanionBuilder,
    (DbMoodEntry, BaseReferences<_$AppDb, $MoodEntriesTable, DbMoodEntry>),
    DbMoodEntry,
    PrefetchHooks Function()>;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$MoodEntriesTableTableManager get moodEntries =>
      $$MoodEntriesTableTableManager(_db, _db.moodEntries);
}
