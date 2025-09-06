import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom tab bar variants for different contexts in the personal finance app
enum CustomTabBarVariant {
  transactions, // Income, Expenses, Transfers
  planning, // Monthly, Yearly, Categories
  goals, // Active, Completed, Paused
}

/// Custom tab bar that provides contextual navigation within screens
/// Optimized for financial data organization and mobile interaction
class CustomTabBar extends StatelessWidget {
  final CustomTabBarVariant variant;
  final int currentIndex;
  final Function(int) onTap;
  final bool isScrollable;

  const CustomTabBar({
    super.key,
    required this.variant,
    required this.currentIndex,
    required this.onTap,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        tabs: _buildTabs(context),
        onTap: (index) {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        isScrollable: isScrollable,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withValues(alpha: 0.1),
        ),
        splashFactory: InkRipple.splashFactory,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    switch (variant) {
      case CustomTabBarVariant.transactions:
        return [
          _buildTab(
            context: context,
            icon: Icons.trending_up,
            label: 'Receitas',
            index: 0,
          ),
          _buildTab(
            context: context,
            icon: Icons.trending_down,
            label: 'Despesas',
            index: 1,
          ),
          _buildTab(
            context: context,
            icon: Icons.swap_horiz,
            label: 'Transferências',
            index: 2,
          ),
        ];
      case CustomTabBarVariant.planning:
        return [
          _buildTab(
            context: context,
            icon: Icons.calendar_view_month,
            label: 'Mensal',
            index: 0,
          ),
          _buildTab(
            context: context,
            icon: Icons.help_outline,
            label: 'Anual',
            index: 1,
          ),
          _buildTab(
            context: context,
            icon: Icons.category,
            label: 'Categorias',
            index: 2,
          ),
        ];
      case CustomTabBarVariant.goals:
        return [
          _buildTab(
            context: context,
            icon: Icons.play_arrow,
            label: 'Ativas',
            index: 0,
            badge: '3',
          ),
          _buildTab(
            context: context,
            icon: Icons.check_circle,
            label: 'Concluídas',
            index: 1,
          ),
          _buildTab(
            context: context,
            icon: Icons.pause_circle,
            label: 'Pausadas',
            index: 2,
          ),
        ];
    }
  }

  Widget _buildTab({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    String? badge,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              if (badge != null)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

/// Custom tab bar view that works with CustomTabBar
/// Provides smooth transitions and proper gesture handling
class CustomTabBarView extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;

  const CustomTabBarView({
    super.key,
    required this.children,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: children,
      physics: const BouncingScrollPhysics(),
    );
  }
}

/// Wrapper widget that combines CustomTabBar with DefaultTabController
/// Simplifies usage when you need both tab bar and tab view
class CustomTabBarWrapper extends StatefulWidget {
  final CustomTabBarVariant variant;
  final List<Widget> children;
  final Function(int)? onTabChanged;
  final int initialIndex;

  const CustomTabBarWrapper({
    super.key,
    required this.variant,
    required this.children,
    this.onTabChanged,
    this.initialIndex = 0,
  });

  @override
  State<CustomTabBarWrapper> createState() => _CustomTabBarWrapperState();
}

class _CustomTabBarWrapperState extends State<CustomTabBarWrapper>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.children.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (widget.onTabChanged != null && _tabController.indexIsChanging) {
      widget.onTabChanged!(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTabBar(
          variant: widget.variant,
          currentIndex: _tabController.index,
          onTap: (index) {
            _tabController.animateTo(index);
          },
        ),
        Expanded(
          child: CustomTabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
