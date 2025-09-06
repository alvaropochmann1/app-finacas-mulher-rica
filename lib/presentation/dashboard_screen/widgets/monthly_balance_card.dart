import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MonthlyBalanceCard extends StatefulWidget {
  final double balance;
  final bool isPrivacyEnabled;
  final VoidCallback onPrivacyToggle;

  const MonthlyBalanceCard({
    super.key,
    required this.balance,
    required this.isPrivacyEnabled,
    required this.onPrivacyToggle,
  });

  @override
  State<MonthlyBalanceCard> createState() => _MonthlyBalanceCardState();
}

class _MonthlyBalanceCardState extends State<MonthlyBalanceCard> {
  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formattedValue = absValue.toStringAsFixed(2).replaceAll('.', ',');
    final parts = formattedValue.split(',');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '${isNegative ? '-' : ''}R\$ $integerPart,${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                'Saldo do Mês',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: widget.onPrivacyToggle,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: widget.isPrivacyEnabled
                        ? 'visibility_off'
                        : 'visibility',
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: widget.isPrivacyEnabled
                ? Text(
                    '••••••',
                    key: const ValueKey('hidden'),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 32.sp,
                    ),
                  )
                : Text(
                    _formatCurrency(widget.balance),
                    key: const ValueKey('visible'),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 28.sp,
                    ),
                  ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: widget.balance >= 0 ? 'trending_up' : 'trending_down',
                color: widget.balance >= 0
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimary.withValues(alpha: 0.8),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                widget.balance >= 0 ? 'Saldo positivo' : 'Atenção ao saldo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
