import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GoalCardWidget extends StatelessWidget {
  final Map<String, dynamic> goal;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onAddContribution;
  final VoidCallback onShare;

  const GoalCardWidget({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onAddContribution,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final double targetAmount = (goal['targetAmount'] as num).toDouble();
    final double currentAmount = (goal['currentAmount'] as num).toDouble();
    final double progress =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final int progressPercentage = (progress * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showContextMenu(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, colorScheme),
                SizedBox(height: 2.h),
                _buildProgressSection(
                    context, colorScheme, progress, progressPercentage),
                SizedBox(height: 2.h),
                _buildAmountSection(
                    context, colorScheme, targetAmount, currentAmount),
                SizedBox(height: 1.5.h),
                _buildDateSection(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: _getCategoryColor(goal['category'] as String)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: _getCategoryIcon(goal['category'] as String),
            color: _getCategoryColor(goal['category'] as String),
            size: 6.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                goal['category'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        CustomIconWidget(
          iconName: 'more_vert',
          color: colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, ColorScheme colorScheme,
      double progress, int progressPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '$progressPercentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getProgressColor(progress),
                  ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1.h,
          decoration: BoxDecoration(
            color: colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: _getProgressColor(progress),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(BuildContext context, ColorScheme colorScheme,
      double targetAmount, double currentAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor Atual',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              'R\$ ${currentAmount.toStringAsFixed(2).replaceAll('.', ',')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light),
                  ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Meta',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              'R\$ ${targetAmount.toStringAsFixed(2).replaceAll('.', ',')}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, ColorScheme colorScheme) {
    final DateTime targetDate = DateTime.parse(goal['targetDate'] as String);
    final int daysRemaining = targetDate.difference(DateTime.now()).inDays;

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'schedule',
          color: colorScheme.onSurfaceVariant,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Text(
          daysRemaining > 0
              ? '$daysRemaining dias restantes'
              : daysRemaining == 0
                  ? 'Meta vence hoje!'
                  : 'Meta vencida há ${-daysRemaining} dias',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: daysRemaining < 0
                    ? AppTheme.getErrorColor(
                        Theme.of(context).brightness == Brightness.light)
                    : daysRemaining < 30
                        ? AppTheme.getWarningColor(
                            Theme.of(context).brightness == Brightness.light)
                        : colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(
              context,
              'add_circle',
              'Adicionar Contribuição',
              onAddContribution,
            ),
            _buildContextMenuItem(
              context,
              'edit',
              'Editar Meta',
              onEdit,
            ),
            _buildContextMenuItem(
              context,
              'share',
              'Compartilhar Progresso',
              onShare,
            ),
            _buildContextMenuItem(
              context,
              'delete',
              'Excluir Meta',
              onDelete,
              isDestructive: true,
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context,
    String iconName,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: isDestructive
            ? AppTheme.getErrorColor(
                Theme.of(context).brightness == Brightness.light)
            : colorScheme.onSurface,
        size: 6.w,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDestructive
                  ? AppTheme.getErrorColor(
                      Theme.of(context).brightness == Brightness.light)
                  : colorScheme.onSurface,
            ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'casa própria':
        return 'home';
      case 'viagem dos sonhos':
        return 'flight';
      case 'carro':
        return 'directions_car';
      case 'reserva de emergência':
        return 'security';
      case 'educação':
        return 'school';
      case 'aposentadoria':
        return 'elderly';
      default:
        return 'savings';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'casa própria':
        return const Color(0xFF4CAF50);
      case 'viagem dos sonhos':
        return const Color(0xFF2196F3);
      case 'carro':
        return const Color(0xFFFF9800);
      case 'reserva de emergência':
        return const Color(0xFFF44336);
      case 'educação':
        return const Color(0xFF9C27B0);
      case 'aposentadoria':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFFE8B931);
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF4CAF50); // Success green
    } else if (progress >= 0.75) {
      return const Color(0xFF8BC34A); // Light green
    } else if (progress >= 0.5) {
      return const Color(0xFFE8B931); // Accent gold
    } else if (progress >= 0.25) {
      return const Color(0xFFFF9800); // Warning orange
    } else {
      return const Color(0xFFFF5722); // Error red-orange
    }
  }
}
