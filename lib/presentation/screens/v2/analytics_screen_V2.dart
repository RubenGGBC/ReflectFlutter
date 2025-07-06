// lib/presentation/screens/v2/analytics_screen_v2.dart
// ============================================================================
// ANALYTICS SCREEN V2 - ESTILO AVANZADO CON ANÁLISIS PREDICTIVO INTEGRADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../../ai/provider/predective_analysis_provider.dart';

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

  // Estados de inicialización para IA
  bool _isInitializing = false;
  String _initializationStatus = 'Preparando análisis avanzado...';
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 6, vsync: this);

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
                  // Header simplificado como card
                  _buildSimpleHeader(),

                  const SizedBox(height: 16),

                  // Tab bar mejorado
                  _buildEnhancedTabBar(),

                  const SizedBox(height: 20),

                  // Contenido de tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(analyticsProvider),
                        _buildTrendsTab(analyticsProvider),
                        _buildPatternsTab(analyticsProvider),
                        _buildPredictionTab(analyticsProvider),
                        _buildInsightsTab(analyticsProvider),
                        _buildReportsTab(analyticsProvider),
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
  // HEADER SIMPLIFICADO COMO CARD
  // ============================================================================
  Widget _buildSimpleHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
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
            color: AnalyticsColors.primaryGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
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
                      'Analytics Avanzados',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AnalyticsColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Descubre patrones en tu bienestar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AnalyticsColors.textSecondary,
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
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AnalyticsColors.primaryGradient[0].withOpacity(0.2),
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
                  gradient: isSelected
                      ? const LinearGradient(colors: AnalyticsColors.primaryGradient)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AnalyticsColors.primaryGradient[1].withOpacity(0.3),
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
                          ? Colors.white
                          : AnalyticsColors.textSecondary,
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
          Tab(text: '📊 Resumen'),
          Tab(text: '📈 Tendencias'),
          Tab(text: '🕐 Patrones'),
          Tab(text: '🔮 Predicción'),
          Tab(text: '💡 Insights'),
          Tab(text: '📋 Reporte'),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: RESUMEN GENERAL (NUEVO)
  // ============================================================================
  Widget _buildOverviewTab(OptimizedAnalyticsProvider analyticsProvider) {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, predictiveProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Estado del análisis
              _buildAnalysisStatusCard(predictiveProvider),

              const SizedBox(height: 20),

              // Métricas rápidas
              _buildQuickMetricsGrid(analyticsProvider, predictiveProvider),

              const SizedBox(height: 20),

              // Insights recientes
              _buildRecentInsightsCard(predictiveProvider),

              const SizedBox(height: 20),

              // Acciones recomendadas
              _buildActionItemsCard(predictiveProvider),

              const SizedBox(height: 20),

              // Análisis actual de bienestar
              _buildCurrentDayAnalysis(analyticsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalysisStatusCard(PredictiveAnalysisProvider provider) {
    final summary = provider.getAnalysisSummary();
    final overallStatus = summary['overall_status'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AnalyticsColors.backgroundCard,
            AnalyticsColors.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.primaryGradient[0].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AnalyticsColors.primaryGradient[1].withOpacity(0.2),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado del Análisis',
                      style: TextStyle(
                        color: AnalyticsColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overallStatus['ai_status'] ?? 'Estado desconocido',
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AnalyticsColors.accentGradient[1],
                    ),
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            children: [
              _buildStatusCard(
                'Insights IA',
                summary['ai_insights']['available'] ? 'Disponibles' : 'Pendiente',
                summary['ai_insights']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['ai_insights']['available'] ? AnalyticsColors.chartGradient3[0] : AnalyticsColors.chartGradient1[0],
              ),
              _buildStatusCard(
                'Correlaciones',
                summary['correlations']['available'] ? 'Analizadas' : 'Pendiente',
                summary['correlations']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['correlations']['available'] ? AnalyticsColors.chartGradient3[0] : AnalyticsColors.chartGradient1[0],
              ),
              _buildStatusCard(
                'Forecasts',
                summary['forecasts']['available'] ? 'Generados' : 'Pendiente',
                summary['forecasts']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['forecasts']['available'] ? AnalyticsColors.chartGradient3[0] : AnalyticsColors.chartGradient1[0],
              ),
              _buildStatusCard(
                'Personalidad',
                summary['personality']['available'] ? 'Analizada' : 'Pendiente',
                summary['personality']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['personality']['available'] ? AnalyticsColors.chartGradient3[0] : AnalyticsColors.chartGradient1[0],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetricsGrid(OptimizedAnalyticsProvider analyticsProvider, PredictiveAnalysisProvider predictiveProvider) {
    final summary = analyticsProvider.getDashboardSummary();
    final totalEntries = (summary['total_entries'] as num?)?.toInt() ?? 0;
    final overallScore = (summary['overall_score'] as num?)?.toDouble() ?? 0.0;
    final insightsCount = predictiveProvider.aiInsights.length;
    final correlationsCount = predictiveProvider.emotionalCorrelations.length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Entradas Totales',
          totalEntries.toString(),
          Icons.calendar_today,
          AnalyticsColors.chartGradient1,
        ),
        _buildMetricCard(
          'Puntuación Media',
          overallScore.toStringAsFixed(1),
          Icons.star,
          AnalyticsColors.chartGradient2,
        ),
        _buildMetricCard(
          'Insights IA',
          insightsCount.toString(),
          Icons.lightbulb,
          AnalyticsColors.chartGradient3,
        ),
        _buildMetricCard(
          'Correlaciones',
          correlationsCount.toString(),
          Icons.scatter_plot,
          AnalyticsColors.accentGradient,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, List<Color> gradient) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: gradient[0],
            size: 32,
          ),
          const SizedBox(height: 12),
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
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AnalyticsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInsightsCard(PredictiveAnalysisProvider provider) {
    final insights = provider.aiInsights.take(3).toList();

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.lightGradient,
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
                'Insights Recientes',
                style: TextStyle(
                  color: AnalyticsColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (insights.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Genera análisis en la pestaña "Insights" para ver resultados aquí',
                  style: TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...insights.map((insight) => _buildCompactInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildCompactInsightCard(insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AnalyticsColors.accentGradient,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsCard(PredictiveAnalysisProvider provider) {
    final actionItems = <Map<String, dynamic>>[];

    if (provider.hasAIInsights) {
      final highConfidenceInsights = provider.aiInsights
          .where((insight) => insight.confidence > 0.8)
          .length;

      if (highConfidenceInsights > 0) {
        actionItems.add({
          'title': 'Revisar insights de alta confianza',
          'description': '$highConfidenceInsights insights requieren tu atención',
          'icon': Icons.priority_high,
          'color': AnalyticsColors.chartGradient3[0],
          'action': () => _tabController.animateTo(4),
        });
      }
    }

    if (provider.hasCorrelations) {
      actionItems.add({
        'title': 'Explorar correlaciones encontradas',
        'description': 'Nuevos patrones detectados en tus datos',
        'icon': Icons.insights,
        'color': AnalyticsColors.accentGradient[1],
        'action': () => _tabController.animateTo(2),
      });
    }

    if (!provider.hasForecasts) {
      actionItems.add({
        'title': 'Generar predicciones de bienestar',
        'description': 'Obtén forecasts para los próximos días',
        'icon': Icons.trending_up,
        'color': AnalyticsColors.primaryGradient[1],
        'action': () => _tabController.animateTo(3),
      });
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
          const Text(
            'Acciones Recomendadas',
            style: TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          if (actionItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Las recomendaciones aparecerán aquí después de ejecutar los análisis.',
                  style: TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...actionItems.map((item) => _buildActionItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildActionItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item['action'],
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (item['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          color: AnalyticsColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: const TextStyle(
                          color: AnalyticsColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AnalyticsColors.textTertiary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TAB 2: TENDENCIAS Y COMPARACIONES
  // ============================================================================
  Widget _buildTrendsTab(OptimizedAnalyticsProvider analyticsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Comparación semanal con datos reales
          _buildWeeklyComparisonCard(analyticsProvider),

          const SizedBox(height: 20),

          // Gráfico de mood con datos reales
          _buildDetailedMoodChart(analyticsProvider),

          const SizedBox(height: 20),

          // Métricas de tendencia con datos reales
          _buildTrendMetrics(analyticsProvider),

          const SizedBox(height: 20),

          // Análisis del día actual
          _buildCurrentDayAnalysis(analyticsProvider),

          const SizedBox(height: 20),

          // Quick stats de mood
          _buildQuickMoodStats(analyticsProvider),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparisonCard(OptimizedAnalyticsProvider analyticsProvider) {
    final weeklyData = analyticsProvider.getWeeklyComparison();
    final hasData = weeklyData['has_data'] as bool? ?? false;

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AnalyticsColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AnalyticsColors.textTertiary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.insights_rounded,
              color: AnalyticsColors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              weeklyData['message'] ?? 'Necesitas más datos para comparación semanal',
              style: const TextStyle(
                color: AnalyticsColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 🛠️ FIX: Cast to 'num?' first, then convert to 'double' to prevent type errors.
    final moodChange = (weeklyData['mood_change'] as num?)?.toDouble() ?? 0.0;
    final energyChange = (weeklyData['energy_change'] as num?)?.toDouble() ?? 0.0;
    final stressChange = (weeklyData['stress_change'] as num?)?.toDouble() ?? 0.0;

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

                // Cambios en métricas
                _buildChangeMetric(
                  'Estado de Ánimo',
                  moodChange,
                  Icons.sentiment_satisfied_alt,
                  AnalyticsColors.chartGradient1[0],
                ),
                const SizedBox(height: 12),
                _buildChangeMetric(
                  'Nivel de Energía',
                  energyChange,
                  Icons.battery_charging_full,
                  AnalyticsColors.chartGradient3[0],
                ),
                const SizedBox(height: 12),
                _buildChangeMetric(
                  'Nivel de Estrés',
                  stressChange,
                  Icons.psychology,
                  AnalyticsColors.chartGradient2[0],
                  isStress: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangeMetric(String label, double change, IconData icon, Color color, {bool isStress = false}) {
    final isPositive = isStress ? change < 0 : change > 0;
    final changeText = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AnalyticsColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive
                  ? AnalyticsColors.chartGradient3[0].withOpacity(0.2)
                  : AnalyticsColors.chartGradient2[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? AnalyticsColors.chartGradient3[0]
                      : AnalyticsColors.chartGradient2[0],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  changeText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? AnalyticsColors.chartGradient3[0]
                        : AnalyticsColors.chartGradient2[0],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMoodChart(OptimizedAnalyticsProvider analyticsProvider) {
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

          if (moodData.isEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'No hay suficientes datos para mostrar el gráfico',
                  style: TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AnalyticsColors.textTertiary.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: moodData.length > 7 ? moodData.length / 7 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < moodData.length) {
                            final date = DateTime.parse(moodData[value.toInt()]['date']);
                            return Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(
                                color: AnalyticsColors.textTertiary,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: AnalyticsColors.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: moodData.length.toDouble() - 1,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    // Línea de Mood
                    LineChartBarData(
                      spots: moodData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['mood'] as num).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: AnalyticsColors.accentGradient,
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AnalyticsColors.accentGradient[1],
                            strokeWidth: 2,
                            strokeColor: AnalyticsColors.backgroundCard,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: AnalyticsColors.accentGradient
                              .map((color) => color.withOpacity(0.2))
                              .toList(),
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
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
    // 🛠️ FIX: Safe casting for totalEntries and overallScore
    final totalEntries = (summary['total_entries'] as num?)?.toInt() ?? 0;
    final overallScore = (summary['overall_score'] as num?)?.toDouble() ?? 0.0;
    final trendEmoji = summary['trend_emoji'] ?? '📊';

    return Row(
      children: [
        Expanded(
          child: _buildTrendMetricCard(
            'Entradas Totales',
            totalEntries.toString(),
            trendEmoji,
            AnalyticsColors.chartGradient3,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrendMetricCard(
            'Puntuación Promedio',
            overallScore.toStringAsFixed(1),
            '📊 /10',
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

  Widget _buildCurrentDayAnalysis(OptimizedAnalyticsProvider analyticsProvider) {
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    // 🛠️ FIX: Safe casting for score
    final score = (wellbeingStatus['score'] as num?)?.toInt() ?? 0;
    final hasEntry = score > 0;

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
                'Estado Actual de Bienestar',
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
            wellbeingStatus['message'] ?? '',
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
                Text(wellbeingStatus['emoji'] ?? '💡', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nivel: ${wellbeingStatus['level'] ?? 'Sin datos'}',
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
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    // 🛠️ FIX: Safe casting for mood, energy, and stress
    final avgMood = (wellbeingStatus['mood'] as num?)?.toDouble() ?? 0.0;
    final avgEnergy = (wellbeingStatus['energy'] as num?)?.toDouble() ?? 0.0;
    final avgStress = (wellbeingStatus['stress'] as num?)?.toDouble() ?? 0.0;

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
            'Métricas Detalladas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow('Estado de Ánimo', avgMood, Icons.sentiment_satisfied_alt),
          const SizedBox(height: 16),
          _buildStatRow('Nivel de Energía', avgEnergy, Icons.battery_charging_full),
          const SizedBox(height: 16),
          _buildStatRow('Nivel de Estrés', avgStress, Icons.psychology, isStress: true),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, IconData icon, {bool isStress = false}) {
    final color = isStress
        ? (value <= 3 ? AnalyticsColors.chartGradient3[0] :
    value <= 6 ? AnalyticsColors.chartGradient1[0] : AnalyticsColors.chartGradient2[0])
        : (value >= 7 ? AnalyticsColors.chartGradient3[0] :
    value >= 4 ? AnalyticsColors.chartGradient1[0] : AnalyticsColors.chartGradient2[0]);

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AnalyticsColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: value / 10,
                backgroundColor: AnalyticsColors.backgroundSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
                'Análisis de Patrones Horarios',
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
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
            'Factores que Influyen en tu Bienestar',
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
              widthFactor: (correlation['strength'] as num).toDouble(),
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
    final hourlyData = _getHourlyPatternData(analyticsProvider);

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
            'Actividad por Hora del Día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AnalyticsColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          // Heatmap visual mejorado
          SizedBox(
            height: 100,
            child: Row(
              children: List.generate(24, (hour) {
                final intensity = hourlyData[hour] ?? 0.0;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: AnalyticsColors.chartGradient3[0].withOpacity(intensity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: intensity > 0.5
                          ? Text(
                        hour.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
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
  // TAB 4: PREDICCIÓN Y ANÁLISIS FUTURO CON IA
  // ============================================================================
  Widget _buildPredictionTab(OptimizedAnalyticsProvider analyticsProvider) {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, predictiveProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Predicción de bienestar inteligente
              _buildAIWellbeingPredictionCard(analyticsProvider, predictiveProvider),

              const SizedBox(height: 20),

              // Forecasts de mood avanzados
              _buildAdvancedForecastsCard(predictiveProvider),

              const SizedBox(height: 20),

              // Correlaciones emocionales
              _buildEmotionalCorrelationsCard(predictiveProvider),

              const SizedBox(height: 20),

              // Análisis de personalidad
              _buildPersonalityAnalysisCard(predictiveProvider),

              const SizedBox(height: 20),

              // Alertas y recomendaciones
              _buildStressAlertsCard(analyticsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIWellbeingPredictionCard(OptimizedAnalyticsProvider analyticsProvider, PredictiveAnalysisProvider predictiveProvider) {
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
              const Expanded(
                child: Text(
                  'Predicción de Bienestar IA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
              ),
              if (!predictiveProvider.hasForecasts)
                ElevatedButton.icon(
                  onPressed: () => _generateForecasts(predictiveProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnalyticsColors.accentGradient[1],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  label: const Text(
                    'Generar',
                    style: TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _buildAdvancedForecastsCard(PredictiveAnalysisProvider provider) {
    if (!provider.hasForecasts) {
      return _buildAnalysisPromptCard(
        title: 'Generar Forecasts Avanzados',
        description: 'Obtén predicciones de tu estado de ánimo, energía y estrés para los próximos días.',
        icon: Icons.trending_up,
        onGenerate: () => _generateForecasts(provider),
        isLoading: provider.isGeneratingForecasts,
      );
    }

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Forecasts de Mood Avanzados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _generateForecasts(provider),
                icon: const Icon(
                  Icons.refresh,
                  color: AnalyticsColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mini gráfico de forecasts
          _buildForecastChart(provider.moodForecasts),

          const SizedBox(height: 16),

          // Lista de forecasts próximos
          ...provider.moodForecasts.take(3).map((forecast) => _buildCompactForecastCard(forecast)),
        ],
      ),
    );
  }

  Widget _buildEmotionalCorrelationsCard(PredictiveAnalysisProvider provider) {
    if (!provider.hasCorrelations) {
      return _buildAnalysisPromptCard(
        title: 'Analizar Correlaciones Emocionales',
        description: 'Descubre cómo diferentes aspectos de tu vida se relacionan con tu bienestar.',
        icon: Icons.scatter_plot,
        onGenerate: () => _generateCorrelations(provider),
        isLoading: provider.isAnalyzingCorrelations,
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
                child: const Icon(
                  Icons.scatter_plot,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Correlaciones Emocionales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '${provider.emotionalCorrelations.length} correlaciones significativas detectadas',
            style: const TextStyle(
              color: AnalyticsColors.textSecondary,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          ...provider.emotionalCorrelations.take(2).map((correlation) => _buildCompactCorrelationCard(correlation)),
        ],
      ),
    );
  }

  Widget _buildPersonalityAnalysisCard(PredictiveAnalysisProvider provider) {
    if (!provider.hasPersonalityProfile) {
      return _buildAnalysisPromptCard(
        title: 'Análisis de Personalidad Emocional',
        description: 'Obtén un perfil detallado de tus rasgos emocionales y áreas de crecimiento.',
        icon: Icons.psychology,
        onGenerate: () => _generatePersonalityAnalysis(provider),
        isLoading: provider.isAnalyzingPersonality,
      );
    }

    final profile = provider.personalityProfile!;

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.lightGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tu Personalidad Emocional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AnalyticsColors.textPrimary,
                  ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.dominantEmotionalPattern,
                  style: const TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.personalityDescription,
                  style: const TextStyle(
                    color: AnalyticsColors.textSecondary,
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

  Widget _buildAnalysisPromptCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onGenerate,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AnalyticsColors.accentGradient[1],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AnalyticsColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: isLoading ? null : onGenerate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AnalyticsColors.accentGradient[1],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome, color: Colors.white),
            label: Text(
              isLoading ? 'Analizando...' : 'Generar Análisis',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart(List forecasts) {
    if (forecasts.isEmpty) return Container();

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: forecasts.asMap().entries.map((entry) {
          final forecast = entry.value;
          final height = (forecast.predictedMoodScore / 10) * 60;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: AnalyticsColors.accentGradient,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${forecast.date.day}/${forecast.date.month}',
                    style: const TextStyle(
                      color: AnalyticsColors.textTertiary,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactForecastCard(forecast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${forecast.date.day}/${forecast.date.month}',
            style: const TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mood: ${forecast.predictedMoodScore.toStringAsFixed(1)}',
              style: const TextStyle(
                color: AnalyticsColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AnalyticsColors.accentGradient[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(forecast.confidence * 100).toInt()}%',
              style: TextStyle(
                color: AnalyticsColors.accentGradient[0],
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCorrelationCard(correlation) {
    final isPositive = correlation.correlationStrength > 0;
    final color = isPositive ? AnalyticsColors.chartGradient3[0] : AnalyticsColors.chartGradient2[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${correlation.factor1} ↔ ${correlation.factor2}',
              style: const TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${(correlation.correlationStrength * 100).abs().toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                  ((summary['total_entries'] as num?)?.toInt() ?? 0).toString(),
                  AnalyticsColors.chartGradient1[0],
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  'Promedio General',
                  ((summary['overall_score'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
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
    final insights = analyticsProvider.getHighlightedInsights();
    final primaryInsight = insights.isNotEmpty ? insights.first : null;

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

          if (primaryInsight != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    primaryInsight['emoji'] ?? '🧠',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          primaryInsight['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AnalyticsColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          primaryInsight['description'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AnalyticsColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🧠 Continúa registrando tu progreso diario para obtener insights personalizados de IA.',
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
                insight['icon'] ?? '📊',
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
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
  // TAB 6: REPORTES SEMANALES
  // ============================================================================
  Widget _buildReportsTab(OptimizedAnalyticsProvider analyticsProvider) {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, predictiveProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Reporte semanal inteligente
              _buildWeeklyReportCard(predictiveProvider),

              const SizedBox(height: 20),

              // Análisis comparativo
              _buildComparativeAnalysisCard(predictiveProvider),

              const SizedBox(height: 20),

              // Métricas de progreso
              _buildProgressMetricsCard(analyticsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyReportCard(PredictiveAnalysisProvider provider) {
    if (!provider.hasWeeklyReport) {
      return _buildAnalysisPromptCard(
        title: 'Generar Reporte Semanal Inteligente',
        description: 'Obtén un resumen completo de tu semana con insights personalizados.',
        icon: Icons.assessment,
        onGenerate: () => _generateWeeklyReport(provider),
        isLoading: provider.isGeneratingWeeklyReport,
      );
    }

    final report = provider.weeklyReport!;
    final growthScore = (report.overallGrowthScore * 100).toInt();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assessment,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reporte Semanal Inteligente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(report.weekStart)} - ${_formatDate(report.weekEnd)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    Text(
                      '$growthScore%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Crecimiento',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            report.aiSummary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Botón para ver detalles
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showWeeklyReportDetails(report),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Ver Detalles Completos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparativeAnalysisCard(PredictiveAnalysisProvider provider) {
    if (!provider.hasWeeklyReport) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AnalyticsColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AnalyticsColors.textTertiary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            'Genera un reporte semanal para ver análisis comparativo',
            style: TextStyle(
              color: AnalyticsColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final report = provider.weeklyReport!;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Análisis Comparativo',
                style: TextStyle(
                  color: AnalyticsColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildComparisonMetric(
                  'Tendencia Semanal',
                  _formatTrend(report.weeklyTrend),
                  _getTrendColor(report.weeklyTrend),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonMetric(
                  'Insights Generados',
                  '${report.keyInsights.length}',
                  AnalyticsColors.lightGradient[0],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (report.personalizedRecommendations.isNotEmpty) ...[
            const Text(
              'Recomendaciones Principales:',
              style: TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...report.personalizedRecommendations.take(2).map((rec) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AnalyticsColors.accentGradient[0],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(
                          color: AnalyticsColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressMetricsCard(OptimizedAnalyticsProvider analyticsProvider) {
    final summary = analyticsProvider.getDashboardSummary();
    final streakData = analyticsProvider.getStreakData();

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
            'Métricas de Progreso',
            style: TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildProgressMetric(
                  'Racha Actual',
                  '${(streakData['current'] as num?)?.toInt() ?? 0} días',
                  Icons.local_fire_department,
                  AnalyticsColors.chartGradient2[0],
                ),
              ),
              Expanded(
                child: _buildProgressMetric(
                  'Total Entradas',
                  '${(summary['total_entries'] as num?)?.toInt() ?? 0}',
                  Icons.edit_note,
                  AnalyticsColors.chartGradient1[0],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildProgressMetric(
                  'Mejor Racha',
                  '${(streakData['best'] as num?)?.toInt() ?? 0} días',
                  Icons.emoji_events,
                  AnalyticsColors.chartGradient3[0],
                ),
              ),
              Expanded(
                child: _buildProgressMetric(
                  'Puntuación',
                  '${((summary['overall_score'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1)}/10',
                  Icons.star,
                  AnalyticsColors.lightGradient[0],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildProgressMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE ANÁLISIS IA
  // ============================================================================

  Future<void> _generateForecasts(PredictiveAnalysisProvider provider) async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      HapticFeedback.lightImpact();
      await provider.generateAdvancedMoodForecasts(userId: user!.id);
    }
  }

  Future<void> _generateCorrelations(PredictiveAnalysisProvider provider) async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      HapticFeedback.lightImpact();
      await provider.analyzeEmotionalCorrelations(userId: user!.id);
    }
  }

  Future<void> _generatePersonalityAnalysis(PredictiveAnalysisProvider provider) async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      HapticFeedback.lightImpact();
      await provider.analyzeEmotionalPersonality(userId: user!.id);
    }
  }

  Future<void> _generateWeeklyReport(PredictiveAnalysisProvider provider) async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.id != null) {
      HapticFeedback.lightImpact();
      await provider.generateWeeklyIntelligenceReport(userId: user!.id);
    }
  }

  void _showWeeklyReportDetails(report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AnalyticsColors.backgroundPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AnalyticsColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reporte Semanal Detallado',
                        style: TextStyle(
                          color: AnalyticsColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        report.aiSummary,
                        style: const TextStyle(
                          color: AnalyticsColors.textSecondary,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      // Aquí se podrían agregar más detalles del reporte
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTrend(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return 'Mejorando';
      case 'stable':
        return 'Estable';
      case 'declining':
        return 'Declinando';
      default:
        return trend;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return AnalyticsColors.chartGradient3[0];
      case 'stable':
        return AnalyticsColors.chartGradient1[0];
      case 'declining':
        return AnalyticsColors.chartGradient2[0];
      default:
        return AnalyticsColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  // ============================================================================
  // MÉTODOS HELPER MEJORADOS CON DATOS REALES
  // ============================================================================

  List<Map<String, dynamic>> _getPeakPerformanceHours(OptimizedAnalyticsProvider analyticsProvider) {
    final moodData = analyticsProvider.getMoodChartData();

    if (moodData.isEmpty) {
      return [
        {
          'timeRange': 'Sin datos',
          'description': 'Registra más entradas para identificar patrones',
          'score': 0.0,
          'emoji': '📊',
        },
      ];
    }

    // Analizar datos por hora del día
    final hourlyStats = <int, List<double>>{};

    for (final entry in moodData) {
      final date = DateTime.parse(entry['date']);
      final hour = date.hour;
      final mood = (entry['mood'] as num).toDouble();

      hourlyStats.putIfAbsent(hour, () => []).add(mood);
    }

    // Calcular promedios por hora
    final hourlyAverages = hourlyStats.map((hour, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      return MapEntry(hour, avg);
    });

    // Identificar las mejores horas
    final sortedHours = hourlyAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final peakHours = <Map<String, dynamic>>[];

    // Tomar las 3 mejores horas si hay suficientes datos
    for (int i = 0; i < math.min(3, sortedHours.length); i++) {
      final hour = sortedHours[i].key;
      final score = sortedHours[i].value;

      String timeRange;
      String description;
      String emoji;

      if (hour >= 5 && hour < 12) {
        timeRange = '${hour}:00 - ${hour + 2}:00 AM';
        description = 'Mañana productiva';
        emoji = '🌅';
      } else if (hour >= 12 && hour < 17) {
        timeRange = '${hour}:00 - ${hour + 2}:00 PM';
        description = 'Tarde activa';
        emoji = '☀️';
      } else if (hour >= 17 && hour < 22) {
        timeRange = '${hour}:00 - ${hour + 2}:00 PM';
        description = 'Noche tranquila';
        emoji = '🌙';
      } else {
        timeRange = '${hour}:00 - ${hour + 2}:00';
        description = 'Horario nocturno';
        emoji = '🌃';
      }

      peakHours.add({
        'timeRange': timeRange,
        'description': description,
        'score': score.toStringAsFixed(1),
        'emoji': emoji,
      });
    }

    return peakHours.isNotEmpty ? peakHours : [
      {
        'timeRange': 'Analizando...',
        'description': 'Necesitas más datos para identificar patrones',
        'score': '0.0',
        'emoji': '📈',
      },
    ];
  }

  List<Map<String, dynamic>> _getMoodCorrelations(OptimizedAnalyticsProvider analyticsProvider) {
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final correlations = <Map<String, dynamic>>[];

    // 🛠️ FIX: Safe casting for mood, energy, and stress
    final mood = (wellbeingStatus['mood'] as num?)?.toDouble() ?? 5.0;
    final energy = (wellbeingStatus['energy'] as num?)?.toDouble() ?? 5.0;
    final stress = (wellbeingStatus['stress'] as num?)?.toDouble() ?? 5.0;

    // Correlación sueño-mood
    if (mood >= 7) {
      correlations.add({
        'emoji': '😴',
        'description': 'Tu buen estado de ánimo sugiere buena calidad de sueño',
        'strength': 0.8,
      });
    } else if (mood < 5) {
      correlations.add({
        'emoji': '😴',
        'description': 'Mejorar el sueño podría elevar tu estado de ánimo',
        'strength': 0.6,
      });
    }

    // Correlación ejercicio-energía
    if (energy >= 7) {
      correlations.add({
        'emoji': '🏃‍♀️',
        'description': 'Tu alta energía sugiere buena actividad física',
        'strength': 0.75,
      });
    } else {
      correlations.add({
        'emoji': '🏃‍♀️',
        'description': 'Más ejercicio podría aumentar tus niveles de energía',
        'strength': 0.5,
      });
    }

    // Correlación estrés-bienestar
    if (stress <= 3) {
      correlations.add({
        'emoji': '🧘',
        'description': 'Tu bajo estrés contribuye positivamente a tu bienestar',
        'strength': 0.85,
      });
    } else if (stress >= 7) {
      correlations.add({
        'emoji': '🧘',
        'description': 'Reducir el estrés es clave para mejorar tu bienestar',
        'strength': 0.9,
      });
    }

    return correlations;
  }

  Map<int, double> _getHourlyPatternData(OptimizedAnalyticsProvider analyticsProvider) {
    final moodData = analyticsProvider.getMoodChartData();
    final hourlyIntensity = <int, double>{};

    if (moodData.isEmpty) {
      // Retornar datos vacíos si no hay información
      for (int i = 0; i < 24; i++) {
        hourlyIntensity[i] = 0.0;
      }
      return hourlyIntensity;
    }

    // Contar entradas por hora
    final hourlyCounts = <int, int>{};
    for (final entry in moodData) {
      final date = DateTime.parse(entry['date']);
      final hour = date.hour;
      hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
    }

    // Normalizar a intensidad 0-1
    final maxCount = hourlyCounts.values.isEmpty ? 1 : hourlyCounts.values.reduce(math.max);

    for (int i = 0; i < 24; i++) {
      final count = hourlyCounts[i] ?? 0;
      hourlyIntensity[i] = count / maxCount;
    }

    return hourlyIntensity;
  }

  Map<String, dynamic> _getWellbeingPrediction(OptimizedAnalyticsProvider analyticsProvider) {
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final streakData = analyticsProvider.getStreakData();
    final summary = analyticsProvider.getDashboardSummary();

    // 🛠️ FIX: Safe casting for all numeric values
    final currentScore = (wellbeingStatus['score'] as num?)?.toInt() ?? 5;
    final currentStreak = (streakData['current'] as num?)?.toInt() ?? 0;
    final totalEntries = (summary['total_entries'] as num?)?.toInt() ?? 0;

    // Lógica de predicción mejorada basada en múltiples factores
    if (currentScore >= 8 && currentStreak >= 7) {
      return {
        'prediction': 'Excelente',
        'emoji': '🌟',
        'recommendation': 'Tu consistencia de $currentStreak días está dando frutos. Mantén estos hábitos positivos.',
      };
    } else if (currentScore >= 6 && currentStreak >= 3) {
      return {
        'prediction': 'En buen camino',
        'emoji': '📈',
        'recommendation': 'Con $currentStreak días de racha, estás construyendo buenos hábitos. Sigue así para ver mejoras.',
      };
    } else if (totalEntries < 5) {
      return {
        'prediction': 'Necesitas más datos',
        'emoji': '🌱',
        'recommendation': 'Con solo $totalEntries registros, necesitas más consistencia para predicciones precisas.',
      };
    } else {
      return {
        'prediction': 'Oportunidad de mejora',
        'emoji': '💪',
        'recommendation': 'Enfócate en la consistencia diaria. Pequeños pasos llevan a grandes cambios.',
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