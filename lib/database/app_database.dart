import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/food_record_dao.dart';
import 'dao/settings_dao.dart';
import 'entity/food_record.dart';
import 'entity/settings.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [FoodRecord, Settings])
abstract class AppDatabase extends FloorDatabase {
  FoodRecordDao get foodRecordDao;
  SettingsDao get settingsDao;
}
