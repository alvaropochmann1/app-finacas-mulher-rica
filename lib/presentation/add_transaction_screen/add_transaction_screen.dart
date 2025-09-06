import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_picker_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/photo_attachment_widget.dart';
import './widgets/transaction_type_selector.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  XFile? _attachedPhoto;
  bool _isLoading = false;

  // Form validation state
  String? _amountError;
  String? _categoryError;
  String? _descriptionError;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTransactionTypeChanged(bool isIncome) {
    setState(() {
      _isIncome = isIncome;
      _selectedCategory = null; // Reset category when type changes
      _categoryError = null;
    });
  }

  void _onAmountChanged(String amount) {
    setState(() {
      _amountError = null;
    });
  }

  void _onDescriptionChanged(String description) {
    setState(() {
      _descriptionError = null;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _categoryError = null;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onPhotoChanged(XFile? photo) {
    setState(() {
      _attachedPhoto = photo;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate amount
    String amountText =
        _amountController.text.replaceAll(RegExp(r'[^\d,]'), '');
    if (amountText.isEmpty || amountText == '0' || amountText == '0,00') {
      setState(() {
        _amountError = 'Digite um valor válido';
      });
      isValid = false;
    }

    // Validate category
    if (_selectedCategory == null) {
      setState(() {
        _categoryError = 'Selecione uma categoria';
      });
      isValid = false;
    }

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      setState(() {
        _descriptionError = 'Digite uma descrição';
      });
      isValid = false;
    }

    return isValid;
  }

  double _parseAmount(String amountText) {
    // Remove currency symbol and format
    String cleanAmount = amountText
        .replaceAll('R\$ ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(cleanAmount) ?? 0.0;
  }

  Future<void> _saveTransaction() async {
    if (!_validateForm()) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      final amount = _parseAmount(_amountController.text);
      final description = _descriptionController.text.trim();

      // Create transaction data
      final transactionData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'type': _isIncome ? 'income' : 'expense',
        'amount': _isIncome ? amount : -amount,
        'description': description,
        'category': _selectedCategory,
        'date': _selectedDate.toIso8601String(),
        'hasPhoto': _attachedPhoto != null,
        'photoPath': _attachedPhoto?.path,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Success feedback
      HapticFeedback.mediumImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: 'Transação salva com sucesso!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        textColor: Colors.white,
        fontSize: 14,
      );

      // Navigate back to previous screen
      if (mounted) {
        Navigator.pop(context, transactionData);
      }
    } catch (e) {
      // Error handling
      HapticFeedback.heavyImpact();

      Fluttertoast.showToast(
        msg: 'Erro ao salvar transação. Tente novamente.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.getErrorColor(
            Theme.of(context).brightness == Brightness.light),
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDiscardDialog() {
    final hasData = _amountController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategory != null ||
        _attachedPhoto != null;

    if (!hasData) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('Você perderá todas as informações inseridas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getErrorColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: _showDiscardDialog,
          icon: CustomIconWidget(
            iconName: 'close',
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Nova Transação',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  )
                : Text(
                    'Salvar',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.h),

              // Transaction Type Selector
              TransactionTypeSelector(
                isIncome: _isIncome,
                onTypeChanged: _onTransactionTypeChanged,
              ),

              // Amount Input
              AmountInputWidget(
                controller: _amountController,
                isIncome: _isIncome,
                onAmountChanged: _onAmountChanged,
              ),

              // Show amount error
              if (_amountError != null)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _amountError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getErrorColor(
                          theme.brightness == Brightness.light),
                    ),
                  ),
                ),

              // Description Input
              DescriptionInputWidget(
                controller: _descriptionController,
                onDescriptionChanged: _onDescriptionChanged,
              ),

              // Show description error
              if (_descriptionError != null)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _descriptionError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getErrorColor(
                          theme.brightness == Brightness.light),
                    ),
                  ),
                ),

              // Category Picker
              CategoryPickerWidget(
                selectedCategory: _selectedCategory,
                isIncome: _isIncome,
                onCategorySelected: _onCategorySelected,
              ),

              // Show category error
              if (_categoryError != null)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _categoryError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.getErrorColor(
                          theme.brightness == Brightness.light),
                    ),
                  ),
                ),

              // Date Picker
              DatePickerWidget(
                selectedDate: _selectedDate,
                onDateSelected: _onDateSelected,
              ),

              // Photo Attachment
              PhotoAttachmentWidget(
                attachedPhoto: _attachedPhoto,
                onPhotoChanged: _onPhotoChanged,
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Salvando...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Salvar Transação',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
