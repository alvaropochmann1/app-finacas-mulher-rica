import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onCopyPreviousMonth;
  final VoidCallback onCreateTemplate;
  final VoidCallback onAddCategory;

  const QuickActionsWidget({
    super.key,
    required this.onCopyPreviousMonth,
    required this.onCreateTemplate,
    required this.onAddCategory,
  });

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
            'Ações Rápidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Copiar Mês Anterior',
                  'content_copy',
                  colorScheme.primary,
                  onCopyPreviousMonth,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Criar Modelo',
                  'bookmark_add',
                  AppTheme.getAccentColor(theme.brightness == Brightness.light),
                  onCreateTemplate,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              'Adicionar Categoria',
              'add_circle_outline',
              AppTheme.getSuccessColor(theme.brightness == Brightness.light),
              onAddCategory,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback onPressed, {
    bool isFullWidth = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        ),
        child: isFullWidth
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: iconName,
                    color: color,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: iconName,
                    color: color,
                    size: 20,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
