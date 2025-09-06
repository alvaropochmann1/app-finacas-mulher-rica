import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom_bar.dart';
import './widgets/dashboard_header.dart';
import './widgets/expense_pie_chart.dart';
import './widgets/monthly_balance_card.dart';
import './widgets/monthly_expenses_card.dart';
import './widgets/quick_action_buttons.dart';
import './widgets/recent_transactions_list.dart';
import './widgets/recommendations_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _currentDate = DateTime.now();
  bool _isPrivacyEnabled = false;
  int _currentBottomNavIndex = 0;

  // Mock data for dashboard
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      "id": 1,
      "description": "Supermercado Extra",
      "amount": -150.75,
      "category": "Alimentação",
      "type": "Despesa",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "description": "Salário",
      "amount": 3500.00,
      "category": "Trabalho",
      "type": "Receita",
      "date": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 3,
      "description": "Uber",
      "amount": -25.50,
      "category": "Transporte",
      "type": "Despesa",
      "date": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 4,
      "description": "Farmácia",
      "amount": -45.30,
      "category": "Saúde",
      "type": "Despesa",
      "date": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 5,
      "description": "Cinema",
      "amount": -35.00,
      "category": "Lazer",
      "type": "Despesa",
      "date": DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  final List<Map<String, dynamic>> _mockExpenseData = [
    {"category": "Alimentação", "amount": 450.75},
    {"category": "Transporte", "amount": 280.50},
    {"category": "Saúde", "amount": 125.30},
    {"category": "Lazer", "amount": 180.00},
    {"category": "Casa", "amount": 320.25},
    {"category": "Educação", "amount": 150.00},
  ];

  final List<Map<String, dynamic>> _mockRecommendations = [
    {
      "type": "positive",
      "title": "Parabéns pela economia!",
      "description":
          "Você economizou 15% em alimentação este mês. Que tal investir essa quantia em uma reserva de emergência?",
    },
    {
      "type": "warning",
      "title": "Atenção aos gastos com lazer",
      "description":
          "Seus gastos com entretenimento aumentaram 20% comparado ao mês passado. Considere estabelecer um limite mensal.",
    },
    {
      "type": "neutral",
      "title": "Dica de investimento",
      "description":
          "Com seu perfil de gastos, considere investir em fundos de renda fixa para começar a fazer seu dinheiro trabalhar para você.",
    },
  ];

  double get _monthlyBalance {
    final income = _mockTransactions
        .where((t) => (t['amount'] as double) > 0)
        .fold<double>(0, (sum, t) => sum + (t['amount'] as double));
    final expenses = _mockTransactions
        .where((t) => (t['amount'] as double) < 0)
        .fold<double>(0, (sum, t) => sum + (t['amount'] as double).abs());
    return income - expenses;
  }

  double get _monthlyExpenses {
    return _mockTransactions
        .where((t) => (t['amount'] as double) < 0)
        .fold<double>(0, (sum, t) => sum + (t['amount'] as double).abs());
  }

  double get _monthlyIncome {
    return _mockTransactions
        .where((t) => (t['amount'] as double) > 0)
        .fold<double>(0, (sum, t) => sum + (t['amount'] as double));
  }

  double get _currentVariance {
    const expectedExpenses = 1200.0; // Mock expected monthly expenses
    final actualExpenses = _monthlyExpenses;
    return ((expectedExpenses - actualExpenses) / expectedExpenses) * 100;
  }

  void _togglePrivacy() {
    setState(() {
      _isPrivacyEnabled = !_isPrivacyEnabled;
    });
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
    });
  }

  void _deleteTransaction(int transactionId) {
    setState(() {
      _mockTransactions.removeWhere((t) => t['id'] == transactionId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transação excluída com sucesso'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(
                  currentDate: _currentDate,
                  userName: 'Maria',
                  onPreviousMonth: _navigateToPreviousMonth,
                  onNextMonth: _navigateToNextMonth,
                ),
                MonthlyBalanceCard(
                  balance: _monthlyBalance,
                  isPrivacyEnabled: _isPrivacyEnabled,
                  onPrivacyToggle: _togglePrivacy,
                ),
                MonthlyExpensesCard(
                  totalExpenses: _monthlyExpenses,
                  monthlyIncome: _monthlyIncome,
                  isPrivacyEnabled: _isPrivacyEnabled,
                ),
                const QuickActionButtons(),
                ExpensePieChart(
                  expenseData: _mockExpenseData,
                  isPrivacyEnabled: _isPrivacyEnabled,
                ),
                RecentTransactionsList(
                  transactions: _mockTransactions,
                  isPrivacyEnabled: _isPrivacyEnabled,
                  onDeleteTransaction: _deleteTransaction,
                ),
                RecommendationsSection(
                  recommendations: _mockRecommendations,
                  currentVariance: _currentVariance,
                ),
                SizedBox(height: 10.h), // Bottom padding for navigation
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
      ),
    );
  }
}
