import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/add_goal_bottom_sheet.dart';
import './widgets/empty_goals_widget.dart';
import './widgets/goal_card_widget.dart';
import './widgets/goal_detail_bottom_sheet.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  int _currentBottomNavIndex = 3; // Goals tab active

  // Mock goals data
  List<Map<String, dynamic>> _goals = [
    {
      'id': 1,
      'title': 'Apartamento na Praia',
      'category': 'Casa própria',
      'targetAmount': 250000.0,
      'currentAmount': 45000.0,
      'targetDate': '2026-12-31',
      'createdAt': '2025-01-01',
      'isCompleted': false,
    },
    {
      'id': 2,
      'title': 'Viagem para Europa',
      'category': 'Viagem dos sonhos',
      'targetAmount': 15000.0,
      'currentAmount': 8500.0,
      'targetDate': '2025-07-15',
      'createdAt': '2024-10-15',
      'isCompleted': false,
    },
    {
      'id': 3,
      'title': 'Carro Zero KM',
      'category': 'Carro',
      'targetAmount': 65000.0,
      'currentAmount': 65000.0,
      'targetDate': '2025-03-01',
      'createdAt': '2024-08-01',
      'isCompleted': true,
    },
    {
      'id': 4,
      'title': 'Reserva de Emergência',
      'category': 'Reserva de emergência',
      'targetAmount': 30000.0,
      'currentAmount': 22500.0,
      'targetDate': '2025-06-30',
      'createdAt': '2024-12-01',
      'isCompleted': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.goals,
        actions: [
          IconButton(
            onPressed: _showAddGoalBottomSheet,
            icon: CustomIconWidget(
              iconName: 'add',
              color: colorScheme.primary,
              size: 6.w,
            ),
            tooltip: 'Nova Meta',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: _goals.isEmpty ? _buildEmptyState() : _buildGoalsList(),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton:
          _goals.isNotEmpty ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildEmptyState() {
    return EmptyGoalsWidget(
      onCreateGoal: _showAddGoalBottomSheet,
    );
  }

  Widget _buildGoalsList() {
    final activeGoals =
        _goals.where((goal) => !(goal['isCompleted'] as bool)).toList();
    final completedGoals =
        _goals.where((goal) => goal['isCompleted'] as bool).toList();

    return CustomScrollView(
      slivers: [
        // Header with statistics
        SliverToBoxAdapter(
          child: _buildGoalsHeader(),
        ),

        // Active goals section
        if (activeGoals.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader('Metas Ativas', activeGoals.length),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final goal = activeGoals[index];
                return GoalCardWidget(
                  goal: goal,
                  onTap: () => _showGoalDetail(goal),
                  onDelete: () => _deleteGoal(goal),
                  onEdit: () => _editGoal(goal),
                  onAddContribution: () => _showAddContribution(goal),
                  onShare: () => _shareGoalProgress(goal),
                );
              },
              childCount: activeGoals.length,
            ),
          ),
        ],

        // Completed goals section
        if (completedGoals.isNotEmpty) ...[
          SliverToBoxAdapter(
            child:
                _buildSectionHeader('Metas Concluídas', completedGoals.length),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final goal = completedGoals[index];
                return GoalCardWidget(
                  goal: goal,
                  onTap: () => _showGoalDetail(goal),
                  onDelete: () => _deleteGoal(goal),
                  onEdit: () => _editGoal(goal),
                  onAddContribution: () => _showAddContribution(goal),
                  onShare: () => _shareGoalProgress(goal),
                );
              },
              childCount: completedGoals.length,
            ),
          ),
        ],

        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: 10.h),
        ),
      ],
    );
  }

  Widget _buildGoalsHeader() {
    final totalGoals = _goals.length;
    final completedGoals =
        _goals.where((goal) => goal['isCompleted'] as bool).length;
    final totalTargetAmount = _goals.fold<double>(
        0, (sum, goal) => sum + (goal['targetAmount'] as num).toDouble());
    final totalCurrentAmount = _goals.fold<double>(
        0, (sum, goal) => sum + (goal['currentAmount'] as num).toDouble());
    final overallProgress = totalTargetAmount > 0
        ? (totalCurrentAmount / totalTargetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            AppTheme.getAccentColor(
                    Theme.of(context).brightness == Brightness.light)
                .withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total de Metas',
                  totalGoals.toString(),
                  'flag',
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Concluídas',
                  completedGoals.toString(),
                  'check_circle',
                  AppTheme.getSuccessColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Poupado',
                  'R\$ ${totalCurrentAmount.toStringAsFixed(0).replaceAll('.', ',')}',
                  'savings',
                  AppTheme.getAccentColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Progresso Geral',
                  '${(overallProgress * 100).round()}%',
                  'trending_up',
                  _getProgressColor(overallProgress),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String iconName, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 6.w,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddGoalBottomSheet,
      child: CustomIconWidget(
        iconName: 'add',
        color: Theme.of(context).colorScheme.onSecondary,
        size: 7.w,
      ),
    );
  }

  void _showAddGoalBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddGoalBottomSheet(
        onGoalCreated: _addGoal,
      ),
    );
  }

  void _showGoalDetail(Map<String, dynamic> goal) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GoalDetailBottomSheet(
        goal: goal,
        onContributionAdded: (amount) => _addContribution(goal, amount),
      ),
    );
  }

  void _addGoal(Map<String, dynamic> newGoal) {
    setState(() {
      _goals.add(newGoal);
    });
  }

  void _addContribution(Map<String, dynamic> goal, double amount) {
    setState(() {
      final index = _goals.indexWhere((g) => g['id'] == goal['id']);
      if (index != -1) {
        final currentAmount =
            (_goals[index]['currentAmount'] as num).toDouble();
        final targetAmount = (_goals[index]['targetAmount'] as num).toDouble();
        final newAmount = currentAmount + amount;

        _goals[index]['currentAmount'] = newAmount;

        // Check if goal is completed
        if (newAmount >= targetAmount &&
            !(_goals[index]['isCompleted'] as bool)) {
          _goals[index]['isCompleted'] = true;
          _showGoalCompletedCelebration(_goals[index]);
        } else {
          _checkMilestone(
              _goals[index], currentAmount, newAmount, targetAmount);
        }
      }
    });
  }

  void _deleteGoal(Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tem certeza que deseja excluir a meta "${goal['title']}"?'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.getWarningColor(
                        Theme.of(context).brightness == Brightness.light)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb',
                    color: AppTheme.getWarningColor(
                        Theme.of(context).brightness == Brightness.light),
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Que tal pausar esta meta ao invés de excluir? Você pode retomá-la quando quiser!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.getWarningColor(
                                Theme.of(context).brightness ==
                                    Brightness.light),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement pause goal functionality
            },
            child: Text('Pausar Meta'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _goals.removeWhere((g) => g['id'] == goal['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Meta "${goal['title']}" excluída'),
                  backgroundColor: AppTheme.getErrorColor(
                      Theme.of(context).brightness == Brightness.light),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getErrorColor(
                  Theme.of(context).brightness == Brightness.light),
            ),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _editGoal(Map<String, dynamic> goal) {
    // TODO: Implement edit goal functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidade de edição em desenvolvimento')),
    );
  }

  void _showAddContribution(Map<String, dynamic> goal) {
    _showGoalDetail(goal);
  }

  void _shareGoalProgress(Map<String, dynamic> goal) {
    final double targetAmount = (goal['targetAmount'] as num).toDouble();
    final double currentAmount = (goal['currentAmount'] as num).toDouble();
    final double progress =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final int progressPercentage = (progress * 100).round();

    final String shareText = '''
🎯 Minha meta: ${goal['title']}
💰 Progresso: $progressPercentage% (R\$ ${currentAmount.toStringAsFixed(2).replaceAll('.', ',')} de R\$ ${targetAmount.toStringAsFixed(2).replaceAll('.', ',')})
📱 Acompanhe suas metas com Planilha Mulher Rica!
    ''';

    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Progresso copiado para compartilhar!'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Compartilhar Progresso'),
                content: Text(shareText),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Fechar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _checkMilestone(Map<String, dynamic> goal, double oldAmount,
      double newAmount, double targetAmount) {
    final double oldProgress = oldAmount / targetAmount;
    final double newProgress = newAmount / targetAmount;

    final List<double> milestones = [0.25, 0.50, 0.75];

    for (double milestone in milestones) {
      if (oldProgress < milestone && newProgress >= milestone) {
        _showMilestoneCelebration(goal, (milestone * 100).round());
        break;
      }
    }
  }

  void _showMilestoneCelebration(Map<String, dynamic> goal, int percentage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: AppTheme.getAccentColor(
                  Theme.of(context).brightness == Brightness.light),
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Parabéns! 🎉',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light),
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Você alcançou $percentage% da sua meta "${goal['title']}"!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Continue assim, você está no caminho certo para realizar seus sonhos!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showGoalCompletedCelebration(Map<String, dynamic> goal) {
    _celebrationController.forward();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_celebrationController.value * 0.2),
                  child: CustomIconWidget(
                    iconName: 'emoji_events',
                    color: AppTheme.getAccentColor(
                        Theme.of(context).brightness == Brightness.light),
                    size: 20.w,
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
            Text(
              'META CONQUISTADA! 🏆',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Parabéns! Você realizou sua meta "${goal['title']}"!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Você é uma mulher rica e poderosa! Continue criando e conquistando seus sonhos!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddGoalBottomSheet();
            },
            child: Text('Criar Nova Meta'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Celebrar!'),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/transactions-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/planning-screen');
        break;
      case 3:
        // Already on goals screen
        break;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF4CAF50); // Success green
    } else if (progress >= 0.75) {
      return const Color(0xFF8BC34A); // Light green
    } else if (progress >= 0.5) {
      return const Color(0xFFE8B931); // Accent gold
    } else if (progress >= 0.25) {
      return const Color(0xFFFF9800); // Warning orange
    } else {
      return const Color(0xFFFF5722); // Error red-orange
    }
  }
}
