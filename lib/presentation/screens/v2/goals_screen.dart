// lib/presentation/screens/goals/goals_screen.dart
// ============================================================================
// PANTALLA COMPLETA DE OBJETIVOS CON TRACKING VISUAL Y GESTIÓN COMPLETA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// ============================================================================
// 🎨 PALETA DE COLORES MODERNA (BASADA EN ANALYTICSCOLORS)
// ============================================================================
class GoalsColors {
  // Fondo principal - Negro profundo
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  // Gradientes Azul Oscuro a Morado
  static const List<Color> primaryGradient = [
    Color(0xFF1e3a8a), // Azul oscuro
    Color(0xFF581c87), // Morado oscuro
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6), // Azul
    Color(0xFF8b5cf6), // Morado
  ];

  static const List<Color> lightGradient = [
    Color(0xFF60a5fa), // Azul claro
    Color(0xFFa855f7), // Morado claro
  ];

  // Gradientes adicionales para gráficos
  static const List<Color> chartGradient1 = [
    Color(0xFF06b6d4), // Cyan
    Color(0xFF3b82f6), // Azul
  ];

  static const List<Color> chartGradient2 = [
    Color(0xFF8b5cf6), // Morado
    Color(0xFFec4899), // Rosa
  ];

  static const List<Color> chartGradient3 = [
    Color(0xFF10b981), // Verde
    Color(0xFF06b6d4), // Cyan
  ];

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);
}


class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _fabController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadGoals();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    // Iniciar animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
        _progressController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabController.forward();
    });
  }

  void _loadGoals() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;
    if (user != null) {
      context.read<GoalsProvider>().loadUserGoals(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoalsColors.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GoalsColors.primaryGradient[0].withOpacity(0.5),
              GoalsColors.backgroundPrimary,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async => _loadGoals(),
              backgroundColor: GoalsColors.backgroundCard,
              color: GoalsColors.accentGradient[1],
              child: CustomScrollView(
                slivers: [
                  // Header personalizado
                  _buildSliverHeader(),

                  // Estadísticas de objetivos
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildGoalsOverview(),
                    ),
                  ),

                  // Lista de objetivos activos
                  _buildGoalsList(),

                  // Espacio para FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddGoalBottomSheet(),
          backgroundColor: GoalsColors.chartGradient2[1],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_task),
          label: const Text(
            'New Goal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          heroTag: 'add_goal',
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GoalsColors.accentGradient[1].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      color: GoalsColors.accentGradient[1],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Goals',
                          style: TextStyle(
                            color: GoalsColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Track your progress and achieve greatness',
                          style: TextStyle(
                            color: GoalsColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showGoalsSettings(),
                    icon: const Icon(
                      Icons.tune,
                      color: GoalsColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsOverview() {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final activeGoals = goalsProvider.activeGoals;
        final completedGoals = goalsProvider.completedGoals;
        final totalProgress = goalsProvider.averageProgress;

        return Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Cards de estadísticas
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      'Active Goals',
                      activeGoals.length.toString(),
                      Icons.trending_up,
                      GoalsColors.chartGradient1[0],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOverviewCard(
                      'Completed',
                      completedGoals.length.toString(),
                      Icons.check_circle,
                      GoalsColors.chartGradient3[0],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progreso general
              _buildOverallProgress(totalProgress),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GoalsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GoalsColors.textTertiary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: GoalsColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: GoalsColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GoalsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GoalsColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: GoalsColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: GoalsColors.chartGradient2[1],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress * _progressAnimation.value,
                  backgroundColor: GoalsColors.backgroundSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(GoalsColors.chartGradient2[1]),
                  minHeight: 8,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            progress > 0.8
                ? "You're crushing your goals! 🔥"
                : progress > 0.5
                ? "Great progress, keep it up! 💪"
                : "Every step counts. You've got this! 🌱",
            style: const TextStyle(
              color: GoalsColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        if (goalsProvider.isLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(GoalsColors.chartGradient2[1]),
                ),
              ),
            ),
          );
        }

        final goals = goalsProvider.goals;

        if (goals.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final goal = goals[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.5 + (index * 0.1)),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 0.8),
                    1.0,
                    curve: Curves.easeOutBack,
                  ),
                )),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _buildGoalCard(goal),
                ),
              );
            },
            childCount: goals.length,
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(goal) {
    final color = _getGoalTypeColor(goal.type);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GoalsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.isCompleted
              ? GoalsColors.chartGradient3[0].withOpacity(0.5)
              : GoalsColors.textTertiary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del objetivo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGoalTypeIcon(goal.type),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        color: GoalsColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: const TextStyle(
                        color: GoalsColors.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: GoalsColors.textSecondary,
                ),
                color: GoalsColors.backgroundSecondary,
                onSelected: (value) => _handleGoalAction(goal, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: GoalsColors.textSecondary),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: GoalsColors.textPrimary)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: goal.isCompleted ? 'reactivate' : 'complete',
                    child: Row(
                      children: [
                        Icon(
                          goal.isCompleted ? Icons.refresh : Icons.check_circle,
                          color: GoalsColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          goal.isCompleted ? 'Reactivate' : 'Complete',
                          style: const TextStyle(color: GoalsColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Barra de progreso
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            color: GoalsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: GoalsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: goal.progress * _progressAnimation.value,
                            backgroundColor: GoalsColors.backgroundSecondary,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(goal.progress * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (goal.isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GoalsColors.chartGradient3[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GoalsColors.chartGradient3[0].withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration,
                    color: GoalsColors.chartGradient3[0],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Goal completed! Great job! 🎉',
                    style: TextStyle(
                      color: GoalsColors.chartGradient3[0],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: GoalsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GoalsColors.textTertiary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: GoalsColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Goals Yet',
            style: TextStyle(
              color: GoalsColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your first goal and start your journey towards personal growth.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GoalsColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalBottomSheet(),
            style: ElevatedButton.styleFrom(
              backgroundColor: GoalsColors.chartGradient2[1],
              foregroundColor: GoalsColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Create First Goal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGoalTypeColor(goalType) {
    final typeString = goalType.toString();
    if (typeString.contains('consistency')) return GoalsColors.chartGradient1[0];
    if (typeString.contains('mood')) return GoalsColors.chartGradient2[1];
    if (typeString.contains('positiveMoments')) return GoalsColors.lightGradient[0];
    if (typeString.contains('stressReduction')) return GoalsColors.chartGradient3[0];
    return GoalsColors.accentGradient[1];
  }

  IconData _getGoalTypeIcon(goalType) {
    final typeString = goalType.toString();
    if (typeString.contains('consistency')) return Icons.timeline;
    if (typeString.contains('mood')) return Icons.sentiment_satisfied;
    if (typeString.contains('positiveMoments')) return Icons.star;
    if (typeString.contains('stressReduction')) return Icons.spa;
    return Icons.flag;
  }

  void _showAddGoalBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalBottomSheet(),
    );
  }

  void _showGoalsSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Goals settings coming soon!'),
        backgroundColor: GoalsColors.accentGradient[1],
      ),
    );
  }

  void _handleGoalAction(goal, String action) {
    final goalsProvider = context.read<GoalsProvider>();

    switch (action) {
      case 'edit':
        _showEditGoalBottomSheet(goal);
        break;
      case 'complete':
        goalsProvider.completeGoal(goal.id);
        break;
      case 'reactivate':
        goalsProvider.reactivateGoal(goal.id);
        break;
      case 'delete':
        _showDeleteGoalDialog(goal);
        break;
    }
  }

  void _showEditGoalBottomSheet(goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddGoalBottomSheet(existingGoal: goal),
    );
  }

  void _showDeleteGoalDialog(goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GoalsColors.backgroundCard,
        title: const Text(
          'Delete Goal',
          style: TextStyle(color: GoalsColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This action cannot be undone.',
          style: const TextStyle(color: GoalsColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalsProvider>().deleteGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM SHEET PARA AÑADIR/EDITAR OBJETIVOS
// ============================================================================

class AddGoalBottomSheet extends StatefulWidget {
  final dynamic existingGoal;

  const AddGoalBottomSheet({super.key, this.existingGoal});

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedType = 'consistency';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _goalTypes = [
    {
      'value': 'consistency',
      'label': 'Consistency',
      'description': 'Track daily habits and routines',
      'icon': Icons.timeline,
      'color': GoalsColors.chartGradient1[0],
    },
    {
      'value': 'mood',
      'label': 'Mood Improvement',
      'description': 'Improve your average mood score',
      'icon': Icons.sentiment_satisfied,
      'color': GoalsColors.chartGradient2[1],
    },
    {
      'value': 'positiveMoments',
      'label': 'Positive Moments',
      'description': 'Increase positive daily moments',
      'icon': Icons.star,
      'color': GoalsColors.lightGradient[0],
    },
    {
      'value': 'stressReduction',
      'label': 'Stress Reduction',
      'description': 'Lower your stress levels',
      'icon': Icons.spa,
      'color': GoalsColors.chartGradient3[0],
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _populateExistingGoal();
    }
  }

  void _populateExistingGoal() {
    final goal = widget.existingGoal;
    _titleController.text = goal.title;
    _descriptionController.text = goal.description;
    _targetController.text = goal.targetValue.toString();
    _selectedType = goal.type.toString().split('.').last;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: GoalsColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GoalsColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.existingGoal != null ? 'Edit Goal' : 'Create New Goal',
                  style: const TextStyle(
                    color: GoalsColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Goal Title
                _buildTextField(
                  controller: _titleController,
                  label: 'Goal Title',
                  hint: 'e.g., Meditate daily for 30 days',
                  icon: Icons.title,
                ),
                const SizedBox(height: 16),

                // Goal Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe what you want to achieve',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Goal Type
                const Text(
                  'Goal Type',
                  style: TextStyle(
                    color: GoalsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                ..._goalTypes.map((type) => _buildGoalTypeOption(type)),

                const SizedBox(height: 20),

                // Target Value
                _buildTextField(
                  controller: _targetController,
                  label: 'Target Value',
                  hint: 'e.g., 30 (days), 8.0 (mood score)',
                  icon: Icons.track_changes,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: GoalsColors.textTertiary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: GoalsColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GoalsColors.chartGradient2[1],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : Text(
                          widget.existingGoal != null ? 'Update Goal' : 'Create Goal',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GoalsColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: GoalsColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: GoalsColors.textSecondary),
            prefixIcon: const Icon(Icons.title, color: GoalsColors.textSecondary),
            filled: true,
            fillColor: GoalsColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: GoalsColors.accentGradient[1]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalTypeOption(Map<String, dynamic> type) {
    final isSelected = _selectedType == type['value'];
    final color = type['color'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : GoalsColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : GoalsColors.textTertiary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type['icon'],
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['label'],
                    style: const TextStyle(
                      color: GoalsColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['description'],
                    style: const TextStyle(
                      color: GoalsColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _saveGoal() async {
    if (_titleController.text.trim().isEmpty ||
        _targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final goalsProvider = context.read<GoalsProvider>();
      final user = authProvider.currentUser;

      if (user == null) return;

      if (widget.existingGoal != null) {
        // Update existing goal
        await goalsProvider.updateGoal(
          widget.existingGoal.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetValue: double.parse(_targetController.text),
          type: _selectedType,
        );
      } else {
        // Create new goal
        await goalsProvider.createGoal(
          userId: user.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          targetValue: double.parse(_targetController.text),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingGoal != null
                  ? 'Goal updated successfully!'
                  : 'Goal created successfully!',
            ),
            backgroundColor: GoalsColors.chartGradient3[0],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}