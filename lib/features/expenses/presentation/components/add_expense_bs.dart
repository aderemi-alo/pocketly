// import 'package:pocketly/core/core.dart';
// import 'package:pocketly/features/features.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/services.dart';

// class CurrencyInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     }

//     // Remove all non-digit characters
//     String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

//     if (digitsOnly.isEmpty) {
//       return const TextEditingValue(text: '');
//     }

//     // Parse the number and format with commas
//     int value = int.parse(digitsOnly);
//     String formatted = NumberFormat('#,###').format(value);

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }

// class AddExpenseBottomSheet extends ConsumerStatefulWidget {
//   const AddExpenseBottomSheet({super.key});

//   @override
//   ConsumerState<AddExpenseBottomSheet> createState() =>
//       _AddExpenseBottomSheetState();
// }

// class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final FocusNode _amountFocusNode = FocusNode();
//   bool _isAmountFocused = false;
//   Category? _selectedCategory;
//   DateTime? _selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     _amountFocusNode.addListener(() {
//       setState(() {
//         _isAmountFocused = _amountFocusNode.hasFocus;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _amountFocusNode.dispose();
//     nameController.dispose();
//     descriptionController.dispose();
//     amountController.dispose();
//     _selectedCategory = null;
//     _selectedDate = null;
//     super.dispose();
//   }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onSurface: AppColors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final categories = ref.watch(categoriesProvider);
//     return Container(
//       padding: context.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text('Add Expense', style: theme.textTheme.titleLarge),
//           Divider(color: AppColors.outline, height: context.h(32)),

//           Padding(
//             padding: context.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Amount input
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.surfaceVariant,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: _isAmountFocused
//                           ? AppColors.primary
//                           : Colors.transparent,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       context.horizontalSpace(16),
//                       Text(
//                         '₦',
//                         style: theme.textTheme.bodyLarge?.copyWith(
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.textTertiary,
//                         ),
//                       ),
//                       Expanded(
//                         child: TextFormField(
//                           controller: amountController,
//                           focusNode: _amountFocusNode,
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             fontSize: 30,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: -1,
//                           ),
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [CurrencyInputFormatter()],
//                           decoration: InputDecoration(
//                             hintText: '0.00',
//                             hintStyle: theme.textTheme.bodyLarge?.copyWith(
//                               color: AppColors.textTertiary,
//                               fontSize: 30,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: -2,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: BorderSide.none,
//                             ),
//                             errorBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedErrorBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(16),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: context.symmetric(
//                               vertical: 10,
//                               horizontal: 4,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 context.verticalSpace(20),
//                 // Name input
//                 TextFormField(
//                   controller: nameController,
//                   style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
//                   decoration: InputDecoration(
//                     hintText: 'Name',
//                     hintStyle: theme.textTheme.bodyMedium?.copyWith(
//                       color: AppColors.textTertiary,
//                       fontSize: 16,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: const BorderSide(color: AppColors.primary),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 context.verticalSpace(16),
//                 // Description input
//                 TextFormField(
//                   style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
//                   decoration: InputDecoration(
//                     hintText: 'Description',
//                     hintStyle: theme.textTheme.bodyMedium?.copyWith(
//                       color: AppColors.textTertiary,
//                       fontSize: 16,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: const BorderSide(color: AppColors.primary),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 context.verticalSpace(16),
//                 // Category
//                 Text(
//                   'Category',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//                 context.verticalSpace(10),
//                 //Category Selector
//                 Wrap(
//                   spacing: 5,
//                   runSpacing: 5,
//                   children: categories.map((category) {
//                     final isSelected = _selectedCategory?.id == category.id;

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedCategory = category;
//                         });
//                       },
//                       child: Container(
//                         padding: context.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? category.color
//                               : AppColors.surfaceVariant,
//                           borderRadius: BorderRadius.circular(25),
//                           border: Border.all(
//                             color: isSelected
//                                 ? category.color
//                                 : AppColors.outline,
//                             width: isSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: Text(
//                           category.name,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: isSelected
//                                 ? AppColors.surface
//                                 : AppColors.textPrimary,
//                             fontWeight: isSelected
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 context.verticalSpace(32),

//                 // Date input
//                 TextFormField(
//                   readOnly: true,
//                   onTap: _selectDate,
//                   controller: TextEditingController(
//                     text: _selectedDate != null
//                         ? DateFormat('MMMM d, yyyy').format(_selectedDate!)
//                         : '',
//                   ),
//                   style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
//                   decoration: InputDecoration(
//                     hintText: 'Date',
//                     hintStyle: theme.textTheme.bodyMedium?.copyWith(
//                       color: AppColors.textTertiary,
//                       fontSize: 16,
//                     ),
//                     suffixIcon: IconButton(
//                       onPressed: _selectDate,
//                       icon: const Icon(Icons.calendar_today),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: const BorderSide(color: AppColors.primary),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 context.verticalSpace(32),
//                 // Add button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       ref
//                           .read(expensesProvider.notifier)
//                           .addExpense(
//                             name: nameController.text.trim(),
//                             amount:
//                                 double.tryParse(
//                                   amountController.text.replaceAll(',', ''),
//                                 ) ??
//                                 0,
//                             category: _selectedCategory!,
//                             date: _selectedDate!,
//                             description: descriptionController.text.trim(),
//                           );
//                       context.pop();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       foregroundColor: AppColors.surface,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(32),
//                       ),
//                       padding: context.symmetric(vertical: 16),
//                     ),
//                     child: const Text(
//                       'Save Expense',
//                       style: TextStyle(color: AppColors.surface),
//                     ),
//                   ),
//                 ),
//                 context.verticalSpace(16),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
