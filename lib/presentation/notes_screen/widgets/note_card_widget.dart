import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onArchive;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.onShare,
    required this.onDuplicate,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String title = note['title'] as String? ?? 'Sem título';
    final String content = note['content'] as String? ?? '';
    final DateTime date = note['date'] as DateTime? ?? DateTime.now();
    final String category = note['category'] as String? ?? 'geral';
    final Color categoryColor = _getCategoryColor(category, colorScheme);

    return Dismissible(
      key: Key('note_${note['id']}'),
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
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: categoryColor.withValues(alpha: 0.3),
            width: 1,
          ),
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCategoryLabel(category),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                if (content.isNotEmpty)
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatDate(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Spacer(),
                    if (content.length > 150)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(content.length / 100).ceil()}min leitura',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'orcamento':
        return AppTheme.getSuccessColor(
            colorScheme.brightness == Brightness.light);
      case 'investimentos':
        return AppTheme.getAccentColor(
            colorScheme.brightness == Brightness.light);
      case 'metas':
        return colorScheme.primary;
      case 'insights':
        return AppTheme.getWarningColor(
            colorScheme.brightness == Brightness.light);
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'orcamento':
        return 'Orçamento';
      case 'investimentos':
        return 'Investimentos';
      case 'metas':
        return 'Metas';
      case 'insights':
        return 'Insights';
      default:
        return 'Geral';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ontem, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Excluir anotação',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir esta anotação? Esta ação não pode ser desfeita.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getErrorColor(
                    theme.brightness == Brightness.light),
              ),
              child: Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.3),
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
                    onEdit();
                  },
                ),
                _buildContextMenuItem(
                  context,
                  icon: 'share',
                  title: 'Compartilhar',
                  onTap: () {
                    Navigator.pop(context);
                    onShare();
                  },
                ),
                _buildContextMenuItem(
                  context,
                  icon: 'content_copy',
                  title: 'Duplicar',
                  onTap: () {
                    Navigator.pop(context);
                    onDuplicate();
                  },
                ),
                _buildContextMenuItem(
                  context,
                  icon: 'archive',
                  title: 'Arquivar',
                  onTap: () {
                    Navigator.pop(context);
                    onArchive();
                  },
                ),
                Divider(height: 3.h),
                _buildContextMenuItem(
                  context,
                  icon: 'delete',
                  title: 'Excluir',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
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
    final color = isDestructive
        ? AppTheme.getErrorColor(theme.brightness == Brightness.light)
        : theme.colorScheme.onSurface;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: color,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
