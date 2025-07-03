// lib/presentation/screens/v2/analytics_screen_v2.dart
// ============================================================================
// ANALYTICS SCREEN V2 - ESTILO MINIMALISTA CON GRADIENTES AZUL-MORADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// ============================================================================
// MISMA PALETA DE COLORES DE LA HOME MINIMALISTA
// ============================================================================
class AnalyticsColors {
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

class AnalyticsScreenV2 extends StatefulWidget {
  const AnalyticsScreenV2({super.key});

  @override
  State<AnalyticsScreenV2> createState() => _AnalyticsScreenV2State();
}

class _AnalyticsScreenV2State extends State<AnalyticsScreenV2>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  int _selectedPeriod = 30;
  final List<int> _periodOptions = [7, 30, 90];
  final List<String> _periodLabels = ['7 días', '30 días', '90 días'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 4, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _shimmerController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _loadInitialData() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      Provider.of<OptimizedAnalyticsProvider>(context, listen: false)
          .loadCompleteAnalytics(user.id, days: _selectedPeriod);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnalyticsColors.backgroundPrimary,
      body: SafeArea(
        child: Consumer<OptimizedAnalyticsProvider>(
          builder: (context, analyticsProvider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header con período selector
                  _buildAnimatedHeader(),

                  const SizedBox(height: 16),

                  // Tab bar mejorado
                  _buildEnhancedTabBar(),

                  const SizedBox(height: 20),

                  // Contenido de tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTrendsTab(analyticsProvider),
                        _buildPatternsTab(analyticsProvider),
                        _buildPredictionTab(analyticsProvider),
                        _buildInsightsTab(analyticsProvider),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================================
  // WIDGETS PARA ANÁLISIS DEL DÍA ACTUAL
  // ============================================================================

  Widget _buildCurrentDayAnalysis(OptimizedAnalyticsProvider analyticsProvider) {
    // Usar método real del provider
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final score = wellbeingStatus['score'] as int? ?? 0;
    final hasEntry = score > 0; // Si hay score, hay entrada

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasEntry
              ? AnalyticsColors.chartGradient3[0].withOpacity(0.3)
              : AnalyticsColors.chartGradient2[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasEntry
                ? AnalyticsColors.chartGradient3[1].withOpacity(0.2)
                : AnalyticsColors.chartGradient2[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasEntry
                        ? AnalyticsColors.chartGradient3
                        : AnalyticsColors.chartGradient2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasEntry ? Icons.check_circle_rounded : Icons.access_time_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Análisis del Día Actual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            hasEntry
                ? 'Has registrado tu progreso hoy. Tu puntuación actual es $score/10.'
                : 'Aún no has registrado tu progreso de hoy. ¡Es un buen momento para reflexionar!',
            style: const TextStyle(
              fontSize: 16,
              color: AnalyticsColors.textPrimary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasEntry
                        ? 'Continúa manteniendo estos hábitos positivos para seguir mejorando.'
                        : 'Dedica unos minutos a reflexionar sobre tu día para obtener insights valiosos.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AnalyticsColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMoodStats(OptimizedAnalyticsProvider analyticsProvider) {
    // Usar datos reales del provider
    final summary = analyticsProvider.getDashboardSummary();
    final avgMood = (summary['overall_score'] as num?)?.toDouble() ?? 0.0;

    // Determinar tendencia basada en el score
    String trendIcon;
    String trendDescription;

    if (avgMood >= 8) {
      trendIcon = '🌟';
      trendDescription = 'Excelente';
    } else if (avgMood >= 6) {
      trendIcon = '📈';
      trendDescription = 'Mejorando';
    } else if (avgMood >= 4) {
      trendIcon = '📊';
      trendDescription = 'Estable';
    } else {
      trendIcon = '📉';
      trendDescription = 'Necesita atención';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.lightGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AnalyticsColors.lightGradient,
              ),
            ),
            child: Center(
              child: Text(
                trendIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado de Ánimo Promedio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      avgMood.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AnalyticsColors.lightGradient[0],
                      ),
                    ),
                    const Text(
                      '/10',
                      style: TextStyle(
                        fontSize: 16,
                        color: AnalyticsColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AnalyticsColors.lightGradient[0].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trendDescription,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AnalyticsColors.lightGradient[0],
                        ),
                      ),
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

  Widget _buildStressAlertsCard(OptimizedAnalyticsProvider analyticsProvider) {
    final stressAlerts = analyticsProvider.getStressAlerts();
    final requiresAttention = stressAlerts['requires_attention'] as bool? ?? false;

    if (!requiresAttention) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AnalyticsColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AnalyticsColors.chartGradient3[0].withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AnalyticsColors.chartGradient3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Estrés bajo - ¡Continúa así!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AnalyticsColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.chartGradient2[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.chartGradient2[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.chartGradient2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stressAlerts['alert_icon'] ?? '⚠️',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stressAlerts['alert_title'] ?? 'Alerta de Estrés',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Recomendaciones:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          ...((stressAlerts['recommendations'] as List?) ?? [])
              .map((recommendation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AnalyticsColors.chartGradient2[0],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AnalyticsColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ))
              .toList(),
        ],
      ),
    );
  }

  // ============================================================================
  // HEADER ANIMADO CON GRADIENTES
  // ============================================================================
  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AnalyticsColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AnalyticsColors.primaryGradient[1].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.7),
                          Colors.white,
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics Avanzados',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Descubre patrones en tu bienestar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Selector de período
            _buildPeriodSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: _periodOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final days = entry.value;
          final label = _periodLabels[index];
          final isSelected = _selectedPeriod == days;

          return Expanded(
            child: GestureDetector(
              onTap: () => _updatePeriod(days),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AnalyticsColors.primaryGradient[0]
                          : Colors.white70,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================================
  // TAB BAR MEJORADO
  // ============================================================================
  Widget _buildEnhancedTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.primaryGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.primaryGradient[1].withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: AnalyticsColors.accentGradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AnalyticsColors.accentGradient[1].withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AnalyticsColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: '📈 Tendencias'),
          Tab(text: '🕐 Patrones'),
          Tab(text: '🔮 Predicción'),
          Tab(text: '💡 Insights'),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: TENDENCIAS Y COMPARACIONES
  // ============================================================================
  Widget _buildTrendsTab(OptimizedAnalyticsProvider analyticsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progreso semanal avanzado
          _buildWeeklyComparisonCard(analyticsProvider),

          const SizedBox(height: 20),

          // Gráfico de mood detallado
          _buildDetailedMoodChart(analyticsProvider),

          const SizedBox(height: 20),

          // Métricas de tendencia
          _buildTrendMetrics(analyticsProvider),

          const SizedBox(height: 20),

          // Análisis del día actual usando método real
          _buildCurrentDayAnalysis(analyticsProvider),

          const SizedBox(height: 20),

          // Quick stats de mood usando método real
          _buildQuickMoodStats(analyticsProvider),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparisonCard(OptimizedAnalyticsProvider analyticsProvider) {
    final comparisonData = _getWeeklyComparisonData(analyticsProvider);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AnalyticsColors.chartGradient1[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AnalyticsColors.chartGradient1[1].withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AnalyticsColors.chartGradient1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.compare_arrows_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Comparación Semanal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AnalyticsColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildComparisonMetric(
                        'Esta Semana',
                        comparisonData['current']?.toStringAsFixed(1) ?? '0.0',
                        AnalyticsColors.chartGradient1[0],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AnalyticsColors.accentGradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildComparisonMetric(
                        'Semana Anterior',
                        comparisonData['previous']?.toStringAsFixed(1) ?? '0.0',
                        AnalyticsColors.chartGradient2[0],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: comparisonData['improvement']
                        ? AnalyticsColors.chartGradient3[0].withOpacity(0.2)
                        : AnalyticsColors.chartGradient2[0].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        comparisonData['improvement']
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: comparisonData['improvement']
                            ? AnalyticsColors.chartGradient3[0]
                            : AnalyticsColors.chartGradient2[0],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comparisonData['improvement']
                            ? 'Mejorando respecto a la semana anterior'
                            : 'Oportunidad de mejora esta semana',
                        style: TextStyle(
                          fontSize: 14,
                          color: comparisonData['improvement']
                              ? AnalyticsColors.chartGradient3[0]
                              : AnalyticsColors.chartGradient2[0],
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
      },
    );
  }

  Widget _buildComparisonMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AnalyticsColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMoodChart(OptimizedAnalyticsProvider analyticsProvider) {
    // Usar datos reales del provider
    final moodData = analyticsProvider.getMoodChartData();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.accentGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.accentGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolución del Estado de Ánimo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          // Placeholder para gráfico - en producción usar charts reales
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AnalyticsColors.accentGradient.map((c) => c.withOpacity(0.1)).toList(),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '📊 Gráfico de Mood',
                    style: TextStyle(
                      color: AnalyticsColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${moodData.length} registros disponibles',
                    style: const TextStyle(
                      color: AnalyticsColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendMetrics(OptimizedAnalyticsProvider analyticsProvider) {
    final summary = analyticsProvider.getDashboardSummary();
    final totalEntries = summary['total_entries'] as int? ?? 0;
    final overallScore = summary['overall_score'] as double? ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildTrendMetricCard(
            'Entradas Totales',
            totalEntries.toString(),
            '📈 +$totalEntries',
            AnalyticsColors.chartGradient3,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrendMetricCard(
            'Puntuación Promedio',
            overallScore.toStringAsFixed(1),
            '📊 ${overallScore >= 5 ? '+' : ''}${(overallScore - 5).toStringAsFixed(1)}',
            AnalyticsColors.chartGradient2,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendMetricCard(String title, String value, String trend, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AnalyticsColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: gradient[0],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: gradient[1],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 2: PATRONES Y HORAS PICO
  // ============================================================================
  Widget _buildPatternsTab(OptimizedAnalyticsProvider analyticsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPeakPerformanceCard(analyticsProvider),

          const SizedBox(height: 20),

          _buildMoodCorrelationsCard(analyticsProvider),

          const SizedBox(height: 20),

          _buildHourlyPatternsCard(analyticsProvider),
        ],
      ),
    );
  }

  Widget _buildPeakPerformanceCard(OptimizedAnalyticsProvider analyticsProvider) {
    final peakHours = _getPeakPerformanceHours(analyticsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.lightGradient[1].withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AnalyticsColors.lightGradient[0],
                          AnalyticsColors.lightGradient[1],
                          AnalyticsColors.lightGradient[0],
                        ],
                        stops: [
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Tus Mejores Horas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...peakHours.map((hour) => _buildPeakHourItem(hour)).toList(),
        ],
      ),
    );
  }

  Widget _buildPeakHourItem(Map<String, dynamic> hour) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AnalyticsColors.lightGradient,
              ),
            ),
            child: Center(
              child: Text(
                hour['emoji'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hour['timeRange'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hour['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AnalyticsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AnalyticsColors.lightGradient[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${hour['score']}/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AnalyticsColors.lightGradient[0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCorrelationsCard(OptimizedAnalyticsProvider analyticsProvider) {
    final correlations = _getMoodCorrelations(analyticsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.chartGradient2[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.chartGradient2[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Correlaciones de Bienestar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          ...correlations.map((correlation) => _buildCorrelationItem(correlation)).toList(),
        ],
      ),
    );
  }

  Widget _buildCorrelationItem(Map<String, dynamic> correlation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.chartGradient2[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            correlation['emoji'],
            style: const TextStyle(fontSize: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              correlation['description'],
              style: const TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textPrimary,
              ),
            ),
          ),

          Container(
            width: 60,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AnalyticsColors.backgroundPrimary,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: correlation['strength'],
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.chartGradient2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyPatternsCard(OptimizedAnalyticsProvider analyticsProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.chartGradient3[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.chartGradient3[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrones por Hora del Día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          // Heatmap visual simple
          SizedBox(
            height: 100,
            child: Row(
              children: List.generate(24, (hour) {
                final intensity = (math.sin(hour * math.pi / 12) + 1) / 2;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: AnalyticsColors.chartGradient3[0].withOpacity(intensity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '00:00',
                style: TextStyle(
                  fontSize: 12,
                  color: AnalyticsColors.textSecondary,
                ),
              ),
              Text(
                '12:00',
                style: TextStyle(
                  fontSize: 12,
                  color: AnalyticsColors.textSecondary,
                ),
              ),
              Text(
                '23:59',
                style: TextStyle(
                  fontSize: 12,
                  color: AnalyticsColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 3: PREDICCIÓN Y ANÁLISIS FUTURO
  // ============================================================================
  Widget _buildPredictionTab(OptimizedAnalyticsProvider analyticsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildWellbeingPredictionCard(analyticsProvider),

          const SizedBox(height: 20),

          _buildDashboardSummaryCard(analyticsProvider),

          const SizedBox(height: 20),

          _buildAIInsightsCard(analyticsProvider),

          const SizedBox(height: 20),

          // Agregar alertas de estrés usando método real
          _buildStressAlertsCard(analyticsProvider),
        ],
      ),
    );
  }

  Widget _buildWellbeingPredictionCard(OptimizedAnalyticsProvider analyticsProvider) {
    final prediction = _getWellbeingPrediction(analyticsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.primaryGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.primaryGradient[1].withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Predicción de Bienestar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AnalyticsColors.primaryGradient.map((c) => c.withOpacity(0.1)).toList(),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  prediction['emoji'],
                  style: const TextStyle(fontSize: 48),
                ),

                const SizedBox(height: 12),

                Text(
                  prediction['prediction'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Basado en $_selectedPeriod días de datos',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AnalyticsColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  prediction['recommendation'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: AnalyticsColors.textPrimary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSummaryCard(OptimizedAnalyticsProvider analyticsProvider) {
    final summary = analyticsProvider.getDashboardSummary();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.accentGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.accentGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Ejecutivo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  'Días Activos',
                  (summary['total_entries'] ?? 0).toString(),
                  AnalyticsColors.chartGradient1[0],
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  'Promedio General',
                  (summary['overall_score'] ?? 0.0).toStringAsFixed(1),
                  AnalyticsColors.chartGradient2[0],
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  'Tendencia',
                  summary['trend_emoji'] ?? '📊',
                  AnalyticsColors.chartGradient3[0],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AnalyticsColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAIInsightsCard(OptimizedAnalyticsProvider analyticsProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.lightGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AnalyticsColors.lightGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Insights de IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AnalyticsColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🧠 La IA ha detectado que tu mejor rendimiento ocurre entre las 9-11 AM. '
                  'Considera programar tareas importantes en ese horario para maximizar tu productividad.',
              style: TextStyle(
                fontSize: 14,
                color: AnalyticsColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 4: INSIGHTS DETALLADOS
  // ============================================================================
  Widget _buildInsightsTab(OptimizedAnalyticsProvider analyticsProvider) {
    final insights = analyticsProvider.getInsights();
    final highlightedInsights = analyticsProvider.getHighlightedInsights();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Insights destacados
          ...highlightedInsights.map((insight) => _buildHighlightedInsightCard(insight)).toList(),

          if (highlightedInsights.isNotEmpty) const SizedBox(height: 20),

          // Insights generales
          ...insights.map((insight) => _buildInsightCard(insight)).toList(),

          const SizedBox(height: 20),

          _buildRecommendationsCard(analyticsProvider),
        ],
      ),
    );
  }

  Widget _buildHighlightedInsightCard(Map<String, String> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AnalyticsColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.primaryGradient[1].withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            insight['emoji'] ?? '💡',
            style: const TextStyle(fontSize: 40),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] ?? 'Insight Destacado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight['description'] ?? 'Descripción del insight',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, String> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.accentGradient[0].withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.accentGradient[1].withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AnalyticsColors.accentGradient,
              ),
            ),
            child: Center(
              child: Text(
                insight['emoji'] ?? '📊',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] ?? 'Insight',
                  style: const TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['description'] ?? 'Descripción',
                  style: const TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(OptimizedAnalyticsProvider analyticsProvider) {
    final recommendations = analyticsProvider.getTopRecommendations();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.lightGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recomendaciones Personalizadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          if (recommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Continúa registrando tu progreso para obtener recomendaciones personalizadas',
                  style: TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...recommendations.take(3).map((rec) => _buildRecommendationItem(rec)).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AnalyticsColors.lightGradient[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AnalyticsColors.lightGradient,
              ),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] ?? 'Recomendación',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
                if (recommendation['description'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    recommendation['description'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AnalyticsColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS HELPER PARA DATOS SIMULADOS
  // ============================================================================

  Map<String, dynamic> _getWeeklyComparisonData(OptimizedAnalyticsProvider analyticsProvider) {
    // Usar datos reales del provider cuando estén disponibles
    final summary = analyticsProvider.getDashboardSummary();
    final currentScore = (summary['overall_score'] as num?)?.toDouble() ?? 5.0;

    // Simular datos de semana anterior (en producción esto vendría del provider)
    final previousScore = currentScore * 0.85; // Simular mejora del 15%

    return {
      'current': currentScore,
      'previous': previousScore,
      'improvement': currentScore > previousScore,
    };
  }

  List<Map<String, dynamic>> _getPeakPerformanceHours(OptimizedAnalyticsProvider analyticsProvider) {
    // Simular datos de horas pico - en producción usar método real del provider
    return [
      {
        'timeRange': '9:00 - 11:00 AM',
        'description': 'Tu pico de energía y creatividad',
        'score': 8.5,
        'emoji': '🚀',
      },
      {
        'timeRange': '2:00 - 4:00 PM',
        'description': 'Segundo momento de alta productividad',
        'score': 7.8,
        'emoji': '💪',
      },
      {
        'timeRange': '7:00 - 9:00 PM',
        'description': 'Momento ideal para reflexión',
        'score': 7.2,
        'emoji': '🧘',
      },
    ];
  }

  List<Map<String, dynamic>> _getMoodCorrelations(OptimizedAnalyticsProvider analyticsProvider) {
    // Simular correlaciones - en producción usar método real
    return [
      {
        'emoji': '😴',
        'description': 'El sueño de calidad mejora tu mood en un 85%',
        'strength': 0.85,
      },
      {
        'emoji': '🏃‍♀️',
        'description': 'El ejercicio tiene un impacto positivo del 72%',
        'strength': 0.72,
      },
      {
        'emoji': '👥',
        'description': 'La interacción social mejora tu bienestar en 68%',
        'strength': 0.68,
      },
    ];
  }

  Map<String, dynamic> _getWellbeingPrediction(OptimizedAnalyticsProvider analyticsProvider) {
    // Usar datos reales del provider
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final currentScore = wellbeingStatus['score'] as int? ?? 5;
    final streakData = analyticsProvider.getStreakData();
    final currentStreak = streakData['current'] as int? ?? 0;

    // Lógica de predicción basada en datos reales
    if (currentScore >= 8 && currentStreak >= 7) {
      return {
        'prediction': 'Excelente',
        'emoji': '🌟',
        'recommendation': 'Continúa con tus hábitos actuales. Tu consistencia está generando excelentes resultados.',
      };
    } else if (currentScore >= 6) {
      return {
        'prediction': 'Estable con mejoras',
        'emoji': '📈',
        'recommendation': 'Con pequeños ajustes y más consistencia podrías alcanzar un nivel excelente.',
      };
    } else {
      return {
        'prediction': 'Espacio para crecer',
        'emoji': '🌱',
        'recommendation': 'Enfócate en mantener la consistencia diaria para ver mejoras significativas.',
      };
    }
  }

  void _updatePeriod(int days) {
    setState(() {
      _selectedPeriod = days;
    });
    _loadInitialData();
  }
}