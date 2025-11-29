import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketly/features/expenses/data/models/expense_hive.dart';
import 'package:pocketly/features/expenses/data/models/category_hive.dart';

class HiveDatabase {
  static const String _expenseBoxName = 'expenses';
  static const String _categoryBoxName = 'categories';
  static Box<ExpenseHive>? _expenseBox;
  static Box<CategoryHive>? _categoryBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ExpenseHiveAdapter());
    Hive.registerAdapter(CategoryHiveAdapter());

    // Open boxes
    _expenseBox = await Hive.openBox<ExpenseHive>(_expenseBoxName);
    _categoryBox = await Hive.openBox<CategoryHive>(_categoryBoxName);
  }

  static Box<ExpenseHive> get expenseBox {
    if (_expenseBox == null) {
      throw Exception(
        'HiveDatabase not initialized. Call HiveDatabase.init() first.',
      );
    }
    return _expenseBox!;
  }

  static Box<CategoryHive> get categoryBox {
    if (_categoryBox == null) {
      throw Exception(
        'HiveDatabase not initialized. Call HiveDatabase.init() first.',
      );
    }
    return _categoryBox!;
  }

  static Future<void> close() async {
    await _expenseBox?.close();
    await _categoryBox?.close();
    _expenseBox = null;
    _categoryBox = null;
  }

  static Future<void> clearAll() async {
    await _expenseBox?.clear();
    await _categoryBox?.clear();
  }
}
