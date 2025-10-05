import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
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
            : Expanded(
                child: ListView.builder(
                  itemCount: expensesState.expenses.length,
                  itemBuilder: (context, index) {
                    return ExpenseCard(expense: expensesState.expenses[index]);
                    // return Container(
                    //   padding: context.symmetric(
                    //     horizontal: 16,
                    //     vertical: 12,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.surface,
                    //     borderRadius: BorderRadius.circular(16),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         decoration: BoxDecoration(
                    //           color: expensesState
                    //               .expenses[index]
                    //               .category
                    //               .color
                    //               .withValues(alpha: 0.5),
                    //           shape: BoxShape.circle,
                    //         ),
                    //         child:
                    //             expensesState.expenses[index].category.icon,
                    //       ),
                    //       Text(expensesState.expenses[index].name),
                    //       Text(
                    //         expensesState.expenses[index].amount.toString(),
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AddEditExpenseScreen(onSave: (expense) {}),
          //   ),
          // );
          context.push(AppRoutes.addExpense);
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
