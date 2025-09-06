import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecommendationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final double currentVariance;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.currentVariance,
  });

  Color _getRecommendationColor(BuildContext context, String type) {
    final theme = Theme.of(context);
    switch (type.toLowerCase()) {
      case 'danger':
        return AppTheme.getErrorColor(theme.brightness == Brightness.light);
      case 'positive':
        return AppTheme.getSuccessColor(theme.brightness == Brightness.light);
      case 'warning':
        return AppTheme.getWarningColor(theme.brightness == Brightness.light);
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getRecommendationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'danger':
        return Icons.warning;
      case 'positive':
        return Icons.trending_up;
      case 'warning':
        return Icons.info;
      default:
        return Icons.lightbulb;
    }
  }

  String _getVarianceMessage() {
    if (currentVariance <= -10) {
      return 'Atenção: Gastos 10% acima do planejado';
    } else if (currentVariance >= 10) {
      return 'Parabéns: Economia de 10% no orçamento';
    } else {
      return 'Orçamento dentro do esperado';
    }
  }

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
            'Recomendações Personalizadas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildVarianceAlert(context),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return _buildRecommendationCard(context, recommendation);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceAlert(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color alertColor;
    IconData alertIcon;
    String alertType;

    if (currentVariance <= -10) {
      alertColor = AppTheme.getErrorColor(theme.brightness == Brightness.light);
      alertIcon = Icons.trending_down;
      alertType = 'danger';
    } else if (currentVariance >= 10) {
      alertColor =
          AppTheme.getSuccessColor(theme.brightness == Brightness.light);
      alertIcon = Icons.trending_up;
      alertType = 'positive';
    } else {
      alertColor = colorScheme.primary;
      alertIcon = Icons.check_circle;
      alertType = 'neutral';
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alertColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: alertColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: alertIcon.toString().split('.').last,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getVarianceMessage(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  alertType == 'danger'
                      ? 'Continue focada nos seus objetivos! Pequenos ajustes fazem grande diferença.'
                      : alertType == 'positive'
                          ? 'Que tal investir essa economia? Seu futuro financeiro agradece!'
                          : 'Você está no caminho certo! Continue assim.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, Map<String, dynamic> recommendation) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recommendationColor =
        _getRecommendationColor(context, recommendation['type'] as String);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: recommendationColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getRecommendationIcon(recommendation['type'] as String)
                  .toString()
                  .split('.')
                  .last,
              color: recommendationColor,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  recommendation['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
