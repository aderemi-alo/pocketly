import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class CategoryDetailModal extends StatelessWidget {
  final String categoryId;
  final List<Expense> expenses;
  final VoidCallback? onExpenseTap;

  const CategoryDetailModal({
    super.key,
    required this.categoryId,
    required this.expenses,
    this.onExpenseTap,
  });

  static void show({
    required BuildContext context,
    required String categoryId,
    required List<Expense> expenses,
    VoidCallback? onExpenseTap,
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.5),
      builder: (context) => CategoryDetailModal(
        categoryId: categoryId,
        expenses: expenses,
        onExpenseTap: onExpenseTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = Categories.getById(categoryId);

    // Get top 3 expenses for this category
    final categoryExpenses =
        expenses.where((exp) => exp.category.id == categoryId).toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final topExpenses = categoryExpenses.take(3).toList();
    final total = categoryExpenses.fold<double>(
      0.0,
      (sum, exp) => sum + exp.amount,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Center(
            child: Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: GestureDetector(
          onTap: () {}, // Prevent tap from propagating to parent
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: context.screenHeight * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),

                          // Header Section
                          _buildHeader(
                            context,
                            category,
                            categoryExpenses.length,
                            total,
                          ),

                          const SizedBox(height: 24),

                          // Top Transactions Section
                          _buildTopTransactions(context, category, topExpenses),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Category category,
    int transactionCount,
    double total,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Category Icon and Name
            Row(
              children: [
                // Animated Icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: (1 - value) * -3.14,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(category.icon, size: 28, color: category.color),
                  ),
                ),
                const SizedBox(width: 12),

                // Category Name and Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: category.name,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 2),
                      TextWidget(
                        text:
                            '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                // Close Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Total Spent Card
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-20 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: 'Total Spent',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: '₦${FormatUtils.formatCurrency(total)}',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTransactions(
    BuildContext context,
    Category category,
    List<Expense> topExpenses,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextWidget(
            text: 'Top Transactions',
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 12),

          if (topExpenses.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: const TextWidget(
                text: 'No transactions yet',
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            )
          else
            ...topExpenses.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(-20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: TextWidget(
                            text: '#${index + 1}',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: category.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Expense Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: expense.name,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 2),
                            TextWidget(
                              text: DateFormat(
                                'MMM d, yyyy',
                              ).format(expense.date),
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      TextWidget(
                        text: '₦${FormatUtils.formatCurrency(expense.amount)}',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
