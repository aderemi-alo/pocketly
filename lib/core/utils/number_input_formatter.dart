import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Custom TextInputFormatter for formatting numbers with commas
class NumberFormattingInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digit characters except decimal point
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points - keep only the first one
    final List<String> parts = cleanText.split('.');
    if (parts.length > 2) {
      cleanText = '${parts[0]}.${parts.sublist(1).join()}';
    }

    // Limit decimal places to 2
    if (parts.length == 2 && parts[1].length > 2) {
      cleanText = '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    if (cleanText.isEmpty) {
      return const TextEditingValue();
    }

    // Special handling for decimal point at the end (e.g., "123.")
    final bool hasTrailingDecimal = cleanText.endsWith('.');
    if (hasTrailingDecimal) {
      cleanText = cleanText.substring(0, cleanText.length - 1);
    }

    // Parse the number
    final double? number = double.tryParse(cleanText);
    if (number == null && cleanText.isNotEmpty) {
      return oldValue;
    }

    // Format with commas
    String formattedText = '';
    if (number != null) {
      formattedText = NumberFormat('#,##0.##').format(number);
    } else if (cleanText.isNotEmpty) {
      // Handle case where user is typing digits but no decimal yet
      formattedText = NumberFormat(
        '#,##0',
      ).format(int.tryParse(cleanText) ?? 0);
    }

    // Add back the trailing decimal if it was there
    if (hasTrailingDecimal) {
      formattedText += '.';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
