// lib/presentation/screens/v2/home_screen_v2.dart
// ✅ HOME SCREEN CON ANÁLISIS AVANZADOS Y MÉTRICAS INTELIGENTES

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

// Providers
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/goal_model.dart';

class MontereyColors {
  // Colores base - Monterey Dark Theme
  static const Color primaryBackground = Color(0xFF0D0B1E);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentTeal = Color(0xFF06B6D4);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGreen = Color(0xFF10B981);

  // Superficies - Glass Morphism
  static const Color surfacePrimary = Color(0xFF1E1B2E);
  static const Color surfaceSecondary = Color(0xFF2A2640);
  static const Color surfaceTertiary = Color(0xFF363152);

  // Colores de texto
  static const Color labelPrimary = Color(0xFFFFFFFF);
  static const Color labelSecondary = Color(0xFFB4B4B8);
  static const Color labelTertiary = Color(0xFF8E8E93);

  // Gradientes
  static const List<Color> primaryGradient = [Color(0xFF7C3AED), Color(0xFFD946EF)];
  static const List<Color> blueGradient = [Color(0xFF3B82F6), Color(0xFF06B6D4)];
  static const List<Color> pinkGradient = [Color(0xFFEC4899), Color(0xFFF472B6)];
  static const List<Color> purpleGradient = [Color(0xFF8B5CF6), Color(0xFF6366F1)];
  static const List<Color> goldGradient = [Color(0xFFF59E0B), Color(0xFFEAB308)];
  static const List<Color> greenGradient = [Color(0xFF10B981), Color(0xFF34D399)];
  static const List<Color> redGradient = [Color(0xFFEF4444), Color(0xFFF87171)];
  static const List<Color> backgroundGradient = [Color(0xFF0D0B1E), Color(0xFF1A1625), Color(0xFF252035)];
}

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {

  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardsController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  late AnimationController _glowController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late AnimationController _analyticsController;

  // Animaciones
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _analyticsAnimation;

  // Staggered animations para cards
  late List<Animation<double>> _cardAnimations;
  late List<Animation<Offset>> _cardSlideAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
        _startStaggeredAnimations();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    _analyticsController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    // Controladores principales
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _analyticsController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Animaciones básicas
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _cardsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _analyticsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _analyticsController,
      curve: Curves.easeOutCubic,
    ));

    // Staggered animations para cards
    _setupStaggeredAnimations();

    // Iniciar animaciones infinitas
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _shimmerController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
    _particleController.repeat();
  }

  void _setupStaggeredAnimations() {
    _cardAnimations = List.generate(10, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardsController,
        curve: Interval(
          index * 0.08,
          0.5 + (index * 0.08),
          curve: Curves.elasticOut,
        ),
      ));
    });

    _cardSlideAnimations = List.generate(10, (index) {
      return Tween<Offset>(
        begin: Offset(0, 0.3 + (index * 0.05)),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardsController,
        curve: Interval(
          index * 0.08,
          0.5 + (index * 0.08),
          curve: Curves.easeOutCubic,
        ),
      ));
    });
  }

  void _startStaggeredAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _slideController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _cardsController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _analyticsController.forward();
      }
    });
  }

  void _loadInitialData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      // Cargar todos los datos necesarios
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<OptimizedMomentsProvider>().loadMoments(user.id);
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id);
      context.read<GoalsProvider>().loadUserGoals(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<OptimizedAuthProvider, OptimizedDailyEntriesProvider,
        OptimizedMomentsProvider, OptimizedAnalyticsProvider, GoalsProvider>(
      builder: (context, authProvider, entriesProvider, momentsProvider,
          analyticsProvider, goalsProvider, child) {

        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(
            child: Text('No hay usuario autenticado',
                style: TextStyle(color: Colors.white)),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: MontereyColors.backgroundGradient,
            ),
          ),
          child: Stack(
            children: [
              // Fondo animado con partículas
              _buildAnimatedBackground(),

              // Contenido principal
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header personalizado con efectos
                          _buildEnhancedPersonalizedHeader(user, 0),
                          const SizedBox(height: 24),

                          // Estado del día actual con glow
                          _buildEnhancedTodayStatusCard(entriesProvider, momentsProvider, 1),
                          const SizedBox(height: 20),

                          // 🆕 SECCIÓN DE ANÁLISIS INTELIGENTE
                          _buildIntelligentAnalyticsSection(analyticsProvider, entriesProvider, momentsProvider, 2),
                          const SizedBox(height: 20),

                          // Métricas principales con animaciones
                          _buildEnhancedMainMetricsSection(analyticsProvider, entriesProvider, 3),
                          const SizedBox(height: 20),

                          // 🆕 ANÁLISIS DE TENDENCIAS
                          _buildTrendsAnalysisSection(analyticsProvider, entriesProvider, 4),
                          const SizedBox(height: 20),

                          // Goals Progress con shimmer
                          _buildEnhancedGoalsProgressSection(goalsProvider, 5),
                          const SizedBox(height: 20),

                          // 🆕 ANÁLISIS DE CORRELACIONES
                          _buildCorrelationAnalysisSection(analyticsProvider, entriesProvider, 6),
                          const SizedBox(height: 20),

                          // Momentos con efectos de luz
                          _buildEnhancedTodayMomentsSection(momentsProvider, 7),
                          const SizedBox(height: 20),

                          // 🆕 ALERTAS Y PREDICCIONES INTELIGENTES
                          _buildSmartAlertsSection(analyticsProvider, entriesProvider, 8),
                          const SizedBox(height: 20),

                          // Insights con gradientes animados
                          _buildEnhancedInsightsSection(analyticsProvider, 9),
                          const SizedBox(height: 20),

                          // Quick actions con hover effects
                          _buildEnhancedQuickActionsSection(9),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🆕 SECCIÓN DE ANÁLISIS INTELIGENTE
  Widget _buildIntelligentAnalyticsSection(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider, OptimizedMomentsProvider momentsProvider, int index) {

    final analytics = analyticsProvider.analytics;
    final intelligentData = _calculateIntelligentMetrics(analytics, entriesProvider, momentsProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index], _analyticsAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.purpleGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology, color: MontereyColors.accentViolet),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Análisis Inteligente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.purpleGradient),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'IA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Grid de métricas inteligentes
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildIntelligentMetricCard(
                        '🧠',
                        'Salud Mental',
                        intelligentData['mentalHealthScore'],
                        _getMentalHealthColor(intelligentData['mentalHealthScore']),
                        'Basado en patrones',
                      ),
                      _buildIntelligentMetricCard(
                        '⚡',
                        'Productividad',
                        intelligentData['productivityScore'],
                        _getProductivityColor(intelligentData['productivityScore']),
                        'Análisis de energía',
                      ),
                      _buildIntelligentMetricCard(
                        '🎯',
                        'Equilibrio',
                        intelligentData['balanceScore'],
                        _getBalanceColor(intelligentData['balanceScore']),
                        'Vida-trabajo',
                      ),
                      _buildIntelligentMetricCard(
                        '📈',
                        'Tendencia',
                        intelligentData['trendDirection'],
                        _getTrendColor(intelligentData['trendDirection']),
                        'Últimos 7 días',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🆕 ANÁLISIS DE TENDENCIAS
  Widget _buildTrendsAnalysisSection(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider, int index) {

    final trendsData = _calculateTrends(analyticsProvider, entriesProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.goldGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.trending_up, color: MontereyColors.accentGold),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Análisis de Tendencias',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tendencias principales
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrendCard(
                          'Humor',
                          trendsData['moodTrend'],
                          trendsData['moodDirection'],
                          MontereyColors.blueGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTrendCard(
                          'Energía',
                          trendsData['energyTrend'],
                          trendsData['energyDirection'],
                          MontereyColors.greenGradient,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrendCard(
                          'Estrés',
                          trendsData['stressTrend'],
                          trendsData['stressDirection'],
                          MontereyColors.redGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTrendCard(
                          'Sueño',
                          trendsData['sleepTrend'],
                          trendsData['sleepDirection'],
                          MontereyColors.purpleGradient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🆕 ANÁLISIS DE CORRELACIONES
  Widget _buildCorrelationAnalysisSection(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider, int index) {

    final correlations = _calculateCorrelations(analyticsProvider, entriesProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.pinkGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.scatter_plot, color: MontereyColors.accentPink),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Correlaciones Inteligentes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Correlaciones más importantes
                  ...correlations.map((correlation) => _buildCorrelationItem(correlation)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🆕 ALERTAS Y PREDICCIONES INTELIGENTES
  Widget _buildSmartAlertsSection(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider, int index) {

    final alerts = _generateSmartAlerts(analyticsProvider, entriesProvider);

    if (alerts.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index], _pulseAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value * _pulseAnimation.value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.redGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          alerts.any((a) => a['priority'] == 'high') ? Icons.warning : Icons.info,
                          color: alerts.any((a) => a['priority'] == 'high') ? Colors.red : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Alertas Inteligentes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alertas
                  ...alerts.map((alert) => _buildSmartAlertItem(alert)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // MÉTODOS DE CÁLCULO AVANZADOS

  Map<String, dynamic> _calculateIntelligentMetrics(Map<String, dynamic> analytics,
      OptimizedDailyEntriesProvider entriesProvider, OptimizedMomentsProvider momentsProvider) {

    if (analytics.isEmpty || entriesProvider.entries.isEmpty) {
      return {
        'mentalHealthScore': 'N/A',
        'productivityScore': 'N/A',
        'balanceScore': 'N/A',
        'trendDirection': 'N/A',
      };
    }

    final basicStats = analytics['basic_stats'] as Map<String, dynamic>? ?? {};
    final entries = entriesProvider.entries;
    final recentEntries = entries.take(7).toList();

    // Salud Mental (combinación de humor, estrés, ansiedad)
    final avgMood = basicStats['avg_mood'] as double? ?? 0.0;
    final avgStress = basicStats['avg_stress'] as double? ?? 0.0;
    final mentalHealthScore = ((avgMood * 2 - avgStress) / 3).clamp(0.0, 10.0);

    // Productividad (energía + productividad laboral + enfoque)
    final avgEnergy = basicStats['avg_energy'] as double? ?? 0.0;
    final productivityScore = (avgEnergy * 1.2).clamp(0.0, 10.0);

    // Equilibrio (balance entre diferentes aspectos)
    final avgSocial = _calculateAverage(recentEntries, 'socialInteraction');
    final avgPhysical = _calculateAverage(recentEntries, 'physicalActivity');
    final balanceScore = ((avgSocial + avgPhysical + avgEnergy) / 3).clamp(0.0, 10.0);

    // Tendencia (comparación últimos 7 días vs anteriores)
    final trendDirection = _calculateTrendDirection(entries);

    return {
      'mentalHealthScore': mentalHealthScore.toStringAsFixed(1),
      'productivityScore': productivityScore.toStringAsFixed(1),
      'balanceScore': balanceScore.toStringAsFixed(1),
      'trendDirection': trendDirection,
    };
  }

  Map<String, dynamic> _calculateTrends(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider) {

    final entries = entriesProvider.entries;
    if (entries.length < 7) {
      return {
        'moodTrend': 'N/A',
        'energyTrend': 'N/A',
        'stressTrend': 'N/A',
        'sleepTrend': 'N/A',
        'moodDirection': 'stable',
        'energyDirection': 'stable',
        'stressDirection': 'stable',
        'sleepDirection': 'stable',
      };
    }

    final recent = entries.take(3).toList();
    final previous = entries.skip(3).take(4).toList();

    return {
      'moodTrend': _calculateTrendValue(recent, previous, 'moodScore'),
      'energyTrend': _calculateTrendValue(recent, previous, 'energyLevel'),
      'stressTrend': _calculateTrendValue(recent, previous, 'stressLevel'),
      'sleepTrend': _calculateTrendValue(recent, previous, 'sleepHours'),
      'moodDirection': _getTrendDirection(recent, previous, 'moodScore'),
      'energyDirection': _getTrendDirection(recent, previous, 'energyLevel'),
      'stressDirection': _getTrendDirection(recent, previous, 'stressLevel'),
      'sleepDirection': _getTrendDirection(recent, previous, 'sleepHours'),
    };
  }

  List<Map<String, dynamic>> _calculateCorrelations(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider) {

    final entries = entriesProvider.entries;
    if (entries.length < 10) return [];

    final correlations = <Map<String, dynamic>>[];

    // Correlación Sueño - Energía
    final sleepEnergyCorr = _calculateCorrelation(entries, 'sleepQuality', 'energyLevel');
    if (sleepEnergyCorr.abs() > 0.3) {
      correlations.add({
        'title': 'Sueño → Energía',
        'strength': sleepEnergyCorr,
        'description': sleepEnergyCorr > 0
            ? 'Mejor sueño mejora tu energía'
            : 'El sueño afecta negativamente tu energía',
        'icon': '😴',
      });
    }

    // Correlación Ejercicio - Humor
    final exerciseMoodCorr = _calculateCorrelation(entries, 'physicalActivity', 'moodScore');
    if (exerciseMoodCorr.abs() > 0.3) {
      correlations.add({
        'title': 'Ejercicio → Humor',
        'strength': exerciseMoodCorr,
        'description': exerciseMoodCorr > 0
            ? 'Más ejercicio mejora tu humor'
            : 'El ejercicio afecta tu humor negativamente',
        'icon': '🏃‍♀️',
      });
    }

    // Correlación Estrés - Productividad
    final stressProductivityCorr = _calculateCorrelation(entries, 'stressLevel', 'workProductivity');
    if (stressProductivityCorr.abs() > 0.3) {
      correlations.add({
        'title': 'Estrés → Productividad',
        'strength': stressProductivityCorr,
        'description': stressProductivityCorr < 0
            ? 'Más estrés reduce tu productividad'
            : 'El estrés aumenta tu productividad',
        'icon': '😰',
      });
    }

    return correlations.take(3).toList();
  }

  List<Map<String, dynamic>> _generateSmartAlerts(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider) {

    final alerts = <Map<String, dynamic>>[];
    final entries = entriesProvider.entries;
    final analytics = analyticsProvider.analytics;

    if (entries.isEmpty) return alerts;

    final recentEntries = entries.take(3).toList();

    // Alerta de estrés elevado
    final avgStress = _calculateAverage(recentEntries, 'stressLevel');
    if (avgStress > 7.0) {
      alerts.add({
        'type': 'stress',
        'priority': 'high',
        'title': 'Estrés Elevado Detectado',
        'description': 'Tus niveles de estrés han estado altos últimamente',
        'recommendation': 'Considera técnicas de relajación o meditación',
        'icon': '⚠️',
        'color': MontereyColors.redGradient,
      });
    }

    // Alerta de baja energía
    final avgEnergy = _calculateAverage(recentEntries, 'energyLevel');
    if (avgEnergy < 4.0) {
      alerts.add({
        'type': 'energy',
        'priority': 'medium',
        'title': 'Energía Baja Persistente',
        'description': 'Tu energía ha estado baja los últimos días',
        'recommendation': 'Revisa tus hábitos de sueño y alimentación',
        'icon': '🔋',
        'color': MontereyColors.goldGradient,
      });
    }

    // Alerta de falta de ejercicio
    final avgExercise = _calculateAverage(recentEntries, 'physicalActivity');
    if (avgExercise < 3.0) {
      alerts.add({
        'type': 'exercise',
        'priority': 'low',
        'title': 'Actividad Física Baja',
        'description': 'No has estado muy activo físicamente',
        'recommendation': 'Intenta incluir más movimiento en tu día',
        'icon': '🏃‍♀️',
        'color': MontereyColors.greenGradient,
      });
    }

    return alerts.take(2).toList();
  }

  // WIDGETS DE LOS NUEVOS ANÁLISIS

  Widget _buildIntelligentMetricCard(String emoji, String title, String value,
      List<Color> gradient, String subtitle) {
    return AnimatedBuilder(
      animation: _analyticsAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1 * _analyticsAnimation.value)).toList(),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradient.first.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(colors: gradient).createShader(bounds);
                },
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendCard(String title, String value, String direction, List<Color> gradient) {
    IconData trendIcon = Icons.trending_flat;
    if (direction == 'up') trendIcon = Icons.trending_up;
    if (direction == 'down') trendIcon = Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.first.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(trendIcon, color: gradient.first, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(colors: gradient).createShader(bounds);
            },
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationItem(Map<String, dynamic> correlation) {
    final strength = correlation['strength'] as double;
    final isPositive = strength > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(correlation['icon'], style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correlation['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  correlation['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(strength.abs() * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAlertItem(Map<String, dynamic> alert) {
    final gradient = alert['color'] as List<Color>;
    final priority = alert['priority'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.first.withOpacity(0.3),
          width: priority == 'high' ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(alert['icon'], style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert['description'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 ${alert['recommendation']}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODOS AUXILIARES DE CÁLCULO

  double _calculateAverage(List<dynamic> entries, String field) {
    if (entries.isEmpty) return 0.0;

    double sum = 0.0;
    int count = 0;

    for (final entry in entries) {
      final value = _getFieldValue(entry, field);
      if (value != null) {
        sum += value;
        count++;
      }
    }

    return count > 0 ? sum / count : 0.0;
  }

  double? _getFieldValue(dynamic entry, String field) {
    try {
      switch (field) {
        case 'moodScore':
          return entry.moodScore?.toDouble();
        case 'energyLevel':
          return entry.energyLevel?.toDouble();
        case 'stressLevel':
          return entry.stressLevel?.toDouble();
        case 'sleepQuality':
          return entry.sleepQuality?.toDouble();
        case 'sleepHours':
          return entry.sleepHours?.toDouble();
        case 'physicalActivity':
          return entry.physicalActivity?.toDouble();
        case 'socialInteraction':
          return entry.socialInteraction?.toDouble();
        case 'workProductivity':
          return entry.workProductivity?.toDouble();
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _calculateTrendDirection(List<dynamic> entries) {
    if (entries.length < 7) return 'stable';

    final recent = entries.take(3);
    final previous = entries.skip(3).take(4);

    final recentAvg = _calculateAverage(recent.toList(), 'moodScore');
    final previousAvg = _calculateAverage(previous.toList(), 'moodScore');

    final diff = recentAvg - previousAvg;
    if (diff > 0.5) return 'Mejorando ↗️';
    if (diff < -0.5) return 'Descendiendo ↘️';
    return 'Estable →';
  }

  String _calculateTrendValue(List<dynamic> recent, List<dynamic> previous, String field) {
    final recentAvg = _calculateAverage(recent, field);
    final previousAvg = _calculateAverage(previous, field);

    if (previousAvg == 0) return recentAvg.toStringAsFixed(1);

    final percentChange = ((recentAvg - previousAvg) / previousAvg * 100);
    return '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%';
  }

  String _getTrendDirection(List<dynamic> recent, List<dynamic> previous, String field) {
    final recentAvg = _calculateAverage(recent, field);
    final previousAvg = _calculateAverage(previous, field);

    final diff = recentAvg - previousAvg;
    if (diff > 0.3) return 'up';
    if (diff < -0.3) return 'down';
    return 'stable';
  }

  double _calculateCorrelation(List<dynamic> entries, String field1, String field2) {
    if (entries.length < 10) return 0.0;

    final values1 = <double>[];
    final values2 = <double>[];

    for (final entry in entries) {
      final val1 = _getFieldValue(entry, field1);
      final val2 = _getFieldValue(entry, field2);
      if (val1 != null && val2 != null) {
        values1.add(val1);
        values2.add(val2);
      }
    }

    if (values1.length < 5) return 0.0;

    final mean1 = values1.reduce((a, b) => a + b) / values1.length;
    final mean2 = values2.reduce((a, b) => a + b) / values2.length;

    double numerator = 0.0;
    double sumSq1 = 0.0;
    double sumSq2 = 0.0;

    for (int i = 0; i < values1.length; i++) {
      final diff1 = values1[i] - mean1;
      final diff2 = values2[i] - mean2;
      numerator += diff1 * diff2;
      sumSq1 += diff1 * diff1;
      sumSq2 += diff2 * diff2;
    }

    final denominator = math.sqrt(sumSq1 * sumSq2);
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  // MÉTODOS DE COLOR BASADOS EN VALORES

  List<Color> _getMentalHealthColor(String value) {
    if (value == 'N/A') return MontereyColors.purpleGradient;
    final score = double.tryParse(value) ?? 0.0;
    if (score >= 7) return MontereyColors.greenGradient;
    if (score >= 5) return MontereyColors.goldGradient;
    return MontereyColors.redGradient;
  }

  List<Color> _getProductivityColor(String value) {
    if (value == 'N/A') return MontereyColors.blueGradient;
    final score = double.tryParse(value) ?? 0.0;
    if (score >= 7) return MontereyColors.greenGradient;
    if (score >= 5) return MontereyColors.goldGradient;
    return MontereyColors.redGradient;
  }

  List<Color> _getBalanceColor(String value) {
    if (value == 'N/A') return MontereyColors.purpleGradient;
    final score = double.tryParse(value) ?? 0.0;
    if (score >= 7) return MontereyColors.greenGradient;
    if (score >= 5) return MontereyColors.goldGradient;
    return MontereyColors.redGradient;
  }

  List<Color> _getTrendColor(String value) {
    if (value.contains('↗️')) return MontereyColors.greenGradient;
    if (value.contains('↘️')) return MontereyColors.redGradient;
    return MontereyColors.blueGradient;
  }

  // [Resto del código anterior se mantiene igual...]
  // Incluir todos los métodos existentes: _buildAnimatedBackground, _buildEnhancedPersonalizedHeader,
  // _buildEnhancedTodayStatusCard, _buildEnhancedMainMetricsSection, _buildEnhancedGoalsProgressSection,
  // _buildEnhancedTodayMomentsSection, _buildEnhancedInsightsSection, _buildEnhancedQuickActionsSection,
  // _buildGlassCard, métodos helper, navegación, etc.

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildEnhancedPersonalizedHeader(user, int index) {
    final greeting = _getContextualGreeting();

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index], _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MontereyColors.primaryGradient.map((color) =>
                  Color.lerp(color, Colors.white, 0.1 * _glowAnimation.value)!
                  ).toList(),
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: MontereyColors.primaryPurple.withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 30 * _glowAnimation.value,
                    offset: const Offset(0, 8),
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: MontereyColors.accentPink.withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 50 * _glowAnimation.value,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(_shimmerAnimation.value - 1, 0),
                              end: Alignment(_shimmerAnimation.value, 0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Contenido principal
                  Row(
                    children: [
                      // Avatar animado con efectos
                      AnimatedBuilder(
                        animation: Listenable.merge([_pulseAnimation, _rotationAnimation, _floatingAnimation]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Transform.rotate(
                                    angle: _rotationAnimation.value * 0.1,
                                    child: Text(
                                      user.avatarEmoji ?? '😊',
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),

                      // Texto de saludo con efectos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatingAnimation.value * 0.5),
                                  child: Text(
                                    greeting,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, -_floatingAnimation.value * 0.3),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                        colors: [Colors.white, Color(0xFFF8FAFC)],
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 15,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTodayStatusCard(OptimizedDailyEntriesProvider entriesProvider,
      OptimizedMomentsProvider momentsProvider, int index) {

    final todayEntry = entriesProvider.todayEntry;
    final todayMomentsCount = momentsProvider.todayCount;
    final hasReflection = todayEntry != null;

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index], _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Stack(
                children: [
                  // Glow effect background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.5,
                          colors: [
                            (hasReflection ? Colors.green : Colors.orange)
                                .withOpacity(0.1 * _glowAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Contenido principal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  (hasReflection ? Colors.green : Colors.orange).withOpacity(0.3),
                                  (hasReflection ? Colors.green : Colors.orange).withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              hasReflection ? Icons.check_circle : Icons.pending,
                              color: hasReflection ? Colors.green : Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hasReflection ? 'Reflexión completada' : 'Reflexión pendiente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        hasReflection
                            ? 'Has registrado tu día. ¡Excelente trabajo!'
                            : 'Tómate un momento para reflexionar sobre tu día.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      if (todayMomentsCount > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: MontereyColors.blueGradient.map((c) => c.withOpacity(0.2)).toList(),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '✨ Momentos capturados hoy: $todayMomentsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMainMetricsSection(OptimizedAnalyticsProvider analyticsProvider,
      OptimizedDailyEntriesProvider entriesProvider, int index) {

    final analytics = analyticsProvider.analytics;
    final wellbeingScore = _getWellbeingScore(analytics);
    final streakDays = _getStreakDays(analytics);
    final avgMood = _getAverageMood(analytics);
    final totalEntries = entriesProvider.entries.length;

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: MontereyColors.primaryGradient,
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Métricas Principales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // Puntuación principal de bienestar con efectos
                    Expanded(
                      flex: 2,
                      child: _buildEnhancedWellbeingScoreCard(wellbeingScore),
                    ),
                    const SizedBox(width: 16),

                    // Métricas secundarias con animaciones
                    Expanded(
                      child: Column(
                        children: [
                          _buildEnhancedSmallMetricCard(
                            title: 'Racha',
                            value: '${streakDays}d',
                            icon: Icons.local_fire_department_rounded,
                            gradient: MontereyColors.pinkGradient,
                          ),
                          const SizedBox(height: 12),
                          _buildEnhancedSmallMetricCard(
                            title: 'Humor',
                            value: avgMood.toStringAsFixed(1),
                            icon: Icons.sentiment_satisfied_rounded,
                            gradient: MontereyColors.purpleGradient,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Grid de estadísticas con efectos staggered
                _buildEnhancedStatsGrid(analytics, totalEntries),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedWellbeingScoreCard(double score) {
    final percentage = (score / 10.0).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.02,
          child: _buildGlassCard(
            child: Stack(
              children: [
                // Glow background animado
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: RadialGradient(
                        colors: [
                          MontereyColors.primaryPurple.withOpacity(0.2 * _glowAnimation.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Contenido principal
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Círculo de progreso animado
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value * 0.1,
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: percentage,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percentage > 0.7 ? Colors.green :
                                    percentage > 0.4 ? Colors.orange : Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Texto central con efectos
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade300],
                                ).createShader(bounds);
                              },
                              child: Text(
                                score.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bienestar General',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSmallMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.5),
          child: _buildGlassCard(
            height: 74,
            child: Stack(
              children: [
                // Glow background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: gradient.map((c) => c.withOpacity(0.1 * _glowAnimation.value)).toList(),
                      ),
                    ),
                  ),
                ),

                // Contenido
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient.map((c) => c.withOpacity(0.3)).toList()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: gradient.first, size: 20),
                    ),
                    const SizedBox(height: 6),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(colors: gradient).createShader(bounds);
                      },
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedStatsGrid(Map<String, dynamic> analytics, int totalEntries) {
    final stats = [
      _StatItem('📝', 'Entradas', '$totalEntries', MontereyColors.blueGradient),
      _StatItem('💪', 'Energía', '${_getEnergyLevel(analytics)}', MontereyColors.goldGradient),
      _StatItem('😌', 'Estrés', '${_getStressLevel(analytics)}', [Colors.green, Colors.teal]),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return AnimatedBuilder(
          animation: _cardAnimations[index % _cardAnimations.length],
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimations[index % _cardAnimations.length].value,
              child: _buildEnhancedStatCard(stat),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedStatCard(_StatItem stat) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.3),
          child: _buildGlassCard(
            child: Stack(
              children: [
                // Shimmer effect
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                        end: Alignment(_shimmerAnimation.value, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Contenido
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(stat.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(colors: stat.gradient).createShader(bounds);
                      },
                      child: Text(
                        stat.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      stat.title,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedGoalsProgressSection(GoalsProvider goalsProvider, int index) {
    final activeGoals = goalsProvider.activeGoals;
    final averageProgress = goalsProvider.averageProgress;

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.blueGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flag, color: MontereyColors.accentTeal),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Objetivos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: MontereyColors.blueGradient),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: MontereyColors.accentTeal.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${activeGoals.length} activos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  if (activeGoals.isNotEmpty) ...[
                    const SizedBox(height: 20),

                    // Progreso promedio con animación
                    _buildEnhancedProgressBar(averageProgress),

                    const SizedBox(height: 20),

                    // Top 3 objetivos con efectos
                    ...activeGoals.take(3).map((goal) => _buildEnhancedGoalItem(goal)),
                  ] else ...[
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '🎯',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No tienes objetivos activos',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            '¡Crea tu primer objetivo!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso promedio: ${(progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _cardsAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Progreso principal
                  Container(
                    width: MediaQuery.of(context).size.width * progress * _cardsAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: MontereyColors.blueGradient),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: MontereyColors.accentTeal.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // Shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedGoalItem(GoalModel goal) {
    final progress = goal.progress;
    final typeEmoji = _getGoalTypeEmoji(goal.type);

    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.2),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(typeEmoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            height: 6,
                            width: (MediaQuery.of(context).size.width - 140) * progress,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: MontereyColors.blueGradient),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color: MontereyColors.accentTeal.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: MontereyColors.blueGradient.map((c) => c.withOpacity(0.2)).toList()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: MontereyColors.accentTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTodayMomentsSection(OptimizedMomentsProvider momentsProvider, int index) {
    final todayPositive = momentsProvider.getMomentsByType('positive').length;
    final todayNegative = momentsProvider.getMomentsByType('negative').length;
    final todayNeutral = momentsProvider.getMomentsByType('neutral').length;

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.pinkGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: MontereyColors.accentPink),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Momentos de Hoy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedMomentTypeCard('😊', 'Positivos', todayPositive, [Colors.green, Colors.lightGreen]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedMomentTypeCard('😐', 'Neutrales', todayNeutral, [Colors.grey, Colors.blueGrey]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedMomentTypeCard('😔', 'Negativos', todayNegative, [Colors.red, Colors.redAccent]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMomentTypeCard(String emoji, String label, int count, List<Color> gradient) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.01,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient.map((c) => c.withOpacity(0.1 * _glowAnimation.value)).toList(),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: gradient.first.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: 10 * _glowAnimation.value,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(colors: gradient).createShader(bounds);
                  },
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedInsightsSection(OptimizedAnalyticsProvider analyticsProvider, int index) {
    final insights = analyticsProvider.getHighlightedInsights();

    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MontereyColors.purpleGradient.map((c) => c.withOpacity(0.3)).toList()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb, color: MontereyColors.accentViolet),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Insights del Día',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ...insights.take(2).map((insight) => _buildEnhancedInsightItem(insight)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedInsightItem(Map<String, String> insight) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.2),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Shimmer effect
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                        end: Alignment(_shimmerAnimation.value, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Contenido
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withOpacity(0.3),
                            Colors.amber.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('💡', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (insight['description'] != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              insight['description']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedQuickActionsSection(int index) {
    return AnimatedBuilder(
      animation: Listenable.merge([_cardAnimations[index], _cardSlideAnimations[index]]),
      builder: (context, child) {
        return Transform.translate(
          offset: _cardSlideAnimations[index].value * 100,
          child: Transform.scale(
            scale: _cardAnimations[index].value,
            child: _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedActionButton(
                          'Reflexionar',
                          Icons.edit_note,
                          MontereyColors.blueGradient,
                              () => _navigateToDailyReview(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedActionButton(
                          'Momento',
                          Icons.add_reaction,
                          MontereyColors.pinkGradient,
                              () => _navigateToMoments(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEnhancedActionButton(
                          'Objetivo',
                          Icons.flag,
                          MontereyColors.goldGradient,
                              () => _navigateToGoals(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedActionButton(String label, IconData icon, List<Color> gradient, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.005,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient.map((c) => c.withOpacity(0.1 * _glowAnimation.value)).toList(),
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gradient.first.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 15 * _glowAnimation.value,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient.map((c) => c.withOpacity(0.3)).toList()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: gradient.first, size: 24),
                  ),
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(colors: gradient).createShader(bounds);
                    },
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassCard({required Widget child, double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  // Helper methods para extraer datos de analytics
  double _getWellbeingScore(Map<String, dynamic> analytics) {
    if (analytics.isEmpty) return 0.0;
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>?;
    return (basicStats?['avg_wellbeing'] as double? ?? 0.0) * 10;
  }

  int _getStreakDays(Map<String, dynamic> analytics) {
    if (analytics.isEmpty) return 0;
    final streakData = analytics['streak_data'] as Map<String, dynamic>?;
    return streakData?['current_streak'] as int? ?? 0;
  }

  double _getAverageMood(Map<String, dynamic> analytics) {
    if (analytics.isEmpty) return 0.0;
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>?;
    return basicStats?['avg_mood'] as double? ?? 0.0;
  }

  String _getEnergyLevel(Map<String, dynamic> analytics) {
    if (analytics.isEmpty) return 'N/A';
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>?;
    final energy = basicStats?['avg_energy'] as double? ?? 0.0;
    return energy.toStringAsFixed(1);
  }

  String _getStressLevel(Map<String, dynamic> analytics) {
    if (analytics.isEmpty) return 'N/A';
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>?;
    final stress = basicStats?['avg_stress'] as double? ?? 0.0;
    return stress.toStringAsFixed(1);
  }

  String _getContextualGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 18) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  String _getGoalTypeEmoji(GoalType type) {
    switch (type) {
      case GoalType.consistency:
        return '🎯';
      case GoalType.mood:
        return '😊';
      case GoalType.positiveMoments:
        return '✨';
      case GoalType.stressReduction:
        return '😌';
      default:
        return '🎯';
    }
  }

  // Navigation methods
  void _navigateToDailyReview() {
    Navigator.pushNamed(context, '/daily-review');
  }

  void _navigateToMoments() {
    Navigator.pushNamed(context, '/moments');
  }

  void _navigateToGoals() {
    Navigator.pushNamed(context, '/goals');
  }
}

// Clase auxiliar para stats
class _StatItem {
  final String emoji;
  final String title;
  final String value;
  final List<Color> gradient;

  _StatItem(this.emoji, this.title, this.value, this.gradient);
}

// Painter para efectos de partículas en el fondo
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.screen;

    for (int i = 0; i < 50; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * 100) % size.height;
      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;

      paint.color = MontereyColors.primaryGradient[i % MontereyColors.primaryGradient.length]
          .withOpacity(opacity * 0.1);

      canvas.drawCircle(
        Offset(x, y),
        1 + math.sin(animationValue * 4 * math.pi + i) * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}