import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../database/entity/food_record.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  String _selectedMealType = 'breakfast';
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _isRecognizing = false;

  final Map<String, Map<String, dynamic>> _quickFoods = {
    '米饭': {'emoji': '🍚', 'calories': 280},
    '面条': {'emoji': '🍜', 'calories': 350},
    '鸡蛋': {'emoji': '🥚', 'calories': 70},
    '苹果': {'emoji': '🍎', 'calories': 52},
    '香蕉': {'emoji': '🍌', 'calories': 89},
    '牛奶': {'emoji': '🥛', 'calories': 150},
    '鸡胸': {'emoji': '🍗', 'calories': 165},
    '沙拉': {'emoji': '🥗', 'calories': 50},
  };

  @override
  void initState() {
    super.initState();
    _selectDefaultMealType();
  }

  void _selectDefaultMealType() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 10) {
      _selectedMealType = 'breakfast';
    } else if (hour >= 10 && hour < 14) {
      _selectedMealType = 'lunch';
    } else if (hour >= 14 && hour < 18) {
      _selectedMealType = 'snack';
    } else if (hour >= 18 && hour < 22) {
      _selectedMealType = 'dinner';
    } else {
      _selectedMealType = 'snack';
    }
    setState(() {});
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _isRecognizing = true;
      });

      try {
        final bytes = await File(photo.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final extension = photo.path.split('.').last.toLowerCase();
        final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

        final response = await http.post(
          Uri.parse('https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer sk-4247310fbd91423f8edace6993f06235',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'qwen-vl-plus',
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text': '图中主要物体是什么？只回答一个词，例如：苹果、猫、汽车。'
                  },
                  {
                    'type': 'image_url',
                    'image_url': {
                      'url': 'data:$mimeType;base64,$base64Image'
                    }
                  }
                ]
              }
            ],
            'max_tokens': 20,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final foodName = data['choices'][0]['message']['content'].trim();

          setState(() {
            _nameController.text = foodName;

            // Check if food is in quick food list
            if (_quickFoods.containsKey(foodName)) {
              _caloriesController.text = _quickFoods[foodName]!['calories'].toString();
            } else {
              // Random calories between 300-500
              final randomCalories = 300 + Random().nextInt(201);
              _caloriesController.text = randomCalories.toString();
            }
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('识别失败，请重试')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('识别出错: $e')),
          );
        }
      } finally {
        setState(() {
          _isRecognizing = false;
        });
      }
    }
  }

  Future<void> _saveRecord() async {
    final name = _nameController.text.trim();
    final caloriesText = _caloriesController.text.trim();

    if (name.isEmpty || caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    final calories = int.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的卡路里数值')),
      );
      return;
    }

    final now = DateTime.now();
    final record = FoodRecord(
      name: name,
      calories: calories,
      mealType: _selectedMealType,
      recordDate: now.toString().substring(0, 10),
      createdAt: now.toIso8601String(),
    );

    await database.foodRecordDao.insertRecord(record);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _selectQuickFood(String name) {
    final food = _quickFoods[name]!;
    setState(() {
      _nameController.text = name;
      _caloriesController.text = food['calories'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('添加食物'),
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
          child: _isRecognizing
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('识别中...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const Text(
                      '选择餐次：',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'breakfast', label: Text('早餐')),
                        ButtonSegment(value: 'lunch', label: Text('午餐')),
                        ButtonSegment(value: 'dinner', label: Text('晚餐')),
                        ButtonSegment(value: 'snack', label: Text('零食')),
                      ],
                      selected: {_selectedMealType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedMealType = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '食物名称：',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '请输入食物名称',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: _takePicture,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 20),
                              SizedBox(width: 8),
                              Text(
                                '📷 拍照识别食物',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '卡路里（kcal）：',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '例如：165',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '快捷选择：',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickFoods.entries.map((entry) {
                        return InkWell(
                          onTap: () => _selectQuickFood(entry.key),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: 90,
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    entry.value['emoji'],
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    '${entry.value['calories']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      key: const Key('save_record_button'),
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4FCF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '保存记录',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
