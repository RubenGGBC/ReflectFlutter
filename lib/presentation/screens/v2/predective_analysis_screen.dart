// lib/presentation/screens/v2/predective_analysis_screen.dart
// ============================================================================
// ENHANCED PREDICTIVE ANALYSIS SCREEN - IA ANALYTICS AVANZADOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// AI provider removed
import '../../providers/optimized_providers.dart';

// ============================================================================
// COLORES PARA ANALYTICS AVANZADOS
// ============================================================================
class AnalyticsColors {
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  static const List<Color> primaryGradient = [
    Color(0xFF1e3a8a), // Azul oscuro
    Color(0xFF581c87), // Morado oscuro
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6), // Azul
    Color(0xFF8b5cf6), // Morado
  ];

  static const List<Color> insightGradient = [
    Color(0xFF10b981), // Verde
    Color(0xFF3b82f6), // Azul
  ];

  static const List<Color> warningGradient = [
    Color(0xFFf59e0b), // Amarillo
    Color(0xFFef4444), // Rojo
  ];

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);

  static const Color positive = Color(0xFF10b981);
  static const Color neutral = Color(0xFFf59e0b);
  static const Color negative = Color(0xFFef4444);
}

class PredictiveAnalysisScreen extends StatefulWidget {
  const PredictiveAnalysisScreen({super.key});

  @override
  State<PredictiveAnalysisScreen> createState() => _PredictiveAnalysisScreenState();
}

class _PredictiveAnalysisScreenState extends State<PredictiveAnalysisScreen>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES DE ANIMACIÓN
  // ============================================================================
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Estados de inicialización
  bool _isInitializing = true;
  String _initializationStatus = 'Preparando análisis avanzado...';
  String? _initializationError;

  // Control de tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTabs();
    _startInitialization();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupTabs() {
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _startInitialization() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _initializeAndRunAnalysis();
      }
    });
  }

  Future<void> _initializeAndRunAnalysis() async {
    final auth = context.read<OptimizedAuthProvider>();

    if (auth.currentUser?.id == null) {
      setState(() {
        _initializationError = 'Usuario no autenticado';
        _isInitializing = false;
      });
      return;
    }

    try {
      setState(() {
        _initializationStatus = 'Verificando motor de IA...';
      });

      // The provider automatically checks AI status on creation.
      // We just wait a moment to make the UI feel responsive.
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isInitializing = false;
      });
      _animationController.forward();
      HapticFeedback.lightImpact();

    } catch (e) {
      setState(() {
        _initializationError = 'Error al inicializar: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnalyticsColors.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AnalyticsColors.backgroundPrimary,
              AnalyticsColors.backgroundSecondary,
            ],
          ),
        ),
        child: SafeArea(
          child: _isInitializing
              ? _buildInitializationView()
              : _buildAnalyticsView(),
        ),
      ),
    );
  }

  // ============================================================================
  // VISTA DE INICIALIZACIÓN
  // ============================================================================

  Widget _buildInitializationView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AnalyticsColors.primaryGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AnalyticsColors.primaryGradient[1].withOpacity(0.3 + (_pulseAnimation.value * 0.4)),
                      blurRadius: 20 + (_pulseAnimation.value * 10),
                      spreadRadius: 2 + (_pulseAnimation.value * 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            _initializationError ?? _initializationStatus,
            style: TextStyle(
              color: _initializationError != null
                  ? AnalyticsColors.negative
                  : AnalyticsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_initializationError == null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AnalyticsColors.accentGradient[1],
                ),
                backgroundColor: AnalyticsColors.backgroundSecondary,
              ),
            ),
          ],
          if (_initializationError != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isInitializing = true;
                  _initializationError = null;
                });
                _startInitialization();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AnalyticsColors.accentGradient[1],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================================
  // VISTA PRINCIPAL DE ANALYTICS
  // ============================================================================

  Widget _buildAnalyticsView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildInsightsTab(),
                  _buildCorrelationsTab(),
                  _buildForecastsTab(),
                  _buildPersonalityTab(),
                  _buildWeeklyReportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER Y NAVEGACIÓN
  // ============================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AnalyticsColors.textTertiary.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AnalyticsColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AnalyticsColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'IA Analytics',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Análisis Predictivo Avanzado',
                  style: TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Consumer<PredictiveAnalysisProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isLoading
                    ? null
                    : () => _refreshCurrentTab(),
                icon: AnimatedRotation(
                  turns: provider.isLoading ? 1 : 0,
                  duration: const Duration(seconds: 1),
                  child: Icon(
                    Icons.refresh,
                    color: provider.isLoading
                        ? AnalyticsColors.textTertiary
                        : AnalyticsColors.textPrimary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: AnalyticsColors.accentGradient),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AnalyticsColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Resumen'),
          Tab(text: 'Insights'),
          Tab(text: 'Correlaciones'),
          Tab(text: 'Forecasts'),
          Tab(text: 'Personalidad'),
          Tab(text: 'Reporte'),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: RESUMEN GENERAL
  // ============================================================================

  Widget _buildOverviewTab() {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalysisStatus(provider),
              const SizedBox(height: 20),
              _buildQuickStats(provider),
              const SizedBox(height: 20),
              _buildRecentInsights(provider),
              const SizedBox(height: 20),
              _buildActionItems(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalysisStatus(PredictiveAnalysisProvider provider) {
    final summary = provider.getAnalysisSummary();
    final overallStatus = summary['overall_status'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AnalyticsColors.backgroundCard,
            AnalyticsColors.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AnalyticsColors.insightGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
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
                summary['ai_insights']['available'] ? 'Disponibles' : 'No analizado',
                summary['ai_insights']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['ai_insights']['available'] ? AnalyticsColors.positive : AnalyticsColors.neutral,
              ),
              _buildStatusCard(
                'Correlaciones',
                summary['correlations']['available'] ? 'Analizadas' : 'No analizado',
                summary['correlations']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['correlations']['available'] ? AnalyticsColors.positive : AnalyticsColors.neutral,
              ),
              _buildStatusCard(
                'Forecasts',
                summary['forecasts']['available'] ? 'Generados' : 'No analizado',
                summary['forecasts']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['forecasts']['available'] ? AnalyticsColors.positive : AnalyticsColors.neutral,
              ),
              _buildStatusCard(
                'Personalidad',
                summary['personality']['available'] ? 'Analizada' : 'No analizado',
                summary['personality']['available'] ? Icons.check_circle : Icons.hourglass_empty,
                summary['personality']['available'] ? AnalyticsColors.positive : AnalyticsColors.neutral,
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

  Widget _buildQuickStats(PredictiveAnalysisProvider provider) {
    final summary = provider.getAnalysisSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas Rápidas',
          style: TextStyle(
            color: AnalyticsColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickStatCard(
                'Insights Generados',
                '${summary['ai_insights']['count'] ?? 0}',
                Icons.lightbulb,
                AnalyticsColors.insightGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                'Correlaciones',
                '${summary['correlations']['count'] ?? 0}',
                Icons.scatter_plot,
                AnalyticsColors.accentGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickStatCard(
                'Forecasts',
                '${summary['forecasts']['count'] ?? 0}d',
                Icons.trending_up,
                AnalyticsColors.primaryGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient[1].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInsights(PredictiveAnalysisProvider provider) {
    final insights = provider.aiInsights.take(3).toList();

    if (insights.isEmpty) {
      return _buildEmptyState(
        'Sin Insights Recientes',
        'Genera un análisis en la pestaña "Insights" para ver los resultados aquí.',
        Icons.psychology,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights Recientes',
          style: TextStyle(
            color: AnalyticsColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _buildInsightCard(insight, isCompact: true)),
      ],
    );
  }

  Widget _buildActionItems(PredictiveAnalysisProvider provider) {
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
          'color': AnalyticsColors.positive,
          'action': () => _tabController.animateTo(1),
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

    if (provider.hasWeeklyReport) {
      final growthScore = provider.weeklyReport?.overallGrowthScore ?? 0.0;
      actionItems.add({
        'title': 'Revisar reporte semanal',
        'description': 'Score de crecimiento: ${(growthScore * 100).toInt()}%',
        'icon': Icons.assessment,
        'color': AnalyticsColors.insightGradient[0],
        'action': () => _tabController.animateTo(5),
      });
    }

    if (actionItems.isEmpty) {
      return _buildEmptyState(
        'Sin Acciones Recomendadas',
        'Las recomendaciones aparecerán aquí después de ejecutar los análisis.',
        Icons.pending_actions,
      );
    }

    return Column(
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
        const SizedBox(height: 12),
        ...actionItems.map((item) => _buildActionItemCard(item)),
      ],
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
              color: AnalyticsColors.backgroundCard,
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
  // TAB 2: INSIGHTS IA
  // ============================================================================

  Widget _buildInsightsTab() {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isGeneratingInsights) {
          return _buildLoadingState('Generando insights automáticos...');
        }

        if (provider.insightsError != null) {
          return _buildErrorState(
            'Error generando insights',
            provider.insightsError!,
                () => _refreshInsights(),
          );
        }

        if (!provider.hasAIInsights) {
          return _buildAnalysisPrompt(
            title: 'Generar Insights IA',
            description: 'La IA analizará tus datos recientes para encontrar patrones, tendencias y recomendaciones personalizadas.',
            icon: Icons.lightbulb_outline,
            onAnalyze: () => _refreshInsights(),
            isLoading: provider.isGeneratingInsights,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsightsHeader(provider),
              const SizedBox(height: 20),
              ...provider.aiInsights.map((insight) => _buildInsightCard(insight)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsHeader(PredictiveAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AnalyticsColors.insightGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insights Automáticos IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.aiInsights.length} insights generados • Última actualización: ${_formatLastGeneration(provider.lastInsightsGeneration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(SmartInsight insight, {bool isCompact = false}) {
    final categoryColor = _getCategoryColor(insight.category);
    final categoryIcon = _getCategoryIcon(insight.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.1),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        color: AnalyticsColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            insight.category.toUpperCase(),
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildConfidenceIndicator(insight.confidence),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            insight.description,
            style: const TextStyle(
              color: AnalyticsColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (!isCompact && insight.actionableAdvice.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: categoryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: categoryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recomendación',
                          style: TextStyle(
                            color: AnalyticsColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.actionableAdvice,
                          style: const TextStyle(
                            color: AnalyticsColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  Widget _buildConfidenceIndicator(double confidence) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt,
          color: AnalyticsColors.textTertiary,
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(
          '${(confidence * 100).toInt()}%',
          style: const TextStyle(
            color: AnalyticsColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 3: CORRELACIONES
  // ============================================================================

  Widget _buildCorrelationsTab() {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isAnalyzingCorrelations) {
          return _buildLoadingState('Analizando correlaciones...');
        }

        if (provider.correlationsError != null) {
          return _buildErrorState(
            'Error analizando correlaciones',
            provider.correlationsError!,
                () => _refreshCorrelations(),
          );
        }

        if (!provider.hasCorrelations) {
          return _buildAnalysisPrompt(
            title: 'Analizar Correlaciones',
            description: 'Descubre cómo diferentes aspectos de tu vida, como el sueño y el ejercicio, se relacionan con tu estado de ánimo y energía.',
            icon: Icons.scatter_plot,
            onAnalyze: () => _refreshCorrelations(),
            isLoading: provider.isAnalyzingCorrelations,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCorrelationsHeader(provider),
              const SizedBox(height: 20),
              ...provider.emotionalCorrelations.map((correlation) =>
                  _buildCorrelationCard(correlation)
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCorrelationsHeader(PredictiveAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AnalyticsColors.accentGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.scatter_plot,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correlaciones Emocionales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${provider.emotionalCorrelations.length} correlaciones significativas detectadas',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard(EmotionalCorrelation correlation) {
    final strengthColor = _getCorrelationColor(correlation.correlationStrength);
    final isPositive = correlation.correlationStrength > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: strengthColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: strengthColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: strengthColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${correlation.factor1} ↔ ${correlation.factor2}',
                      style: const TextStyle(
                        color: AnalyticsColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Correlación: ${isPositive ? "+" : ""}${(correlation.correlationStrength * 100).toInt()}%',
                      style: TextStyle(
                        color: strengthColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            correlation.description,
            style: const TextStyle(
              color: AnalyticsColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (correlation.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Ejemplos observados:',
              style: TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...correlation.examples.map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: strengthColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      example,
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          if (correlation.recommendation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: strengthColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: strengthColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      correlation.recommendation,
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
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

  // ============================================================================
  // TAB 4: FORECASTS
  // ============================================================================

  Widget _buildForecastsTab() {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isGeneratingForecasts) {
          return _buildLoadingState('Generando forecasts de mood...');
        }

        if (provider.forecastsError != null) {
          return _buildErrorState(
            'Error generando forecasts',
            provider.forecastsError!,
                () => _refreshForecasts(),
          );
        }

        if (!provider.hasForecasts) {
          return _buildAnalysisPrompt(
            title: 'Generar Forecasts',
            description: 'Obtén una predicción de tu estado de ánimo, energía y estrés para los próximos días, basada en tus patrones históricos.',
            icon: Icons.trending_up,
            onAnalyze: () => _refreshForecasts(),
            isLoading: provider.isGeneratingForecasts,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForecastsHeader(provider),
              const SizedBox(height: 20),
              _buildForecastsChart(provider),
              const SizedBox(height: 20),
              ...provider.moodForecasts.map((forecast) =>
                  _buildForecastCard(forecast)
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForecastsHeader(PredictiveAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AnalyticsColors.primaryGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forecasts de Mood',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Predicciones para los próximos ${provider.moodForecasts.length} días',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastsChart(PredictiveAnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia Predicha',
            style: TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: provider.moodForecasts.asMap().entries.map((entry) {
                final forecast = entry.value;
                final height = (forecast.predictedMoodScore / 10) * 80;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: AnalyticsColors.accentGradient,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatForecastDate(forecast.date),
                          style: const TextStyle(
                            color: AnalyticsColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(MoodForecast forecast) {
    final moodColor = _getMoodColor(forecast.predictedMoodScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: moodColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moodColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: moodColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatFullForecastDate(forecast.date),
                      style: const TextStyle(
                        color: AnalyticsColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confianza: ${(forecast.confidence * 100).toInt()}%',
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildForecastMetric(
                  'Mood',
                  forecast.predictedMoodScore,
                  Icons.sentiment_satisfied,
                  AnalyticsColors.positive,
                ),
              ),
              Expanded(
                child: _buildForecastMetric(
                  'Energía',
                  forecast.predictedEnergyLevel,
                  Icons.battery_charging_full,
                  AnalyticsColors.accentGradient[1],
                ),
              ),
              Expanded(
                child: _buildForecastMetric(
                  'Estrés',
                  forecast.predictedStressLevel,
                  Icons.warning,
                  AnalyticsColors.negative,
                ),
              ),
            ],
          ),

          if (forecast.influences.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Factores influyentes:',
              style: TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: forecast.influences.map((influence) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AnalyticsColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  influence,
                  style: const TextStyle(
                    color: AnalyticsColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              )).toList(),
            ),
          ],

          if (forecast.recommendation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: moodColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.recommend,
                    color: moodColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      forecast.recommendation,
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
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

  Widget _buildForecastMetric(String label, double value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AnalyticsColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 5: PERSONALIDAD EMOCIONAL
  // ============================================================================

  Widget _buildPersonalityTab() {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isAnalyzingPersonality) {
          return _buildLoadingState('Analizando personalidad emocional...');
        }

        if (provider.personalityError != null) {
          return _buildErrorState(
            'Error analizando personalidad',
            provider.personalityError!,
                () => _refreshPersonality(),
          );
        }

        if (!provider.hasPersonalityProfile) {
          return _buildAnalysisPrompt(
            title: 'Analizar Personalidad Emocional',
            description: 'Obtén un perfil detallado de tus rasgos emocionales, fortalezas y áreas de crecimiento basadas en tus patrones a largo plazo.',
            icon: Icons.psychology,
            onAnalyze: () => _refreshPersonality(),
            isLoading: provider.isAnalyzingPersonality,
          );
        }

        final profile = provider.personalityProfile!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalityHeader(profile),
              const SizedBox(height: 20),
              _buildEmotionalTraits(profile),
              const SizedBox(height: 20),
              _buildPersonalityInsights(profile),
              const SizedBox(height: 20),
              _buildGrowthAreas(profile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalityHeader(EmotionalPersonalityProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AnalyticsColors.insightGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Personalidad Emocional',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.dominantEmotionalPattern,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.personalityDescription,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalTraits(EmotionalPersonalityProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rasgos Emocionales',
            style: TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...profile.emotionalTraits.entries.map((entry) {
            return _buildTraitBar(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildTraitBar(String trait, double value) {
    final percentage = (value * 100).toInt();
    final color = _getTraitColor(value);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTraitName(trait),
                style: const TextStyle(
                  color: AnalyticsColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AnalyticsColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityInsights(EmotionalPersonalityProfile profile) {
    return Row(
      children: [
        Expanded(
          child: _buildInsightsList(
            'Fortalezas',
            profile.strengthAreas,
            AnalyticsColors.positive,
            Icons.star,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInsightsList(
            'Áreas de Crecimiento',
            profile.growthAreas,
            AnalyticsColors.accentGradient[1],
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsList(String title, List<String> items, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: AnalyticsColors.textSecondary,
                      fontSize: 12,
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

  Widget _buildGrowthAreas(EmotionalPersonalityProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AnalyticsColors.backgroundCard,
            AnalyticsColors.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AnalyticsColors.accentGradient[0],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Recomendaciones de Desarrollo',
                style: TextStyle(
                  color: AnalyticsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Basándome en tu perfil emocional, estas son algunas áreas donde podrías enfocar tu crecimiento personal:',
            style: TextStyle(
              color: AnalyticsColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...profile.growthAreas.asMap().entries.map((entry) {
            final index = entry.key;
            final area = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AnalyticsColors.accentGradient[1].withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AnalyticsColors.accentGradient[1].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AnalyticsColors.accentGradient[1],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      area,
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 6: REPORTE SEMANAL
  // ============================================================================

  Widget _buildWeeklyReportTab() {
    return Consumer<PredictiveAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isGeneratingWeeklyReport) {
          return _buildLoadingState('Generando reporte semanal...');
        }

        if (provider.weeklyReportError != null) {
          return _buildErrorState(
            'Error generando reporte',
            provider.weeklyReportError!,
                () => _refreshWeeklyReport(),
          );
        }

        if (!provider.hasWeeklyReport) {
          return _buildAnalysisPrompt(
            title: 'Generar Reporte Semanal',
            description: 'Obtén un resumen inteligente de tu semana, incluyendo métricas clave, score de crecimiento y recomendaciones personalizadas.',
            icon: Icons.assessment,
            onAnalyze: () => _refreshWeeklyReport(),
            isLoading: provider.isGeneratingWeeklyReport,
          );
        }

        final report = provider.weeklyReport!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeeklyReportHeader(report),
              const SizedBox(height: 20),
              _buildWeeklyGrowthScore(report),
              const SizedBox(height: 20),
              _buildWeeklyInsights(report),
              const SizedBox(height: 20),
              _buildWeeklyRecommendations(report),
              const SizedBox(height: 20),
              _buildComparativeAnalysis(report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyReportHeader(WeeklyIntelligenceReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AnalyticsColors.primaryGradient),
        borderRadius: BorderRadius.circular(16),
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
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.aiSummary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGrowthScore(WeeklyIntelligenceReport report) {
    final score = (report.overallGrowthScore * 100).toInt();
    final scoreColor = _getScoreColor(report.overallGrowthScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: scoreColor,
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                '$score%',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Score de Crecimiento Semanal',
                  style: TextStyle(
                    color: AnalyticsColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tendencia: ${_formatTrend(report.weeklyTrend)}',
                  style: TextStyle(
                    color: _getTrendColor(report.weeklyTrend),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Basado en consistencia, mejoras y logros alcanzados',
                  style: TextStyle(
                    color: AnalyticsColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsights(WeeklyIntelligenceReport report) {
    if (report.keyInsights.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights Clave de la Semana',
          style: TextStyle(
            color: AnalyticsColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...report.keyInsights.map((insight) => _buildInsightCard(insight, isCompact: true)),
      ],
    );
  }

  Widget _buildWeeklyRecommendations(WeeklyIntelligenceReport report) {
    if (report.personalizedRecommendations.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AnalyticsColors.backgroundCard,
            AnalyticsColors.backgroundSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.insightGradient[0].withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: AnalyticsColors.insightGradient[0],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Recomendaciones Personalizadas',
                style: TextStyle(
                  color: AnalyticsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...report.personalizedRecommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AnalyticsColors.insightGradient[0].withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AnalyticsColors.insightGradient[0].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AnalyticsColors.insightGradient[0],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparativeAnalysis(WeeklyIntelligenceReport report) {
    if (report.comparativeAnalysis.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnalyticsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AnalyticsColors.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: AnalyticsColors.accentGradient[0],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Análisis Comparativo',
                style: TextStyle(
                  color: AnalyticsColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...report.comparativeAnalysis.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
                  const SizedBox(width: 12),
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(
                      color: AnalyticsColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: AnalyticsColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // ESTADOS DE CARGA, ERROR Y PROMPTS
  // ============================================================================

  Widget _buildAnalysisPrompt({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onAnalyze,
    required bool isLoading,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AnalyticsColors.textTertiary.withOpacity(0.3),
                ),
              ),
              child: Icon(
                icon,
                color: AnalyticsColors.accentGradient[1],
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 18,
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
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: AnalyticsColors.accentGradient[1],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.psychology, color: Colors.white),
              label: Text(
                isLoading ? 'Analizando...' : 'Ejecutar Análisis',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AnalyticsColors.accentGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AnalyticsColors.accentGradient[1].withOpacity(0.3 + (_pulseAnimation.value * 0.3)),
                      blurRadius: 20 + (_pulseAnimation.value * 10),
                      spreadRadius: 2 + (_pulseAnimation.value * 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 30,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: AnalyticsColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AnalyticsColors.accentGradient[1],
              ),
              backgroundColor: AnalyticsColors.backgroundSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String title, String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnalyticsColors.negative.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AnalyticsColors.negative,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: AnalyticsColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AnalyticsColors.accentGradient[1],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String description, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AnalyticsColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AnalyticsColors.textTertiary.withOpacity(0.3),
                ),
              ),
              child: Icon(
                icon,
                color: AnalyticsColors.textTertiary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AnalyticsColors.textPrimary,
                fontSize: 18,
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
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE REFRESH
  // ============================================================================

  Future<void> _refreshCurrentTab() async {
    switch (_tabController.index) {
      case 1:
        await _refreshInsights();
        break;
      case 2:
        await _refreshCorrelations();
        break;
      case 3:
        await _refreshForecasts();
        break;
      case 4:
        await _refreshPersonality();
        break;
      case 5:
        await _refreshWeeklyReport();
        break;
      default:
        break;
    }
  }

  Future<void> _refreshInsights() async {
    final auth = context.read<OptimizedAuthProvider>();
    final predictive = context.read<PredictiveAnalysisProvider>();

    if (auth.currentUser?.id != null) {
      await predictive.generateAIInsights(
        userId: auth.currentUser!.id,
        forceRegenerate: true,
      );
    }
  }

  Future<void> _refreshCorrelations() async {
    final auth = context.read<OptimizedAuthProvider>();
    final predictive = context.read<PredictiveAnalysisProvider>();

    if (auth.currentUser?.id != null) {
      await predictive.analyzeEmotionalCorrelations(
        userId: auth.currentUser!.id,
      );
    }
  }

  Future<void> _refreshForecasts() async {
    final auth = context.read<OptimizedAuthProvider>();
    final predictive = context.read<PredictiveAnalysisProvider>();

    if (auth.currentUser?.id != null) {
      await predictive.generateAdvancedMoodForecasts(
        userId: auth.currentUser!.id,
      );
    }
  }

  Future<void> _refreshPersonality() async {
    final auth = context.read<OptimizedAuthProvider>();
    final predictive = context.read<PredictiveAnalysisProvider>();

    if (auth.currentUser?.id != null) {
      await predictive.analyzeEmotionalPersonality(
        userId: auth.currentUser!.id,
      );
    }
  }

  Future<void> _refreshWeeklyReport() async {
    final auth = context.read<OptimizedAuthProvider>();
    final predictive = context.read<PredictiveAnalysisProvider>();

    if (auth.currentUser?.id != null) {
      await predictive.generateWeeklyIntelligenceReport(
        userId: auth.currentUser!.id,
      );
    }
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD PARA FORMATEO Y COLORES
  // ============================================================================

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'pattern':
        return AnalyticsColors.accentGradient[1];
      case 'prediction':
        return AnalyticsColors.primaryGradient[1];
      case 'recommendation':
        return AnalyticsColors.insightGradient[0];
      case 'alert':
        return AnalyticsColors.negative;
      default:
        return AnalyticsColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pattern':
        return Icons.trending_up;
      case 'prediction':
        return Icons.online_prediction;
      case 'recommendation':
        return Icons.lightbulb;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  Color _getCorrelationColor(double strength) {
    final absStrength = strength.abs();
    if (absStrength > 0.7) {
      return strength > 0 ? AnalyticsColors.positive : AnalyticsColors.negative;
    } else if (absStrength > 0.4) {
      return AnalyticsColors.neutral;
    } else {
      return AnalyticsColors.textTertiary;
    }
  }

  Color _getMoodColor(double moodScore) {
    if (moodScore >= 7) {
      return AnalyticsColors.positive;
    } else if (moodScore >= 4) {
      return AnalyticsColors.neutral;
    } else {
      return AnalyticsColors.negative;
    }
  }

  Color _getTraitColor(double value) {
    if (value >= 0.8) {
      return AnalyticsColors.positive;
    } else if (value >= 0.6) {
      return AnalyticsColors.accentGradient[1];
    } else if (value >= 0.4) {
      return AnalyticsColors.neutral;
    } else {
      return AnalyticsColors.negative;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) {
      return AnalyticsColors.positive;
    } else if (score >= 0.6) {
      return AnalyticsColors.accentGradient[1];
    } else if (score >= 0.4) {
      return AnalyticsColors.neutral;
    } else {
      return AnalyticsColors.negative;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return AnalyticsColors.positive;
      case 'stable':
        return AnalyticsColors.neutral;
      case 'declining':
        return AnalyticsColors.negative;
      default:
        return AnalyticsColors.textSecondary;
    }
  }

  String _formatTraitName(String trait) {
    return trait.split('_').map((word) =>
    word[0].toUpperCase() + word.substring(1)
    ).join(' ');
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

  String _formatLastGeneration(DateTime? date) {
    if (date == null) return 'Nunca';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'hace unos segundos';
    }
  }

  String _formatForecastDate(DateTime date) {
    final weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return weekdays[date.weekday - 1];
  }

  String _formatFullForecastDate(DateTime date) {
    final weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }
}
