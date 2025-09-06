import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DateSectionHeader extends StatelessWidget {
  final DateTime date;
  final double totalAmount;
  final bool isToday;

  const DateSectionHeader({
    super.key,
    required this.date,
    required this.totalAmount,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primary.withValues(alpha: 0.05)
            : colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        isToday ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                if (isToday) ...[
                  SizedBox(height: 0.2.h),
                  Text(
                    'Hoje',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'R\$ ${totalAmount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: totalAmount >= 0
                  ? const Color(0xFF00B894)
                  : const Color(0xFFE74C3C),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoje';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Ontem';
    } else {
      final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      final months = [
        'Jan',
        'Fev',
        'Mar',
        'Abr',
        'Mai',
        'Jun',
        'Jul',
        'Ago',
        'Set',
        'Out',
        'Nov',
        'Dez'
      ];

      return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
    }
  }
}
