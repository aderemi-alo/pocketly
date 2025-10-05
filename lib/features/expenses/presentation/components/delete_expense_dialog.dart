import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class DeleteExpenseDialog extends ConsumerWidget {
  final String expenseId;
  const DeleteExpenseDialog({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Delete Expense'),
      content: const Text('Are you sure you want to delete this expense?'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.read(expensesProvider.notifier).deleteExpense(expenseId);
            context.pop(true);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
