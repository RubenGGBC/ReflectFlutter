// lib/presentation/screens/v2/analytics_screen_v2_upgraded.dart
// ============================================================================
// UPGRADED ANALYTICS SCREEN V2 - ENHANCED WITH CONSOLIDATED ANALYTICS SERVICE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// App Theme & Design System
import 'components/modern_design_system.dart';

// Providers
import '../../providers/optimized_providers.dart';

// Models
import '../../../data/models/analytics_models.dart';

// New Consolidated Analytics Service
import '../../../data/services/analytics_service.dart';
import '../../../data/services/optimized_database_service.dart';
import '../../../ai/services/predictive_analysis_service.dart';

// Dependency Injection
import '../../../injection_container_clean.dart' as clean_di;

class AnalyticsScreenV2Upgraded extends StatefulWidget {
  const AnalyticsScreenV2Upgraded({super.key});

  @override
  State<AnalyticsScreenV2Upgraded> createState() => _AnalyticsScreenV2UpgradedState();
}

class _AnalyticsScreenV2UpgradedState extends State<AnalyticsScreenV2Upgraded>
    with TickerProviderStateMixin {

  // Animation Controllers
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Data & State
  int _selectedPeriod = 30;
  final List<int> _periodOptions = [7, 30, 90];
  final List<String> _periodLabels = ['7 días', '30 días', '90 días'];

  // Analytics Data
  Map<String, dynamic> _completeAnalytics = {};
  Map<String, dynamic> _dashboardData = {};
  PrediccionEstadoAnimo? _moodPrediction;
  AnalisisTriggersAnsiedad? _anxietyAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  // Services
  late AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
    _loadAnalyticsData();
  }

  void _initializeServices() {
    final databaseService = clean_di.sl<OptimizedDatabaseService>();
    final predictiveService = clean_di.sl<PredictiveAnalysisService>();
    _analyticsService = AnalyticsService(
      databaseService: databaseService,
      predictiveService: predictiveService,
    );
  }

  void _setupAnimations() {
    _tabController = TabController(length: 5, vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadAnalyticsData() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _errorMessage = 'Usuario no autenticado';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load comprehensive analytics using the new service
      final analytics = await _analyticsService.loadCompleteAnalytics(
        user.id, 
        days: _selectedPeriod
      );

      // Load dashboard data
      final dashboard = await _analyticsService.getDashboardData(
        user.id, 
        days: _selectedPeriod
      );

      // Load specialized analytics
      final moodPrediction = await _analyticsService.predecirEstadoAnimoProximaSemana(user.id);
      final anxietyAnalysis = await _analyticsService.analizarTriggersAnsiedad(user.id);

      setState(() {
        _completeAnalytics = analytics;
        _dashboardData = dashboard;
        _moodPrediction = moodPrediction;
        _anxietyAnalysis = anxietyAnalysis;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando análisis: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics Avanzados'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildModernTabBar(theme),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(theme)
                      : _errorMessage != null
                          ? _buildErrorState(theme)
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOverviewTab(theme),
                                _buildAdvancedAnalyticsTab(theme),
                                _buildPredictiveTab(theme),
                                _buildPatternsTab(theme),
                                _buildInsightsTab(theme),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TAB BAR
  // ============================================================================
  Widget _buildModernTabBar(ThemeData theme) {
    return ModernTabBar(
      controller: _tabController,
      tabs: const [
        'Resumen',
        'Análisis',
        'Predicciones',
        'Patrones',
        'Insights',
      ],
    );
  }

  // ============================================================================
  // LOADING & ERROR STATES
  // ============================================================================
  Widget _buildLoadingState(ThemeData theme) {
    return const ModernLoadingIndicator(
      message: 'Cargando análisis avanzados...',
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return ModernErrorState(
      message: _errorMessage ?? 'Error desconocido',
      onRetry: _loadAnalyticsData,
    );
  }

  // ============================================================================
  // TAB CONTENT
  // ============================================================================
  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Column(
        children: [
          ModernSectionHeader(
            title: 'Resumen General',
            subtitle: 'Últimos $_selectedPeriod días',
            action: _buildPeriodSelector(theme),
          ),
          const SizedBox(height: ModernSpacing.md),
          _buildQuickStatsGrid(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildWellnessScoreCard(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildRecentInsights(theme),
        ],
      ),
    );
  }

  Widget _buildAdvancedAnalyticsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Column(
        children: [
          ModernSectionHeader(
            title: 'Análisis Avanzado',
            subtitle: 'Correlaciones y tendencias',
          ),
          const SizedBox(height: ModernSpacing.md),
          _buildCorrelationMatrix(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildTimeSeriesAnalysis(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildAnomaliesDetection(theme),
        ],
      ),
    );
  }

  Widget _buildPredictiveTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Column(
        children: [
          ModernSectionHeader(
            title: 'Análisis Predictivo',
            subtitle: 'Predicciones basadas en datos',
          ),
          const SizedBox(height: ModernSpacing.md),
          _buildMoodPredictionCard(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildBurnoutRiskCard(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildRecommendationsCard(theme),
        ],
      ),
    );
  }

  Widget _buildPatternsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Column(
        children: [
          ModernSectionHeader(
            title: 'Patrones de Comportamiento',
            subtitle: 'Tendencias identificadas',
          ),
          const SizedBox(height: ModernSpacing.md),
          _buildWeeklyPatterns(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildAnxietyTriggersCard(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildEmotionalPatterns(theme),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Column(
        children: [
          ModernSectionHeader(
            title: 'Insights Inteligentes',
            subtitle: 'Recomendaciones personalizadas',
          ),
          const SizedBox(height: ModernSpacing.md),
          _buildSmartInsights(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildActionableRecommendations(theme),
          const SizedBox(height: ModernSpacing.lg),
          _buildProgressTracking(theme),
        ],
      ),
    );
  }

  // ============================================================================
  // PERIOD SELECTOR
  // ============================================================================
  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedPeriod,
          items: List.generate(_periodOptions.length, (index) {
            return DropdownMenuItem(
              value: _periodOptions[index],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(_periodLabels[index]),
              ),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadAnalyticsData();
            }
          },
        ),
      ),
    );
  }

  // ============================================================================
  // QUICK STATS GRID
  // ============================================================================
  Widget _buildQuickStatsGrid(ThemeData theme) {
    final basicAnalytics = _completeAnalytics['basic_analytics'] as Map<String, dynamic>? ?? {};
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: ModernSpacing.md,
      mainAxisSpacing: ModernSpacing.md,
      childAspectRatio: 1.5,
      children: [
        ModernStatCard(
          title: 'Estado de Ánimo Promedio',
          value: '${(basicAnalytics['average_mood'] ?? 0.0).toStringAsFixed(1)}/10',
          subtitle: _getTrendDescription(basicAnalytics['mood_trend'] ?? 0.0),
          icon: Icons.mood,
          accentColor: theme.primaryColor,
        ),
        ModernStatCard(
          title: 'Nivel de Energía',
          value: '${(basicAnalytics['average_energy'] ?? 0.0).toStringAsFixed(1)}/10',
          subtitle: 'Promedio general',
          icon: Icons.battery_charging_full,
          accentColor: Colors.orange,
        ),
        ModernStatCard(
          title: 'Nivel de Estrés',
          value: '${(basicAnalytics['average_stress'] ?? 0.0).toStringAsFixed(1)}/10',
          subtitle: 'Promedio general',
          icon: Icons.trending_up,
          accentColor: Colors.red,
        ),
        ModernStatCard(
          title: 'Calidad de Sueño',
          value: '${(basicAnalytics['average_sleep'] ?? 0.0).toStringAsFixed(1)}/10',
          subtitle: 'Promedio general',
          icon: Icons.bedtime,
          accentColor: Colors.blue,
        ),
      ],
    );
  }

  // ============================================================================
  // WELLNESS SCORE CARD
  // ============================================================================
  Widget _buildWellnessScoreCard(ThemeData theme) {
    final wellnessScore = _dashboardData['wellness_score'] ?? 7.5;
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puntuación de Bienestar',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wellnessScore.toStringAsFixed(1)}/10',
                      style: ModernTypography.title1(context).copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ModernSpacing.xs),
                    Text(
                      _getWellnessDescription(wellnessScore),
                      style: ModernTypography.body2(context),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    _getWellnessIcon(wellnessScore),
                    size: 40,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PLACEHOLDER WIDGETS (TO BE IMPLEMENTED)
  // ============================================================================
  Widget _buildRecentInsights(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights Recientes',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Los insights aparecerán aquí basados en tu análisis de datos.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationMatrix(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matriz de Correlaciones',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Las correlaciones entre diferentes métricas aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesAnalysis(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis de Series Temporales',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Tendencias y patrones temporales aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesDetection(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detección de Anomalías',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Eventos inusuales en tus datos aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPredictionCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Predicción de Estado de Ánimo',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          if (_moodPrediction != null) ...[
            Text(
              'Predicción para la próxima semana: ${_moodPrediction!.estadoAnimoPredicto.toStringAsFixed(1)}/10',
              style: ModernTypography.body1(context),
            ),
            const SizedBox(height: ModernSpacing.sm),
            Text(
              'Confianza: ${(_moodPrediction!.confianza * 100).toStringAsFixed(0)}%',
              style: ModernTypography.body2(context),
            ),
          ] else
            Text(
              'Predicción de estado de ánimo aparecerá aquí.',
              style: ModernTypography.body2(context),
            ),
        ],
      ),
    );
  }

  Widget _buildBurnoutRiskCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riesgo de Burnout',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Análisis de riesgo de burnout aparecerá aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recomendaciones Personalizadas',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          if (_moodPrediction?.factoresInfluencia.isNotEmpty == true) ...[
            ...(_moodPrediction!.factoresInfluencia.take(3).map((factor) => 
              Padding(
                padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
                child: Text(
                  '• ${factor.nombre}',
                  style: ModernTypography.body2(context),
                ),
              )
            )),
          ] else
            Text(
              'Recomendaciones personalizadas aparecerán aquí.',
              style: ModernTypography.body2(context),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPatterns(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patrones Semanales',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Patrones de comportamiento semanal aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnxietyTriggersCard(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Triggers de Ansiedad',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          if (_anxietyAnalysis?.triggersDetectados.isNotEmpty == true) ...[
            ...(_anxietyAnalysis!.triggersDetectados.take(3).map((trigger) => 
              Padding(
                padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
                child: Text(
                  '• ${trigger.nombre}',
                  style: ModernTypography.body2(context),
                ),
              )
            )),
          ] else
            Text(
              'Análisis de triggers de ansiedad aparecerá aquí.',
              style: ModernTypography.body2(context),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionalPatterns(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patrones Emocionales',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Patrones emocionales identificados aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsights(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights Inteligentes',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Insights generados por IA aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableRecommendations(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recomendaciones Accionables',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Recomendaciones específicas y accionables aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracking(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seguimiento de Progreso',
            style: ModernTypography.title3(context),
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Métricas de progreso y logros aparecerán aquí.',
            style: ModernTypography.body2(context),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  String _getTrendDescription(double trend) {
    if (trend > 0.1) return 'Mejorando';
    if (trend < -0.1) return 'Declinando';
    return 'Estable';
  }

  String _getWellnessDescription(double score) {
    if (score >= 8.0) return 'Excelente bienestar';
    if (score >= 6.0) return 'Buen bienestar';
    if (score >= 4.0) return 'Bienestar moderado';
    return 'Necesita atención';
  }

  IconData _getWellnessIcon(double score) {
    if (score >= 8.0) return Icons.sentiment_very_satisfied;
    if (score >= 6.0) return Icons.sentiment_satisfied;
    if (score >= 4.0) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }
}