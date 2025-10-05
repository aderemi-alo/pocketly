import 'package:intl/intl.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

// Add/Edit Expense Screen
class AddEditExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  Category _selectedCategory = Categories.predefined.first;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense?.name ?? '');
    _amountController = TextEditingController(
      text: widget.expense != null
          ? NumberFormat('#,##0.##').format(widget.expense!.amount)
          : '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );

    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: widget.expense?.id ?? '',
        name: _nameController.text.trim(),
        amount:
            double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0,
        category: _selectedCategory,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _selectedDate,
      );

      if (widget.expense != null) {
        ref
            .read(expensesProvider.notifier)
            .updateExpense(
              expenseId: expense.id,
              name: expense.name,
              amount: expense.amount,
              category: expense.category,
              date: expense.date,
              description: expense.description,
            );
      } else {
        ref
            .read(expensesProvider.notifier)
            .addExpense(
              name: expense.name,
              amount: expense.amount,
              category: expense.category,
              date: expense.date,
              description: expense.description,
            );
      }
      context.pop();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.expense != null ? 'Edit Expense' : 'Add Expense',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: context.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input - Large
              Center(
                child: Padding(
                  padding: context.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        'Amount',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      context.verticalSpace(8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₦',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 48,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          context.horizontalSpace(4),
                          IntrinsicWidth(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                NumberFormattingInputFormatter(),
                              ],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 48,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -1.5,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                fillColor: AppColors.background,
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(
                                      value.replaceAll(',', ''),
                                    ) ==
                                    null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              context.verticalSpace(8),

              // Name Input
              Text(
                'Name *',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              context.verticalSpace(8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Lunch, Coffee, Uber',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: context.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              context.verticalSpace(18),

              // Category Selection
              Text(
                'Category',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              context.verticalSpace(8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final entry = categories.elementAt(index);
                  final categoryName = entry.name;
                  final config = entry;
                  final isSelected = _selectedCategory == entry;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = entry;
                      });
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: context.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedCategory.color
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? _selectedCategory.color
                              : AppColors.outline,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _selectedCategory.color.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surface.withValues(alpha: 0.2)
                                  : config.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              config.icon.icon,
                              color: isSelected ? Colors.white : config.color,
                              size: 20,
                            ),
                          ),
                          context.horizontalSpace(6),
                          Expanded(
                            child: Text(
                              categoryName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Date Input
              Text(
                'Date *',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              context.verticalSpace(8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: context.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      context.horizontalSpace(12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              context.verticalSpace(12),

              // Description Input
              Text(
                'Description (Optional)',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              context.verticalSpace(8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any additional notes...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: context.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              context.verticalSpace(24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: context.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    widget.expense != null ? 'Update Expense' : 'Add Expense',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),

              context.verticalSpace(24),
            ],
          ),
        ),
      ),
    );
  }
}
