import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketly/features/expenses/data/models/expense_isar.dart';

class IsarDatabase {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    _isar = await _openDatabase();
    return _isar!;
  }

  static Future<Isar> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    return await Isar.open(
      [ExpenseIsarSchema],
      directory: dir.path,
      name: 'PocketlyDatabase',
    );
  }

  static Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}
