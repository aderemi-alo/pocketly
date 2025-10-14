class ExpenseStatsModel {
  final double total;
  final int count;
  final Map<String, double> categoryBreakdown;
  final double? averagePerExpense;
  final double? dailyAverage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String period;

  const ExpenseStatsModel({
    required this.total,
    required this.count,
    required this.categoryBreakdown,
    this.averagePerExpense,
    this.dailyAverage,
    this.startDate,
    this.endDate,
    required this.period,
  });

  factory ExpenseStatsModel.fromJson(Map<String, dynamic> json) {
    return ExpenseStatsModel(
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
      categoryBreakdown: (json['categoryBreakdown'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      averagePerExpense: json['averagePerExpense'] != null
          ? (json['averagePerExpense'] as num).toDouble()
          : null,
      dailyAverage: json['dailyAverage'] != null
          ? (json['dailyAverage'] as num).toDouble()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      period: json['period'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'count': count,
      'categoryBreakdown': categoryBreakdown,
      if (averagePerExpense != null) 'averagePerExpense': averagePerExpense,
      if (dailyAverage != null) 'dailyAverage': dailyAverage,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'period': period,
    };
  }

  @override
  String toString() =>
      'ExpenseStatsModel(total: $total, count: $count, period: $period)';
}
