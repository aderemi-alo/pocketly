import 'package:intl/intl.dart';
import 'package:pocketly/core/core.dart';

class MonthHeader extends StatelessWidget {
  final String monthKey;
  final double totalAmount;

  const MonthHeader({
    super.key,
    required this.monthKey,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse the month key (format: YYYY-MM)
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final date = DateTime(year, month);

    // Format the month name
    final monthName = DateFormat('MMMM yyyy').format(date);

    return Padding(
      padding: context.only(top: 24, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            monthName,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '₦ ${FormatUtils.formatCurrency(totalAmount)}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
