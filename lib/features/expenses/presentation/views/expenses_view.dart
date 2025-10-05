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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Expenses List
            expensesState.expenses.isEmpty
                ? const Center(child: Text('No expenses yet'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: expensesState.expenses.length,
                      itemBuilder: (context, index) {
                        return ExpenseCard(
                          expense: expensesState.expenses[index],
                        );
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
          ],
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
