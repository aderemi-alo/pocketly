import 'package:pocketly/features/features.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final Category category;
  final DateTime date;

  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
  });

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    Category? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
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
