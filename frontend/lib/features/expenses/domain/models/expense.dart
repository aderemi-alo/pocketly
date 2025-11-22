import 'package:pocketly/features/features.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final Category category;
  final DateTime date;
  final String? description;
  final DateTime updatedAt;
  final bool isDeleted;

  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    Category? category,
    DateTime? date,
    String? description,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Expense(id: $id, name: $name, amount: $amount)';
}
