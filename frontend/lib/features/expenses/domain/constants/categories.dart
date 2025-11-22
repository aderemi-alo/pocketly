import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class Categories {
  // Unix epoch date (Jan 1, 1970) used to mark predefined/system categories
  // This date serves as a marker to identify system/predefined categories
  static final _predefinedDate = DateTime(1970, 1, 1);

  static final List<Category> predefined = [
    Category(
      id: 'food',
      name: 'Food',
      icon: LucideIcons.utensils,
      color: const Color(0xFF4CAF50),
      updatedAt: _predefinedDate,
    ),
    Category(
      id: 'transportation',
      name: 'Transportation',
      icon: LucideIcons.car,
      color: const Color(0xFF2196F3),
      updatedAt: _predefinedDate,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: LucideIcons.tv,
      color: const Color(0xFF9C27B0),
      updatedAt: _predefinedDate,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: LucideIcons.shoppingCart,
      color: const Color(0xFFFF9800),
      updatedAt: _predefinedDate,
    ),
    Category(
      id: 'bills',
      name: 'Bills',
      icon: LucideIcons.fileText,
      color: const Color(0xFFFF5722),
      updatedAt: _predefinedDate,
    ),
    Category(
      id: 'healthcare',
      name: 'Healthcare',
      icon: LucideIcons.heart,
      color: const Color(0xFFE91E63),
      updatedAt: _predefinedDate,
    ),
    Category(
      id: 'others',
      name: 'Others',
      icon: LucideIcons.menu,
      color: const Color(0xFF607D8B),
      updatedAt: _predefinedDate,
    ),
  ];

  static Category getById(String id) {
    return predefined.firstWhere(
      (category) => category.id == id,
      orElse: () => predefined.last, // Default to 'Others'
    );
  }
}
