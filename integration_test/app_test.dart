import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:calorie_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Calorie Tracker Integration Tests', () {

    // Test 1: Modify daily calorie target
    testWidgets('Test 1: Modify daily calorie target', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Click Settings tab
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      // Verify entered settings page
      expect(find.text('每日卡路里目标'), findsOneWidget);

      // Clear and input new target value
      final targetField = find.byType(TextField).first;
      await tester.tap(targetField);
      await tester.pumpAndSettle();

      await tester.enterText(targetField, '');
      await tester.pumpAndSettle();

      await tester.enterText(targetField, '2000');
      await tester.pumpAndSettle();

      // Click save button
      await tester.tap(find.text('保存目标'));
      await tester.pumpAndSettle();

      // Return to home page
      await tester.tap(find.text('首页'));
      await tester.pumpAndSettle();

      // Verify target value is updated to 2000
      expect(find.byKey(const Key('target_value')), findsOneWidget);
      final targetWidget = tester.widget<Text>(find.byKey(const Key('target_value')));
      expect(targetWidget.data, '2000');
    });

    // Test 2: Add meals (breakfast, lunch, dinner)
    testWidgets('Test 2: Add three meals food records', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add breakfast - Rice
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('早餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('米饭'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Add breakfast - Egg
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('早餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('鸡蛋'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Add lunch - Noodles
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('午餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('面条'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Add lunch - Milk
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('午餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('牛奶'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Add dinner - Chicken
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('晚餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('鸡胸'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Add dinner - Salad
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('晚餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('沙拉'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Verify all foods are displayed on home page
      expect(find.textContaining('米饭'), findsOneWidget);
      expect(find.textContaining('鸡蛋'), findsOneWidget);
      expect(find.textContaining('面条'), findsOneWidget);
      expect(find.textContaining('牛奶'), findsOneWidget);
      expect(find.textContaining('鸡胸'), findsOneWidget);
      expect(find.textContaining('沙拉'), findsOneWidget);
    });

    // Test 3: Delete food record
    testWidgets('Test 3: Delete food record', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add a food record first
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('早餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('米饭'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Tap on the rice record to delete
      await tester.tap(find.textContaining('米饭'));
      await tester.pumpAndSettle();

      // Verify delete dialog appears
      expect(find.text('确认删除'), findsOneWidget);

      // Click confirm button
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();

      // Verify rice text disappears
      expect(find.textContaining('米饭'), findsNothing);
    });

    // Test 4: View history records
    testWidgets('Test 4: View history records', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add a food record first
      await tester.tap(find.byKey(const Key('fab_add')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('早餐'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('米饭'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('保存记录'));
      await tester.pumpAndSettle();

      // Click History tab
      await tester.tap(find.text('历史'));
      await tester.pumpAndSettle();

      // Verify month display
      expect(find.textContaining('月'), findsWidgets);

      // Click first date record (today)
      final dateCards = find.byType(Card);
      if (dateCards.evaluate().isNotEmpty) {
        // Find the first clickable card that's not the month selector
        final cards = tester.widgetList<Card>(dateCards).toList();
        if (cards.length > 1) {
          await tester.tap(dateCards.at(1));
          await tester.pumpAndSettle();

          // Verify rice is displayed in detail page
          expect(find.textContaining('米饭'), findsOneWidget);
        }
      }
    });
  });
}
