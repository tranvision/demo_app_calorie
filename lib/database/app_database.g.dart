// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  FoodRecordDao? _foodRecordDaoInstance;

  SettingsDao? _settingsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `FoodRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `calories` INTEGER NOT NULL, `mealType` TEXT NOT NULL, `recordDate` TEXT NOT NULL, `createdAt` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Settings` (`id` INTEGER NOT NULL, `dailyTarget` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  FoodRecordDao get foodRecordDao {
    return _foodRecordDaoInstance ??= _$FoodRecordDao(database, changeListener);
  }

  @override
  SettingsDao get settingsDao {
    return _settingsDaoInstance ??= _$SettingsDao(database, changeListener);
  }
}

class _$FoodRecordDao extends FoodRecordDao {
  _$FoodRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _foodRecordInsertionAdapter = InsertionAdapter(
            database,
            'FoodRecord',
            (FoodRecord item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'calories': item.calories,
                  'mealType': item.mealType,
                  'recordDate': item.recordDate,
                  'createdAt': item.createdAt
                }),
        _foodRecordDeletionAdapter = DeletionAdapter(
            database,
            'FoodRecord',
            ['id'],
            (FoodRecord item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'calories': item.calories,
                  'mealType': item.mealType,
                  'recordDate': item.recordDate,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FoodRecord> _foodRecordInsertionAdapter;

  final DeletionAdapter<FoodRecord> _foodRecordDeletionAdapter;

  @override
  Future<List<FoodRecord>> findByDate(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM FoodRecord WHERE recordDate = ?1',
        mapper: (Map<String, Object?> row) => FoodRecord(
            id: row['id'] as int?,
            name: row['name'] as String,
            calories: row['calories'] as int,
            mealType: row['mealType'] as String,
            recordDate: row['recordDate'] as String,
            createdAt: row['createdAt'] as String),
        arguments: [date]);
  }

  @override
  Future<List<FoodRecord>> findByMonth(String monthPattern) async {
    return _queryAdapter.queryList(
        'SELECT * FROM FoodRecord WHERE recordDate LIKE ?1',
        mapper: (Map<String, Object?> row) => FoodRecord(
            id: row['id'] as int?,
            name: row['name'] as String,
            calories: row['calories'] as int,
            mealType: row['mealType'] as String,
            recordDate: row['recordDate'] as String,
            createdAt: row['createdAt'] as String),
        arguments: [monthPattern]);
  }

  @override
  Future<void> deleteAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM FoodRecord');
  }

  @override
  Future<int> insertRecord(FoodRecord record) {
    return _foodRecordInsertionAdapter.insertAndReturnId(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteRecord(FoodRecord record) {
    return _foodRecordDeletionAdapter.deleteAndReturnChangedRows(record);
  }
}

class _$SettingsDao extends SettingsDao {
  _$SettingsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _settingsInsertionAdapter = InsertionAdapter(
            database,
            'Settings',
            (Settings item) => <String, Object?>{
                  'id': item.id,
                  'dailyTarget': item.dailyTarget
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Settings> _settingsInsertionAdapter;

  @override
  Future<Settings?> getSettings() async {
    return _queryAdapter.query('SELECT * FROM Settings WHERE id = 1',
        mapper: (Map<String, Object?> row) => Settings(
            id: row['id'] as int, dailyTarget: row['dailyTarget'] as int));
  }

  @override
  Future<void> insertOrUpdate(Settings settings) async {
    await _settingsInsertionAdapter.insert(
        settings, OnConflictStrategy.replace);
  }
}
