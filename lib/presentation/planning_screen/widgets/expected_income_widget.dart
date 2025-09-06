import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExpectedIncomeWidget extends StatefulWidget {
  final double currentIncome;
  final Function(double) onIncomeChanged;

  const ExpectedIncomeWidget({
    super.key,
    required this.currentIncome,
    required this.onIncomeChanged,
  });

  @override
  State<ExpectedIncomeWidget> createState() => _ExpectedIncomeWidgetState();
}

class _ExpectedIncomeWidgetState extends State<ExpectedIncomeWidget> {
  late TextEditingController _incomeController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(
      text:
          widget.currentIncome > 0 ? _formatCurrency(widget.currentIncome) : '',
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  double _parseCurrency(String value) {
    String cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.getSuccessColor(
                      theme.brightness == Brightness.light),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receita Esperada',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Defina sua receita prevista para o mês',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          TextFormField(
            controller: _incomeController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.getSuccessColor(
                  theme.brightness == Brightness.light),
            ),
            decoration: InputDecoration(
              hintText: 'R\$ 0,00',
              hintStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getSuccessColor(
                      theme.brightness == Brightness.light),
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                double parsedValue = _parseCurrency(value);
                widget.onIncomeChanged(parsedValue);

                // Format the input
                String formatted = _formatCurrency(parsedValue);
                if (formatted != value) {
                  _incomeController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              } else {
                widget.onIncomeChanged(0.0);
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9R\$\s,.]')),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Esta será a base para calcular seu orçamento mensal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
