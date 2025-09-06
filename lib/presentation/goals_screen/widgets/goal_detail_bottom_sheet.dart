import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class GoalDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> goal;
  final Function(double) onContributionAdded;

  const GoalDetailBottomSheet({
    super.key,
    required this.goal,
    required this.onContributionAdded,
  });

  @override
  State<GoalDetailBottomSheet> createState() => _GoalDetailBottomSheetState();
}

class _GoalDetailBottomSheetState extends State<GoalDetailBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  final _contributionController = TextEditingController();

  // Mock contribution history
  final List<Map<String, dynamic>> _contributionHistory = [
    {
      'id': 1,
      'amount': 500.0,
      'date': '2025-01-05',
      'description': 'Contribuição inicial',
    },
    {
      'id': 2,
      'amount': 300.0,
      'date': '2025-01-15',
      'description': 'Economia do mês',
    },
    {
      'id': 3,
      'amount': 200.0,
      'date': '2025-01-25',
      'description': 'Freelance extra',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final double targetAmount = (widget.goal['targetAmount'] as num).toDouble();
    final double currentAmount =
        (widget.goal['currentAmount'] as num).toDouble();
    final double progress =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _contributionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(context, colorScheme),
                  SizedBox(height: 3.h),
                  _buildQuickContribution(context, colorScheme),
                  SizedBox(height: 3.h),
                  _buildMilestones(context, colorScheme),
                  SizedBox(height: 3.h),
                  _buildContributionHistory(context, colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.goal['title'] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.goal['category'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, ColorScheme colorScheme) {
    final double targetAmount = (widget.goal['targetAmount'] as num).toDouble();
    final double currentAmount =
        (widget.goal['currentAmount'] as num).toDouble();
    final double progress =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final int progressPercentage = (progress * 100).round();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Piggy bank illustration
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: _getCategoryColor(widget.goal['category'] as String)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'savings',
                color: _getCategoryColor(widget.goal['category'] as String),
                size: 10.w,
              ),
            ),
            SizedBox(height: 3.h),

            // Progress circle
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 2.w,
                          backgroundColor:
                              colorScheme.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(progress),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$progressPercentage%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _getProgressColor(progress),
                            ),
                          ),
                          Text(
                            'concluído',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 3.h),

            // Amount info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Atual',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'R\$ ${currentAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      'Meta',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'R\$ ${targetAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                Column(
                  children: [
                    Text(
                      'Restante',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'R\$ ${(targetAmount - currentAmount).toStringAsFixed(2).replaceAll('.', ',')}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getWarningColor(
                            theme.brightness == Brightness.light),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContribution(
      BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar Contribuição',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contributionController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CurrencyInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: 'R\$ 0,00',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'attach_money',
                          color: colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                ElevatedButton(
                  onPressed: _addContribution,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Adicionar'),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            // Quick amount buttons
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [50, 100, 200, 500].map((amount) {
                return OutlinedButton(
                  onPressed: () => _setQuickAmount(amount.toDouble()),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('R\$ $amount'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestones(BuildContext context, ColorScheme colorScheme) {
    final double targetAmount = (widget.goal['targetAmount'] as num).toDouble();
    final double currentAmount =
        (widget.goal['currentAmount'] as num).toDouble();
    final double progress =
        targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

    final List<Map<String, dynamic>> milestones = [
      {'percentage': 0.25, 'label': '25%', 'amount': targetAmount * 0.25},
      {'percentage': 0.50, 'label': '50%', 'amount': targetAmount * 0.50},
      {'percentage': 0.75, 'label': '75%', 'amount': targetAmount * 0.75},
      {'percentage': 1.00, 'label': '100%', 'amount': targetAmount},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marcos da Jornada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ...milestones.map((milestone) {
              final bool isCompleted =
                  progress >= (milestone['percentage'] as double);
              final bool isCurrent = !isCompleted &&
                  progress >= ((milestone['percentage'] as double) - 0.25);

              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.getSuccessColor(
                                theme.brightness == Brightness.light)
                            : isCurrent
                                ? AppTheme.getWarningColor(
                                    theme.brightness == Brightness.light)
                                : colorScheme.outline.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: Colors.white,
                              size: 4.w,
                            )
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${milestone['label']} - R\$ ${(milestone['amount'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isCompleted
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isCompleted
                                  ? AppTheme.getSuccessColor(
                                      theme.brightness == Brightness.light)
                                  : colorScheme.onSurface,
                            ),
                          ),
                          if (isCompleted)
                            Text(
                              'Parabéns! Marco alcançado! 🎉',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.getSuccessColor(
                                    theme.brightness == Brightness.light),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionHistory(
      BuildContext context, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Contribuições',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ..._contributionHistory.map((contribution) {
              final DateTime date =
                  DateTime.parse(contribution['date'] as String);
              final String formattedDate =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getSuccessColor(
                                theme.brightness == Brightness.light)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'add',
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                        size: 4.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contribution['description'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+ R\$ ${(contribution['amount'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _setQuickAmount(double amount) {
    _contributionController.text =
        'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _addContribution() {
    final String text = _contributionController.text;
    if (text.isEmpty) return;

    final double amount = _parseAmount(text);
    if (amount <= 0) return;

    HapticFeedback.mediumImpact();
    widget.onContributionAdded(amount);
    _contributionController.clear();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Contribuição de R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')} adicionada!'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );

    // Update animation
    final double targetAmount = (widget.goal['targetAmount'] as num).toDouble();
    final double newCurrentAmount =
        (widget.goal['currentAmount'] as num).toDouble() + amount;
    final double newProgress = targetAmount > 0
        ? (newCurrentAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimationController.reset();
    _progressAnimationController.forward();
  }

  double _parseAmount(String text) {
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) return 0.0;
    return double.parse(cleanText) / 100;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'casa própria':
        return const Color(0xFF4CAF50);
      case 'viagem dos sonhos':
        return const Color(0xFF2196F3);
      case 'carro':
        return const Color(0xFFFF9800);
      case 'reserva de emergência':
        return const Color(0xFFF44336);
      case 'educação':
        return const Color(0xFF9C27B0);
      case 'aposentadoria':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFFE8B931);
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

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(newValue.text.replaceAll(RegExp(r'[^\d]'), ''));
    final String formatted = _formatCurrency(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(int value) {
    final double amount = value / 100;
    return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}