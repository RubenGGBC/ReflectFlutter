// lib/presentation/screens/v2/home_screen_v2.dart - VERSIÓN FINAL OPTIMIZADA
// ============================================================================
// PANTALLA DE INICIO HÍBRIDA INSPIRADA EN LAS IMÁGENES CON TODAS LAS MÉTRICAS
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

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

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _profilePictureAnimation;
  late Animation<Offset> _welcomeTextAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _pulseAnimation;

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
    _profilePictureController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _welcomeTextController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _profilePictureAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _profilePictureController,
        curve: Curves.elasticOut,
      ),
    );

    _welcomeTextAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeTextController,
      curve: Curves.easeOutBack,
    ));

    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardsController,
        curve: Curves.easeOutBack,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Secuencia de animaciones
    _fadeController.forward();
    _pulseController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
        _profilePictureController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _welcomeTextController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _cardsController.forward();
      }
    });
  }

  void _loadInitialData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      try {
        final momentsProvider = context.read<OptimizedMomentsProvider>();
        final analyticsProvider = context.read<OptimizedAnalyticsProvider>();

        // Cargar datos completos
        momentsProvider.loadTodayMoments(user.id);
        analyticsProvider.loadCompleteAnalytics(user.id, days: 30);
      } catch (e) {
        debugPrint('Error loading initial data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final momentsProvider = context.watch<OptimizedMomentsProvider>();
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Usuario no encontrado.'),
        ),
      );
    }

    final isLoadingData = momentsProvider.isLoading || analyticsProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E), // Azul oscuro
              Color(0xFF16213E), // Azul medio
              Color(0xFF0F3460), // Azul más claro
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                _loadInitialData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header moderno (inspirado en imagen 3)
                    _buildModernHeader(user),
                    const SizedBox(height: 32),

                    // Mensaje de bienvenida personalizado (inspirado en imagen 2)
                    _buildWelcomeMessage(user),
                    const SizedBox(height: 24),

                    // Contenido principal
                    if (isLoadingData) ...[
                      _buildLoadingContent(),
                    ] else ...[
                      // Métricas principales híbridas (inspirado en imagen 1)
                      _buildHybridMetricsCards(analyticsProvider, momentsProvider),
                      const SizedBox(height: 24),

                      // Progreso semanal con gráfico (inspirado en imagen 3)
                      _buildWeeklyProgressChart(analyticsProvider),
                      const SizedBox(height: 24),

                      // Tracker de humor (inspirado en imagen 3)
                      _buildMoodTracker(analyticsProvider),
                      const SizedBox(height: 24),

                      // Tareas de hoy (inspirado en imagen 3)
                      _buildTodayTasks(momentsProvider),
                      const SizedBox(height: 24),

                      // Recomendaciones personalizadas (inspirado en imagen 2)
                      _buildPersonalizedRecommendations(analyticsProvider),
                      const SizedBox(height: 24),
                    ],

                    // Programas destacados (inspirado en imagen 2)
                    _buildFeaturedPrograms(),
                    const SizedBox(height: 100), // Espacio para el bottom nav
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentsStatsRow(OptimizedMomentsProvider moments) {
    final todayCount = moments.todayCount;
    final totalCount = moments.totalCount;
    final positiveCount = moments.positiveCount;
    final negativeCount = moments.negativeCount;

    // Calcular ratio de momentos positivos
    final positiveRatio = totalCount > 0 ? (positiveCount / totalCount) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
                todayCount.toString(),
                'Today',
                const Color(0xFFFFD700)
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _buildMiniStat(
                '${(positiveRatio * 100).round()}%',
                'Positive',
                const Color(0xFF4ECDC4)
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _buildMiniStat(
                totalCount.toString(),
                'Total',
                const Color(0xFF45B7D1)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildModernHeader(OptimizedUserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: Row(
        children: [
          // Profile picture con animación
          ScaleTransition(
            scale: _profilePictureAnimation,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: _buildAvatarContent(user),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Usuario info (como imagen 3)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Ícono de configuración
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFFFFD700),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(OptimizedUserModel user) {
    return SlideTransition(
      position: _welcomeTextAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${user.name}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Based on your data, we've curated some recommendations for you.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHybridMetricsCards(OptimizedAnalyticsProvider analytics, OptimizedMomentsProvider moments) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final streakData = analytics.analytics['streak_data'] as Map<String, dynamic>?;

    // Usar los métodos reales disponibles
    final todayMomentsCount = moments.todayCount;
    final totalMomentsCount = moments.totalCount;
    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    final avgMood = basicStats?['avg_mood'] as double? ?? 0.0;
    final wellbeingScore = (avgMood * 10).round();

    return FadeTransition(
      opacity: _cardsAnimation,
      child: Row(
        children: [
          // Card principal (inspirado en imagen 1 - Today's)
          Expanded(
            child: _buildMainMetricCard(
              title: "Today's",
              value: todayMomentsCount.toString().padLeft(5, '0'),
              subtitle: "${DateTime.now().hour} am ${(avgMood * 1.5).toStringAsFixed(1)}cM",
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              hasChart: true,
              hasIndicator: true,
            ),
          ),
          const SizedBox(width: 16),
          // Card secundario (inspirado en imagen 1 - Daily Insights)
          Expanded(
            child: _buildMainMetricCard(
              title: "Wellbeing",
              value: "$wellbeingScore%",
              subtitle: "${DateTime.now().hour} am, ${currentStreak}st",
              gradient: const LinearGradient(
                colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
              ),
              hasPlayButton: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required LinearGradient gradient,
    bool hasChart = false,
    bool hasPlayButton = false,
    bool hasIndicator = false,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              if (hasChart) const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              if (hasChart) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (hasIndicator) _buildDotsIndicator(),
              if (hasPlayButton)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const Spacer(),
          // Value
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
            // Mini gráfico simplificado
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

    return FadeTransition(
      opacity: _cardsAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'View Details',
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Gráfico mejorado con datos reales
            _buildAdvancedChart(moodTrends),
            const SizedBox(height: 24),
            // Métricas de progreso con datos reales
            Row(
              children: [
                Expanded(
                  child: _buildProgressMetric(currentStreak.toString(), 'Days Streak'),
                ),
                Expanded(
                  child: _buildProgressMetric('${avgMood.toStringAsFixed(1)}', 'Avg. Mood'),
                ),
                Expanded(
                  child: _buildProgressMetric(totalEntries.toString(), 'Total Entries'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedChart(List<dynamic> moodTrends) {
    if (moodTrends.isEmpty) {
      return _buildSimpleChart(); // Fallback al gráfico simple
    }

    // Tomar los últimos 7 días de datos
    final last7Days = moodTrends.take(7).toList();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final dayData = index < last7Days.length ? last7Days[index] : null;
          final moodScore = (dayData?['mood_score'] as num?)?.toDouble() ?? 0.0;          final normalizedHeight = moodScore / 10.0; // Normalizar de 0-10 a 0-1

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
    final avgMood = basicStats?['avg_mood'] as double? ?? 7.5;

    String moodMessage;
    Color moodColor;
    if (avgMood >= 8.0) {
      moodMessage = "Your mood has been excellent this week!";
      moodColor = const Color(0xFF4ECDC4);
    } else if (avgMood >= 6.0) {
      moodMessage = "Your mood has been generally positive this week!";
      moodColor = const Color(0xFFFFD700);
    } else if (avgMood >= 4.0) {
      moodMessage = "Your mood has been stable this week.";
      moodColor = const Color(0xFFFFA500);
    } else {
      moodMessage = "Consider some self-care practices this week.";
      moodColor = const Color(0xFFFF6B6B);
    }

    return FadeTransition(
      opacity: _cardsAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con promedio de mood
            Row(
              children: [
                const Text(
                  'Mood Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: moodColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: moodColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        avgMood.toStringAsFixed(1),
                        style: TextStyle(
                          color: moodColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Gráfico de mood con línea y puntos
            _buildMoodChart(moodTrends),

            const SizedBox(height: 16),

            // Días de la semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final day = entry.value;
                final isToday = index == DateTime.now().weekday - 1;

                return Text(
                  day,
                  style: TextStyle(
                    color: isToday
                        ? const Color(0xFFFFD700)
                        : Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              })
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Mensaje de mood con icono
            Row(
              children: [
                Icon(
                  _getMoodIcon(avgMood),
                  color: moodColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    moodMessage,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Leyenda de colores
            _buildMoodLegend(),
          ],
        ),
      ),
    );
  }

  IconData _getMoodIcon(double mood) {
    if (mood >= 8.0) return Icons.sentiment_very_satisfied;
    if (mood >= 6.0) return Icons.sentiment_satisfied;
    if (mood >= 4.0) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  Widget _buildMoodLegend() {
    return Row(
      children: [
        _buildLegendItem('Excellent', const Color(0xFF4ECDC4)),
        const SizedBox(width: 16),
        _buildLegendItem('Good', const Color(0xFFFFD700)),
        const SizedBox(width: 16),
        _buildLegendItem('Fair', const Color(0xFFFFA500)),
        const SizedBox(width: 16),
        _buildLegendItem('Low', const Color(0xFFFF6B6B)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodChart(List<dynamic> moodTrends) {
    // Preparar datos para los últimos 7 días
    final List<double> moodData = [];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (moodTrends.isNotEmpty) {
      // Usar datos reales (tomar últimos 7 días)
      final last7Days = moodTrends.take(7).toList().reversed.toList();
      for (int i = 0; i < 7; i++) {
        if (i < last7Days.length) {
          final dayData = last7Days[i];
          final moodScore = (dayData?['mood_score'] as num?)?.toDouble() ?? 0.5;          moodData.add(moodScore);
        } else {
          // Rellenar con datos promedio si no hay suficientes datos
          moodData.add(5.0 + (math.Random().nextDouble() * 3.0));
        }
      }
    } else {
      // Datos de ejemplo si no hay datos reales
      moodData.addAll([4.5, 6.2, 7.8, 8.5, 6.1, 5.9, 7.3]);
    }

    return Container(
      height: 120,
      child: Stack(
        children: [
          // Gráfico principal
          CustomPaint(
            size: const Size(double.infinity, 120),
            painter: MoodChartPainter(moodData),
          ),
          // Indicadores de max/min mood
          Positioned(
            top: 8,
            right: 8,
            child: _buildMoodIndicators(moodData),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicators(List<double> moodData) {
    if (moodData.isEmpty) return const SizedBox.shrink();

    final maxMood = moodData.reduce(math.max);
    final minMood = moodData.reduce(math.min);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              color: const Color(0xFF4ECDC4),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              maxMood.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_down,
              color: const Color(0xFFFF6B6B),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              minMood.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayTasks(OptimizedMomentsProvider moments) {
    // Usar los getters reales disponibles
    final todayMomentsCount = moments.todayCount;
    final positiveMomentsCount = moments.positiveCount;
    final totalMomentsCount = moments.totalCount;

    // Generar tareas basadas en momentos del día
    final tasks = <Map<String, dynamic>>[
      {
        'icon': Icons.self_improvement,
        'title': 'Morning meditation',
        'duration': '10 min',
        'color': const Color(0xFFFFD700),
        'completed': todayMomentsCount > 2,
      },
      {
        'icon': Icons.book,
        'title': 'Gratitude journal',
        'duration': '15 min',
        'color': const Color(0xFF4ECDC4),
        'completed': todayMomentsCount > 5,
      },
      {
        'icon': Icons.directions_walk,
        'title': 'Mindful walk',
        'duration': '20 min',
        'color': const Color(0xFF45B7D1),
        'completed': positiveMomentsCount > 3,
      },
    ];

    return FadeTransition(
      opacity: _cardsAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Today's tasks",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$todayMomentsCount moments today',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tasks.map((task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTaskCard(
              icon: task['icon'] as IconData,
              title: task['title'] as String,
              duration: task['duration'] as String,
              color: task['color'] as Color,
              completed: task['completed'] as bool,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required String duration,
    required Color color,
    bool completed = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed
              ? color.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(completed ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              completed ? Icons.check : icon,
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
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            completed ? Icons.check_circle : Icons.arrow_forward_ios,
            color: completed ? color : Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations(OptimizedAnalyticsProvider analytics) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final avgStress = basicStats?['avg_stress'] as double? ?? 5.0;
    final avgEnergy = basicStats?['avg_energy'] as double? ?? 5.0;

    // Recomendaciones basadas en métricas reales
    final recommendations = <Map<String, dynamic>>[];

    if (avgStress > 6.0) {
      recommendations.add({
        'title': 'Stress Relief',
        'subtitle': 'Your stress levels are elevated. Try these techniques.',
        'color': const Color(0xFFE8D5C4),
        'icon': Icons.spa,
      });
    }

    if (avgEnergy < 5.0) {
      recommendations.add({
        'title': 'Energy Boost',
        'subtitle': 'Quick exercises to boost your energy levels.',
        'color': const Color(0xFFF4E4BC),
        'icon': Icons.flash_on,
      });
    }

    // Recomendación por defecto
    recommendations.add({
      'title': 'Mindful Moments',
      'subtitle': 'Quick exercises for daily mindfulness.',
      'color': const Color(0xFFF4E4BC),
      'icon': Icons.self_improvement,
    });

    return FadeTransition(
      opacity: _cardsAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for you',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                return _buildRecommendationCard(
                  title: rec['title'] as String,
                  subtitle: rec['subtitle'] as String,
                  color: rec['color'] as Color,
                  icon: rec['icon'] as IconData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B4513),
              size: 28,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFF2D2D2D).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedPrograms() {
    return FadeTransition(
      opacity: _cardsAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Programs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProgramCard(
            title: 'Journey to Inner Peace',
            subtitle: 'A comprehensive program for emotional well-being.',
            isNew: true,
            color: const Color(0xFFF4E4BC),
          ),
          const SizedBox(height: 16),
          _buildProgramCard(
            title: 'Daily Gratitude Practice',
            subtitle: 'Cultivate a positive mindset with daily gratitude exercises.',
            color: const Color(0xFFE8D5C4),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard({
    required String title,
    required String subtitle,
    required Color color,
    bool isNew = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isNew) const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.spa,
              color: Color(0xFF8B4513),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: List.generate(5, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildAvatarContent(OptimizedUserModel user) {
    if (user.hasProfilePicture) {
      return Image.file(
        File(user.profilePicturePath!),
        fit: BoxFit.cover,
        width: 46,
        height: 46,
        errorBuilder: (context, error, stackTrace) {
          return _buildEmojiAvatar(user.avatarEmoji);
        },
      );
    } else {
      return _buildEmojiAvatar(user.avatarEmoji);
    }
  }

  Widget _buildEmojiAvatar(String emoji) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTER PARA EL MOOD CHART
// ============================================================================

class MoodChartPainter extends CustomPainter {
  final List<double> moodData;

  MoodChartPainter(this.moodData);

  @override
  void paint(Canvas canvas, Size size) {
    if (moodData.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = gradientPaint.shader;

    // Calcular posiciones de los puntos
    final points = <Offset>[];
    final double stepX = size.width / (moodData.length - 1);

    for (int i = 0; i < moodData.length; i++) {
      final double x = i * stepX;
      // Normalizar mood data (0-10) a altura del canvas
      final double normalizedMood = moodData[i] / 10.0;
      final double y = size.height - (normalizedMood * size.height * 0.8) - (size.height * 0.1);
      points.add(Offset(x, y));
    }

    // Dibujar área bajo la curva (relleno gradient)
    if (points.length > 1) {
      final areaPath = Path();
      areaPath.moveTo(points[0].dx, size.height);
      areaPath.lineTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        final currentPoint = points[i];
        final previousPoint = points[i - 1];
        final controlPointX = previousPoint.dx + (currentPoint.dx - previousPoint.dx) / 2;

        areaPath.quadraticBezierTo(
          controlPointX, previousPoint.dy,
          currentPoint.dx, currentPoint.dy,
        );
      }

      areaPath.lineTo(points.last.dx, size.height);
      areaPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.3),
            const Color(0xFF4ECDC4).withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, areaPaint);
    }

    // Dibujar línea principal
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        // Crear curva suave entre puntos
        final currentPoint = points[i];
        final previousPoint = points[i - 1];

        final controlPointX = previousPoint.dx + (currentPoint.dx - previousPoint.dx) / 2;

        path.quadraticBezierTo(
          controlPointX, previousPoint.dy,
          currentPoint.dx, currentPoint.dy,
        );
      }

      canvas.drawPath(path, paint);
    }

    // Dibujar líneas de referencia horizontales
    final referencePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Línea de referencia en el medio (mood 5)
    final midY = size.height - (0.5 * size.height * 0.8) - (size.height * 0.1);
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      referencePaint,
    );

    // Línea de referencia superior (mood 8)
    final highY = size.height - (0.8 * size.height * 0.8) - (size.height * 0.1);
    canvas.drawLine(
      Offset(0, highY),
      Offset(size.width, highY),
      referencePaint,
    );

    // Dibujar puntos
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final moodValue = moodData[i];

      // Color del punto basado en el valor del mood
      Color pointColor;
      if (moodValue >= 8.0) {
        pointColor = const Color(0xFF4ECDC4); // Excelente
      } else if (moodValue >= 6.0) {
        pointColor = const Color(0xFFFFD700); // Bueno
      } else if (moodValue >= 4.0) {
        pointColor = const Color(0xFFFFA500); // Regular
      } else {
        pointColor = const Color(0xFFFF6B6B); // Necesita atención
      }

      // Círculo exterior (sombra)
      pointPaint.color = Colors.black.withOpacity(0.3);
      canvas.drawCircle(point + const Offset(1, 1), 7, pointPaint);

      // Círculo principal
      pointPaint.color = pointColor;
      canvas.drawCircle(point, 6, pointPaint);

      // Círculo interior (brillo)
      pointPaint.color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(point, 3, pointPaint);

      // Punto central
      pointPaint.color = pointColor;
      canvas.drawCircle(point, 1.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}