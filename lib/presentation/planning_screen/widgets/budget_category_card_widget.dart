import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BudgetCategoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String name = (category['name'] as String?) ?? '';
    final String icon = (category['icon'] as String?) ?? 'category';
    final double budgeted = (category['budgeted'] as num?)?.toDouble() ?? 0.0;
    final double spent = (category['spent'] as num?)?.toDouble() ?? 0.0;
    final double percentage = budgeted > 0 ? (spent / budgeted) * 100 : 0.0;
    final bool isOverBudget = percentage > 100;
    final bool isNearLimit = percentage > 90 && percentage <= 100;

    Color progressColor =
        AppTheme.getSuccessColor(theme.brightness == Brightness.light);
    if (isOverBudget) {
      progressColor =
          AppTheme.getErrorColor(theme.brightness == Brightness.light);
    } else if (isNearLimit) {
      progressColor =
          AppTheme.getWarningColor(theme.brightness == Brightness.light);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOverBudget
              ? BorderSide(
                  color: AppTheme.getErrorColor(
                          theme.brightness == Brightness.light)
                      .withValues(alpha: 0.3),
                  width: 1)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: progressColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: icon,
                        color: progressColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Orçado: ${_formatCurrency(budgeted)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          HapticFeedback.lightImpact();
                          if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'delete' && onDelete != null) {
                            onDelete!();
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'edit',
                                    color: colorScheme.onSurface,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'delete',
                                    color: AppTheme.getErrorColor(
                                        theme.brightness == Brightness.light),
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Excluir',
                                    style: TextStyle(
                                      color: AppTheme.getErrorColor(
                                          theme.brightness == Brightness.light),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        child: CustomIconWidget(
                          iconName: 'more_vert',
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gasto: ${_formatCurrency(spent)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                LinearProgressIndicator(
                  value: percentage > 100 ? 1.0 : percentage / 100,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                if (isNearLimit || isOverBudget) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: isOverBudget ? 'warning' : 'info',
                          color: progressColor,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            isOverBudget
                                ? 'Orçamento ultrapassado! Revise seus gastos.'
                                : 'Atenção: Você está próximo do limite.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: progressColor,
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
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
