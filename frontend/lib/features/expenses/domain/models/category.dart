import 'package:flutter/material.dart';
import 'package:pocketly/core/core.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DateTime updatedAt;
  final bool isDeleted;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.updatedAt,
    this.isDeleted = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
