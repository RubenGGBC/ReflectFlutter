// lib/presentation/screens/v2/home_screen_v2.dart - VERSIÓN CON INTEGRACIÓN DE GOALS
// ============================================================================
// PANTALLA DE INICIO HÍBRIDA CON INTEGRACIÓN COMPLETA DE GOALS Y MÉTRICAS
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/optimized_models.dart';
import '../../../data/models/goal_model.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// Widgets personalizados
import '../../widgets/profile_picture_widget.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _profilePictureController;
  late AnimationController _welcomeTextController;
  late AnimationController _cardsController;
  late AnimationController _pulseController;
  late AnimationController _goalsController; // ✅ NUEVO: Para goals

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _profilePictureAnimation;
  late Animation<Offset> _welcomeTextAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _goalsAnimation; // ✅ NUEVO: Para goals

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _profilePictureController.dispose();
    _welcomeTextController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    _goalsController.dispose(); // ✅ NUEVO
    super.dispose();
  }

  void _setupAnimations() {
    // Controladores existentes
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _profilePictureController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _welcomeTextController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    // ✅ NUEVO: Controller para goals
    _goalsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animaciones existentes
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
    _profilePictureAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _profilePictureController, curve: Curves.elasticOut),
    );
    _welcomeTextAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeTextController,
      curve: Curves.easeOutCubic,
    ));
    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOutBack),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // ✅ NUEVO: Animación para goals
    _goalsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _goalsController, curve: Curves.easeOutCubic),
    );

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _profilePictureController.forward();
    _welcomeTextController.forward();
    _cardsController.forward();
    _goalsController.forward(); // ✅ NUEVO
    _pulseController.repeat(reverse: true);
  }

  void _loadInitialData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      // Cargar datos existentes
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id);
      context.read<OptimizedMomentsProvider>().loadMoments(user.id);
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);

      // ✅ NUEVO: Cargar goals
      context.read<GoalsProvider>().loadUserGoals(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<OptimizedAuthProvider, OptimizedAnalyticsProvider,
        OptimizedMomentsProvider, GoalsProvider>( // ✅ NUEVO: GoalsProvider
      builder: (context, authProvider, analyticsProvider, momentsProvider, goalsProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isLoadingData = analyticsProvider.isLoading ||
            momentsProvider.isLoading ||
            goalsProvider.isLoading; // ✅ NUEVO

        return Scaffold(
          backgroundColor: ModernColors.darkPrimary,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ModernColors.primaryGradient,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header moderno
                    _buildModernHeader(user),
                    const SizedBox(height: 32),

                    // Mensaje de bienvenida personalizado
                    _buildWelcomeMessage(user),
                    const SizedBox(height: 24),

                    // Contenido principal
                    if (isLoadingData) ...[
                      _buildLoadingContent(),
                    ] else ...[
                      // ✅ NUEVO: Resumen de goals en la parte superior
                      _buildGoalsOverviewSection(goalsProvider),
                      const SizedBox(height: 24),

                      // Métricas principales híbridas (existente)
                      _buildHybridMetricsCards(analyticsProvider, momentsProvider),
                      const SizedBox(height: 24),

                      // ✅ NUEVO: Chart de progreso de goals
                      _buildGoalsProgressChart(goalsProvider),
                      const SizedBox(height: 24),

                      // Progreso semanal con gráfico (existente)
                      _buildWeeklyProgressChart(analyticsProvider),
                      const SizedBox(height: 24),

                      // Tracker de humor (existente)
                      _buildMoodTracker(analyticsProvider),
                      const SizedBox(height: 24),

                      // ✅ NUEVO: Goals activos destacados
                      _buildActiveGoalsSection(goalsProvider),
                      const SizedBox(height: 24),

                      // Tareas de hoy (existente)
                      _buildTodayTasks(momentsProvider),
                      const SizedBox(height: 24),

                      // Recomendaciones personalizadas (existente)
                      _buildPersonalizedRecommendations(analyticsProvider),
                      const SizedBox(height: 24),
                    ],

                    // Programas destacados (existente)
                    _buildFeaturedPrograms(),
                    const SizedBox(height: 100), // Espacio para el bottom nav
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // ✅ NUEVOS MÉTODOS PARA GOALS
  // ============================================================================

  Widget _buildGoalsOverviewSection(GoalsProvider goalsProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _goalsAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🎯 Your Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/goals'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGoalMetricCard(
                      'Active',
                      goalsProvider.activeGoals.length.toString(),
                      Icons.trending_up,
                      const Color(0xFF4ECDC4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoalMetricCard(
                      'Progress',
                      '${(goalsProvider.averageProgress * 100).round()}%',
                      Icons.track_changes,
                      const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoalMetricCard(
                      'Completed',
                      goalsProvider.completedGoals.length.toString(),
                      Icons.check_circle,
                      const Color(0xFF45B7D1),
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

  Widget _buildGoalMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgressChart(GoalsProvider goalsProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goals Progress Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (goalsProvider.activeGoals.isEmpty) ...[
            _buildEmptyGoalsState(),
          ] else ...[
            _buildGoalsChart(goalsProvider.activeGoals),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsChart(List<GoalModel> goals) {
    return Column(
      children: goals.take(4).map((goal) => _buildGoalProgressBar(goal)).toList(),
    );
  }

  Widget _buildGoalProgressBar(GoalModel goal) {
    final progress = goal.progress;
    final color = _getGoalTypeColor(goal.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoalsSection(GoalsProvider goalsProvider) {
    final activeGoals = goalsProvider.activeGoals;

    if (activeGoals.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.flag_outlined,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No active goals yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal to start tracking progress',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/goals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Create Goal'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activeGoals.length,
              itemBuilder: (context, index) {
                final goal = activeGoals[index];
                return _buildActiveGoalCard(goal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoalCard(GoalModel goal) {
    final color = _getGoalTypeColor(goal.type);
    final icon = _getGoalTypeIcon(goal.type);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                '${(goal.progress * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            goal.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalsState() {
    return Column(
      children: [
        Icon(
          Icons.flag_outlined,
          color: Colors.white.withOpacity(0.5),
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          'No goals to track yet',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/goals'),
          child: const Text(
            'Create your first goal',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // ✅ MÉTODOS DE UTILIDAD PARA GOALS
  // ============================================================================

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return const Color(0xFF4ECDC4);
      case GoalType.mood:
        return const Color(0xFFFFD700);
      case GoalType.positiveMoments:
        return const Color(0xFF45B7D1);
      case GoalType.stressReduction:
        return const Color(0xFF96CEB4);
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

  // ============================================================================
  // MÉTODOS EXISTENTES (MANTENER IGUAL)
  // ============================================================================

  Widget _buildModernHeader(OptimizedUserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Profile picture con animación
              ScaleTransition(
                scale: _profilePictureAnimation,
                child: ProfilePictureWidget(
                  user: user,
                  size: 50,
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ),
              const SizedBox(width: 16),
              // Info del usuario
              Expanded(
                child: SlideTransition(
                  position: _welcomeTextAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${user.name}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getGreetingMessage(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Notificaciones
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(OptimizedUserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '✨',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Take a moment to check in with yourself and track your progress.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHybridMetricsCards(OptimizedAnalyticsProvider analytics, OptimizedMomentsProvider moments) {
    return ScaleTransition(
      scale: _cardsAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Daily Streak',
                value: _getStreakValue(analytics),
                subtitle: 'days in a row',
                gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                icon: Icons.local_fire_department,
                hasChart: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: 'Mood Score',
                value: _getMoodValue(analytics),
                subtitle: 'today\'s average',
                gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                icon: Icons.sentiment_satisfied,
                hasChart: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    bool hasChart = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              if (hasChart) _buildDotsIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          if (hasChart) ...[
            const SizedBox(height: 8),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressChart(OptimizedAnalyticsProvider analytics) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = analytics.analytics['streak_data'] as Map<String, dynamic>?;
    final moodTrends = analytics.analytics['mood_trends'] as List<dynamic>? ?? [];

    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    final avgMood = basicStats?['avg_mood'] as double? ?? 0.0;
    final totalEntries = basicStats?['total_entries'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressMetric(currentStreak.toString(), 'Day Streak'),
              ),
              Expanded(
                child: _buildProgressMetric(avgMood.toStringAsFixed(1), 'Avg Mood'),
              ),
              Expanded(
                child: _buildProgressMetric(totalEntries.toString(), 'Entries'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMoodChart(moodTrends),
        ],
      ),
    );
  }

  Widget _buildMoodChart(List<dynamic> moodTrends) {
    if (moodTrends.isEmpty) {
      return _buildSimpleChart();
    }

    final last7Days = moodTrends.take(7).toList();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final dayData = index < last7Days.length ? last7Days[index] : null;
          final moodScore = (dayData?['mood_score'] as num?)?.toDouble() ?? 0.0;
          final normalizedHeight = moodScore / 10.0;

          return Expanded(
            child: _buildChartBar(
              normalizedHeight.clamp(0.1, 1.0),
              days[index],
              isHighlighted: moodScore > 7.0,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSimpleChart() {
    return Container(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildChartBar(0.4, 'Mon')),
          Expanded(child: _buildChartBar(0.6, 'Tue')),
          Expanded(child: _buildChartBar(0.8, 'Wed')),
          Expanded(child: _buildChartBar(0.9, 'Thu', isHighlighted: true)),
          Expanded(child: _buildChartBar(1.0, 'Fri', isHighlighted: true)),
          Expanded(child: _buildChartBar(0.3, 'Sat')),
          Expanded(child: _buildChartBar(0.7, 'Sun')),
        ],
      ),
    );
  }

  Widget _buildChartBar(double height, String day, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 8,
            height: 60 * height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isHighlighted
                    ? [const Color(0xFF4ECDC4), const Color(0xFF44A08D)]
                    : [const Color(0xFFFFD700), const Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMoodTracker(OptimizedAnalyticsProvider analytics) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final moodTrends = analytics.analytics['mood_trends'] as List<dynamic>? ?? [];
    final avgMood = basicStats?['avg_mood'] as double? ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mood Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${avgMood.toStringAsFixed(1)}/10',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodIcon('😢', 'Very Bad', avgMood >= 1 && avgMood < 3),
              _buildMoodIcon('😔', 'Bad', avgMood >= 3 && avgMood < 5),
              _buildMoodIcon('😐', 'Neutral', avgMood >= 5 && avgMood < 7),
              _buildMoodIcon('🙂', 'Good', avgMood >= 7 && avgMood < 9),
              _buildMoodIcon('😊', 'Great', avgMood >= 9),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIcon(String emoji, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFFD700).withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTasks(OptimizedMomentsProvider moments) {
    final todayCount = moments.todayCount;
    final totalCount = moments.totalCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.today,
                color: Color(0xFF4ECDC4),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$todayCount moments logged today',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$totalCount total moments recorded',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todayCount > 0 ? 'Active' : 'Start Today',
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations(OptimizedAnalyticsProvider analytics) {
    final recommendations = analytics.getTopRecommendations();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for You',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.take(3).map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  rec['emoji'] ?? '💡',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFeaturedPrograms() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Programs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildProgramCard(
                  'Mindfulness',
                  'Daily meditation practice',
                  Icons.self_improvement,
                  const Color(0xFF667eea),
                ),
                _buildProgramCard(
                  'Gratitude',
                  'Practice thankfulness',
                  Icons.favorite,
                  const Color(0xFF11998e),
                ),
                _buildProgramCard(
                  'Sleep Better',
                  'Improve your rest',
                  Icons.bedtime,
                  const Color(0xFF764ba2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(String title, String description, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! ☀️';
    if (hour < 18) return 'Good afternoon! 🌤️';
    return 'Good evening! 🌙';
  }

  String _getStreakValue(OptimizedAnalyticsProvider analytics) {
    final streakData = analytics.analytics['streak_data'] as Map<String, dynamic>?;
    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    return currentStreak.toString();
  }

  String _getMoodValue(OptimizedAnalyticsProvider analytics) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final avgMood = basicStats?['avg_mood'] as double? ?? 0.0;
    return avgMood.toStringAsFixed(1);
  }
}