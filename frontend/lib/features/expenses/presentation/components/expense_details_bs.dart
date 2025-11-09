import 'package:intl/intl.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ExpenseDetailsBottomSheet extends ConsumerWidget {
  final Expense expense;
  const ExpenseDetailsBottomSheet({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = expense.category;
    final theme = Theme.of(context);
    return Container(
      padding: context.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: context.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expense Details', style: theme.textTheme.bodyLarge),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    LucideIcons.x,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.outline, height: 1),
          context.verticalSpace(16),
          Padding(
            padding: context.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: context.all(16),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 30,
                      ),
                    ),
                    context.horizontalSpace(8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          expense.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                context.verticalSpace(16),
                Container(
                  width: double.infinity,
                  padding: context.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Amount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '₦${FormatUtils.formatCurrency(expense.amount)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                          letterSpacing: -1,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                context.verticalSpace(16),
                // Date
                Text(
                  'Date',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                context.verticalSpace(5),
                Text(
                  DateFormat(
                    'EEEE, MMMM d, yyyy',
                  ).format(expense.date.toLocal()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Description
                if (expense.description != null) ...[
                  context.verticalSpace(16),
                  Text(
                    'Description',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  context.verticalSpace(5),
                  Text(
                    expense.description ?? 'No description',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                context.verticalSpace(32),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          context.pop();
                          context.push(
                            '/expenses/${AppRoutes.addExpense}',
                            extra: expense,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.pen, size: 15),
                            context.horizontalSpace(8),
                            Text(
                              'Edit',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    context.horizontalSpace(16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) =>
                                DeleteExpenseDialog(expenseId: expense.id),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.trash2, size: 15),
                            context.horizontalSpace(8),
                            Text(
                              'Delete',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
