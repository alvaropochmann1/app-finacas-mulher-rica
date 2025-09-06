import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar variants for different screens in the personal finance app
enum CustomAppBarVariant {
  dashboard,
  transactions,
  planning,
  goals,
  notes,
  addTransaction,
}

/// Custom app bar that adapts to different screen contexts
/// Provides consistent navigation and actions across the app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomAppBarVariant variant;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.variant,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 2,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
      centerTitle: _shouldCenterTitle(),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton || Navigator.of(context).canPop()) {
      return IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        icon: const Icon(Icons.arrow_back_ios),
        tooltip: 'Voltar',
      );
    }

    // Dashboard specific leading widget
    if (variant == CustomAppBarVariant.dashboard) {
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 18,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (title != null) {
      return Text(
        title!,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    switch (variant) {
      case CustomAppBarVariant.dashboard:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Olá, Maria!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Vamos cuidar das suas finanças',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      case CustomAppBarVariant.transactions:
        return Text(
          'Transações',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
      case CustomAppBarVariant.planning:
        return Text(
          'Planejamento',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
      case CustomAppBarVariant.goals:
        return Text(
          'Metas Financeiras',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
      case CustomAppBarVariant.notes:
        return Text(
          'Anotações',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
      case CustomAppBarVariant.addTransaction:
        return Text(
          'Nova Transação',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) return actions;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.dashboard:
        return [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/notes-screen');
            },
            icon: const Icon(Icons.note_add_outlined),
            tooltip: 'Anotações',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement notifications
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Notificações',
          ),
          const SizedBox(width: 8),
        ];
      case CustomAppBarVariant.transactions:
        return [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement search
            },
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement filter
            },
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
          ),
          const SizedBox(width: 8),
        ];
      case CustomAppBarVariant.planning:
        return [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement calendar view
            },
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendário',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement export
            },
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exportar',
          ),
          const SizedBox(width: 8),
        ];
      case CustomAppBarVariant.goals:
        return [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement add goal
            },
            icon: const Icon(Icons.add),
            tooltip: 'Nova Meta',
          ),
          const SizedBox(width: 8),
        ];
      case CustomAppBarVariant.notes:
        return [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement search notes
            },
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
          ),
          const SizedBox(width: 8),
        ];
      case CustomAppBarVariant.addTransaction:
        return [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement save transaction
            },
            child: Text(
              'Salvar',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ];
    }
  }

  bool _shouldCenterTitle() {
    switch (variant) {
      case CustomAppBarVariant.dashboard:
        return false;
      case CustomAppBarVariant.transactions:
      case CustomAppBarVariant.planning:
      case CustomAppBarVariant.goals:
      case CustomAppBarVariant.notes:
      case CustomAppBarVariant.addTransaction:
        return true;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
