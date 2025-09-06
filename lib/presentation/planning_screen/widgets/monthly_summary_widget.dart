import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MonthlySummaryWidget extends StatelessWidget {
  final double totalIncome;
  final double totalBudgeted;
  final double totalSpent;

  const MonthlySummaryWidget({
    super.key,
    required this.totalIncome,
    required this.totalBudgeted,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double projectedBalance = totalIncome - totalBudgeted;
    final double actualBalance = totalIncome - totalSpent;
    final bool isPositiveProjected = projectedBalance >= 0;
    final bool isPositiveActual = actualBalance >= 0;

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
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'assessment',
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Resumo Mensal',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSummaryRow(
            context,
            'Receita Esperada',
            totalIncome,
            AppTheme.getSuccessColor(theme.brightness == Brightness.light),
            'trending_up',
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
            context,
            'Total Orçado',
            totalBudgeted,
            colorScheme.primary,
            'account_balance_wallet',
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
            context,
            'Total Gasto',
            totalSpent,
            AppTheme.getErrorColor(theme.brightness == Brightness.light),
            'trending_down',
          ),
          SizedBox(height: 3.h),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Projetado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatCurrency(projectedBalance),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isPositiveProjected
                          ? AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light)
                          : AppTheme.getErrorColor(
                              theme.brightness == Brightness.light),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Saldo Real',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatCurrency(actualBalance),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isPositiveActual
                          ? AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light)
                          : AppTheme.getErrorColor(
                              theme.brightness == Brightness.light),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isPositiveProjected || !isPositiveActual) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.getWarningColor(
                        theme.brightness == Brightness.light)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.getWarningColor(
                        theme.brightness == Brightness.light),
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      !isPositiveProjected
                          ? 'Seu orçamento está acima da receita esperada. Considere ajustar suas metas.'
                          : 'Seus gastos estão acima do planejado. Revise suas despesas.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getWarningColor(
                            theme.brightness == Brightness.light),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPositiveProjected &&
              isPositiveActual &&
              actualBalance > projectedBalance) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'celebration',
                    color: AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light),
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Parabéns! Você está gastando menos do que planejou. Considere investir a diferença.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double value,
    Color color,
    String iconName,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          _formatCurrency(value),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
