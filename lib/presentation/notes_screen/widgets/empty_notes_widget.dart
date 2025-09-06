import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyNotesWidget extends StatelessWidget {
  final VoidCallback onCreateNote;

  const EmptyNotesWidget({
    super.key,
    required this.onCreateNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'note_add',
                color: colorScheme.primary,
                size: 15.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Suas anotações financeiras',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Registre suas ideias, insights e decisões financeiras em um só lugar',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            _buildTipCard(
              context,
              icon: 'lightbulb',
              title: 'Insights Financeiros',
              description: 'Anote descobertas sobre seus hábitos de gastos',
              color: AppTheme.getWarningColor(
                  theme.brightness == Brightness.light),
            ),
            SizedBox(height: 2.h),
            _buildTipCard(
              context,
              icon: 'trending_up',
              title: 'Estratégias de Investimento',
              description: 'Registre suas pesquisas e planos de investimento',
              color: AppTheme.getSuccessColor(
                  theme.brightness == Brightness.light),
            ),
            SizedBox(height: 2.h),
            _buildTipCard(
              context,
              icon: 'flag',
              title: 'Metas e Objetivos',
              description: 'Documente seus sonhos e como alcançá-los',
              color: colorScheme.primary,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onCreateNote,
              icon: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onPrimary,
                size: 20,
              ),
              label: Text(
                'Criar primeira anotação',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: color,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
