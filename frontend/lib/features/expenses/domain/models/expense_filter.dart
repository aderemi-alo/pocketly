class ExpenseFilter {
  final String? selectedMonth;
  final String? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseFilter({
    this.selectedMonth,
    this.selectedCategory,
    this.startDate,
    this.endDate,
  });

  ExpenseFilter copyWith({
    String? selectedMonth,
    String? selectedCategory,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseFilter(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get hasActiveFilters {
    return selectedMonth != null ||
        selectedCategory != null ||
        startDate != null ||
        endDate != null;
  }

  bool get hasDateRange {
    return startDate != null || endDate != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseFilter &&
        other.selectedMonth == selectedMonth &&
        other.selectedCategory == selectedCategory &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode =>
      Object.hash(selectedMonth, selectedCategory, startDate, endDate);

  @override
  String toString() =>
      'ExpenseFilter(selectedMonth: $selectedMonth, selectedCategory: $selectedCategory, startDate: $startDate, endDate: $endDate)';
}
