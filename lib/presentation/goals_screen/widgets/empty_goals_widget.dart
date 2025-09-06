import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyGoalsWidget extends StatelessWidget {
  final VoidCallback onCreateGoal;

  const EmptyGoalsWidget({
    super.key,
    required this.onCreateGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Inspiring illustration
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'savings',
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    size: 40.w,
                  ),
                  Positioned(
                    top: 15.w,
                    right: 15.w,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getAccentColor(
                            theme.brightness == Brightness.light),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'star',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18.w,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'trending_up',
                        color: Colors.white,
                        size: 4.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // Motivational title
            Text(
              'Seus Sonhos Começam Aqui!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Inspiring description
            Text(
              'Transforme seus sonhos em realidade criando metas financeiras inteligentes. Cada grande conquista começa com um primeiro passo.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),

            // Benefits list
            _buildBenefitItem(
              context,
              'track_changes',
              'Acompanhe seu progresso em tempo real',
              colorScheme,
            ),
            SizedBox(height: 1.h),
            _buildBenefitItem(
              context,
              'celebration',
              'Celebre cada marco conquistado',
              colorScheme,
            ),
            SizedBox(height: 1.h),
            _buildBenefitItem(
              context,
              'psychology',
              'Mantenha-se motivada com lembretes',
              colorScheme,
            ),
            SizedBox(height: 4.h),

            // Create goal button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onCreateGoal();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add_circle',
                      color: colorScheme.onPrimary,
                      size: 6.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Criar Minha Primeira Meta',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Secondary action
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showGoalIdeas(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb_outline',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Ver Ideias de Metas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String iconName,
    String text,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  void _showGoalIdeas(BuildContext context) {
    final List<Map<String, dynamic>> goalIdeas = [
      {
        'title': 'Casa Própria',
        'description': 'Realize o sonho da casa própria com planejamento',
        'icon': 'home',
        'color': Color(0xFF4CAF50),
        'suggestedAmount': 150000.0,
      },
      {
        'title': 'Viagem dos Sonhos',
        'description': 'Conheça lugares incríveis pelo mundo',
        'icon': 'flight',
        'color': Color(0xFF2196F3),
        'suggestedAmount': 8000.0,
      },
      {
        'title': 'Reserva de Emergência',
        'description': 'Tenha segurança para imprevistos',
        'icon': 'security',
        'color': Color(0xFFF44336),
        'suggestedAmount': 20000.0,
      },
      {
        'title': 'Carro Novo',
        'description': 'Conquiste sua independência e mobilidade',
        'icon': 'directions_car',
        'color': Color(0xFFFF9800),
        'suggestedAmount': 45000.0,
      },
      {
        'title': 'Educação',
        'description': 'Invista no seu futuro profissional',
        'icon': 'school',
        'color': Color(0xFF9C27B0),
        'suggestedAmount': 15000.0,
      },
      {
        'title': 'Aposentadoria',
        'description': 'Garanta um futuro tranquilo e confortável',
        'icon': 'elderly',
        'color': Color(0xFF607D8B),
        'suggestedAmount': 500000.0,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 70.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Ideias de Metas Financeiras',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView.builder(
                itemCount: goalIdeas.length,
                itemBuilder: (context, index) {
                  final idea = goalIdeas[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color:
                              (idea['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: idea['icon'] as String,
                          color: idea['color'] as Color,
                          size: 6.w,
                        ),
                      ),
                      title: Text(
                        idea['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(idea['description'] as String),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Sugestão: R\$ ${(idea['suggestedAmount'] as double).toStringAsFixed(2).replaceAll('.', ',')}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: idea['color'] as Color,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                      trailing: CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onCreateGoal();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
