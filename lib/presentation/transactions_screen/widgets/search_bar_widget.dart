import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onClear;
  final bool isActive;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onClear,
    this.isActive = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward();
      _focusNode.requestFocus();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reverse();
      _focusNode.unfocus();
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar transações...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      )
                    : IconButton(
                        onPressed: widget.onClear,
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
        );
      },
    );
  }
}
