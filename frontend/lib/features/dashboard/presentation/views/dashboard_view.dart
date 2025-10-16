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
        padding: context.all(20),
        child: Column(
          children: [
            // Summary Cards
            Row(
              children: [
                // Total Spent
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: context.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Total Spent',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        context.verticalSpace(4),
                        TextWidget(
                          text: '₦${FormatUtils.formatCurrency(totalSpent)}',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        context.verticalSpace(2),
                        TextWidget(
                          text: 'This Month',
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                context.horizontalSpace(12),

                // Transactions
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: context.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Transactions',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        context.verticalSpace(4),
                        TextWidget(
                          text: '$totalTransactions',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        context.verticalSpace(2),
                        TextWidget(
                          text: 'This Month',
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                context.horizontalSpace(12),
              ],
            ),
            context.verticalSpace(24),

            // Spending by Category Card
            Container(
              padding: context.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Spending by Category',
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      TextWidget(
                        text: 'This Month',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  context.verticalSpace(16),

                  _buildCategoryChart(expensesState),
                ],
              ),
            ),
            context.verticalSpace(24),

            // Weekly Spending Bar Chart
            Container(
              padding: context.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'This Week\'s Spending',
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  context.verticalSpace(16),

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
        padding: context.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: TextWidget(
          text: 'No data yet',
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              onCategoryTap: (categoryId) {
                _showCategoryDetail(categoryId, expensesState);
              },
            ),
          ),
        ),
        context.verticalSpace(16),

        // Legend
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryData.length,
          itemBuilder: (context, index) {
            final category = categoryData[index];
            return GestureDetector(
              onTap: () =>
                  _showCategoryDetail(category.categoryId, expensesState),
              child: Padding(
                padding: context.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.icon,
                            size: 16,
                            color: category.color,
                          ),
                        ),
                        context.horizontalSpace(8),
                        TextWidget(
                          text: category.name,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                    TextWidget(
                      text: '${category.percentage.toStringAsFixed(1)} %',
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: -0.5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
          categoryId: categoryId,
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

  void _showCategoryDetail(String categoryId, ExpensesState expensesState) {
    CategoryDetailModal.show(
      context: context,
      categoryId: categoryId,
      expenses: expensesState.expenses,
    );
  }
}
