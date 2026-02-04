import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../database/entity/food_record.dart';
import 'add_food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<FoodRecord> _todayRecords = [];
  int _dailyTarget = 1800;
  bool _showPromoCard = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadPromoCardState();
  }

  Future<void> _loadPromoCardState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Hide promo card by default (can be enabled by user)
      _showPromoCard = prefs.getBool('show_promo_card') ?? false;
    });
  }

  Future<void> _hidePromoCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_promo_card', false);
    setState(() {
      _showPromoCard = false;
    });
  }

  void refresh() {
    _loadData();
  }

  Future<void> _loadData() async {
    final today = DateTime.now().toString().substring(0, 10);
    final records = await database.foodRecordDao.findByDate(today);
    final settings = await database.settingsDao.getSettings();

    setState(() {
      _todayRecords = records;
      _dailyTarget = settings?.dailyTarget ?? 1800;
    });
  }

  int get _totalCalories {
    return _todayRecords.fold(0, (sum, record) => sum + record.calories);
  }

  int get _remaining {
    return _dailyTarget - _totalCalories;
  }

  Color _getProgressColor() {
    final percentage = _totalCalories / _dailyTarget;
    if (percentage > 1.0) return Colors.red;
    if (percentage > 0.85) return Colors.orange;
    if (percentage > 0.70) return Colors.lightGreen;
    return Colors.green;
  }

  Map<String, List<FoodRecord>> _groupByMealType() {
    final grouped = <String, List<FoodRecord>>{
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };
    for (var record in _todayRecords) {
      grouped[record.mealType]?.add(record);
    }
    return grouped;
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
    final grouped = _groupByMealType();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      '自律茄子',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatCard(),
                    if (_showPromoCard) ...[
                      const SizedBox(height: 16),
                      _buildPromoCard(),
                    ],
                    const SizedBox(height: 16),
                    for (var mealType in ['breakfast', 'lunch', 'dinner', 'snack'])
                      if (grouped[mealType]!.isNotEmpty) ...[
                        _buildMealSection(mealType, grouped[mealType]!),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('fab_add'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFoodPage()),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFF1565C0),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard() {
    final percentage = _dailyTarget > 0 ? (_totalCalories / _dailyTarget).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('🍽 已摄入', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalCalories',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('🎯 目标', style: TextStyle(fontSize: 14), key: Key('target_label')),
                    const SizedBox(height: 4),
                    Text(
                      '$_dailyTarget',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      key: const Key('target_value'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${_remaining.abs()}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _remaining >= 0 ? '剩余' : '超标',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientInfo('🥚 蛋白质', '0 / 87.2克'),
                _buildNutrientInfo('🍞 碳水化合物', '0 / 207.6克'),
                _buildNutrientInfo('🧈 脂肪', '0 / 23.5克'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPromoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '您的专属好礼',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '立即解锁高级功能，仅需',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: _hidePromoCard,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '¥148/年',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(原价 ¥328)',
                  style: TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('这是一个演示功能')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('继续', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealType, List<FoodRecord> records) {
    final totalCalories = records.fold(0, (sum, r) => sum + r.calories);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMealTypeIcon(mealType)} ${_getMealTypeName(mealType)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalCalories',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var record in records)
              InkWell(
                onTap: () => _deleteRecord(record),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text('├─ ', style: TextStyle(color: Colors.grey)),
                            Expanded(
                              child: Text(record.name),
                            ),
                            Text(
                              '·' * 10,
                              style: TextStyle(color: Colors.grey[400], letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${record.calories}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
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
