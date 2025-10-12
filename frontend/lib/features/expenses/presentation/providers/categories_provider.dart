import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

final categoriesProvider = Provider<List<Category>>((ref) {
  return Categories.predefined;
});

final categoryByIdProvider = Provider.family<Category, String>((ref, id) {
  return Categories.getById(id);
});
