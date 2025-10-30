import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketly/core/core.dart';

class OtpInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final String? errorText;

  const OtpInputWidget({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _values = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final pastedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (pastedValue.length >= widget.length) {
        // Fill all fields with pasted value
        for (int i = 0; i < widget.length; i++) {
          if (i < pastedValue.length) {
            _values[i] = pastedValue[i];
            _controllers[i].text = pastedValue[i];
          }
        }
        _focusNodes.last.requestFocus();
      } else {
        // Fill available fields
        for (int i = 0; i < pastedValue.length && i < widget.length; i++) {
          _values[i] = pastedValue[i];
          _controllers[i].text = pastedValue[i];
        }
        if (pastedValue.length < widget.length) {
          _focusNodes[pastedValue.length].requestFocus();
        } else {
          _focusNodes.last.requestFocus();
        }
      }
    } else {
      _values[index] = value;
    }

    final otp = _values.join('');
    widget.onChanged(otp);

    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }

    // Auto-focus next field
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _onBackspace(int index) {
    if (_values[index].isEmpty && index > 0) {
      // Move to previous field if current is empty
      _focusNodes[index - 1].requestFocus();
    } else {
      // Clear current field
      _values[index] = '';
      _controllers[index].clear();
    }

    final otp = _values.join('');
    widget.onChanged(otp);
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onBackspace(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            widget.length,
            (index) => _buildDigitField(index),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildDigitField(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _values[index].isNotEmpty
              ? AppColors.primary
              : AppColors.outline,
          width: _values[index].isNotEmpty ? 2 : 1,
        ),
        color: _values[index].isNotEmpty
            ? AppColors.primary.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surface,
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(event, index),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onChanged(index, value),
          onTap: () {
            // Select all text when tapped
            _controllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controllers[index].text.length,
            );
          },
        ),
      ),
    );
  }
}
