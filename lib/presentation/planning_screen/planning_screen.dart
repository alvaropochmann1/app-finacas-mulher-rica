import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/budget_category_card_widget.dart';
import './widgets/category_editor_bottom_sheet.dart';
import './widgets/expected_income_widget.dart';
import './widgets/month_navigation_widget.dart';
import './widgets/monthly_summary_widget.dart';
import './widgets/quick_actions_widget.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  DateTime _selectedDate = DateTime.now();
  double _expectedIncome = 5500.0;
  List<Map<String, dynamic>> _budgetCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _budgetCategories = [
      {
        'id': 1,
        'name': 'Alimentação',
        'icon': 'restaurant',
        'budgeted': 800.0,
        'spent': 650.0,
        'notes': 'Inclui supermercado e delivery',
      },
      {
        'id': 2,
        'name': 'Transporte',
        'icon': 'directions_car',
        'budgeted': 400.0,
        'spent': 420.0,
        'notes': 'Combustível e manutenção',
      },
      {
        'id': 3,
        'name': 'Casa',
        'icon': 'home',
        'budgeted': 1200.0,
        'spent': 1200.0,
        'notes': 'Aluguel, condomínio e contas',
      },
      {
        'id': 4,
        'name': 'Saúde',
        'icon': 'health_and_safety',
        'budgeted': 300.0,
        'spent': 180.0,
        'notes': 'Plano de saúde e medicamentos',
      },
      {
        'id': 5,
        'name': 'Lazer',
        'icon': 'sports_esports',
        'budgeted': 500.0,
        'spent': 380.0,
        'notes': 'Cinema, restaurantes e viagens',
      },
      {
        'id': 6,
        'name': 'Educação',
        'icon': 'school',
        'budgeted': 250.0,
        'spent': 250.0,
        'notes': 'Cursos online e livros',
      },
    ];
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _selectedDate = selectedDate;
        });
      }
    });
  }

  void _updateExpectedIncome(double income) {
    setState(() {
      _expectedIncome = income;
    });
  }

  void _showCategoryEditor({Map<String, dynamic>? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryEditorBottomSheet(
        category: category,
        onSave: (savedCategory) {
          setState(() {
            if (category != null) {
              // Edit existing category
              final index = _budgetCategories.indexWhere(
                (cat) => (cat['id'] as int) == (savedCategory['id'] as int),
              );
              if (index != -1) {
                _budgetCategories[index] = savedCategory;
              }
            } else {
              // Add new category
              _budgetCategories.add(savedCategory);
            }
          });
          HapticFeedback.mediumImpact();
        },
      ),
    );
  }

  void _deleteCategory(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Categoria'),
        content: Text(
            'Tem certeza que deseja excluir a categoria "${(category['name'] as String)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _budgetCategories.removeWhere(
                  (cat) => (cat['id'] as int) == (category['id'] as int),
                );
              });
              Navigator.of(context).pop();
              HapticFeedback.mediumImpact();
            },
            child: Text(
              'Excluir',
              style: TextStyle(
                color: AppTheme.getErrorColor(
                    Theme.of(context).brightness == Brightness.light),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyPreviousMonth() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Orçamento do mês anterior copiado com sucesso!'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _createTemplate() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modelo de orçamento salvo com sucesso!'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  double get _totalBudgeted {
    return _budgetCategories.fold(
        0.0,
        (sum, category) =>
            sum + ((category['budgeted'] as num?)?.toDouble() ?? 0.0));
  }

  double get _totalSpent {
    return _budgetCategories.fold(
        0.0,
        (sum, category) =>
            sum + ((category['spent'] as num?)?.toDouble() ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(variant: CustomAppBarVariant.planning),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {
              _initializeMockData();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonthNavigationWidget(
                  selectedDate: _selectedDate,
                  onPreviousMonth: _navigateToPreviousMonth,
                  onNextMonth: _navigateToNextMonth,
                  onDateTap: _showDatePicker,
                ),
                ExpectedIncomeWidget(
                  currentIncome: _expectedIncome,
                  onIncomeChanged: _updateExpectedIncome,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorias de Orçamento',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showCategoryEditor(),
                        icon: CustomIconWidget(
                          iconName: 'add',
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_budgetCategories.isEmpty)
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'category',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Nenhuma categoria criada',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Comece criando categorias para organizar seu orçamento mensal',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),
                        ElevatedButton.icon(
                          onPressed: () => _showCategoryEditor(),
                          icon: CustomIconWidget(
                            iconName: 'add',
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                          label: Text('Criar Primeira Categoria'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _budgetCategories.length,
                    itemBuilder: (context, index) {
                      final category = _budgetCategories[index];
                      return BudgetCategoryCardWidget(
                        category: category,
                        onTap: () => _showCategoryEditor(category: category),
                        onEdit: () => _showCategoryEditor(category: category),
                        onDelete: () => _deleteCategory(category),
                      );
                    },
                  ),
                if (_budgetCategories.isNotEmpty) ...[
                  MonthlySummaryWidget(
                    totalIncome: _expectedIncome,
                    totalBudgeted: _totalBudgeted,
                    totalSpent: _totalSpent,
                  ),
                  QuickActionsWidget(
                    onCopyPreviousMonth: _copyPreviousMonth,
                    onCreateTemplate: _createTemplate,
                    onAddCategory: () => _showCategoryEditor(),
                  ),
                ],
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard-screen');
              break;
            case 1:
              Navigator.pushNamed(context, '/transactions-screen');
              break;
            case 2:
              // Already on planning screen
              break;
            case 3:
              Navigator.pushNamed(context, '/goals-screen');
              break;
          }
        },
      ),
    );
  }
}
