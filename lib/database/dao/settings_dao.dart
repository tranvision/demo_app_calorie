import 'package:floor/floor.dart';
import '../entity/settings.dart';

@dao
abstract class SettingsDao {
  @Query('SELECT * FROM Settings WHERE id = 1')
  Future<Settings?> getSettings();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrUpdate(Settings settings);
}
