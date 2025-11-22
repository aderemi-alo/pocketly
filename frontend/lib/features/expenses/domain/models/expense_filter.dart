class ExpenseFilter {
  final String? selectedMonth;
  final String? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const ExpenseFilter({
    this.selectedMonth,
    this.selectedCategory,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  ExpenseFilter copyWith({
    String? selectedMonth,
    String? selectedCategory,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return ExpenseFilter(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters {
    return selectedMonth != null ||
        selectedCategory != null ||
        startDate != null ||
        endDate != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
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
        other.endDate == endDate &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(
    selectedMonth,
    selectedCategory,
    startDate,
    endDate,
    searchQuery,
  );

  @override
  String toString() =>
      'ExpenseFilter(selectedMonth: $selectedMonth, selectedCategory: $selectedCategory, startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery)';
}
