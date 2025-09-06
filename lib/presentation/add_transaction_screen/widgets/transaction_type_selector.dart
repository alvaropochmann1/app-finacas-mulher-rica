import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionTypeSelector extends StatelessWidget {
  final bool isIncome;
  final Function(bool) onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.isIncome,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: isIncome
                      ? AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_up',
                      color: isIncome
                          ? Colors.white
                          : AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Receita',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isIncome
                            ? Colors.white
                            : AppTheme.getSuccessColor(
                                theme.brightness == Brightness.light),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: !isIncome
                      ? AppTheme.getErrorColor(
                          theme.brightness == Brightness.light)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_down',
                      color: !isIncome
                          ? Colors.white
                          : AppTheme.getErrorColor(
                              theme.brightness == Brightness.light),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Despesa',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: !isIncome
                            ? Colors.white
                            : AppTheme.getErrorColor(
                                theme.brightness == Brightness.light),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
