import 'package:floor/floor.dart';
import '../entity/food_record.dart';

@dao
abstract class FoodRecordDao {
  @Query('SELECT * FROM FoodRecord WHERE recordDate = :date')
  Future<List<FoodRecord>> findByDate(String date);

  @Query('SELECT * FROM FoodRecord WHERE recordDate LIKE :monthPattern')
  Future<List<FoodRecord>> findByMonth(String monthPattern);

  @Insert()
  Future<int> insertRecord(FoodRecord record);

  @delete
  Future<int> deleteRecord(FoodRecord record);

  @Query('DELETE FROM FoodRecord')
  Future<void> deleteAll();
}
