import 'package:intl/intl.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ExpenseFilterBar extends StatefulWidget {
  final ExpenseFilter filter;
  final List<String> availableMonths;
  final List<Category> categories;
  final Function(ExpenseFilter) onFilterChanged;

  const ExpenseFilterBar({
    super.key,
    required this.filter,
    required this.availableMonths,
    required this.categories,
    required this.onFilterChanged,
  });

  @override
  State<ExpenseFilterBar> createState() => _ExpenseFilterBarState();
}

class _ExpenseFilterBarState extends State<ExpenseFilterBar> {
  bool _isOpen = false;
  bool _showCustomRange = false;

  void _clearFilters() {
    widget.onFilterChanged(const ExpenseFilter());
    setState(() {
      _showCustomRange = false;
    });
  }

  void _handleMonthClick(String month) {
    DateTime? startDate;
    DateTime? endDate;

    if (month == 'this_month') {
      final now = DateTime.now();
      startDate = DateTime(now.year, now.month);
      endDate = DateTime(now.year, now.month + 1, 0);
    } else if (month == 'last_month') {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1);
      startDate = DateTime(lastMonth.year, lastMonth.month);
      endDate = DateTime(lastMonth.year, lastMonth.month + 1, 0);
    } else if (month.isEmpty) {
      // Clear all date filters when "All" is selected
      startDate = null;
      endDate = null;
    }

    widget.onFilterChanged(
      widget.filter.copyWith(
        selectedMonth: month.isEmpty ? null : month,
        startDate: startDate,
        endDate: endDate,
      ),
    );
    setState(() {
      _showCustomRange = false;
    });
  }

  void _handleCustomRangeToggle() {
    setState(() {
      _showCustomRange = !_showCustomRange;
    });
    if (!_showCustomRange) {
      widget.onFilterChanged(widget.filter.copyWith());
    }
  }

  String _formatDateRange() {
    if (widget.filter.selectedMonth == 'this_month') {
      return 'This Month';
    } else if (widget.filter.selectedMonth == 'last_month') {
      return 'Last Month';
    } else if (widget.filter.startDate != null &&
        widget.filter.endDate != null) {
      return '${DateFormat('MMM d').format(widget.filter.startDate!)} - ${DateFormat('MMM d').format(widget.filter.endDate!)}';
    } else if (widget.filter.startDate != null) {
      return 'From ${DateFormat('MMM d').format(widget.filter.startDate!)}';
    } else if (widget.filter.endDate != null) {
      return 'Until ${DateFormat('MMM d').format(widget.filter.endDate!)}';
    }
    return '';
  }

  int get _activeFilterCount {
    int count = 0;
    if (widget.filter.selectedMonth != null) count++;
    if (widget.filter.selectedCategory != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = widget.filter.hasActiveFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Toggle Button
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isOpen = !_isOpen),
              child: Container(
                padding: context.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasActiveFilters
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.funnel,
                      size: 16,
                      color: hasActiveFilters
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    context.horizontalSpace(8),
                    Text(
                      'Filter',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasActiveFilters
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      context.horizontalSpace(8),
                      Container(
                        padding: context.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _activeFilterCount.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    context.horizontalSpace(4),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: hasActiveFilters
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (hasActiveFilters) ...[
              context.horizontalSpace(8),
              GestureDetector(
                onTap: _clearFilters,
                child: Text(
                  'Clear',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Active Filter Badges
        if (hasActiveFilters && !_isOpen) ...[
          context.verticalSpace(8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (widget.filter.selectedMonth != null)
                _buildFilterBadge(
                  _formatDateRange(),
                  () => widget.onFilterChanged(widget.filter.copyWith()),
                ),
              if (widget.filter.selectedCategory != null)
                _buildFilterBadge(
                  widget.filter.selectedCategory!,
                  () => widget.onFilterChanged(widget.filter.copyWith()),
                ),
            ],
          ),
        ],

        // Filter Options
        if (_isOpen) ...[
          context.verticalSpace(12),
          Container(
            padding: context.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Filter
                _buildDateFilter(),
                context.verticalSpace(16),
                // Category Filter
                _buildCategoryFilter(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterBadge(String text, VoidCallback onRemove) {
    return Container(
      padding: context.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          context.horizontalSpace(4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              LucideIcons.x,
              size: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: _handleCustomRangeToggle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  context.horizontalSpace(4),
                  Text(
                    _showCustomRange ? 'Quick select' : 'Custom range',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        context.verticalSpace(8),
        if (!_showCustomRange) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildDateButton(
                'All',
                widget.filter.selectedMonth == null,
                () => _handleMonthClick(''),
              ),
              _buildDateButton(
                'This Month',
                widget.filter.selectedMonth == 'this_month',
                () => _handleMonthClick('this_month'),
              ),
              _buildDateButton(
                'Last Month',
                widget.filter.selectedMonth == 'last_month',
                () => _handleMonthClick('last_month'),
              ),
            ],
          ),
        ] else ...[
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        context.verticalSpace(4),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  widget.filter.startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              widget.onFilterChanged(
                                widget.filter.copyWith(startDate: date),
                              );
                            }
                          },
                          child: Container(
                            padding: context.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.filter.startDate != null
                                        ? DateFormat(
                                            'MMM d, yyyy',
                                          ).format(widget.filter.startDate!)
                                        : 'Select date',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  context.horizontalSpace(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        context.verticalSpace(4),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  widget.filter.endDate ?? DateTime.now(),
                              firstDate:
                                  widget.filter.startDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              widget.onFilterChanged(
                                widget.filter.copyWith(endDate: date),
                              );
                            }
                          },
                          child: Container(
                            padding: context.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.filter.endDate != null
                                        ? DateFormat(
                                            'MMM d, yyyy',
                                          ).format(widget.filter.endDate!)
                                        : 'Select date',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.filter.hasDateRange) ...[
                context.verticalSpace(8),
                GestureDetector(
                  onTap: () => widget.onFilterChanged(widget.filter.copyWith()),
                  child: Text(
                    'Clear date range',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        context.verticalSpace(8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildCategoryButton(
              'All',
              widget.filter.selectedCategory == null,
              () => widget.onFilterChanged(widget.filter.copyWith()),
            ),
            ...widget.categories.map(
              (category) => _buildCategoryButton(
                category.name,
                widget.filter.selectedCategory == category.name,
                () => widget.onFilterChanged(
                  widget.filter.copyWith(selectedCategory: category.name),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(String text, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
