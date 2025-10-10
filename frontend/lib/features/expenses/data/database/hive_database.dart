import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketly/features/expenses/data/models/expense_hive.dart';

class HiveDatabase {
  static const String _expenseBoxName = 'expenses';
  static Box<ExpenseHive>? _expenseBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ExpenseHiveAdapter());

    // Open boxes
    _expenseBox = await Hive.openBox<ExpenseHive>(_expenseBoxName);
  }

  static Box<ExpenseHive> get expenseBox {
    if (_expenseBox == null) {
      throw Exception(
        'HiveDatabase not initialized. Call HiveDatabase.init() first.',
      );
    }
    return _expenseBox!;
  }

  static Future<void> close() async {
    await _expenseBox?.close();
    _expenseBox = null;
  }

  static Future<void> clearAll() async {
    await _expenseBox?.clear();
  }
}
