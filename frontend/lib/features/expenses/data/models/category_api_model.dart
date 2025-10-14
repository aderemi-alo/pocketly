import 'package:flutter/material.dart';
import 'package:pocketly/core/utils/icon_mapper.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';

class CategoryApiModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isPredefined;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryApiModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isPredefined,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isPredefined: json['isPredefined'] as bool,
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isPredefined': isPredefined,
      if (userId != null) 'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert API model to domain model
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      icon: IconMapper.getIconFromString(icon),
      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
    );
  }

  /// Convert domain model to API model
  static CategoryApiModel fromDomain(Category category) {
    // Extract color components and format as hex using new API
    final red = ((category.color.r * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final green = ((category.color.g * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final blue = ((category.color.b * 255.0).round() & 0xff)
        .toRadixString(16)
        .padLeft(2, '0');
    final colorValue = '$red$green$blue';

    return CategoryApiModel(
      id: category.id,
      name: category.name,
      icon: IconMapper.getIconName(category.icon),
      color: '#${colorValue.toUpperCase()}',
      isPredefined: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'CategoryApiModel(id: $id, name: $name)';
}
