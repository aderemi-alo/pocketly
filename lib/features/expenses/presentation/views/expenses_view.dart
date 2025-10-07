import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  Widget _buildGroupedExpensesList(ExpensesState expensesState) {
    final groupedExpenses = expensesState.expensesByMonth;

    if (groupedExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort months by date (newest first)
    final sortedMonths = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Expanded(
      child: ListView.builder(
        itemCount: sortedMonths.length,
        itemBuilder: (context, index) {
          final monthKey = sortedMonths[index];
          final monthExpenses = groupedExpenses[monthKey]!;
          final totalAmount = monthExpenses.fold(
            0.0,
            (sum, expense) => sum + expense.amount,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonthHeader(monthKey: monthKey, totalAmount: totalAmount),
              ...monthExpenses.map((expense) => ExpenseCard(expense: expense)),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Expenses', style: theme.textTheme.titleLarge),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        shadowColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: context.symmetric(horizontal: 16, vertical: 24),
        child: expensesState.expenses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: context.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.receipt,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    context.verticalSpace(16),
                    Text('No expenses yet', style: theme.textTheme.titleLarge),
                    context.verticalSpace(8),
                    Text(
                      'Start tracking by adding your first expense',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : Column(children: [_buildGroupedExpensesList(expensesState)]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addExpense),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
