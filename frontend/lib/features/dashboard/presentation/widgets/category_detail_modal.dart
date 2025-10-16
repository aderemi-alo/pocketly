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
            margin: context.symmetric(horizontal: 20, vertical: 40),
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: context.screenHeight * 0.8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                          // Header Section
                          _buildHeader(
                            context,
                            category,
                            categoryExpenses.length,
                            total,
                          ),

                          context.verticalSpace(12),

                          // Top Transactions Section
                          _buildTopTransactions(context, category, topExpenses),

                          context.verticalSpace(10),
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
        padding: context.all(20),
        color: category.color.withValues(alpha: 0.08),
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
                    child: Icon(
                      category.icon,
                      size: 28,
                      color: category.color.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                context.horizontalSpace(12),

                // Category Name and Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: category.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      TextWidget(
                        text:
                            '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                // Close Button
                SizedBox(
                  height: 56,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            context.verticalSpace(16),

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
                width: double.infinity,
                padding: context.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Total Spent',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    context.verticalSpace(2),
                    TextWidget(
                      text: '₦${FormatUtils.formatCurrency(total)}',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                      color: Theme.of(context).colorScheme.onSurface,
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
      padding: context.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Top Transactions',
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          context.verticalSpace(12),

          if (topExpenses.isEmpty)
            Container(
              padding: context.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: TextWidget(
                text: 'No transactions yet',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  margin: context.only(
                    bottom: index == topExpenses.length - 1 ? 0 : 10,
                  ),
                  padding: context.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        padding: context.only(
                          left: 5,
                          right: 5,
                          top: 3,
                          bottom: 5,
                        ),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: TextWidget(
                          text: '#${index + 1}',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: category.color,
                        ),
                      ),
                      context.horizontalSpace(8),

                      // Expense Details - Wrap in Expanded to handle overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: expense.name,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            context.verticalSpace(4),
                            TextWidget(
                              text: DateFormat(
                                'MMM d, yyyy',
                              ).format(expense.date),
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),

                      // Amount
                      TextWidget(
                        text: '₦${FormatUtils.formatCurrency(expense.amount)}',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              );
            }),

          context.verticalSpace(20),
        ],
      ),
    );
  }
}
