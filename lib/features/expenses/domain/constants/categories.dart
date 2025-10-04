import 'package:flutter/material.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';

class Categories {
  static const List<Category> predefined = [
    Category(id: 'food', name: 'Food', icon: '🍽️', color: Color(0xFF4CAF50)),
    Category(
      id: 'transportation',
      name: 'Transportation',
      icon: '🚗',
      color: Color(0xFF2196F3),
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: '🎬',
      color: Color(0xFF9C27B0),
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: '🛍️',
      color: Color(0xFFFF9800),
    ),
    Category(id: 'bills', name: 'Bills', icon: '💡', color: Color(0xFFFF5722)),
    Category(
      id: 'healthcare',
      name: 'Healthcare',
      icon: '🏥',
      color: Color(0xFFE91E63),
    ),
    Category(
      id: 'others',
      name: 'Others',
      icon: '📦',
      color: Color(0xFF607D8B),
    ),
  ];

  static Category getById(String id) {
    return predefined.firstWhere(
      (category) => category.id == id,
      orElse: () => predefined.last, // Default to 'Others'
    );
  }
}
