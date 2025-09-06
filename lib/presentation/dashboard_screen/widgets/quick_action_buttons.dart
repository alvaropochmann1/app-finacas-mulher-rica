import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  void _handleActionTap(BuildContext context, String action, String route) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: 'remove',
            label: 'Despesa',
            color: AppTheme.getErrorColor(theme.brightness == Brightness.light),
            onTap: () =>
                _handleActionTap(context, 'expense', '/add-transaction-screen'),
          ),
          _buildActionButton(
            context: context,
            icon: 'add',
            label: 'Receita',
            color:
                AppTheme.getSuccessColor(theme.brightness == Brightness.light),
            onTap: () =>
                _handleActionTap(context, 'income', '/add-transaction-screen'),
          ),
          _buildActionButton(
            context: context,
            icon: 'flag',
            label: 'Meta',
            color:
                AppTheme.getAccentColor(theme.brightness == Brightness.light),
            onTap: () => _handleActionTap(context, 'goal', '/goals-screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.symmetric(vertical: 3.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
