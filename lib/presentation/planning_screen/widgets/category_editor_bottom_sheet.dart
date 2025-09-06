import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryEditorBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? category;
  final Function(Map<String, dynamic>) onSave;

  const CategoryEditorBottomSheet({
    super.key,
    this.category,
    required this.onSave,
  });

  @override
  State<CategoryEditorBottomSheet> createState() =>
      _CategoryEditorBottomSheetState();
}

class _CategoryEditorBottomSheetState extends State<CategoryEditorBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late TextEditingController _notesController;
  String _selectedIcon = 'category';
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _budgetFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  final List<Map<String, String>> _availableIcons = [
    {'icon': 'restaurant', 'label': 'Alimentação'},
    {'icon': 'local_gas_station', 'label': 'Combustível'},
    {'icon': 'shopping_cart', 'label': 'Compras'},
    {'icon': 'home', 'label': 'Casa'},
    {'icon': 'health_and_safety', 'label': 'Saúde'},
    {'icon': 'school', 'label': 'Educação'},
    {'icon': 'sports_esports', 'label': 'Lazer'},
    {'icon': 'directions_car', 'label': 'Transporte'},
    {'icon': 'checkroom', 'label': 'Roupas'},
    {'icon': 'pets', 'label': 'Pets'},
    {'icon': 'phone', 'label': 'Telefone'},
    {'icon': 'category', 'label': 'Outros'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?['name'] ?? '',
    );
    _budgetController = TextEditingController(
      text: widget.category != null && (widget.category!['budgeted'] as num) > 0
          ? _formatCurrency((widget.category!['budgeted'] as num).toDouble())
          : '',
    );
    _notesController = TextEditingController(
      text: widget.category?['notes'] ?? '',
    );
    _selectedIcon = widget.category?['icon'] ?? 'category';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    _nameFocus.dispose();
    _budgetFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  double _parseCurrency(String value) {
    String cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  void _saveCategory() {
    if (_nameController.text.trim().isEmpty ||
        _budgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha nome e orçamento'),
          backgroundColor: AppTheme.getErrorColor(
              Theme.of(context).brightness == Brightness.light),
        ),
      );
      return;
    }

    final category = {
      'id': widget.category?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'icon': _selectedIcon,
      'budgeted': _parseCurrency(_budgetController.text),
      'spent': widget.category?['spent'] ?? 0.0,
      'notes': _notesController.text.trim(),
    };

    widget.onSave(category);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.category != null
                          ? 'Editar Categoria'
                          : 'Nova Categoria',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  'Nome da Categoria',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                    hintText: 'Ex: Alimentação, Transporte...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _budgetFocus.requestFocus(),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Orçamento',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _budgetController,
                  focusNode: _budgetFocus,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'R\$ 0,00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      double parsedValue = _parseCurrency(value);
                      String formatted = _formatCurrency(parsedValue);
                      if (formatted != value) {
                        _budgetController.value = TextEditingValue(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9R\$\s,.]')),
                  ],
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _notesFocus.requestFocus(),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Ícone',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  height: 8.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final iconData = _availableIcons[index];
                      final isSelected = _selectedIcon == iconData['icon'];

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedIcon = iconData['icon']!;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 3.w),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.1)
                                : colorScheme.surface,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: iconData['icon']!,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                iconData['label']!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Observações (Opcional)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _notesController,
                  focusNode: _notesFocus,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Adicione observações sobre esta categoria...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.category != null
                          ? 'Salvar Alterações'
                          : 'Criar Categoria',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}