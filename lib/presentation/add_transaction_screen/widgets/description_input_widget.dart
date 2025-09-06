import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DescriptionInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onDescriptionChanged;

  const DescriptionInputWidget({
    super.key,
    required this.controller,
    required this.onDescriptionChanged,
  });

  @override
  State<DescriptionInputWidget> createState() => _DescriptionInputWidgetState();
}

class _DescriptionInputWidgetState extends State<DescriptionInputWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  final List<String> _recentSuggestions = [
    'Supermercado',
    'Combustível',
    'Restaurante',
    'Farmácia',
    'Transporte público',
    'Academia',
    'Salário',
    'Freelance',
    'Venda',
    'Investimento',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.onDescriptionChanged(suggestion);
    _focusNode.unfocus();
  }

  List<String> _getFilteredSuggestions() {
    if (widget.controller.text.isEmpty) {
      return _recentSuggestions.take(5).toList();
    }

    return _recentSuggestions
        .where((suggestion) => suggestion
            .toLowerCase()
            .contains(widget.controller.text.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrição',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Digite uma descrição...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
              onChanged: (value) {
                widget.onDescriptionChanged(value);
                setState(() {});
              },
            ),
          ),
          if (_showSuggestions && _getFilteredSuggestions().isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              constraints: BoxConstraints(maxHeight: 20.h),
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
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 1.h),
                itemCount: _getFilteredSuggestions().length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final suggestion = _getFilteredSuggestions()[index];
                  return ListTile(
                    dense: true,
                    leading: CustomIconWidget(
                      iconName: 'history',
                      color: colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    title: Text(
                      suggestion,
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () => _selectSuggestion(suggestion),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
