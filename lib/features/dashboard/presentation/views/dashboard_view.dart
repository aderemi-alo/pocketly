import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesProvider);

    // Calculate values
    final totalSpent = expensesState.totalAmountCurrentMonth;
    final totalTransactions = expensesState.transactionCountCurrentMonth;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                // Total Spent
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextWidget(
                          text: 'Total Spent',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        context.verticalSpace(4),
                        TextWidget(
                          text: '₦${FormatUtils.formatCurrency(totalSpent)}',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        context.verticalSpace(2),
                        const TextWidget(
                          text: 'This Month',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Transactions
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextWidget(
                          text: 'Transactions',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        context.verticalSpace(4),
                        TextWidget(
                          text: '$totalTransactions',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        context.verticalSpace(2),
                        const TextWidget(
                          text: 'This Month',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                context.horizontalSpace(12),
              ],
            ),
            const SizedBox(height: 24),

            // Spending by Category Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Spending by Category',
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      TextWidget(
                        text: 'This Month',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildCategoryChart(expensesState),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Spending Bar Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: 'This Week\'s Spending',
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 16),

                  _buildWeeklyChart(expensesState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(ExpensesState expensesState) {
    final categoryData = _getCategoryData(expensesState);

    if (categoryData.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: const TextWidget(
          text: 'No data yet',
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      );
    }

    return Column(
      children: [
        // Animated Donut Chart
        SizedBox(
          height: 200,
          child: Center(
            child: AnimatedDonutChart(
              key: ValueKey('donut_chart_${categoryData.length}'),
              data: categoryData,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Legend
        ...categoryData.map((categoryData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: categoryData.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        categoryData.icon,
                        size: 16,
                        color: categoryData.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextWidget(text: categoryData.name, fontSize: 14),
                  ],
                ),
                TextWidget(
                  text: '${categoryData.percentage.toStringAsFixed(1)} %',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.5,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeeklyChart(ExpensesState expensesState) {
    final weeklyData = _getWeeklyData(expensesState);

    return AnimatedBarChart(
      key: ValueKey('bar_chart_${weeklyData.length}'),
      data: weeklyData,
    );
  }

  List<WeeklySpendingData> _getWeeklyData(ExpensesState expensesState) {
    final expensesByDay = expensesState.expensesByDayCurrentWeek;

    // Convert map to list with formatted dates
    final weeklyData = <WeeklySpendingData>[];

    // Days of week labels
    const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    int index = 0;
    expensesByDay.forEach((dateKey, amount) {
      weeklyData.add(
        WeeklySpendingData(date: daysOfWeek[index % 7], amount: amount),
      );
      index++;
    });

    return weeklyData;
  }

  List<CategoryChartData> _getCategoryData(ExpensesState expensesState) {
    final expensesByCategory = expensesState.expensesByCategoryCurrentMonth;
    final totalAmount = expensesState.totalAmountCurrentMonth;

    if (totalAmount == 0) return [];

    final categoryData = <CategoryChartData>[];

    // Collect category data with values (only categories with expenses in current month)
    expensesByCategory.forEach((categoryId, expenses) {
      final totalForCategory = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      // Get category info from constants using the category ID
      final category = Categories.getById(categoryId);

      categoryData.add(
        CategoryChartData(
          name: category.name,
          value: totalForCategory,
          percentage: (totalForCategory / totalAmount) * 100,
          color: category.color,
          icon: category.icon,
        ),
      );
    });

    // Sort by value descending
    categoryData.sort((a, b) => b.value.compareTo(a.value));

    return categoryData;
  }
}
