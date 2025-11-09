import 'package:intl/intl.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

// Swipeable Expense Card Widget
class ExpenseCard extends ConsumerStatefulWidget {
  final Expense expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  ConsumerState<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends ConsumerState<ExpenseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0;
  bool _isOpen = false;

  static const double _actionWidth = 136.0; // Width for both buttons
  static const double _swipeThreshold = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Initialize with a default animation - will be updated in build()
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0), // Default value, will be updated in build()
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragExtent = 0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta!;
      // Only allow left swipe (negative values)
      if (_dragExtent < 0 && _dragExtent > -_actionWidth) {
        _controller.value = -_dragExtent / _actionWidth;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent < -_swipeThreshold) {
      // Open
      _controller.animateTo(1.0);
      setState(() {
        _isOpen = true;
      });
    } else {
      // Close
      _controller.animateTo(0.0);
      setState(() {
        _isOpen = false;
      });
    }
    _dragExtent = 0;
  }

  void _closeActions() {
    _controller.animateTo(0.0);
    setState(() {
      _isOpen = false;
    });
  }

  void _handleCardTap() {
    if (_isOpen) {
      _closeActions();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) =>
            ExpenseDetailsBottomSheet(expense: widget.expense),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.expense.category;
    final theme = Theme.of(context);
    // Update the slide animation with the correct screen width
    final screenWidth = MediaQuery.of(context).size.width;
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-_actionWidth / screenWidth, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onTap: _handleCardTap,
      child: Stack(
        children: [
          // Action Buttons (Behind)
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              padding: context.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _closeActions();
                          context.push(
                            AppRoutes.addExpense,
                            extra: widget.expense,
                          );
                        },
                        child: const Icon(
                          LucideIcons.pen,
                          color: AppColors.surface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  context.horizontalSpace(8),
                  // Delete Button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          _closeActions();
                          showDialog<bool>(
                            context: context,
                            builder: (context) => DeleteExpenseDialog(
                              expenseId: widget.expense.id,
                            ),
                          );
                        },
                        child: const Icon(
                          LucideIcons.trash2,
                          color: AppColors.surface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Card (Slides over buttons)
          SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: _handleCardTap,
              child: Container(
                margin: context.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: context.radius(20),
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
                child: Padding(
                  padding: context.all(16),
                  child: Row(
                    children: [
                      // Category Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.12),
                          borderRadius: context.radius(18),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 24,
                        ),
                      ),

                      context.horizontalSpace(12),

                      // Expense Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.expense.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            context.verticalSpace(4),
                            Text(
                              _formatDate(widget.expense.date),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      context.horizontalSpace(12),

                      // Amount and Category
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₦${FormatUtils.formatCurrency(widget.expense.amount)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          context.verticalSpace(4),
                          Text(
                            category.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
