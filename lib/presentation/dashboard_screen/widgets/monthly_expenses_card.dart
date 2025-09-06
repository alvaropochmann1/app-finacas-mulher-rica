import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MonthlyExpensesCard extends StatelessWidget {
  final double totalExpenses;
  final double monthlyIncome;
  final bool isPrivacyEnabled;

  const MonthlyExpensesCard({
    super.key,
    required this.totalExpenses,
    required this.monthlyIncome,
    required this.isPrivacyEnabled,
  });

  String _formatCurrency(double value) {
    final absValue = value.abs();
    final formattedValue = absValue.toStringAsFixed(2).replaceAll('.', ',');
    final parts = formattedValue.split(',');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'R\$ $integerPart,${parts[1]}';
  }

  double _getExpensePercentage() {
    if (monthlyIncome <= 0) return 0;
    return (totalExpenses / monthlyIncome) * 100;
  }

  Color _getPercentageColor(BuildContext context, double percentage) {
    final colorScheme = Theme.of(context).colorScheme;
    if (percentage <= 50) return colorScheme.tertiary;
    if (percentage <= 80)
      return AppTheme.getWarningColor(
          Theme.of(context).brightness == Brightness.light);
    return AppTheme.getErrorColor(
        Theme.of(context).brightness == Brightness.light);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expensePercentage = _getExpensePercentage();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos do Mês',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getPercentageColor(context, expensePercentage)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPrivacyEnabled
                      ? '••%'
                      : '${expensePercentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _getPercentageColor(context, expensePercentage),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isPrivacyEnabled
                ? Text(
                    '••••••',
                    key: const ValueKey('hidden'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  )
                : Text(
                    _formatCurrency(totalExpenses),
                    key: const ValueKey('visible'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: expensePercentage / 100,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPercentageColor(context, expensePercentage),
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          SizedBox(height: 1.h),
          Text(
            isPrivacyEnabled
                ? 'Percentual da renda oculto'
                : 'de ${_formatCurrency(monthlyIncome)} da renda mensal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
