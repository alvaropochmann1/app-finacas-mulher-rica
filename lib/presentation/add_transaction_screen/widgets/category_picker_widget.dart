import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CategoryPickerWidget extends StatefulWidget {
  final String? selectedCategory;
  final bool isIncome;
  final Function(String) onCategorySelected;

  const CategoryPickerWidget({
    super.key,
    this.selectedCategory,
    required this.isIncome,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPickerWidget> createState() => _CategoryPickerWidgetState();
}

class _CategoryPickerWidgetState extends State<CategoryPickerWidget> {
  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Alimentação', 'icon': 'restaurant'},
    {'name': 'Transporte', 'icon': 'directions_car'},
    {'name': 'Saúde', 'icon': 'local_hospital'},
    {'name': 'Educação', 'icon': 'school'},
    {'name': 'Lazer', 'icon': 'movie'},
    {'name': 'Compras', 'icon': 'shopping_bag'},
    {'name': 'Casa', 'icon': 'home'},
    {'name': 'Serviços', 'icon': 'build'},
    {'name': 'Investimentos', 'icon': 'trending_up'},
    {'name': 'Outros', 'icon': 'more_horiz'},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salário', 'icon': 'work'},
    {'name': 'Freelance', 'icon': 'laptop'},
    {'name': 'Investimentos', 'icon': 'trending_up'},
    {'name': 'Venda', 'icon': 'sell'},
    {'name': 'Presente', 'icon': 'card_giftcard'},
    {'name': 'Prêmio', 'icon': 'emoji_events'},
    {'name': 'Aluguel', 'icon': 'home_work'},
    {'name': 'Outros', 'icon': 'more_horiz'},
  ];

  void _showCategoryBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoryBottomSheet(),
    );
  }

  Widget _buildCategoryBottomSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = widget.isIncome ? _incomeCategories : _expenseCategories;

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Selecionar Categoria',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = widget.selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onCategorySelected(category['name']);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: category['icon'],
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            category['name'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
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
            'Categoria',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: _showCategoryBottomSheet,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (widget.selectedCategory != null) ...[
                    CustomIconWidget(
                      iconName: _getCategoryIcon(widget.selectedCategory!),
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                  ],
                  Expanded(
                    child: Text(
                      widget.selectedCategory ?? 'Selecionar categoria',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: widget.selectedCategory != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String categoryName) {
    final categories = widget.isIncome ? _incomeCategories : _expenseCategories;
    final category = categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => {'icon': 'more_horiz'},
    );
    return category['icon'];
  }
}
