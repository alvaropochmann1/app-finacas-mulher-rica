import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MonthNavigationWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onDateTap;

  const MonthNavigationWidget({
    super.key,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onPreviousMonth();
            },
            icon: CustomIconWidget(
              iconName: 'chevron_left',
              color: colorScheme.primary,
              size: 24,
            ),
            tooltip: 'Mês anterior',
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onDateTap();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      _getMonthName(selectedDate.month),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      selectedDate.year.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onNextMonth();
            },
            icon: CustomIconWidget(
              iconName: 'chevron_right',
              color: colorScheme.primary,
              size: 24,
            ),
            tooltip: 'Próximo mês',
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }
}
