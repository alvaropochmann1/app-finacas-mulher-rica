import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AmountInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isIncome;
  final Function(String) onAmountChanged;

  const AmountInputWidget({
    super.key,
    required this.controller,
    required this.isIncome,
    required this.onAmountChanged,
  });

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    // Remove all non-numeric characters except comma
    String cleanValue = value.replaceAll(RegExp(r'[^\d,]'), '');

    // Handle decimal separator
    if (cleanValue.contains(',')) {
      List<String> parts = cleanValue.split(',');
      if (parts.length > 2) {
        cleanValue = '${parts[0]},${parts[1]}';
      }
      if (parts.length == 2 && parts[1].length > 2) {
        cleanValue = '${parts[0]},${parts[1].substring(0, 2)}';
      }
    }

    // Add thousand separators
    if (cleanValue.contains(',')) {
      List<String> parts = cleanValue.split(',');
      parts[0] = _addThousandSeparators(parts[0]);
      cleanValue = '${parts[0]},${parts[1]}';
    } else {
      cleanValue = _addThousandSeparators(cleanValue);
    }

    return 'R\$ $cleanValue';
  }

  String _addThousandSeparators(String value) {
    if (value.length <= 3) return value;

    String result = '';
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = value[i] + result;
      count++;
    }

    return result;
  }

  void _onAmountChanged(String value) {
    String formatted = _formatCurrency(value);
    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    widget.onAmountChanged(formatted);
  }

  void _addQuickAmount(String amount) {
    HapticFeedback.lightImpact();
    String cleanAmount = amount.replaceAll('R\$ ', '');
    _onAmountChanged(cleanAmount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valor',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              style: AppTheme.currencyStyle(
                isLight: theme.brightness == Brightness.light,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: widget.isIncome
                    ? AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    : AppTheme.getErrorColor(
                        theme.brightness == Brightness.light),
              ),
              decoration: InputDecoration(
                hintText: 'R\$ 0,00',
                hintStyle: AppTheme.currencyStyle(
                  isLight: theme.brightness == Brightness.light,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _onAmountChanged,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickAmountButton('R\$ 50', context),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildQuickAmountButton('R\$ 100', context),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildQuickAmountButton('R\$ 200', context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _addQuickAmount(amount),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          amount,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
