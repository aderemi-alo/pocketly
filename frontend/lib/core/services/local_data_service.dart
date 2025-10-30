import 'package:hive/hive.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';

class LocalDataService {
  /// Check if user has any local data (expenses)
  static bool hasLocalData() {
    try {
      final box = HiveDatabase.expenseBox;
      return box.isNotEmpty;
    } catch (e) {
      // If Hive is not initialized or has errors, assume no local data
      return false;
    }
  }

  /// Get count of local expenses
  static int getLocalDataCount() {
    try {
      final box = HiveDatabase.expenseBox;
      return box.length;
    } catch (e) {
      return 0;
    }
  }
}
