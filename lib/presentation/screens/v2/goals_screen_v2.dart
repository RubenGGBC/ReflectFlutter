// lib/presentation/screens/v2/goals_screen_v2.dart
// ============================================================================
// GOALS SCREEN V2 - WITH TIMER FUNCTIONALITY AND APP THEME INTEGRATION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// App Theme
import '../../../core/themes/app_theme.dart';

// Providers
import '../../providers/optimized_providers.dart';

// Models
import '../../../data/models/goal_model.dart';

class GoalsScreenV2 extends StatefulWidget {
  const GoalsScreenV2({super.key});

  @override
  State<GoalsScreenV2> createState() => _GoalsScreenV2State();
}

class _GoalsScreenV2State extends State<GoalsScreenV2>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Timer functionality
  Timer? _activeTimer;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;
  GoalModel? _activeTimerGoal;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadGoals();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _activeTimer?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
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
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();

    return Scaffold(
      backgroundColor: appColors?.primaryBg ?? theme.colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(appColors, theme),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadGoals(),
                  backgroundColor: appColors?.surface ?? theme.colorScheme.surface,
                  color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGoalsOverview(appColors, theme),
                        const SizedBox(height: 20),
                        _buildActiveTimerSection(appColors, theme),
                        const SizedBox(height: 20),
                        _buildGoalsList(appColors, theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(appColors, theme),
        backgroundColor: appColors?.accentPrimary ?? theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text(
          'Nueva Meta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: appColors?.gradientHeader ?? [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Metas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Alcanza tus objetivos con constancia',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsOverview(AppColors? appColors, ThemeData theme) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final activeGoals = goalsProvider.activeGoals;
        final completedGoals = goalsProvider.completedGoals;
        final totalProgress = goalsProvider.averageProgress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    'Activas',
                    activeGoals.length.toString(),
                    Icons.trending_up,
                    appColors?.accentPrimary ?? Colors.blue,
                    appColors,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewCard(
                    'Completadas',
                    completedGoals.length.toString(),
                    Icons.check_circle,
                    appColors?.positiveMain ?? Colors.green,
                    appColors,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressCard(totalProgress, appColors, theme),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors?.borderColor ?? theme.colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (appColors?.shadowColor ?? theme.colorScheme.shadow).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors?.borderColor ?? theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progreso General',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              appColors?.accentPrimary ?? theme.colorScheme.primary,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Text(
            progress > 0.8
                ? "¡Estás cumpliendo tus metas! 🔥"
                : progress > 0.5
                ? "Excelente progreso, sigue así! 💪"
                : "Cada paso cuenta. ¡Puedes hacerlo! 🌱",
            style: theme.textTheme.bodySmall?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimerSection(AppColors? appColors, ThemeData theme) {
    if (_activeTimerGoal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: appColors?.gradientButton ?? [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _activeTimerGoal!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  _formatTime(_timerSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: appColors?.accentPrimary ?? theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                      label: Text(_isTimerRunning ? 'Pausar' : 'Iniciar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _stopTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.stop),
                      label: const Text('Detener'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(AppColors? appColors, ThemeData theme) {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        if (goalsProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                appColors?.accentPrimary ?? theme.colorScheme.primary,
              ),
            ),
          );
        }

        final goals = goalsProvider.goals;

        if (goals.isEmpty) {
          return _buildEmptyState(appColors, theme);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Metas',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...goals.map((goal) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildGoalCard(goal, appColors, theme),
            )),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(GoalModel goal, AppColors? appColors, ThemeData theme) {
    final color = _getGoalTypeColor(goal.type);
    final hasTimer = _hasTimerFunctionality(goal.type);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goal.isCompleted
              ? appColors?.positiveMain ?? Colors.green
              : appColors?.borderColor ?? theme.colorScheme.outline,
          width: goal.isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (appColors?.shadowColor ?? theme.colorScheme.shadow).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasTimer && !goal.isCompleted)
                IconButton(
                  onPressed: () => _activateTimer(goal),
                  icon: Icon(
                    Icons.timer,
                    color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  ),
                ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                ),
                color: appColors?.surface ?? theme.colorScheme.surface,
                onSelected: (value) => _handleGoalAction(goal, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: appColors?.textSecondary),
                        const SizedBox(width: 8),
                        Text('Editar', style: TextStyle(color: appColors?.textPrimary)),
                      ],
                    ),
                  ),
                  if (!goal.isCompleted) ...[
                    PopupMenuItem(
                      value: 'progress',
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, color: appColors?.textSecondary),
                          const SizedBox(width: 8),
                          Text('Actualizar Progreso', style: TextStyle(color: appColors?.textPrimary)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: appColors?.positiveMain),
                          const SizedBox(width: 8),
                          Text('Completar', style: TextStyle(color: appColors?.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: appColors?.negativeMain),
                        const SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: appColors?.negativeMain)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
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
                  '${goal.progressPercentage}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
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
                color: (appColors?.positiveMain ?? Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (appColors?.positiveMain ?? Colors.green).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration,
                    color: appColors?.positiveMain ?? Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¡Meta completada! ¡Excelente trabajo! 🎉',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: appColors?.positiveMain ?? Colors.green,
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

  Widget _buildEmptyState(AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appColors?.borderColor ?? theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes metas aún',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera meta y comienza tu journey de crecimiento personal.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(appColors, theme),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors?.accentPrimary ?? theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Crear Primera Meta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Timer functionality
  void _activateTimer(GoalModel goal) {
    setState(() {
      _activeTimerGoal = goal;
      _timerSeconds = 0;
      _isTimerRunning = false;
    });
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
    });
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isTimerRunning = false;
    });
    _activeTimer?.cancel();
  }

  void _stopTimer() {
    _activeTimer?.cancel();
    if (_timerSeconds > 0 && _activeTimerGoal != null) {
      _updateGoalProgress(_activeTimerGoal!, _timerSeconds / 60.0); // Convert to minutes
    }
    setState(() {
      _activeTimerGoal = null;
      _timerSeconds = 0;
      _isTimerRunning = false;
    });
  }

  void _updateGoalProgress(GoalModel goal, double additionalProgress) {
    final goalsProvider = context.read<GoalsProvider>();
    final newProgress = (goal.currentValue + additionalProgress).clamp(0.0, goal.targetValue);
    goalsProvider.updateGoalProgress(goal.id!, newProgress);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Goal type helpers
  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return Colors.blue;
      case GoalType.mood:
        return Colors.orange;
      case GoalType.positiveMoments:
        return Colors.purple;
      case GoalType.stressReduction:
        return Colors.green;
    }
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return Icons.timeline;
      case GoalType.mood:
        return Icons.sentiment_satisfied;
      case GoalType.positiveMoments:
        return Icons.star;
      case GoalType.stressReduction:
        return Icons.spa;
    }
  }

  bool _hasTimerFunctionality(GoalType type) {
    return type == GoalType.stressReduction; // Meditation, breathing exercises, etc.
  }

  // Goal actions
  void _handleGoalAction(GoalModel goal, String action) {
    final goalsProvider = context.read<GoalsProvider>();

    switch (action) {
      case 'edit':
        _showEditGoalDialog(goal);
        break;
      case 'progress':
        _showUpdateProgressDialog(goal);
        break;
      case 'complete':
        goalsProvider.completeGoal(goal.id!);
        break;
      case 'delete':
        _showDeleteGoalDialog(goal);
        break;
    }
  }

  void _showAddGoalDialog(AppColors? appColors, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => _GoalDialog(
        appColors: appColors,
        theme: theme,
      ),
    );
  }

  void _showEditGoalDialog(GoalModel goal) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    
    showDialog(
      context: context,
      builder: (context) => _GoalDialog(
        appColors: appColors,
        theme: theme,
        existingGoal: goal,
      ),
    );
  }

  void _showUpdateProgressDialog(GoalModel goal) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final progressController = TextEditingController(text: goal.currentValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors?.surface ?? theme.colorScheme.surface,
        title: Text(
          'Actualizar Progreso',
          style: TextStyle(color: appColors?.textPrimary ?? theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: progressController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: appColors?.textPrimary ?? theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Progreso actual',
                suffixText: goal.suggestedUnit,
                labelStyle: TextStyle(color: appColors?.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final progress = double.tryParse(progressController.text);
              if (progress != null) {
                context.read<GoalsProvider>().updateGoalProgress(goal.id!, progress);
                Navigator.pop(context);
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGoalDialog(GoalModel goal) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors?.surface ?? theme.colorScheme.surface,
        title: Text(
          'Eliminar Meta',
          style: TextStyle(color: appColors?.textPrimary ?? theme.colorScheme.onSurface),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${goal.title}"? Esta acción no se puede deshacer.',
          style: TextStyle(color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalsProvider>().deleteGoal(goal.id!);
              Navigator.pop(context);
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: appColors?.negativeMain ?? Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog for adding/editing goals
class _GoalDialog extends StatefulWidget {
  final AppColors? appColors;
  final ThemeData theme;
  final GoalModel? existingGoal;

  const _GoalDialog({
    required this.appColors,
    required this.theme,
    this.existingGoal,
  });

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  GoalType _selectedType = GoalType.consistency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _titleController.text = widget.existingGoal!.title;
      _descriptionController.text = widget.existingGoal!.description;
      _targetController.text = widget.existingGoal!.targetValue.toString();
      _selectedType = widget.existingGoal!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.appColors?.surface ?? widget.theme.colorScheme.surface,
      title: Text(
        widget.existingGoal != null ? 'Editar Meta' : 'Nueva Meta',
        style: TextStyle(color: widget.appColors?.textPrimary ?? widget.theme.colorScheme.onSurface),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: widget.appColors?.textPrimary ?? widget.theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(color: widget.appColors?.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: TextStyle(color: widget.appColors?.textPrimary ?? widget.theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: widget.appColors?.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GoalType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipo de Meta',
                labelStyle: TextStyle(color: widget.appColors?.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: GoalType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.name,
                    style: TextStyle(color: widget.appColors?.textPrimary ?? widget.theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: widget.appColors?.textPrimary ?? widget.theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Valor Objetivo',
                labelStyle: TextStyle(color: widget.appColors?.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveGoal,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingGoal != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  void _saveGoal() async {
    if (_titleController.text.trim().isEmpty || _targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
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
        await goalsProvider.updateGoal(
          widget.existingGoal!.id!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          targetValue: double.parse(_targetController.text),
          type: _selectedType.name,
        );
      } else {
        await goalsProvider.createGoal(
          userId: user.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType.name,
          targetValue: double.parse(_targetController.text),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}