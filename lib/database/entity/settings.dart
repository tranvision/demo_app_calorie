import 'package:floor/floor.dart';

@Entity()
class Settings {
  @PrimaryKey()
  final int id; // Fixed as 1
  final int dailyTarget; // Daily calorie target, default 1800

  Settings({
    required this.id,
    required this.dailyTarget,
  });
}
