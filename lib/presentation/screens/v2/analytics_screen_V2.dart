// lib/presentation/screens/v2/analytics_screen_v2.dart
// ============================================================================
// ANALYTICS SCREEN V2 - ADVANCED EMOTIONAL ANALYSIS WITH MODERN UI
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// App Theme
import '../../../core/themes/app_theme.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/advanced_emotion_analysis_provider.dart';

// Modern Design System
import 'components/modern_design_system.dart';

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
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _selectedPeriod = 30;
  final List<int> _periodOptions = [7, 30, 90];
  final List<String> _periodLabels = ['7 días', '30 días', '90 días'];

  // Análisis emocional avanzado
  Map<String, dynamic> _emotionalAnalysis = {};
  Map<String, dynamic> _correlationAnalysis = {};
  Map<String, dynamic> _patternAnalysis = {};
  Map<String, dynamic> _advancedAnalysisResults = {};
  bool _isAnalysisLoading = false;
  bool _isAdvancedAnalysisLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _setupAnimations() {
    _tabController = TabController(length: 7, vsync: this);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _loadInitialData() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final advancedAnalysisProvider = Provider.of<AdvancedEmotionAnalysisProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      setState(() {
        _isAnalysisLoading = true;
        _isAdvancedAnalysisLoading = true;
      });
      
      await analyticsProvider.loadCompleteAnalytics(user.id, days: _selectedPeriod);
      
      // Realizar análisis emocional básico
      await _performEmotionalAnalysis(user.id);
      
      // Realizar análisis emocional avanzado
      await _performAdvancedEmotionalAnalysis(user.id, advancedAnalysisProvider);
      
      setState(() {
        _isAnalysisLoading = false;
        _isAdvancedAnalysisLoading = false;
      });
    }
  }

  Future<void> _performEmotionalAnalysis(int userId) async {
    try {
      // Aquí irían las llamadas a los métodos de análisis emocional básico
      await Future.delayed(const Duration(milliseconds: 500)); // Simular procesamiento
      
      setState(() {
        _emotionalAnalysis = _generateEmotionalAnalysis();
        _correlationAnalysis = _generateCorrelationAnalysis();
        _patternAnalysis = _generatePatternAnalysis();
      });
    } catch (e) {
      print('Error en análisis emocional: $e');
    }
  }

  Future<void> _performAdvancedEmotionalAnalysis(int userId, AdvancedEmotionAnalysisProvider provider) async {
    try {
      // Ejecutar todos los análisis avanzados individuales
      final results = <String, dynamic>{};
      
      // 1. Análisis completo integrado
      final completeAnalysis = await provider.performCompleteAdvancedAnalysis(userId);
      results.addAll(completeAnalysis);
      
      // 2. Clustering jerárquico avanzado
      final hierarchicalClustering = await provider.performHierarchicalEmotionalClustering(userId);
      results['hierarchical_clustering'] = hierarchicalClustering;
      
      // 3. Análisis espectral avanzado
      final spectralAnalysis = await provider.performSpectralAnalysis(userId);
      results['spectral_analysis'] = spectralAnalysis;
      
      // 4. Predicción ensemble
      final ensemblePrediction = await provider.performEnsemblePrediction(userId);
      results['ensemble_prediction'] = ensemblePrediction;
      
      // 5. Predicción Random Forest
      final randomForestPrediction = await provider.performRandomForestEmotionalPrediction(userId);
      results['random_forest_prediction'] = randomForestPrediction;
      
      // 6. Descomposición de Series Temporales
      final timeSeriesDecomposition = await provider.performTimeSeriesDecomposition(userId);
      results['time_series_decomposition'] = timeSeriesDecomposition;
      
      // 7. Detección Avanzada de Anomalías
      final anomalyDetection = await provider.performAdvancedAnomalyDetection(userId);
      results['anomaly_detection'] = anomalyDetection;
      
      setState(() {
        _advancedAnalysisResults = results;
      });
    } catch (e) {
      print('Error en análisis emocional avanzado: $e');
      setState(() {
        _advancedAnalysisResults = {'error': e.toString()};
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();

    return Scaffold(
      backgroundColor: appColors?.primaryBg ?? theme.colorScheme.surface,
      body: SafeArea(
        child: Consumer2<AnalyticsProvider, AdvancedEmotionAnalysisProvider>(
          builder: (context, analyticsProvider, advancedProvider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildModernHeaderWithGradient(appColors, theme),
                    const SizedBox(height: 20),
                    _buildEnhancedTabBar(appColors, theme),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(analyticsProvider, appColors, theme),
                          _buildEmotionalAnalysisTab(analyticsProvider, advancedProvider, appColors, theme),
                          _buildMoodTrackingTab(analyticsProvider, appColors, theme),
                          _buildCorrelationsTab(analyticsProvider, advancedProvider, appColors, theme),
                          _buildPatternsTab(analyticsProvider, advancedProvider, appColors, theme),
                          _buildInsightsTab(analyticsProvider, advancedProvider, appColors, theme),
                          _buildVisualizationsTab(analyticsProvider, advancedProvider, appColors, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================================
  // MODERN HEADER WITH GRADIENT AND ANIMATIONS
  // ============================================================================
  Widget _buildModernHeaderWithGradient(AppColors? appColors, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: appColors?.gradientHeader ?? [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.6),
                  theme.colorScheme.tertiary.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (appColors?.accentPrimary ?? theme.colorScheme.primary).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseAnimation.value * 0.1),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis Emocional',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comprende tus patrones emocionales',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildEnhancedPeriodSelector(appColors, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPeriodSelector(AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedPeriod,
          dropdownColor: appColors?.surface ?? theme.colorScheme.surface,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadInitialData();
            }
          },
          items: List.generate(_periodOptions.length, (index) {
            return DropdownMenuItem(
              value: _periodOptions[index],
              child: Text(_periodLabels[index]),
            );
          }),
        ),
      ),
    );
  }

  // ============================================================================
  // ENHANCED TAB BAR WITH ANIMATIONS
  // ============================================================================
  Widget _buildEnhancedTabBar(AppColors? appColors, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (appColors?.surface ?? theme.colorScheme.surface).withOpacity(0.9),
            (appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: appColors?.borderColor ?? theme.colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (appColors?.shadowColor ?? theme.colorScheme.shadow).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: appColors?.accentPrimary ?? theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: appColors?.accentPrimary ?? theme.colorScheme.primary,
        unselectedLabelColor: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: theme.textTheme.titleSmall,
        tabs: const [
          Tab(text: 'Resumen', icon: Icon(Icons.dashboard_outlined, size: 20)),
          Tab(text: 'Emociones', icon: Icon(Icons.psychology_outlined, size: 20)),
          Tab(text: 'Mood Tracking', icon: Icon(Icons.show_chart_outlined, size: 20)),
          Tab(text: 'Correlaciones', icon: Icon(Icons.hub_outlined, size: 20)),
          Tab(text: 'Patrones', icon: Icon(Icons.pattern_outlined, size: 20)),
          Tab(text: 'Insights', icon: Icon(Icons.lightbulb_outline, size: 20)),
          Tab(text: 'Visuales', icon: Icon(Icons.bar_chart_outlined, size: 20)),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB CONTENT - OVERVIEW
  // ============================================================================
  Widget _buildOverviewTab(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final streakData = analyticsProvider.getStreakData();
    final dashboardSummary = analyticsProvider.getDashboardSummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Bienestar',
                  '${wellbeingStatus['score']}/10',
                  wellbeingStatus['emoji'],
                  wellbeingStatus['color'],
                  appColors,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Racha Actual',
                  '${streakData['current']} días',
                  '🔥',
                  Colors.orange,
                  appColors,
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Entradas',
                  '${dashboardSummary['total_entries']}',
                  '📝',
                  Colors.blue,
                  appColors,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Consistencia',
                  '${(dashboardSummary['consistency_rate'] * 100).round()}%',
                  '🎯',
                  Colors.green,
                  appColors,
                  theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Insights
          _buildQuickInsights(analyticsProvider, appColors, theme),

          const SizedBox(height: 24),

          // Recent Recommendations
          _buildRecommendations(analyticsProvider, appColors, theme),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color color, AppColors? appColors, ThemeData theme) {
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
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
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

  Widget _buildQuickInsights(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final insights = analyticsProvider.getHighlightedInsights();

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
          Text(
            'Insights Destacados',
            style: theme.textTheme.titleLarge?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(insight['emoji'] ?? '✨', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        insight['description'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendations(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final recommendations = analyticsProvider.getTopRecommendations();

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
          Text(
            'Recomendaciones',
            style: theme.textTheme.titleLarge?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(rec['emoji'] ?? '💡', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec['title'] ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        rec['description'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB CONTENT - ADVANCED PATTERNS
  // ============================================================================
  Widget _buildAdvancedPatternsTab(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patrones de Comportamiento',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Wellbeing Patterns
          _buildWellbeingPatternsCard(analyticsProvider, appColors, theme),
          
          const SizedBox(height: 20),

          // Behavioral Insights
          _buildBehavioralInsightsCard(analyticsProvider, appColors, theme),

          const SizedBox(height: 20),

          // Trend Analysis
          _buildTrendAnalysisCard(analyticsProvider, appColors, theme),
        ],
      ),
    );
  }

  Widget _buildWellbeingPatternsCard(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final moodData = analyticsProvider.getMoodChartData();
    final streakData = analyticsProvider.getStreakData();

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
              Icon(
                Icons.trending_up_outlined,
                color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Patrones de Bienestar',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Wellbeing Score Circle
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: appColors?.gradientButton ?? [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${wellbeingStatus['score']}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  wellbeingStatus['level'] ?? 'Evaluando',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pattern Components
          _buildPatternComponent('Consistencia', streakData['current'], 30, '🎯', appColors, theme),
          const SizedBox(height: 12),
          _buildPatternComponent('Estabilidad', (moodData.isNotEmpty ? _calculateStability(moodData) : 0), 10, '⚖️', appColors, theme),
          const SizedBox(height: 12),
          _buildPatternComponent('Progreso', (wellbeingStatus['score'] as num?)?.round() ?? 0, 10, '📈', appColors, theme),
        ],
      ),
    );
  }

  Widget _buildBehavioralInsightsCard(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final insights = analyticsProvider.getHighlightedInsights();
    final themes = analyticsProvider.getDominantThemes();

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
              Icon(
                Icons.lightbulb_outline,
                color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Insights de Comportamiento',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (insights.isEmpty)
            _buildEmptyState('Generando insights...', Icons.psychology, appColors, theme)
          else
            ...insights.map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(insight['emoji'] ?? '✨', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight['title'] ?? '',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          insight['description'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
            
          if (themes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Temas Dominantes',
              style: theme.textTheme.titleMedium?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: themes.take(5).map((themeData) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: appColors?.accentPrimary.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: appColors?.accentPrimary ?? Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(themeData['emoji'] ?? '🔖', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      themeData['word'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${themeData['count']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendAnalysisCard(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final moodData = analyticsProvider.getMoodChartData();
    final stressAlerts = analyticsProvider.getStressAlerts();
    final dashboardSummary = analyticsProvider.getDashboardSummary();

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
              Icon(
                Icons.auto_graph,
                color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Análisis de Tendencias',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Trend Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de Tendencias',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dashboardSummary['main_message'] ?? 'Analizando patrones...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTrendIndicator('Bienestar', dashboardSummary['improvement_trend'] ?? 'stable', appColors, theme),
                    const SizedBox(width: 16),
                    _buildTrendIndicator('Estrés', stressAlerts['level'] ?? 'bajo', appColors, theme),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mood Variability
          if (moodData.isNotEmpty) _buildMoodVariabilitySection(moodData, appColors, theme),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB CONTENT - PREDICTIVE
  // ============================================================================
  Widget _buildPredictiveTab(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis Predictivo',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildMoodPredictionCard(analyticsProvider, appColors, theme),
        ],
      ),
    );
  }

  Widget _buildMoodPredictionCard(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final moodData = analyticsProvider.getMoodChartData();
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final currentAnalysis = analyticsProvider.getCurrentDayAnalysis();

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
              Icon(
                Icons.trending_up,
                color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Proyección de Bienestar',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado Actual',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentAnalysis['message'] ?? 'Analizar datos...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Recomendación: ${currentAnalysis['recommendation'] ?? 'Continúa registrando'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Trend Chart Placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gráfico de Tendencias',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB CONTENT - INSIGHTS
  // ============================================================================
  Widget _buildInsightsTab(AnalyticsProvider analyticsProvider, AdvancedEmotionAnalysisProvider advancedProvider, AppColors? appColors, ThemeData theme) {
    final insights = analyticsProvider.getHighlightedInsights();
    final recommendations = analyticsProvider.getTopRecommendations();
    final nextAchievement = analyticsProvider.getNextAchievementToUnlock();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights Detallados',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Next Achievement
          if (nextAchievement != null) ...[
            _buildNextAchievementCard(nextAchievement, appColors, theme),
            const SizedBox(height: 16),
          ],

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            _buildRecommendationsSection(recommendations, appColors, theme),
            const SizedBox(height: 16),
          ],

          // Advanced Prediction Analysis
          if (_advancedAnalysisResults.isNotEmpty) ...[
            ModernSectionHeader(
              title: 'Predicciones Avanzadas',
              subtitle: 'Análisis predictivo mediante Machine Learning',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildEnsemblePredictionCard(advancedProvider, appColors, theme),
            const SizedBox(height: ModernSpacing.md),
            _buildRandomForestPredictionCard(advancedProvider, appColors, theme),
            const SizedBox(height: ModernSpacing.lg),
            
            _buildTimeSeriesDecompositionCard(advancedProvider, appColors, theme),
            const SizedBox(height: ModernSpacing.lg),
            
            _buildAnomalyDetectionCard(advancedProvider, appColors, theme),
            const SizedBox(height: ModernSpacing.lg),
          ],

          // ============================================================================
          // NEW: USER PROGRESSION ANALYTICS
          // ============================================================================
          
          // Streak Analysis
          _buildStreakAnalysisCard(appColors, theme),
          const SizedBox(height: ModernSpacing.lg),
          
          // Wellbeing Prediction
          _buildWellbeingPredictionCard(appColors, theme),
          const SizedBox(height: ModernSpacing.lg),
          
          // Healthy Habits Analysis
          _buildHealthyHabitsCard(appColors, theme),
          const SizedBox(height: ModernSpacing.lg),
          
          // Emotional Patterns
          _buildEmotionalPatternsCard(appColors, theme),
          const SizedBox(height: ModernSpacing.lg),
          
          // Mood Calendar
          _buildMoodCalendarCard(appColors, theme),
          const SizedBox(height: ModernSpacing.lg),
          
          // Intelligent Insights
          _buildIntelligentInsightsCard(appColors, theme),
          const SizedBox(height: ModernSpacing.lg),

          // Insights
          if (insights.isEmpty)
            _buildEmptyState('No hay insights disponibles', Icons.lightbulb_outline, appColors, theme)
          else
            ...insights.map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                      Text(insight['emoji'] ?? '🎯', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight['title'] ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildInsightTypeBadge(insight['type'] ?? 'info', appColors, theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    insight['description'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB CONTENT - VISUALIZATIONS
  // ============================================================================
  Widget _buildVisualizationsTab(AnalyticsProvider analyticsProvider, AdvancedEmotionAnalysisProvider advancedProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visualizaciones Avanzadas',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildVisualizationCard(
            'Tendencias de Humor',
            'Gráfico de líneas mostrando tu evolución emocional',
            Icons.show_chart,
            appColors,
            theme,
          ),

          const SizedBox(height: 16),

          _buildVisualizationCard(
            'Mapa de Calor',
            'Calendario visual de tu bienestar diario',
            Icons.calendar_view_month,
            appColors,
            theme,
          ),

          const SizedBox(height: 16),

          _buildVisualizationCard(
            'Correlaciones',
            'Matriz de correlación entre factores de bienestar',
            Icons.grid_on,
            appColors,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationCard(String title, String description, IconData icon, AppColors? appColors, ThemeData theme) {
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
              Icon(
                icon,
                color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visualización próximamente',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
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

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================
  Widget _buildLoadingCard(String title, String message, AppColors? appColors, ThemeData theme) {
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
        children: [
          CircularProgressIndicator(
            color: appColors?.accentPrimary ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String title, String error, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors?.negativeMain ?? theme.colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: appColors?.negativeMain ?? theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.negativeMain ?? theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(dynamic confidence, AppColors? appColors, ThemeData theme) {
    if (confidence == null) return const SizedBox.shrink();
    
    final confidenceValue = confidence is double ? confidence : (confidence as num).toDouble();
    final percentage = (confidenceValue * 100).round();
    
    Color badgeColor;
    if (percentage >= 80) {
      badgeColor = appColors?.positiveMain ?? Colors.green;
    } else if (percentage >= 60) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = appColors?.negativeMain ?? Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        '$percentage%',
        style: theme.textTheme.bodySmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInsightTypeBadge(String type, AppColors? appColors, ThemeData theme) {
    Color badgeColor;
    String label;
    
    switch (type) {
      case 'achievement':
        badgeColor = appColors?.positiveMain ?? Colors.green;
        label = 'LOGRO';
        break;
      case 'improvement':
        badgeColor = Colors.orange;
        label = 'MEJORA';
        break;
      case 'habit':
        badgeColor = Colors.blue;
        label = 'HÁBITO';
        break;
      case 'streak':
        badgeColor = Colors.red;
        label = 'RACHA';
        break;
      default:
        badgeColor = Colors.grey;
        label = type.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
  
  Widget _buildNextAchievementCard(Map<String, dynamic> achievement, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors?.accentPrimary ?? theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(achievement['emoji'] ?? '🏆', style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximo Logro',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      achievement['title'] ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement['description'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Progreso: ${achievement['current']}/${achievement['target']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${(((achievement['progress'] as num?)?.toDouble() ?? 0.0) * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (achievement['progress'] as num?)?.toDouble() ?? 0.0,
            backgroundColor: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              appColors?.accentPrimary ?? theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationsSection(List<Map<String, dynamic>> recommendations, AppColors? appColors, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendaciones Personalizadas',
          style: theme.textTheme.titleMedium?.copyWith(
            color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(rec['emoji'] ?? '💡', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec['title'] ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      rec['description'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  // Removed old AI-related border method

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  Widget _buildTrendIndicator(String label, String trend, AppColors? appColors, ThemeData theme) {
    IconData icon;
    Color color;
    
    switch (trend) {
      case 'improving':
        icon = Icons.trending_up;
        color = appColors?.positiveMain ?? Colors.green;
        break;
      case 'declining':
        icon = Icons.trending_down;
        color = appColors?.negativeMain ?? Colors.red;
        break;
      case 'stable':
      default:
        icon = Icons.trending_flat;
        color = appColors?.textSecondary ?? Colors.grey;
        break;
    }
    
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMoodVariabilitySection(List<Map<String, dynamic>> moodData, AppColors? appColors, ThemeData theme) {
    final stability = _calculateStability(moodData);
    final recentMoods = moodData.take(7).map((d) => (d['mood'] as num?)?.toDouble() ?? 5.0).toList();
    final avgMood = recentMoods.isNotEmpty ? recentMoods.reduce((a, b) => a + b) / recentMoods.length : 5.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variabilidad del Estado de Ánimo',
          style: theme.textTheme.titleSmall?.copyWith(
            color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMiniStat('Promedio', avgMood.toStringAsFixed(1), '😊', appColors, theme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStat('Estabilidad', '$stability/10', '⚖️', appColors, theme),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMiniStat(String label, String value, String emoji, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors?.surface ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: appColors?.borderColor ?? theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for new analytics features
  int _calculateStability(List<Map<String, dynamic>> moodData) {
    if (moodData.isEmpty) return 0;
    
    final moods = moodData.map((d) => (d['mood'] as num?)?.toDouble() ?? 5.0).toList();
    final average = moods.reduce((a, b) => a + b) / moods.length;
    final variance = moods.map((m) => (m - average) * (m - average)).reduce((a, b) => a + b) / moods.length;
    final stability = (10 - variance.clamp(0, 10)).round();
    
    return stability;
  }
  
  Widget _buildPatternComponent(String name, int value, int maxValue, String emoji, AppColors? appColors, ThemeData theme) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              '$value/$maxValue',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(
            appColors?.accentPrimary ?? theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS DE ANÁLISIS EMOCIONAL CON DATOS REALES
  // ============================================================================
  
  Map<String, dynamic> _generateEmotionalAnalysis() {
    // Usar datos reales del análisis avanzado si están disponibles
    if (_advancedAnalysisResults.isNotEmpty) {
      final clusteringData = _advancedAnalysisResults['clustering_analysis'] as Map<String, dynamic>?;
      final statisticalData = _advancedAnalysisResults['statistical_analysis'] as Map<String, dynamic>?;
      
      if (clusteringData != null && statisticalData != null) {
        final stabilityIndex = clusteringData['emotional_stability_index'] ?? 5.0;
        final silhouetteScore = clusteringData['validation_metrics']?['silhouette_score'] ?? 0.5;
        final descriptiveStats = statisticalData['descriptive_statistics'] as Map<String, dynamic>? ?? {};
        
        return {
          'stability_score': (stabilityIndex * 10).clamp(0, 10),
          'variability_index': (1 - silhouetteScore) * 3,
          'resilience_score': _calculateResilienceFromStats(descriptiveStats),
          'dominant_emotion': _extractDominantEmotion(clusteringData),
          'emotional_range': _extractEmotionalRange(descriptiveStats),
          'stability_trend': stabilityIndex > 0.7 ? 'improving' : stabilityIndex > 0.4 ? 'stable' : 'needs_attention',
        };
      }
    }
    
    // Fallback para datos mínimos
    return {
      'stability_score': 5.0,
      'variability_index': 1.5,
      'resilience_score': 6.0,
      'dominant_emotion': 'Neutral',
      'emotional_range': ['Sin datos suficientes'],
      'stability_trend': 'stable',
    };
  }
  
  Map<String, dynamic> _generateCorrelationAnalysis() {
    // Usar correlaciones reales del análisis estadístico
    if (_advancedAnalysisResults.isNotEmpty) {
      final statisticalData = _advancedAnalysisResults['statistical_analysis'] as Map<String, dynamic>?;
      
      if (statisticalData != null) {
        final correlationMatrix = statisticalData['correlation_matrix'] as Map<String, dynamic>? ?? {};
        final significanceTests = statisticalData['significance_tests'] as Map<String, dynamic>? ?? {};
        
        return {
          'mood_energy': _getCorrelationValue(correlationMatrix, 'mood_scores', 'energy_levels'),
          'mood_stress': _getCorrelationValue(correlationMatrix, 'mood_scores', 'stress_levels'),
          'mood_anxiety': _getCorrelationValue(correlationMatrix, 'mood_scores', 'anxiety_levels'),
          'energy_stress': _getCorrelationValue(correlationMatrix, 'energy_levels', 'stress_levels'),
          'stress_anxiety': _getCorrelationValue(correlationMatrix, 'stress_levels', 'anxiety_levels'),
          'mood_satisfaction': _getCorrelationValue(correlationMatrix, 'mood_scores', 'life_satisfaction'),
          'top_correlations': _extractTopCorrelations(correlationMatrix, significanceTests),
          'correlation_matrix': correlationMatrix,
          'significance_tests': significanceTests,
        };
      }
    }
    
    // Fallback sin datos
    return {
      'mood_energy': 0.0,
      'mood_stress': 0.0,
      'mood_anxiety': 0.0,
      'energy_stress': 0.0,
      'stress_anxiety': 0.0,
      'mood_satisfaction': 0.0,
      'top_correlations': [],
      'correlation_matrix': {},
      'significance_tests': {},
    };
  }
  
  Map<String, dynamic> _generatePatternAnalysis() {
    // Usar datos reales del análisis de series temporales
    if (_advancedAnalysisResults.isNotEmpty) {
      final timeSeriesData = _advancedAnalysisResults['time_series_analysis'] as Map<String, dynamic>?;
      
      if (timeSeriesData != null) {
        final stationarityTests = timeSeriesData['stationarity_tests'] as Map<String, dynamic>? ?? {};
        final autocorrelationData = timeSeriesData['autocorrelation_analysis'] as Map<String, dynamic>? ?? {};
        final forecast = timeSeriesData['forecast'] as Map<String, dynamic>? ?? {};
        
        return {
          'best_day_of_week': _extractBestDay(timeSeriesData),
          'best_hour_of_day': _extractBestHour(timeSeriesData),
          'peak_energy_time': _extractPeakEnergyTime(timeSeriesData),
          'mood_patterns': _extractMoodPatterns(timeSeriesData),
          'weekly_consistency': _calculateConsistency(stationarityTests),
          'seasonal_patterns': _extractSeasonalPatterns(timeSeriesData),
          'trend_direction': _extractTrendDirection(timeSeriesData),
        };
      }
    }
    
    // Fallback sin datos
    return {
      'best_day_of_week': 'Desconocido',
      'best_hour_of_day': 12,
      'peak_energy_time': 'Sin datos',
      'mood_patterns': {
        'morning_mood': 0.0,
        'afternoon_mood': 0.0,
        'evening_mood': 0.0,
      },
      'weekly_consistency': 0.0,
      'seasonal_patterns': ['Sin datos suficientes'],
      'trend_direction': 'stable',
    };
  }
  
  // ============================================================================
  // HELPER METHODS PARA ANÁLISIS DE DATOS REALES
  // ============================================================================
  
  double _calculateResilienceFromStats(Map<String, dynamic> stats) {
    final moodStats = stats['moodScore'] as Map<String, dynamic>? ?? {};
    final stressStats = stats['stressLevel'] as Map<String, dynamic>? ?? {};
    
    final moodMean = moodStats['mean'] ?? 5.0;
    final moodStd = moodStats['std'] ?? 1.0;
    final stressStd = stressStats['std'] ?? 1.0;
    
    // Resilencia basada en estabilidad de humor y manejo del estrés
    return ((moodMean / 10.0) * 5 + (1 / (stressStd + 0.1)) * 5).clamp(0, 10);
  }
  
  String _extractDominantEmotion(Map<String, dynamic> clusteringData) {
    final clusterAnalysis = clusteringData['cluster_analysis'] as Map<String, dynamic>? ?? {};
    final dominantClusterIndex = clusteringData['dominant_cluster'] ?? 0;
    
    // Mapear clusters a emociones basado en características
    final emotionMap = {
      0: 'Equilibrado',
      1: 'Optimista',
      2: 'Reflexivo',
      3: 'Dinámico',
    };
    
    return emotionMap[dominantClusterIndex] ?? 'Neutral';
  }
  
  List<String> _extractEmotionalRange(Map<String, dynamic> stats) {
    final range = <String>[];
    
    final moodStats = stats['moodScore'] as Map<String, dynamic>? ?? {};
    final energyStats = stats['energyLevel'] as Map<String, dynamic>? ?? {};
    final stressStats = stats['stressLevel'] as Map<String, dynamic>? ?? {};
    
    final moodMean = moodStats['mean'] ?? 5.0;
    final energyMean = energyStats['mean'] ?? 5.0;
    final stressMean = stressStats['mean'] ?? 5.0;
    
    if (moodMean > 7) range.add('Alegría');
    if (energyMean > 7) range.add('Vitalidad');
    if (stressMean < 4) range.add('Calma');
    if (moodMean > 6 && stressMean < 5) range.add('Bienestar');
    
    return range.isNotEmpty ? range : ['Equilibrio'];
  }
  
  double _getCorrelationValue(Map<String, dynamic> matrix, String factor1, String factor2) {
    try {
      // Check if the matrix has the nested structure (variable -> variable -> correlation)
      if (matrix.containsKey(factor1) && matrix[factor1] is Map) {
        final subMatrix = matrix[factor1] as Map<String, dynamic>;
        if (subMatrix.containsKey(factor2)) {
          final value = subMatrix[factor2];
          if (value is num) {
            return value.toDouble();
          }
        }
      }
      
      // Check reverse order
      if (matrix.containsKey(factor2) && matrix[factor2] is Map) {
        final subMatrix = matrix[factor2] as Map<String, dynamic>;
        if (subMatrix.containsKey(factor1)) {
          final value = subMatrix[factor1];
          if (value is num) {
            return value.toDouble();
          }
        }
      }
      
      // Fallback to old flat structure for backward compatibility
      final key1 = '${factor1}_$factor2';
      final key2 = '${factor2}_$factor1';
      
      if (matrix.containsKey(key1)) {
        final value = matrix[key1];
        if (value is num) {
          return value.toDouble();
        }
      } else if (matrix.containsKey(key2)) {
        final value = matrix[key2];
        if (value is num) {
          return value.toDouble();
        }
      }
      
      return 0.0;
    } catch (e) {
      print('Error in _getCorrelationValue: $e');
      print('Matrix keys: ${matrix.keys}');
      print('Factor1: $factor1, Factor2: $factor2');
      if (matrix.containsKey(factor1)) {
        print('Matrix[$factor1] type: ${matrix[factor1].runtimeType}');
        print('Matrix[$factor1] value: ${matrix[factor1]}');
      }
      return 0.0;
    }
  }
  
  List<Map<String, dynamic>> _extractTopCorrelations(Map<String, dynamic> matrix, Map<String, dynamic> significance) {
    final correlations = <Map<String, dynamic>>[];
    
    try {
      // Handle nested structure (variable -> variable -> correlation)
      matrix.forEach((factor1, subMatrix) {
        if (subMatrix is Map) {
          final subMap = subMatrix as Map<String, dynamic>;
          subMap.forEach((factor2, value) {
            if (value is num && value.abs() > 0.3 && factor1 != factor2) {
              final key1 = '${factor1}_$factor2';
              final key2 = '${factor2}_$factor1';
              final isSignificant = significance[key1] != null || significance[key2] != null;
              
              // Avoid duplicates (only add if factor1 comes before factor2 alphabetically)
              if (factor1.compareTo(factor2) < 0) {
                correlations.add({
                  'factor1': _formatFactorName(factor1),
                  'factor2': _formatFactorName(factor2),
                  'strength': value.toDouble(),
                  'is_significant': isSignificant,
                });
              }
            }
          });
        }
        // Fallback for flat structure
        else if (subMatrix is num && subMatrix.abs() > 0.3) {
          final parts = factor1.split('_');
          if (parts.length >= 2) {
            final isSignificant = significance[factor1] != null;
            correlations.add({
              'factor1': _formatFactorName(parts[0]),
              'factor2': _formatFactorName(parts[1]),
              'strength': subMatrix.toDouble(),
              'is_significant': isSignificant,
            });
          }
        }
      });
      
      correlations.sort((a, b) => (b['strength'] as double).abs().compareTo((a['strength'] as double).abs()));
      return correlations.take(5).toList();
    } catch (e) {
      print('Error in _extractTopCorrelations: $e');
      print('Matrix structure: ${matrix.runtimeType}');
      print('Matrix keys: ${matrix.keys}');
      return [];
    }
  }
  
  String _formatFactorName(String factor) {
    final nameMap = {
      // New provider variable names
      'mood_scores': 'Estado de Ánimo',
      'energy_levels': 'Nivel de Energía',
      'stress_levels': 'Nivel de Estrés',
      'anxiety_levels': 'Nivel de Ansiedad',
      'life_satisfaction': 'Satisfacción Vital',
      // Legacy names for backward compatibility
      'moodScore': 'Estado de Ánimo',
      'energyLevel': 'Nivel de Energía',
      'stressLevel': 'Nivel de Estrés',
      'sleepQuality': 'Calidad del Sueño',
      'physicalActivity': 'Actividad Física',
      'socialInteraction': 'Interacción Social',
      'meditationMinutes': 'Meditación',
      'anxietyLevel': 'Nivel de Ansiedad',
      'lifeSatisfaction': 'Satisfacción Vital',
    };
    
    return nameMap[factor] ?? factor;
  }
  
  String _extractBestDay(Map<String, dynamic> timeSeriesData) {
    // Extraer el día con mejor promedio de bienestar
    final decomposition = timeSeriesData['stl_decomposition'] as Map<String, dynamic>? ?? {};
    final seasonal = decomposition['seasonal'] as List<dynamic>? ?? [];
    
    if (seasonal.isNotEmpty) {
      final days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final dayIndex = seasonal.indexWhere((value) => value == seasonal.reduce((a, b) => a > b ? a : b));
      return days[dayIndex % 7];
    }
    
    return 'Desconocido';
  }
  
  int _extractBestHour(Map<String, dynamic> timeSeriesData) {
    // Hora con mejor nivel de energía promedio
    final forecast = timeSeriesData['forecast'] as Map<String, dynamic>? ?? {};
    final trend = forecast['trend'] as List<dynamic>? ?? [];
    
    if (trend.isNotEmpty) {
      final maxIndex = trend.indexWhere((value) => value == trend.reduce((a, b) => a > b ? a : b));
      return 8 + (maxIndex % 12);  // Asumiendo datos desde las 8 AM
    }
    
    return 12;
  }
  
  String _extractPeakEnergyTime(Map<String, dynamic> timeSeriesData) {
    final bestHour = _extractBestHour(timeSeriesData);
    return '$bestHour:00 - ${bestHour + 2}:00';
  }
  
  Map<String, double> _extractMoodPatterns(Map<String, dynamic> timeSeriesData) {
    final decomposition = timeSeriesData['stl_decomposition'] as Map<String, dynamic>? ?? {};
    final trend = decomposition['trend'] as List<dynamic>? ?? [];
    
    if (trend.length >= 3) {
      return {
        'morning_mood': (trend[0] as num?)?.toDouble() ?? 5.0,
        'afternoon_mood': (trend[trend.length ~/ 2] as num?)?.toDouble() ?? 5.0,
        'evening_mood': (trend.last as num?)?.toDouble() ?? 5.0,
      };
    }
    
    return {
      'morning_mood': 5.0,
      'afternoon_mood': 5.0,
      'evening_mood': 5.0,
    };
  }
  
  double _calculateConsistency(Map<String, dynamic> stationarityTests) {
    final adfTest = stationarityTests['adf_test'] as Map<String, dynamic>? ?? {};
    final isStationary = adfTest['is_stationary'] ?? false;
    final pValue = adfTest['p_value'] ?? 1.0;
    
    return isStationary ? (1 - pValue) : pValue;
  }
  
  List<String> _extractSeasonalPatterns(Map<String, dynamic> timeSeriesData) {
    final patterns = <String>[];
    final decomposition = timeSeriesData['stl_decomposition'] as Map<String, dynamic>? ?? {};
    final seasonal = decomposition['seasonal'] as List<dynamic>? ?? [];
    
    if (seasonal.isNotEmpty) {
      final maxSeason = seasonal.reduce((a, b) => a > b ? a : b);
      final minSeason = seasonal.reduce((a, b) => a < b ? a : b);
      
      if ((maxSeason - minSeason) > 0.5) {
        patterns.add('Variación estacional significativa');
      } else {
        patterns.add('Patrón estacional estable');
      }
    }
    
    return patterns.isNotEmpty ? patterns : ['Sin patrones detectados'];
  }
  
  String _extractTrendDirection(Map<String, dynamic> timeSeriesData) {
    final decomposition = timeSeriesData['stl_decomposition'] as Map<String, dynamic>? ?? {};
    final trend = decomposition['trend'] as List<dynamic>? ?? [];
    
    if (trend.length >= 2) {
      final start = trend.first as num;
      final end = trend.last as num;
      final difference = end - start;
      
      if (difference > 0.2) return 'improving';
      if (difference < -0.2) return 'declining';
    }
    
    return 'stable';
  }
  
  // ============================================================================
  // VISUALIZACIÓN DE MATRIZ DE CORRELACIONES
  // ============================================================================
  
  Widget _buildCorrelationMatrixVisualization(
    Map<String, dynamic> correlationMatrix, 
    Map<String, dynamic> significanceTests,
    AppColors? appColors, 
    ThemeData theme
  ) {
    final factors = _getUniqueFactors(correlationMatrix);
    
    if (factors.length < 2) {
      return Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Se necesitan más datos para generar la matriz',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Encabezados
          Row(
            children: [
              SizedBox(width: 80), // Espacio para etiquetas de fila
              ...factors.map((factor) => Expanded(
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      _formatFactorName(factor),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          
          // Filas de la matriz
          ...factors.map((rowFactor) => Container(
            height: 50,
            child: Row(
              children: [
                // Etiqueta de fila
                SizedBox(
                  width: 80,
                  child: Text(
                    _formatFactorName(rowFactor),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Celdas de correlación
                ...factors.map((colFactor) {
                  final correlation = _getCorrelationValue(correlationMatrix, rowFactor, colFactor);
                  final key = '${rowFactor}_$colFactor';
                  final isSignificant = significanceTests[key] != null;
                  
                  return Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: _getCorrelationColor(correlation, appColors, theme),
                        borderRadius: BorderRadius.circular(6),
                        border: isSignificant ? Border.all(
                          color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                          width: 2,
                        ) : null,
                      ),
                      child: Center(
                        child: Text(
                          correlation.abs() > 0.01 ? correlation.toStringAsFixed(2) : '0.00',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: correlation.abs() > 0.5 ? Colors.white : 
                                   appColors?.textPrimary ?? theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Correlación fuerte', _getCorrelationColor(0.8, appColors, theme), theme),
              _buildLegendItem('Correlación moderada', _getCorrelationColor(0.5, appColors, theme), theme),
              _buildLegendItem('Correlación débil', _getCorrelationColor(0.2, appColors, theme), theme),
            ],
          ),
          
          if (significanceTests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (appColors?.accentPrimary ?? theme.colorScheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (appColors?.accentPrimary ?? theme.colorScheme.primary).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los bordes azules indican correlaciones estadísticamente significativas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
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
  
  List<String> _getUniqueFactors(Map<String, dynamic> correlationMatrix) {
    final factors = <String>{};
    
    // Handle nested structure (variable -> variable -> correlation)
    correlationMatrix.keys.forEach((key) {
      if (correlationMatrix[key] is Map) {
        // This is a nested structure, so the key itself is a factor
        factors.add(key);
        // Also add the inner keys
        final subMap = correlationMatrix[key] as Map<String, dynamic>;
        factors.addAll(subMap.keys);
      } else {
        // This is a flat structure, split the key
        final parts = key.split('_');
        if (parts.length >= 2) {
          factors.addAll(parts);
        }
      }
    });
    
    return factors.toList()..sort();
  }
  
  Color _getCorrelationColor(double correlation, AppColors? appColors, ThemeData theme) {
    final absCorr = correlation.abs();
    
    if (absCorr >= 0.7) {
      return correlation > 0 
        ? const Color(0xFF10B981).withOpacity(0.8)  // Modern green
        : const Color(0xFFEF4444).withOpacity(0.8); // Modern red
    } else if (absCorr >= 0.4) {
      return correlation > 0 
        ? const Color(0xFF10B981).withOpacity(0.5)
        : const Color(0xFFEF4444).withOpacity(0.5);
    } else if (absCorr >= 0.2) {
      return correlation > 0 
        ? const Color(0xFF10B981).withOpacity(0.3)
        : const Color(0xFFEF4444).withOpacity(0.3);
    } else {
      return (appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest).withOpacity(0.2);
    }
  }
  
  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
  
  // ============================================================================
  // NUEVOS TABS DE ANÁLISIS EMOCIONAL
  // ============================================================================
  
  Widget _buildEmotionalAnalysisTab(AnalyticsProvider analyticsProvider, AdvancedEmotionAnalysisProvider advancedProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedSectionHeader('Análisis Emocional', Icons.psychology, appColors, theme),
          const SizedBox(height: 20),
          
          if (_isAnalysisLoading)
            _buildLoadingCard('Procesando emociones', 'Analizando patrones emocionales...', appColors, theme)
          else ...[
            _buildEmotionalStabilityCard(appColors, theme),
            const SizedBox(height: 20),
            _buildEmotionalRangeCard(appColors, theme),
            const SizedBox(height: 20),
            _buildResilienceCard(appColors, theme),
            const SizedBox(height: 20),
            
            // Análisis avanzado
            if (_isAdvancedAnalysisLoading)
              _buildLoadingCard('Análisis Avanzado', 'Ejecutando clustering emocional y análisis predictivo...', appColors, theme)
            else if (_advancedAnalysisResults.isNotEmpty) ...[
              _buildAdvancedClusteringCard(advancedProvider, appColors, theme),
              const SizedBox(height: ModernSpacing.md),
              _buildHierarchicalClusteringCard(advancedProvider, appColors, theme),
              const SizedBox(height: ModernSpacing.md),
              _buildAdvancedAnomalyDetectionCard(advancedProvider, appColors, theme),
              const SizedBox(height: ModernSpacing.md),
              _buildSpectralAnalysisCard(advancedProvider, appColors, theme),
            ],
          ],
        ],
      ),
    );
  }
  
  Widget _buildCorrelationsTab(AnalyticsProvider analyticsProvider, AdvancedEmotionAnalysisProvider advancedProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedSectionHeader('Correlaciones', Icons.hub, appColors, theme),
          const SizedBox(height: 20),
          
          if (_isAnalysisLoading)
            _buildLoadingCard('Calculando correlaciones', 'Identificando relaciones entre factores...', appColors, theme)
          else ...[
            _buildTopCorrelationsCard(appColors, theme),
            const SizedBox(height: 20),
            _buildCorrelationMatrixCard(appColors, theme),
            const SizedBox(height: 20),
            
            // Análisis estadístico avanzado
            if (_isAdvancedAnalysisLoading)
              _buildLoadingCard('Análisis Estadístico Avanzado', 'Ejecutando correlaciones de Pearson y análisis multivariado...', appColors, theme)
            else if (_advancedAnalysisResults.isNotEmpty)
              _buildAdvancedStatisticalCard(advancedProvider, appColors, theme),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPatternsTab(AnalyticsProvider analyticsProvider, AdvancedEmotionAnalysisProvider advancedProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedSectionHeader('Patrones Temporales', Icons.pattern, appColors, theme),
          const SizedBox(height: 20),
          
          if (_isAnalysisLoading)
            _buildLoadingCard('Detectando patrones', 'Analizando patrones temporales...', appColors, theme)
          else ...[
            _buildTimePatternsCard(appColors, theme),
            const SizedBox(height: 20),
            _buildWeeklyPatternsCard(appColors, theme),
            const SizedBox(height: 20),
            
            // Análisis avanzado de series temporales
            if (_isAdvancedAnalysisLoading)
              _buildLoadingCard('Análisis Temporal Avanzado', 'Ejecutando descomposición STL y análisis de tendencias...', appColors, theme)
            else if (_advancedAnalysisResults.isNotEmpty)
              _buildAdvancedTimeSeriesCard(advancedProvider, appColors, theme),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAnimatedSectionHeader(String title, IconData icon, AppColors? appColors, ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: appColors?.gradientHeader ?? [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmotionalStabilityCard(AppColors? appColors, ThemeData theme) {
    final analysis = _emotionalAnalysis;
    final stability = (analysis['stability_score'] ?? 5.0).toDouble();
    final trend = analysis['stability_trend'] ?? 'stable';
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Estabilidad Emocional',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: stability / 10,
                    strokeWidth: 8,
                    backgroundColor: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      _getStabilityColor(stability, appColors, theme),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      stability.toStringAsFixed(1),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/10',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildTrendIndicator('Tendencia', trend, appColors, theme),
              const Spacer(),
              Text(
                _getStabilityLabel(stability),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getStabilityColor(stability, appColors, theme),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmotionalRangeCard(AppColors? appColors, ThemeData theme) {
    final analysis = _emotionalAnalysis;
    final emotions = analysis['emotional_range'] ?? [];
    final dominant = analysis['dominant_emotion'] ?? 'Equilibrado';
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Rango Emocional',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emoción Dominante',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dominant,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Emociones Detectadas',
            style: theme.textTheme.titleSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map<Widget>((emotion) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: appColors?.accentPrimary.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appColors?.accentPrimary ?? Colors.blue,
                  width: 1,
                ),
              ),
              child: Text(
                emotion,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appColors?.accentPrimary ?? Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResilienceCard(AppColors? appColors, ThemeData theme) {
    final analysis = _emotionalAnalysis;
    final resilience = (analysis['resilience_score'] ?? 5.0).toDouble();
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Resiliencia Emocional',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: resilience / 10,
            backgroundColor: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              _getResilienceColor(resilience, appColors, theme),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capacidad de Recuperación',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${resilience.toStringAsFixed(1)}/10',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopCorrelationsCard(AppColors? appColors, ThemeData theme) {
    final analysis = _correlationAnalysis;
    final correlations = analysis['top_correlations'] ?? [];
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Correlaciones Principales',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...correlations.map<Widget>((correlation) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${correlation['factor1']} ↔ ${correlation['factor2']}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (correlation['strength'] as double).abs(),
                        backgroundColor: appColors?.surface ?? theme.colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation(
                          _getCorrelationColor(correlation['strength'], appColors, theme),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(correlation['strength'] * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _getCorrelationColor(correlation['strength'], appColors, theme),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildCorrelationMatrixCard(AppColors? appColors, ThemeData theme) {
    final analysis = _correlationAnalysis;
    // Safe casting to handle dynamic map types
    final correlationMatrix = analysis['correlation_matrix'] != null 
        ? Map<String, dynamic>.from(analysis['correlation_matrix'] as Map) 
        : <String, dynamic>{};
    final significanceTests = analysis['significance_tests'] != null 
        ? Map<String, dynamic>.from(analysis['significance_tests'] as Map) 
        : <String, dynamic>{};
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (appColors?.accentPrimary ?? theme.colorScheme.primary).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.grid_on, 
                  color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matriz de Correlaciones',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Relaciones entre factores de bienestar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (correlationMatrix.isEmpty)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: (appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ejecutando análisis...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La matriz se generará con más datos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildCorrelationMatrixVisualization(correlationMatrix, significanceTests, appColors, theme),
        ],
      ),
    );
  }
  
  Widget _buildTimePatternsCard(AppColors? appColors, ThemeData theme) {
    final analysis = _patternAnalysis;
    final bestDay = analysis['best_day_of_week'] ?? 'Lunes';
    final bestHour = analysis['best_hour_of_day'] ?? 10;
    final peakTime = analysis['peak_energy_time'] ?? '10:00 - 12:00';
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Patrones Temporales',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildPatternItem('Mejor Día', bestDay, Icons.calendar_today, appColors, theme),
          const SizedBox(height: 12),
          _buildPatternItem('Hora Óptima', '${bestHour}:00', Icons.access_time, appColors, theme),
          const SizedBox(height: 12),
          _buildPatternItem('Pico de Energía', peakTime, Icons.battery_charging_full, appColors, theme),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyPatternsCard(AppColors? appColors, ThemeData theme) {
    final analysis = _patternAnalysis;
    final patterns = analysis['seasonal_patterns'] ?? [];
    final consistency = (analysis['weekly_consistency'] ?? 0.0).toDouble();
    
    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Patrones Semanales',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consistencia Semanal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: consistency,
                  backgroundColor: appColors?.surface ?? theme.colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation(
                    appColors?.accentPrimary ?? theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(consistency * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Patrones Detectados',
            style: theme.textTheme.titleSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          ...patterns.map<Widget>((pattern) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 12,
                  color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pattern,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildPatternItem(String label, String value, IconData icon, AppColors? appColors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: appColors?.accentPrimary ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedCard({
    required Widget child,
    required AppColors? appColors,
    required ThemeData theme,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: appColors?.surface ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: appColors?.borderColor ?? theme.colorScheme.outline,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (appColors?.shadowColor ?? theme.colorScheme.shadow).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
  
  // Helper methods para colores
  Color _getStabilityColor(double stability, AppColors? appColors, ThemeData theme) {
    if (stability >= 8) return appColors?.positiveMain ?? Colors.green;
    if (stability >= 6) return appColors?.accentPrimary ?? Colors.blue;
    if (stability >= 4) return Colors.orange;
    return appColors?.negativeMain ?? Colors.red;
  }
  
  String _getStabilityLabel(double stability) {
    if (stability >= 8) return 'Excelente';
    if (stability >= 6) return 'Buena';
    if (stability >= 4) return 'Regular';
    return 'Necesita Atención';
  }
  
  Color _getResilienceColor(double resilience, AppColors? appColors, ThemeData theme) {
    if (resilience >= 7) return appColors?.positiveMain ?? Colors.green;
    if (resilience >= 5) return appColors?.accentPrimary ?? Colors.blue;
    return Colors.orange;
  }
  

  // ============================================================================
  // ADVANCED ANALYSIS WIDGETS
  // ============================================================================

  Widget _buildAdvancedClusteringCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final clusteringResults = _advancedAnalysisResults['clustering_analysis'] as Map<String, dynamic>?;
    
    if (clusteringResults == null || clusteringResults.containsKey('error')) {
      return _buildErrorCard('Clustering Emocional', 'Error en análisis de clustering', appColors, theme);
    }

    final clusterCount = clusteringResults['cluster_count'] ?? 0;
    final silhouetteScore = clusteringResults['silhouette_score'] ?? 0.0;
    final clusterQuality = clusteringResults['cluster_quality'] ?? 'Unknown';
    final dominantCluster = clusteringResults['dominant_cluster'] ?? 0;
    final stabilityIndex = clusteringResults['emotional_stability_index'] ?? 0.0;

    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bubble_chart, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Clustering Emocional',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Métricas principales
          Row(
            children: [
              Expanded(
                child: _buildMiniStat('Clusters', clusterCount.toString(), '🔵', appColors, theme),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat('Calidad', clusterQuality, '⭐', appColors, theme),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Puntuación de silhouette
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntuación de Silhouette',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: silhouetteScore.clamp(0.0, 1.0),
                  backgroundColor: appColors?.surface ?? theme.colorScheme.surface,
                  valueColor: AlwaysStoppedAnimation(
                    _getSilhouetteColor(silhouetteScore, appColors, theme),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  silhouetteScore.toStringAsFixed(3),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estabilidad emocional
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estabilidad Emocional:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(stabilityIndex * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedAnomalyDetectionCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final anomalyResults = _advancedAnalysisResults['anomaly_detection'] as Map<String, dynamic>?;
    
    if (anomalyResults == null || anomalyResults.containsKey('error')) {
      return _buildErrorCard('Detección de Anomalías', 'Error en análisis de anomalías', appColors, theme);
    }

    final ensembleAnomalies = anomalyResults['ensemble_anomalies'] as List<dynamic>? ?? [];
    final anomalySeverity = anomalyResults['anomaly_severity'] as Map<String, dynamic>? ?? {};
    final anomalyStats = anomalyResults['anomaly_statistics'] as Map<String, dynamic>? ?? {};

    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Detección de Anomalías',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Estado de anomalías
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ensembleAnomalies.isEmpty
                ? appColors?.positiveMain.withOpacity(0.1) ?? Colors.green.withOpacity(0.1)
                : appColors?.negativeMain.withOpacity(0.1) ?? Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ensembleAnomalies.isEmpty
                  ? appColors?.positiveMain ?? Colors.green
                  : appColors?.negativeMain ?? Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  ensembleAnomalies.isEmpty ? Icons.check_circle : Icons.warning,
                  color: ensembleAnomalies.isEmpty
                    ? appColors?.positiveMain ?? Colors.green
                    : appColors?.negativeMain ?? Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ensembleAnomalies.isEmpty ? 'No se detectaron anomalías' : '${ensembleAnomalies.length} anomalías detectadas',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ensembleAnomalies.isEmpty 
                          ? 'Tu patrón emocional es consistente'
                          : 'Se recomienda revisar estos eventos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (ensembleAnomalies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Métodos de Detección:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Z-Score', 'IQR', 'MAD', 'Isolation Forest', 'LOF'
              ].map((method) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appColors?.accentPrimary.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: appColors?.accentPrimary ?? Colors.blue,
                    width: 1,
                  ),
                ),
                child: Text(
                  method,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appColors?.accentPrimary ?? Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedTimeSeriesCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final timeSeriesResults = _advancedAnalysisResults['time_series_analysis'] as Map<String, dynamic>?;
    
    if (timeSeriesResults == null || timeSeriesResults.containsKey('error')) {
      return _buildErrorCard('Análisis Temporal', 'Error en análisis de series temporales', appColors, theme);
    }

    final decomposition = timeSeriesResults['decomposition'] as Map<String, dynamic>? ?? {};
    final changePoints = timeSeriesResults['change_points'] as List<dynamic>? ?? [];
    final forecast = timeSeriesResults['forecast'] as Map<String, dynamic>? ?? {};

    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Análisis de Series Temporales',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Componentes de descomposición
          if (decomposition.isNotEmpty) ...[
            Text(
              'Descomposición Estacional:',
              style: theme.textTheme.titleSmall?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMiniStat('Tendencia', 'Detectada', '📈', appColors, theme)),
                const SizedBox(width: 8),
                Expanded(child: _buildMiniStat('Estacional', 'Detectada', '🔄', appColors, theme)),
                const SizedBox(width: 8),
                Expanded(child: _buildMiniStat('Residuos', 'Analizados', '📊', appColors, theme)),
              ],
            ),
          ],
          
          if (changePoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.change_circle, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${changePoints.length} puntos de cambio detectados',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
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

  Widget _buildAdvancedStatisticalCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final statisticalResults = _advancedAnalysisResults['statistical_analysis'] as Map<String, dynamic>?;
    
    if (statisticalResults == null || statisticalResults.containsKey('error')) {
      return _buildErrorCard('Análisis Estadístico', 'Error en análisis estadístico', appColors, theme);
    }

    final correlationMatrix = statisticalResults['correlation_matrix'] as Map<String, dynamic>? ?? {};
    final significanceTests = statisticalResults['significance_tests'] as Map<String, dynamic>? ?? {};
    final effectSizes = statisticalResults['effect_sizes'] as Map<String, dynamic>? ?? {};

    return _buildAnimatedCard(
      appColors: appColors,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: appColors?.accentPrimary ?? theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Análisis Estadístico Avanzado',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Métricas estadísticas
          Text(
            'Análisis Completados:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Correlaciones de Pearson',
              'Correlaciones Parciales', 
              'ANOVA',
              'Regresión Múltiple',
              'PCA',
              'Tests de Significancia'
            ].map((analysis) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: appColors?.positiveMain.withOpacity(0.1) ?? Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: appColors?.positiveMain ?? Colors.green,
                  width: 1,
                ),
              ),
              child: Text(
                analysis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appColors?.positiveMain ?? Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // NUEVAS CARDS PARA MÉTODOS AVANZADOS
  // ============================================================================

  Widget _buildHierarchicalClusteringCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final hierarchicalResults = _advancedAnalysisResults['hierarchical_clustering'] as Map<String, dynamic>?;
    
    if (hierarchicalResults == null || hierarchicalResults.containsKey('error')) {
      return _buildErrorCard('Clustering Jerárquico', 'Error en análisis jerárquico', appColors, theme);
    }

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Clustering Jerárquico',
              subtitle: 'Análisis con Ward, Complete y Single Linkage',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildHierarchicalMetrics(hierarchicalResults, appColors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSpectralAnalysisCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final spectralResults = _advancedAnalysisResults['spectral_analysis'] as Map<String, dynamic>?;
    
    if (spectralResults == null || spectralResults.containsKey('error')) {
      return _buildErrorCard('Análisis Espectral', 'Error en análisis de frecuencias', appColors, theme);
    }

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Análisis Espectral',
              subtitle: 'FFT, Wavelets y Densidad Espectral',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildSpectralMetrics(spectralResults, appColors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEnsemblePredictionCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final ensembleResults = _advancedAnalysisResults['ensemble_prediction'] as Map<String, dynamic>?;
    
    if (ensembleResults == null || ensembleResults.containsKey('error')) {
      return _buildErrorCard('Predicción Ensemble', 'Error en predicción de conjunto', appColors, theme);
    }

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Predicción Ensemble',
              subtitle: 'Redes Neuronales + Regresión + Árboles',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildEnsembleMetrics(ensembleResults, appColors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomForestPredictionCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final randomForestResults = _advancedAnalysisResults['random_forest_prediction'] as Map<String, dynamic>?;
    
    if (randomForestResults == null || randomForestResults.containsKey('error')) {
      return _buildErrorCard('Random Forest', 'Error en predicción Random Forest', appColors, theme);
    }

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Random Forest Prediction',
              subtitle: 'Bootstrap Sampling + Feature Importance',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildRandomForestMetrics(randomForestResults, appColors, theme),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES PARA MOSTRAR MÉTRICAS
  // ============================================================================

  Widget _buildHierarchicalMetrics(Map<String, dynamic> results, AppColors? appColors, ThemeData theme) {
    final linkageResults = results['linkage_comparison'] as Map<String, dynamic>? ?? {};
    final copheneticCorr = results['cophenetic_correlation'] as double? ?? 0.0;
    
    return Column(
      children: [
        ModernStatCard(
          title: 'Correlación Cofenética',
          value: copheneticCorr.toStringAsFixed(3),
          icon: Icons.link,
          accentColor: _getSilhouetteColor(copheneticCorr, appColors, theme),
        ),
        const SizedBox(height: ModernSpacing.sm),
        ...linkageResults.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.key} Linkage:',
                style: ModernTypography.body2(context),
              ),
              Text(
                entry.value.toString(),
                style: ModernTypography.body2(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSpectralMetrics(Map<String, dynamic> results, AppColors? appColors, ThemeData theme) {
    final fftAnalysis = results['fft_analysis'] as Map<String, dynamic>? ?? {};
    final waveletAnalysis = results['wavelet_analysis'] as Map<String, dynamic>? ?? {};
    final dominantFreq = fftAnalysis['dominant_frequency'] as double? ?? 0.0;
    
    return Column(
      children: [
        ModernStatCard(
          title: 'Frecuencia Dominante',
          value: '${dominantFreq.toStringAsFixed(4)} Hz',
          icon: Icons.waves,
          accentColor: appColors?.accentPrimary ?? Colors.blue,
        ),
        const SizedBox(height: ModernSpacing.sm),
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                title: 'Análisis FFT',
                value: fftAnalysis.isNotEmpty ? 'Completado' : 'N/A',
                icon: Icons.analytics,
                accentColor: Colors.green,
              ),
            ),
            const SizedBox(width: ModernSpacing.sm),
            Expanded(
              child: ModernStatCard(
                title: 'Wavelets',
                value: waveletAnalysis.isNotEmpty ? 'Completado' : 'N/A',
                icon: Icons.timeline,
                accentColor: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnsembleMetrics(Map<String, dynamic> results, AppColors? appColors, ThemeData theme) {
    final ensembleAccuracy = results['ensemble_accuracy'] as double? ?? 0.0;
    final predictions = results['predictions'] as List? ?? [];
    final modelWeights = results['model_weights'] as Map<String, dynamic>? ?? {};
    
    return Column(
      children: [
        ModernStatCard(
          title: 'Precisión del Ensemble',
          value: '${(ensembleAccuracy * 100).toStringAsFixed(1)}%',
          icon: Icons.track_changes,
          accentColor: _getSilhouetteColor(ensembleAccuracy, appColors, theme),
        ),
        const SizedBox(height: ModernSpacing.sm),
        ModernStatCard(
          title: 'Predicciones Generadas',
          value: predictions.length.toString(),
          icon: Icons.trending_up,
          accentColor: appColors?.accentPrimary ?? Colors.blue,
        ),
        if (modelWeights.isNotEmpty) ...[
          const SizedBox(height: ModernSpacing.sm),
          Text(
            'Pesos del Modelo:',
            style: ModernTypography.body2(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          ...modelWeights.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: ModernTypography.caption(context)),
                Text(
                  (entry.value as double).toStringAsFixed(3),
                  style: ModernTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildRandomForestMetrics(Map<String, dynamic> results, AppColors? appColors, ThemeData theme) {
    final oobError = results['oob_error'] as double? ?? 0.0;
    final featureImportance = results['feature_importance'] as Map<String, dynamic>? ?? {};
    final numTrees = results['num_trees'] as int? ?? 0;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                title: 'Error OOB',
                value: '${(oobError * 100).toStringAsFixed(1)}%',
                icon: Icons.error_outline,
                accentColor: oobError < 0.2 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: ModernSpacing.sm),
            Expanded(
              child: ModernStatCard(
                title: 'Número de Árboles',
                value: numTrees.toString(),
                icon: Icons.account_tree,
                accentColor: appColors?.accentPrimary ?? Colors.blue,
              ),
            ),
          ],
        ),
        if (featureImportance.isNotEmpty) ...[
          const SizedBox(height: ModernSpacing.md),
          Text(
            'Importancia de Características:',
            style: ModernTypography.body2(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernSpacing.sm),
          ...featureImportance.entries.take(5).map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: ModernTypography.caption(context),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: (entry.value as double).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(
                      appColors?.accentPrimary ?? Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: ModernSpacing.sm),
                Text(
                  (entry.value as double).toStringAsFixed(3),
                  style: ModernTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildTimeSeriesDecompositionCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final timeSeriesResults = _advancedAnalysisResults['time_series_decomposition'] as Map<String, dynamic>?;
    
    if (timeSeriesResults == null || timeSeriesResults.containsKey('error')) {
      return _buildErrorCard('Descomposición de Series Temporales', 'Error en análisis de series temporales', appColors, theme);
    }

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Descomposición de Series Temporales',
              subtitle: 'STL, Estacionariedad y Autocorrelación',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildTimeSeriesMetrics(timeSeriesResults, appColors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyDetectionCard(AdvancedEmotionAnalysisProvider provider, AppColors? appColors, ThemeData theme) {
    final anomalyResults = _advancedAnalysisResults['anomaly_detection'] as Map<String, dynamic>?;
    
    if (anomalyResults == null || anomalyResults.containsKey('error')) {
      return _buildErrorCard('Detección de Anomalías', 'Error en detección de anomalías', appColors, theme);
    }

    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Detección Avanzada de Anomalías',
              subtitle: 'Z-Score, IQR y MAD Ensemble',
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildAnomalyDetectionMetrics(anomalyResults, appColors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesMetrics(Map<String, dynamic> results, AppColors? appColors, ThemeData theme) {
    final stlDecomposition = results['stl_decomposition'] as Map<String, dynamic>? ?? {};
    final stationarityTests = results['stationarity_tests'] as Map<String, dynamic>? ?? {};
    final trendStrength = results['trend_strength'] as double? ?? 0.0;
    final seasonalStrength = results['seasonal_strength'] as double? ?? 0.0;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                title: 'Fuerza de Tendencia',
                value: '${(trendStrength * 100).toStringAsFixed(1)}%',
                icon: Icons.trending_up,
                accentColor: _getSilhouetteColor(trendStrength, appColors, theme),
              ),
            ),
            const SizedBox(width: ModernSpacing.sm),
            Expanded(
              child: ModernStatCard(
                title: 'Fuerza Estacional',
                value: '${(seasonalStrength * 100).toStringAsFixed(1)}%',
                icon: Icons.waves,
                accentColor: _getSilhouetteColor(seasonalStrength, appColors, theme),
              ),
            ),
          ],
        ),
        const SizedBox(height: ModernSpacing.sm),
        if (stationarityTests.isNotEmpty) ...[
          Text(
            'Pruebas de Estacionariedad:',
            style: ModernTypography.body2(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          ...stationarityTests.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: ModernTypography.caption(context)),
                Text(
                  entry.value.toString(),
                  style: ModernTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildAnomalyDetectionMetrics(Map<String, dynamic> results, AppColors? appColors, ThemeData theme) {
    final anomalies = results['anomalies'] as List? ?? [];
    final methodResults = results['method_results'] as Map<String, dynamic>? ?? {};
    final ensembleScore = results['ensemble_score'] as double? ?? 0.0;
    final anomalyPercentage = results['anomaly_percentage'] as double? ?? 0.0;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ModernStatCard(
                title: 'Anomalías Detectadas',
                value: anomalies.length.toString(),
                icon: Icons.warning,
                accentColor: anomalies.length > 5 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(width: ModernSpacing.sm),
            Expanded(
              child: ModernStatCard(
                title: 'Porcentaje de Anomalías',
                value: '${anomalyPercentage.toStringAsFixed(1)}%',
                icon: Icons.analytics,
                accentColor: anomalyPercentage > 10 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: ModernSpacing.sm),
        ModernStatCard(
          title: 'Puntuación Ensemble',
          value: ensembleScore.toStringAsFixed(3),
          icon: Icons.score,
          accentColor: _getSilhouetteColor(ensembleScore, appColors, theme),
        ),
        if (methodResults.isNotEmpty) ...[
          const SizedBox(height: ModernSpacing.sm),
          Text(
            'Resultados por Método:',
            style: ModernTypography.body2(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          ...methodResults.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: ModernTypography.caption(context)),
                Text(
                  entry.value.toString(),
                  style: ModernTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  // ============================================================================
  // NEW: USER PROGRESSION ANALYTICS METHODS
  // ============================================================================

  /// Streak Analysis Card - Shows current streak, milestones, and progress
  Widget _buildStreakAnalysisCard(AppColors? appColors, ThemeData theme) {
    final analytics = Provider.of<AnalyticsProvider>(context, listen: false).analytics;
    final streakData = analytics['streak_data'] as Map<String, dynamic>? ?? {};
    final currentStreak = streakData['current'] as int? ?? 0;
    final longestStreak = streakData['longest'] as int? ?? 0;
    final streakActive = streakData['active'] as bool? ?? false;
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Análisis de Racha',
              subtitle: 'Tu progreso diario y logros',
            ),
            const SizedBox(height: ModernSpacing.md),
            
            // Current Streak Display
            Container(
              padding: const EdgeInsets.all(ModernSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: streakActive 
                    ? [appColors?.positiveMain?.withValues(alpha: 0.1) ?? Colors.green.withValues(alpha: 0.1), 
                       appColors?.positiveMain?.withValues(alpha: 0.05) ?? Colors.green.withValues(alpha: 0.05)]
                    : [appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1), 
                       appColors?.surface ?? Colors.grey.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: streakActive 
                    ? appColors?.positiveMain?.withValues(alpha: 0.3) ?? Colors.green.withValues(alpha: 0.3)
                    : appColors?.borderColor ?? Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Streak Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: streakActive 
                        ? appColors?.positiveMain?.withValues(alpha: 0.2) ?? Colors.green.withValues(alpha: 0.2)
                        : appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      streakActive ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                      color: streakActive 
                        ? appColors?.positiveMain ?? Colors.green
                        : appColors?.textSecondary ?? Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  
                  // Streak Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Racha Actual',
                          style: ModernTypography.caption(context).copyWith(
                            color: appColors?.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currentStreak días',
                          style: ModernTypography.title2(context).copyWith(
                            color: appColors?.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (longestStreak > currentStreak) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Récord: $longestStreak días',
                            style: ModernTypography.caption(context).copyWith(
                              color: appColors?.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: streakActive 
                        ? appColors?.positiveMain?.withValues(alpha: 0.1) ?? Colors.green.withValues(alpha: 0.1)
                        : appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      streakActive ? 'Activa' : 'Inactiva',
                      style: ModernTypography.caption(context).copyWith(
                        color: streakActive 
                          ? appColors?.positiveMain ?? Colors.green
                          : appColors?.textSecondary ?? Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ModernSpacing.md),
            
            // Milestone Progress
            _buildMilestoneProgress(currentStreak, appColors, theme),
          ],
        ),
      ),
    );
  }

  /// Milestone Progress Widget
  Widget _buildMilestoneProgress(int currentStreak, AppColors? appColors, ThemeData theme) {
    final milestones = [
      {'days': 3, 'title': 'Primer Paso', 'emoji': '👶'},
      {'days': 7, 'title': 'Una Semana', 'emoji': '🌱'},
      {'days': 14, 'title': 'Dos Semanas', 'emoji': '🌿'},
      {'days': 30, 'title': 'Un Mes', 'emoji': '🌳'},
      {'days': 60, 'title': 'Dos Meses', 'emoji': '🏆'},
      {'days': 90, 'title': 'Tres Meses', 'emoji': '💎'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso hacia Logros',
          style: ModernTypography.body2(context).copyWith(
            fontWeight: FontWeight.w600,
            color: appColors?.textPrimary,
          ),
        ),
        const SizedBox(height: ModernSpacing.sm),
        
        ...milestones.map((milestone) {
          final days = milestone['days'] as int;
          final title = milestone['title'] as String;
          final emoji = milestone['emoji'] as String;
          final isAchieved = currentStreak >= days;
          final isCurrent = currentStreak < days && 
                          (milestones.indexOf(milestone) == 0 || 
                           currentStreak >= (milestones[milestones.indexOf(milestone) - 1]['days'] as int));
          
          return Container(
            margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
            padding: const EdgeInsets.all(ModernSpacing.md),
            decoration: BoxDecoration(
              color: isAchieved 
                ? appColors?.positiveMain?.withValues(alpha: 0.1) ?? Colors.green.withValues(alpha: 0.1)
                : isCurrent 
                  ? appColors?.accentPrimary?.withValues(alpha: 0.1) ?? Colors.blue.withValues(alpha: 0.1)
                  : appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAchieved 
                  ? appColors?.positiveMain?.withValues(alpha: 0.3) ?? Colors.green.withValues(alpha: 0.3)
                  : isCurrent 
                    ? appColors?.accentPrimary?.withValues(alpha: 0.3) ?? Colors.blue.withValues(alpha: 0.3)
                    : appColors?.borderColor ?? Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Milestone Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAchieved 
                      ? appColors?.positiveMain?.withValues(alpha: 0.2) ?? Colors.green.withValues(alpha: 0.2)
                      : isCurrent 
                        ? appColors?.accentPrimary?.withValues(alpha: 0.2) ?? Colors.blue.withValues(alpha: 0.2)
                        : appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: ModernSpacing.md),
                
                // Milestone Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ModernTypography.body2(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: appColors?.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$days días',
                        style: ModernTypography.caption(context).copyWith(
                          color: appColors?.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Icon
                Icon(
                  isAchieved 
                    ? Icons.check_circle
                    : isCurrent 
                      ? Icons.radio_button_unchecked
                      : Icons.lock_outline,
                  color: isAchieved 
                    ? appColors?.positiveMain ?? Colors.green
                    : isCurrent 
                      ? appColors?.accentPrimary ?? Colors.blue
                      : appColors?.textSecondary ?? Colors.grey,
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Wellbeing Prediction Card
  Widget _buildWellbeingPredictionCard(AppColors? appColors, ThemeData theme) {
    final analytics = Provider.of<AnalyticsProvider>(context, listen: false).analytics;
    final predictionData = analytics['wellbeing_prediction'] as Map<String, dynamic>? ?? {};
    final currentTrend = predictionData['trend'] as String? ?? 'stable';
    final predictionScore = (predictionData['predicted_score'] as num?)?.toDouble() ?? 5.0;
    final confidence = (predictionData['confidence'] as num?)?.toDouble() ?? 0.0;
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Predicción de Bienestar',
              subtitle: 'Tendencia basada en tus patrones',
            ),
            const SizedBox(height: ModernSpacing.md),
            
            // Prediction Display
            Container(
              padding: const EdgeInsets.all(ModernSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTrendColor(currentTrend, appColors).withValues(alpha: 0.1),
                    _getTrendColor(currentTrend, appColors).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getTrendColor(currentTrend, appColors).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Trend Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTrendColor(currentTrend, appColors).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTrendIcon(currentTrend),
                      color: _getTrendColor(currentTrend, appColors),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  
                  // Prediction Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tendencia: ${_getTrendLabel(currentTrend)}',
                          style: ModernTypography.body2(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: appColors?.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Puntuación Prevista: ${predictionScore.toStringAsFixed(1)}/10',
                          style: ModernTypography.caption(context).copyWith(
                            color: appColors?.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confianza: ${(confidence * 100).toStringAsFixed(0)}%',
                          style: ModernTypography.caption(context).copyWith(
                            color: appColors?.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ModernSpacing.md),
            
            // Recommendations based on prediction
            _buildPredictionRecommendations(currentTrend, predictionScore, appColors, theme),
          ],
        ),
      ),
    );
  }

  /// Prediction Recommendations Widget
  Widget _buildPredictionRecommendations(String trend, double score, AppColors? appColors, ThemeData theme) {
    final recommendations = _getPredictionRecommendations(trend, score);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendaciones',
          style: ModernTypography.body2(context).copyWith(
            fontWeight: FontWeight.w600,
            color: appColors?.textPrimary,
          ),
        ),
        const SizedBox(height: ModernSpacing.sm),
        
        ...recommendations.map((rec) => Container(
          margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
          padding: const EdgeInsets.all(ModernSpacing.md),
          decoration: BoxDecoration(
            color: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                rec['icon'] as IconData,
                color: appColors?.accentPrimary ?? Colors.blue,
                size: 20,
              ),
              const SizedBox(width: ModernSpacing.sm),
              Expanded(
                child: Text(
                  rec['text'] as String,
                  style: ModernTypography.body2(context).copyWith(
                    color: appColors?.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// Healthy Habits Analysis Card
  Widget _buildHealthyHabitsCard(AppColors? appColors, ThemeData theme) {
    final analytics = Provider.of<AnalyticsProvider>(context, listen: false).analytics;
    final habitsData = analytics['habits_analysis'] as Map<String, dynamic>? ?? {};
    final habits = habitsData['habits'] as List<dynamic>? ?? [];
    final overallScore = (habitsData['overall_score'] as num?)?.toDouble() ?? 0.0;
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Análisis de Hábitos Saludables',
              subtitle: 'Tu progreso en hábitos clave',
            ),
            const SizedBox(height: ModernSpacing.md),
            
            // Overall Score
            Container(
              padding: const EdgeInsets.all(ModernSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors?.positiveMain?.withValues(alpha: 0.1) ?? Colors.green.withValues(alpha: 0.1),
                    appColors?.positiveMain?.withValues(alpha: 0.05) ?? Colors.green.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appColors?.positiveMain?.withValues(alpha: 0.3) ?? Colors.green.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Score Circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: appColors?.positiveMain?.withValues(alpha: 0.2) ?? Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        '${(overallScore * 100).toStringAsFixed(0)}%',
                        style: ModernTypography.body2(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: appColors?.positiveMain ?? Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  
                  // Score Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntuación General de Hábitos',
                          style: ModernTypography.body2(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: appColors?.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHabitsScoreLabel(overallScore),
                          style: ModernTypography.caption(context).copyWith(
                            color: appColors?.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ModernSpacing.md),
            
            // Individual Habits
            if (habits.isNotEmpty) ...[
              Text(
                'Hábitos Individuales',
                style: ModernTypography.body2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: appColors?.textPrimary,
                ),
              ),
              const SizedBox(height: ModernSpacing.sm),
              
              ...habits.take(5).map((habit) => _buildHabitItem(habit, appColors, theme)),
            ],
          ],
        ),
      ),
    );
  }

  /// Individual Habit Item
  Widget _buildHabitItem(dynamic habit, AppColors? appColors, ThemeData theme) {
    final habitMap = habit as Map<String, dynamic>;
    final name = habitMap['name'] as String? ?? 'Hábito';
    final score = (habitMap['score'] as num?)?.toDouble() ?? 0.0;
    final consistency = (habitMap['consistency'] as num?)?.toDouble() ?? 0.0;
    final icon = _getHabitIcon(name);
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Habit Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appColors?.accentPrimary?.withValues(alpha: 0.2) ?? Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: appColors?.accentPrimary ?? Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: ModernSpacing.md),
          
          // Habit Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: ModernTypography.body2(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors?.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: consistency,
                        backgroundColor: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(
                          appColors?.accentPrimary ?? Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernSpacing.sm),
                    Text(
                      '${(consistency * 100).toStringAsFixed(0)}%',
                      style: ModernTypography.caption(context).copyWith(
                        color: appColors?.textSecondary,
                        fontWeight: FontWeight.w600,
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

  /// Emotional Patterns Card
  Widget _buildEmotionalPatternsCard(AppColors? appColors, ThemeData theme) {
    final analytics = Provider.of<AnalyticsProvider>(context, listen: false).analytics;
    final patternsData = analytics['emotional_patterns'] as Map<String, dynamic>? ?? {};
    final patterns = patternsData['patterns'] as List<dynamic>? ?? [];
    final dominantEmotion = patternsData['dominant_emotion'] as String? ?? 'neutral';
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Patrones Emocionales',
              subtitle: 'Análisis de tus estados emocionales',
            ),
            const SizedBox(height: ModernSpacing.md),
            
            // Dominant Emotion
            Container(
              padding: const EdgeInsets.all(ModernSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors?.accentSecondary?.withValues(alpha: 0.1) ?? Colors.purple.withValues(alpha: 0.1),
                    appColors?.accentSecondary?.withValues(alpha: 0.05) ?? Colors.purple.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appColors?.accentSecondary?.withValues(alpha: 0.3) ?? Colors.purple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Emotion Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors?.accentSecondary?.withValues(alpha: 0.2) ?? Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getEmotionEmoji(dominantEmotion),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  
                  // Emotion Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emoción Dominante',
                          style: ModernTypography.caption(context).copyWith(
                            color: appColors?.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEmotionLabel(dominantEmotion),
                          style: ModernTypography.title3(context).copyWith(
                            color: appColors?.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ModernSpacing.md),
            
            // Emotional Patterns
            if (patterns.isNotEmpty) ...[
              Text(
                'Patrones Detectados',
                style: ModernTypography.body2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: appColors?.textPrimary,
                ),
              ),
              const SizedBox(height: ModernSpacing.sm),
              
              ...patterns.take(3).map((pattern) => _buildEmotionalPatternItem(pattern, appColors, theme)),
            ],
          ],
        ),
      ),
    );
  }

  /// Emotional Pattern Item Widget
  Widget _buildEmotionalPatternItem(dynamic pattern, AppColors? appColors, ThemeData theme) {
    final patternMap = pattern as Map<String, dynamic>;
    final type = patternMap['type'] as String? ?? 'general';
    final description = patternMap['description'] as String? ?? 'Patrón detectado';
    final strength = (patternMap['strength'] as num?)?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pattern Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appColors?.accentSecondary?.withValues(alpha: 0.2) ?? Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPatternIcon(type),
              color: appColors?.accentSecondary ?? Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: ModernSpacing.md),
          
          // Pattern Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: ModernTypography.body2(context).copyWith(
                    color: appColors?.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: strength,
                        backgroundColor: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(
                          appColors?.accentSecondary ?? Colors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(width: ModernSpacing.sm),
                    Text(
                      'Fuerza: ${(strength * 100).toStringAsFixed(0)}%',
                      style: ModernTypography.caption(context).copyWith(
                        color: appColors?.textSecondary,
                        fontWeight: FontWeight.w600,
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

  /// Mood Calendar Card
  Widget _buildMoodCalendarCard(AppColors? appColors, ThemeData theme) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Calendario de Estado de Ánimo',
              subtitle: 'Visualización de tu progreso',
            ),
            const SizedBox(height: ModernSpacing.md),
            
            // Calendar Grid (Simplified)
            Container(
              height: 200,
              padding: const EdgeInsets.all(ModernSpacing.md),
              decoration: BoxDecoration(
                color: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 48,
                      color: appColors?.accentPrimary ?? Colors.blue,
                    ),
                    const SizedBox(height: ModernSpacing.sm),
                    Text(
                      'Calendario de Progreso',
                      style: ModernTypography.body2(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: appColors?.textPrimary,
                      ),
                    ),
                    const SizedBox(height: ModernSpacing.xs),
                    Text(
                      'Visualización completa disponible pronto',
                      style: ModernTypography.caption(context).copyWith(
                        color: appColors?.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Intelligent Insights Card
  Widget _buildIntelligentInsightsCard(AppColors? appColors, ThemeData theme) {
    final analytics = Provider.of<AnalyticsProvider>(context, listen: false).analytics;
    final insightsData = analytics['intelligent_insights'] as Map<String, dynamic>? ?? {};
    final insights = insightsData['insights'] as List<dynamic>? ?? [];
    final recommendations = analytics['personalized_recommendations'] as List<dynamic>? ?? [];
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModernSectionHeader(
              title: 'Insights Inteligentes',
              subtitle: 'Recomendaciones personalizadas',
            ),
            const SizedBox(height: ModernSpacing.md),
            
            // Insights List
            if (insights.isNotEmpty) ...[
              ...insights.take(3).map((insight) => _buildInsightItem(insight, appColors, theme)),
              const SizedBox(height: ModernSpacing.md),
            ],
            
            // Recommendations
            if (recommendations.isNotEmpty) ...[
              Text(
                'Recomendaciones Personalizadas',
                style: ModernTypography.body2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: appColors?.textPrimary,
                ),
              ),
              const SizedBox(height: ModernSpacing.sm),
              
              ...recommendations.take(3).map((rec) => _buildRecommendationItem(rec, appColors, theme)),
            ],
          ],
        ),
      ),
    );
  }

  /// Insight Item Widget
  Widget _buildInsightItem(dynamic insight, AppColors? appColors, ThemeData theme) {
    final insightMap = insight as Map<String, dynamic>;
    final title = insightMap['title'] as String? ?? 'Insight';
    final description = insightMap['description'] as String? ?? '';
    final confidence = (insightMap['confidence'] as num?)?.toDouble() ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appColors?.accentPrimary?.withValues(alpha: 0.3) ?? Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Insight Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appColors?.accentPrimary?.withValues(alpha: 0.2) ?? Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.insights,
              color: appColors?.accentPrimary ?? Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: ModernSpacing.md),
          
          // Insight Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernTypography.body2(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors?.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: ModernTypography.caption(context).copyWith(
                      color: appColors?.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Confianza: ${(confidence * 100).toStringAsFixed(0)}%',
                      style: ModernTypography.caption(context).copyWith(
                        color: appColors?.textSecondary,
                        fontWeight: FontWeight.w600,
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

  /// Recommendation Item Widget
  Widget _buildRecommendationItem(dynamic recommendation, AppColors? appColors, ThemeData theme) {
    final recMap = recommendation as Map<String, dynamic>;
    final title = recMap['title'] as String? ?? 'Recomendación';
    final description = recMap['description'] as String? ?? '';
    final priority = recMap['priority'] as String? ?? 'medium';
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: appColors?.surfaceVariant ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(priority, appColors).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Recommendation Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPriorityColor(priority, appColors).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.recommend,
              color: _getPriorityColor(priority, appColors),
              size: 20,
            ),
          ),
          const SizedBox(width: ModernSpacing.md),
          
          // Recommendation Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernTypography.body2(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors?.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: ModernTypography.caption(context).copyWith(
                      color: appColors?.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(priority, appColors).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getPriorityLabel(priority),
              style: ModernTypography.caption(context).copyWith(
                color: _getPriorityColor(priority, appColors),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS FOR NEW ANALYTICS
  // ============================================================================

  Color _getTrendColor(String trend, AppColors? appColors) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return appColors?.positiveMain ?? Colors.green;
      case 'declining':
        return appColors?.negativeMain ?? Colors.red;
      case 'stable':
      default:
        return appColors?.accentPrimary ?? Colors.blue;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }

  String _getTrendLabel(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return 'Mejorando';
      case 'declining':
        return 'Declinando';
      case 'stable':
      default:
        return 'Estable';
    }
  }

  List<Map<String, dynamic>> _getPredictionRecommendations(String trend, double score) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return [
          {'icon': Icons.celebration, 'text': 'Continúa con tus hábitos actuales'},
          {'icon': Icons.star, 'text': 'Considera establecer nuevos objetivos'},
        ];
      case 'declining':
        return [
          {'icon': Icons.support, 'text': 'Busca apoyo de amigos o familia'},
          {'icon': Icons.self_improvement, 'text': 'Practica técnicas de autocuidado'},
          {'icon': Icons.schedule, 'text': 'Establece rutinas regulares'},
        ];
      case 'stable':
      default:
        return [
          {'icon': Icons.balance, 'text': 'Mantén el equilibrio actual'},
          {'icon': Icons.explore, 'text': 'Explora nuevas actividades'},
        ];
    }
  }

  String _getHabitsScoreLabel(double score) {
    if (score >= 0.8) return 'Excelente progreso';
    if (score >= 0.6) return 'Buen progreso';
    if (score >= 0.4) return 'Progreso moderado';
    return 'Necesita mejora';
  }

  IconData _getHabitIcon(String habitName) {
    final name = habitName.toLowerCase();
    if (name.contains('sleep') || name.contains('sueño')) return Icons.bedtime;
    if (name.contains('exercise') || name.contains('ejercicio')) return Icons.fitness_center;
    if (name.contains('meditation') || name.contains('meditación')) return Icons.self_improvement;
    if (name.contains('water') || name.contains('agua')) return Icons.water_drop;
    if (name.contains('nutrition') || name.contains('nutrición')) return Icons.restaurant;
    return Icons.check_circle;
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'anxious':
        return '😰';
      case 'calm':
        return '😌';
      case 'excited':
        return '😃';
      case 'neutral':
      default:
        return '😐';
    }
  }

  String _getEmotionLabel(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return 'Feliz';
      case 'sad':
        return 'Triste';
      case 'angry':
        return 'Enojado';
      case 'anxious':
        return 'Ansioso';
      case 'calm':
        return 'Tranquilo';
      case 'excited':
        return 'Emocionado';
      case 'neutral':
      default:
        return 'Neutral';
    }
  }

  IconData _getPatternIcon(String type) {
    switch (type.toLowerCase()) {
      case 'weekly':
        return Icons.date_range;
      case 'daily':
        return Icons.today;
      case 'seasonal':
        return Icons.nature;
      case 'trigger':
        return Icons.warning;
      default:
        return Icons.analytics;
    }
  }

  Color _getPriorityColor(String priority, AppColors? appColors) {
    switch (priority.toLowerCase()) {
      case 'high':
        return appColors?.negativeMain ?? Colors.red;
      case 'medium':
        return appColors?.accentPrimary ?? Colors.blue;
      case 'low':
      default:
        return appColors?.positiveMain ?? Colors.green;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Alta';
      case 'medium':
        return 'Media';
      case 'low':
      default:
        return 'Baja';
    }
  }

  // ============================================================================
  // TAB CONTENT - MOOD TRACKING WITH CUSTOMIZABLE PARAMETERS
  // ============================================================================
  
  Widget _buildMoodTrackingTab(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodTrackingHeader(appColors, theme),
          const SizedBox(height: 20),
          _buildParameterSelector(appColors, theme),
          const SizedBox(height: 20),
          _buildCustomizableMoodChart(analyticsProvider, appColors, theme),
          const SizedBox(height: 20),
          _buildWeeklyHighlightMoments(analyticsProvider, appColors, theme),
        ],
      ),
    );
  }

  Widget _buildMoodTrackingHeader(AppColors? appColors, ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors?.accentPrimary ?? theme.colorScheme.primary,
                      appColors?.accentSecondary ?? theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguimiento Personalizado',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analiza cómo han cambiado tus parámetros emocionales',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
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

  String _selectedParameter = 'mood';
  final List<String> _availableParameters = ['mood', 'energy', 'stress', 'anxiety'];
  final Map<String, String> _parameterLabels = {
    'mood': 'Estado de Ánimo',
    'energy': 'Nivel de Energía', 
    'stress': 'Nivel de Estrés',
    'anxiety': 'Nivel de Ansiedad',
  };

  Widget _buildParameterSelector(AppColors? appColors, ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona el parámetro a analizar:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableParameters.map((parameter) {
              final isSelected = _selectedParameter == parameter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedParameter = parameter;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                      ? LinearGradient(
                          colors: [
                            appColors?.accentPrimary ?? theme.colorScheme.primary,
                            appColors?.accentSecondary ?? theme.colorScheme.secondary,
                          ],
                        )
                      : null,
                    color: isSelected ? null : appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected 
                        ? Colors.transparent
                        : appColors?.borderColor ?? theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _parameterLabels[parameter] ?? parameter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected 
                        ? Colors.white
                        : appColors?.textPrimary ?? theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizableMoodChart(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final chartData = _getParameterChartData(analyticsProvider, _selectedParameter);
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolución de ${_parameterLabels[_selectedParameter]}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: appColors?.accentPrimary?.withOpacity(0.1) ?? theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Últimos ${_selectedPeriod} días',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: _buildParameterLineChart(chartData, appColors, theme),
          ),
          const SizedBox(height: 16),
          _buildChartStatistics(chartData, appColors, theme),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getParameterChartData(AnalyticsProvider analyticsProvider, String parameter) {
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedPeriod));
    
    return dailyEntries
        .where((entry) => entry.entryDate.isAfter(startDate))
        .map((entry) {
          double value = 3.0; // Default value
          switch (parameter) {
            case 'mood':
              value = (entry.moodScore as num?)?.toDouble() ?? 3.0;
              break;
            case 'energy':
              value = (entry.energyLevel as num?)?.toDouble() ?? 3.0;
              break;
            case 'stress':
              value = (entry.stressLevel as num?)?.toDouble() ?? 3.0;
              break;
            case 'anxiety':
              value = (entry.anxietyLevel as num?)?.toDouble() ?? 3.0;
              break;
          }
          return {
            'date': entry.entryDate,
            'value': value,
            'dateStr': '${entry.entryDate.day}/${entry.entryDate.month}',
          };
        })
        .toList()
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  Widget _buildParameterLineChart(List<Map<String, dynamic>> chartData, AppColors? appColors, ThemeData theme) {
    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos suficientes para mostrar el gráfico',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 300),
      painter: ParameterChartPainter(
        data: chartData,
        selectedParameter: _selectedParameter,
        accentColor: appColors?.accentPrimary ?? theme.colorScheme.primary,
        textColor: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildChartStatistics(List<Map<String, dynamic>> chartData, AppColors? appColors, ThemeData theme) {
    if (chartData.isEmpty) return const SizedBox.shrink();
    
    final values = chartData.map((d) => d['value'] as double).toList();
    final average = values.fold(0.0, (sum, value) => sum + value) / values.length;
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final trend = values.length > 1 ? (values.last - values.first) : 0.0;
    
    return Row(
      children: [
        _buildMoodStatCard('Promedio', average.toStringAsFixed(1), Icons.trending_flat, appColors, theme),
        const SizedBox(width: 12),
        _buildMoodStatCard('Máximo', max.toStringAsFixed(1), Icons.trending_up, appColors, theme),
        const SizedBox(width: 12),
        _buildMoodStatCard('Mínimo', min.toStringAsFixed(1), Icons.trending_down, appColors, theme),
        const SizedBox(width: 12),
        _buildMoodStatCard(
          'Tendencia', 
          trend > 0 ? '+${trend.toStringAsFixed(1)}' : trend.toStringAsFixed(1), 
          trend > 0 ? Icons.arrow_upward : trend < 0 ? Icons.arrow_downward : Icons.remove, 
          appColors, 
          theme
        ),
      ],
    );
  }

  Widget _buildMoodStatCard(String label, String value, IconData icon, AppColors? appColors, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors?.surfaceVariant ?? theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: appColors?.accentPrimary ?? theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHighlightMoments(AnalyticsProvider analyticsProvider, AppColors? appColors, ThemeData theme) {
    final highlightMoments = _getWeeklyHighlightMoments(analyticsProvider);
    
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: appColors?.accentSecondary ?? theme.colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Momentos Destacados de la Semana',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (highlightMoments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 48,
                      color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay momentos registrados esta semana',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: highlightMoments.length,
                itemBuilder: (context, index) {
                  final moment = highlightMoments[index];
                  return _buildMomentFlashcard(moment, appColors, theme);
                },
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyHighlightMoments(AnalyticsProvider analyticsProvider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    final optimizedProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);
    final moments = optimizedProvider.moments
        .where((moment) => 
            moment.timestamp.isAfter(weekStart) && 
            moment.timestamp.isBefore(weekEnd))
        .toList();
    
    // Sort by intensity (descending) and take top 5
    moments.sort((a, b) => b.intensity.compareTo(a.intensity));
    
    return moments.take(5).map((moment) => {
      'emoji': moment.emoji,
      'text': moment.text,
      'intensity': moment.intensity,
      'date': moment.timestamp,
      'type': moment.type,
    }).toList();
  }

  Widget _buildMomentFlashcard(Map<String, dynamic> moment, AppColors? appColors, ThemeData theme) {
    final intensity = moment['intensity'] as int;
    final date = moment['date'] as DateTime;
    final emoji = moment['emoji'] as String;
    final text = moment['text'] as String;
    
    final intensityColor = _getIntensityColor(intensity, appColors, theme);
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            intensityColor.withOpacity(0.1),
            intensityColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: intensityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: intensityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$intensity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: appColors?.textPrimary ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: appColors?.textSecondary ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(int intensity, AppColors? appColors, ThemeData theme) {
    if (intensity >= 8) return Colors.green;
    if (intensity >= 6) return appColors?.accentPrimary ?? theme.colorScheme.primary;
    if (intensity >= 4) return Colors.orange;
    return Colors.red;
  }

  // Helper methods
  Color _getSilhouetteColor(double score, AppColors? appColors, ThemeData theme) {
    if (score > 0.7) return appColors?.positiveMain ?? Colors.green;
    if (score > 0.5) return appColors?.accentPrimary ?? Colors.blue;
    if (score > 0.25) return Colors.orange;
    return appColors?.negativeMain ?? Colors.red;
  }
}

// Custom painter for the parameter chart
class ParameterChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String selectedParameter;
  final Color accentColor;
  final Color textColor;

  ParameterChartPainter({
    required this.data,
    required this.selectedParameter,
    required this.accentColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    // Calculate positions
    final maxValue = 5.0; // Assuming scale 1-5
    final minValue = 1.0;
    final valueRange = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final value = data[i]['value'] as double;
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((value - minValue) / valueRange) * size.height;
      
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}