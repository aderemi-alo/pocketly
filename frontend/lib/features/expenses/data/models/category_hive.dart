import 'package:hive/hive.dart';
import 'package:pocketly/features/expenses/data/models/category_api_model.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';
import 'package:pocketly/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';

part 'category_hive.g.dart';

@HiveType(typeId: 1)
class CategoryHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late String color;

  @HiveField(4)
  late bool isPredefined;

  @HiveField(5)
  String? userId;

  @HiveField(6)
  DateTime? syncedAt;

  @HiveField(7)
  late DateTime updatedAt;

  @HiveField(8)
  late bool isDeleted;

  CategoryHive();

  CategoryHive.create({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isPredefined,
    this.userId,
    this.syncedAt,
    DateTime? updatedAt,
    bool isDeleted = false,
  }) {
    this.updatedAt = updatedAt ?? DateTime.now();
    this.isDeleted = isDeleted;
  }

  /// Convert from CategoryApiModel
  factory CategoryHive.fromApiModel(CategoryApiModel apiModel) {
    return CategoryHive.create(
      id: apiModel.id,
      name: apiModel.name,
      icon: apiModel.icon,
      color: apiModel.color,
      isPredefined: apiModel.isPredefined,
      userId: apiModel.userId,
      syncedAt: DateTime.now(),
      updatedAt: apiModel.updatedAt,
      isDeleted: apiModel.isDeleted ?? false,
    );
  }

  /// Convert to CategoryApiModel
  CategoryApiModel toApiModel() {
    return CategoryApiModel(
      id: id,
      name: name,
      icon: icon,
      color: color,
      isPredefined: isPredefined,
      userId: userId,
      createdAt: syncedAt ?? DateTime.now(),
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  /// Convert to domain Category model
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      icon: IconMapper.getIconFromString(icon),
      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  /// Convert from domain Category model
  factory CategoryHive.fromDomain(Category category, {bool isPredefined = false}) {
    return CategoryHive.create(
      id: category.id,
      name: category.name,
      icon: IconMapper.getIconName(category.icon),
      color: '#${category.color.value.toRadixString(16).substring(2).toUpperCase()}',
      isPredefined: isPredefined,
      syncedAt: null,
      updatedAt: category.updatedAt,
      isDeleted: category.isDeleted,
    );
  }
}

