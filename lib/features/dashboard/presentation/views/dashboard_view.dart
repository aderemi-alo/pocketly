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
    final totalSpent = expensesState.totalAmountLast30Days;
    final totalTransactions = expensesState.expenses.length;

    return Padding(
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
          // Add more children here for space-y-6 equivalent
        ],
      ),
    );
  }
}
