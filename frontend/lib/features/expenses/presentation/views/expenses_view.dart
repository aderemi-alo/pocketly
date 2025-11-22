import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  Widget _buildGroupedExpensesList(ExpensesState expensesState) {
    final groupedExpenses = expensesState.filteredExpensesByMonth;

    if (groupedExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort months by date (newest first)
    final sortedMonths = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate total items for proper lazy loading
    final totalItems = sortedMonths.fold<int>(
      0,
      (sum, month) => sum + groupedExpenses[month]!.length + 1, // +1 for header
    );

    return Expanded(
      child: ListView.builder(
        itemCount: totalItems,
        itemBuilder: (context, index) {
          int currentIndex = index;

          // Find which month and expense this index corresponds to
          for (final monthKey in sortedMonths) {
            final monthExpenses = groupedExpenses[monthKey]!;

            if (currentIndex == 0) {
              // Show month header
              final totalAmount = monthExpenses.fold(
                0.0,
                (sum, expense) => sum + expense.amount,
              );
              return MonthHeader(monthKey: monthKey, totalAmount: totalAmount);
            }

            currentIndex--;

            if (currentIndex < monthExpenses.length) {
              // Show expense card
              return ExpenseCard(expense: monthExpenses[currentIndex]);
            }

            currentIndex -= monthExpenses.length;
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.receipt,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    context.verticalSpace(16),
                    Text('No expenses yet', style: theme.textTheme.titleLarge),
                    context.verticalSpace(8),
                    Text(
                      'Start tracking by adding your first expense',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: const Icon(LucideIcons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        ref
                            .read(expensesProvider.notifier)
                            .searchExpenses(value);
                      },
                    ),
                  ),
                  // Filter Bar
                  ExpenseFilterBar(
                    filter: expensesState.filter,
                    availableMonths: const [], // No longer needed
                    categories: Categories.predefined,
                    onFilterChanged: (filter) {
                      ref.read(expensesProvider.notifier).updateFilter(filter);
                    },
                  ),
                  context.verticalSpace(4),
                  // Expenses List
                  _buildGroupedExpensesList(expensesState),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/${AppRoutes.addExpense}'),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
