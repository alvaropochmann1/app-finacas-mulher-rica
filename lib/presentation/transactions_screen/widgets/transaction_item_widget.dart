import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionItemWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const TransactionItemWidget({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDuplicate,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isIncome = (transaction['type'] as String) == 'income';
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final description = transaction['description'] as String;
    final date = transaction['date'] as DateTime;

    return Dismissible(
      key: Key(transaction['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.getErrorColor(theme.brightness == Brightness.light),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        if (onDelete != null) onDelete!();
      },
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showContextMenu(context);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                    size: 6.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isIncome
                          ? AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light)
                          : AppTheme.getErrorColor(
                              theme.brightness == Brightness.light),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            'Excluir Transação',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir esta transação? Esta ação não pode ser desfeita.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getErrorColor(
                    theme.brightness == Brightness.light),
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              _buildContextMenuItem(
                context,
                icon: 'edit',
                title: 'Editar',
                onTap: () {
                  Navigator.pop(context);
                  if (onEdit != null) onEdit!();
                },
              ),
              _buildContextMenuItem(
                context,
                icon: 'content_copy',
                title: 'Duplicar',
                onTap: () {
                  Navigator.pop(context);
                  if (onDuplicate != null) onDuplicate!();
                },
              ),
              _buildContextMenuItem(
                context,
                icon: 'share',
                title: 'Compartilhar',
                onTap: () {
                  Navigator.pop(context);
                  if (onShare != null) onShare!();
                },
              ),
              _buildContextMenuItem(
                context,
                icon: 'delete',
                title: 'Excluir',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) onDelete!();
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? AppTheme.getErrorColor(theme.brightness == Brightness.light)
            : colorScheme.onSurface,
        size: 6.w,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDestructive
              ? AppTheme.getErrorColor(theme.brightness == Brightness.light)
              : colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação':
        return 'restaurant';
      case 'transporte':
        return 'directions_car';
      case 'saúde':
        return 'local_hospital';
      case 'educação':
        return 'school';
      case 'lazer':
        return 'movie';
      case 'casa':
        return 'home';
      case 'salário':
        return 'work';
      case 'freelance':
        return 'computer';
      case 'investimentos':
        return 'trending_up';
      default:
        return 'category';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alimentação':
        return const Color(0xFFFF6B6B);
      case 'transporte':
        return const Color(0xFF4ECDC4);
      case 'saúde':
        return const Color(0xFF45B7D1);
      case 'educação':
        return const Color(0xFF96CEB4);
      case 'lazer':
        return const Color(0xFFFECA57);
      case 'casa':
        return const Color(0xFF6C5CE7);
      case 'salário':
        return const Color(0xFF00B894);
      case 'freelance':
        return const Color(0xFFE17055);
      case 'investimentos':
        return const Color(0xFF00CEC9);
      default:
        return const Color(0xFF74B9FF);
    }
  }
}
