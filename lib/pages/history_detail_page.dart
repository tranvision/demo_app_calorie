import 'package:flutter/material.dart';
import '../main.dart';
import '../database/entity/food_record.dart';

class HistoryDetailPage extends StatefulWidget {
  final String date;

  const HistoryDetailPage({super.key, required this.date});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  List<FoodRecord> _records = [];
  int _dailyTarget = 1800;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await database.settingsDao.getSettings();
    final records = await database.foodRecordDao.findByDate(widget.date);

    setState(() {
      _dailyTarget = settings?.dailyTarget ?? 1800;
      _records = records;
    });
  }

  Map<String, List<FoodRecord>> _groupByMealType() {
    final grouped = <String, List<FoodRecord>>{
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };
    for (var record in _records) {
      grouped[record.mealType]?.add(record);
    }
    return grouped;
  }

  int get _totalCalories {
    return _records.fold(0, (sum, record) => sum + record.calories);
  }

  String _getMealTypeName(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '早餐';
      case 'lunch':
        return '午餐';
      case 'dinner':
        return '晚餐';
      case 'snack':
        return '零食';
      default:
        return mealType;
    }
  }

  String _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍪';
      default:
        return '';
    }
  }

  Future<void> _deleteRecord(FoodRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await database.foodRecordDao.deleteRecord(record);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = _groupByMealType();

    final parsedDate = DateTime.parse(widget.date);
    final day = parsedDate.day;
    final month = parsedDate.month;

    return Scaffold(
      appBar: AppBar(
        title: Text('$month月$day日 详情'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2E2E2E)]
                : [const Color(0xFFE8E0F0), const Color(0xFFF5F0FA)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '总计：$_totalCalories kcal / $_dailyTarget kcal',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var mealType in ['breakfast', 'lunch', 'dinner', 'snack'])
                if (grouped[mealType]!.isNotEmpty) ...[
                  _buildMealSection(mealType, grouped[mealType]!),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealType, List<FoodRecord> records) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getMealTypeIcon(mealType)} ${_getMealTypeName(mealType)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (var record in records)
              InkWell(
                onTap: () => _deleteRecord(record),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${record.calories} kcal',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
