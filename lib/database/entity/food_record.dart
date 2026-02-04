import 'package:floor/floor.dart';

@Entity()
class FoodRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final int calories;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String recordDate; // 'YYYY-MM-DD' format
  final String createdAt; // ISO8601 timestamp

  FoodRecord({
    this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.recordDate,
    required this.createdAt,
  });
}
