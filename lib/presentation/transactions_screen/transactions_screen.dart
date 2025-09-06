import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/date_section_header.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/monthly_summary_card.dart';
import './widgets/search_bar_widget.dart';
import './widgets/transaction_item_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  DateTime _currentMonth = DateTime.now();
  String _selectedFilter = 'Todos';
  bool _isSearchActive = false;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isExporting = false;
  int _currentBottomIndex = 1; // Transactions tab

  // Mock data
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': 1,
      'type': 'expense',
      'category': 'Alimentação',
      'description': 'Supermercado Extra',
      'amount': 245.80,
      'date': DateTime.now(),
    },
    {
      'id': 2,
      'type': 'income',
      'category': 'Salário',
      'description': 'Salário Dezembro',
      'amount': 4500.00,
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 3,
      'type': 'expense',
      'category': 'Transporte',
      'description': 'Uber para trabalho',
      'amount': 28.50,
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 4,
      'type': 'expense',
      'category': 'Saúde',
      'description': 'Farmácia Drogasil',
      'amount': 67.90,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 5,
      'type': 'income',
      'category': 'Freelance',
      'description': 'Projeto Design',
      'amount': 800.00,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 6,
      'type': 'expense',
      'category': 'Lazer',
      'description': 'Cinema Shopping',
      'amount': 45.00,
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 7,
      'type': 'expense',
      'category': 'Casa',
      'description': 'Conta de Luz',
      'amount': 189.45,
      'date': DateTime.now().subtract(const Duration(days: 4)),
    },
    {
      'id': 8,
      'type': 'income',
      'category': 'Investimentos',
      'description': 'Dividendos ITUB4',
      'amount': 125.30,
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    var filtered = _allTransactions.where((transaction) {
      final matchesSearch = _searchQuery.isEmpty ||
          (transaction['description'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (transaction['category'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'Todos' ||
          (_selectedFilter == 'Receitas' && transaction['type'] == 'income') ||
          (_selectedFilter == 'Despesas' && transaction['type'] == 'expense') ||
          (_selectedFilter == 'Transferências' &&
              transaction['type'] == 'transfer');

      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return filtered;
  }

  Map<DateTime, List<Map<String, dynamic>>> get _groupedTransactions {
    final grouped = <DateTime, List<Map<String, dynamic>>>{};

    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = DateTime(date.year, date.month, date.day);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  double get _monthlyIncome {
    return _allTransactions
        .where((t) => t['type'] == 'income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  double get _monthlyExpenses {
    return _allTransactions
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  int get _transactionCount => _allTransactions.length;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 100) {
      if (_fabAnimationController.value == 1.0) {
        _fabAnimationController.reverse();
      }
    } else {
      if (_fabAnimationController.value == 0.0) {
        _fabAnimationController.forward();
      }
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomIndex = index;
    });
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
        1,
      );
    });
  }

  void _onFilterTap(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchQuery = '';
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
      msg: "Transações atualizadas!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate export process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isExporting = false;
    });

    Fluttertoast.showToast(
      msg: "Relatório exportado com sucesso!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onTransactionEdit(Map<String, dynamic> transaction) {
    // TODO: Navigate to edit transaction screen
    Fluttertoast.showToast(
      msg: "Editar: ${transaction['description']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onTransactionDuplicate(Map<String, dynamic> transaction) {
    // TODO: Duplicate transaction logic
    Fluttertoast.showToast(
      msg: "Transação duplicada!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onTransactionShare(Map<String, dynamic> transaction) {
    // TODO: Share transaction logic
    Fluttertoast.showToast(
      msg: "Compartilhar: ${transaction['description']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onTransactionDelete(Map<String, dynamic> transaction) {
    setState(() {
      _allTransactions.removeWhere((t) => t['id'] == transaction['id']);
    });

    Fluttertoast.showToast(
      msg: "Transação excluída!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.transactions,
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: CustomIconWidget(
              iconName: _isSearchActive ? 'close' : 'search',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: _isSearchActive ? 'Fechar busca' : 'Buscar',
          ),
          IconButton(
            onPressed: _isExporting ? null : _exportToExcel,
            icon: _isExporting
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onSurface,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'file_download',
                    color: colorScheme.onSurface,
                    size: 6.w,
                  ),
            tooltip: 'Exportar Excel',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              onSearchChanged: _onSearchChanged,
              onClear: _toggleSearch,
              isActive: _isSearchActive,
            ),

            // Month Navigation
            if (!_isSearchActive) _buildMonthNavigation(),

            // Monthly Summary Cards
            if (!_isSearchActive) _buildMonthlySummary(),

            // Filter Chips
            if (!_isSearchActive) _buildFilterChips(),

            // Transactions List
            Expanded(
              child: _buildTransactionsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, '/add-transaction-screen');
              },
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              child: CustomIconWidget(
                iconName: 'add',
                color: colorScheme.onSecondary,
                size: 7.w,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: CustomIconWidget(
              iconName: 'chevron_left',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          Text(
            _formatMonthYear(_currentMonth),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: CustomIconWidget(
              iconName: 'chevron_right',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MonthlySummaryCard(
            title: 'Receitas',
            amount:
                'R\$ ${_monthlyIncome.toStringAsFixed(2).replaceAll('.', ',')}',
            subtitle: 'Este mês',
            amountColor:
                AppTheme.getSuccessColor(theme.brightness == Brightness.light),
            icon: Icons.trending_up,
            iconColor:
                AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          ),
          MonthlySummaryCard(
            title: 'Despesas',
            amount:
                'R\$ ${_monthlyExpenses.toStringAsFixed(2).replaceAll('.', ',')}',
            subtitle: 'Este mês',
            amountColor:
                AppTheme.getErrorColor(theme.brightness == Brightness.light),
            icon: Icons.trending_down,
            iconColor:
                AppTheme.getErrorColor(theme.brightness == Brightness.light),
          ),
          MonthlySummaryCard(
            title: 'Transações',
            amount: _transactionCount.toString(),
            subtitle: 'Total',
            amountColor: theme.colorScheme.onSurface,
            icon: Icons.receipt_long,
            iconColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todos', 'Receitas', 'Despesas', 'Transferências'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            int? badgeCount;

            if (filter == 'Receitas') {
              badgeCount =
                  _allTransactions.where((t) => t['type'] == 'income').length;
            } else if (filter == 'Despesas') {
              badgeCount =
                  _allTransactions.where((t) => t['type'] == 'expense').length;
            } else if (filter == 'Transferências') {
              badgeCount =
                  _allTransactions.where((t) => t['type'] == 'transfer').length;
            }

            return Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: FilterChipWidget(
                label: filter,
                isSelected: isSelected,
                onTap: () => _onFilterTap(filter),
                badgeCount: badgeCount,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredTransactions.isEmpty) {
      return EmptyStateWidget(
        title: _searchQuery.isNotEmpty
            ? 'Nenhuma transação encontrada'
            : 'Nenhuma transação ainda',
        subtitle: _searchQuery.isNotEmpty
            ? 'Tente buscar por outros termos ou ajuste os filtros.'
            : 'Comece adicionando sua primeira transação para acompanhar suas finanças.',
        buttonText: 'Adicionar Transação',
        onButtonPressed: () {
          Navigator.pushNamed(context, '/add-transaction-screen');
        },
        illustration:
            'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=300&fit=crop',
      );
    }

    final groupedTransactions = _groupedTransactions;
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(4.w),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final transactions = groupedTransactions[date]!;
        final totalAmount = transactions.fold<double>(
          0.0,
          (sum, t) =>
              sum +
              ((t['type'] == 'income' ? 1 : -1) * (t['amount'] as double)),
        );

        final isToday = DateTime.now().difference(date).inDays == 0;

        return Column(
          children: [
            DateSectionHeader(
              date: date,
              totalAmount: totalAmount,
              isToday: isToday,
            ),
            ...transactions.map((transaction) {
              return TransactionItemWidget(
                transaction: transaction,
                onEdit: () => _onTransactionEdit(transaction),
                onDuplicate: () => _onTransactionDuplicate(transaction),
                onShare: () => _onTransactionShare(transaction),
                onDelete: () => _onTransactionDelete(transaction),
              );
            }),
            SizedBox(height: 2.h),
          ],
        );
      },
    );
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
