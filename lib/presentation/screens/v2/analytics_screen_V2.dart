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
    _tabController = TabController(length: 6, vsync: this);
    
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
      // Ejecutar análisis avanzado completo
      final results = await provider.performCompleteAdvancedAnalysis(userId);
      
      setState(() {
        _advancedAnalysisResults = results;
      });
    } catch (e) {
      print('Error en análisis emocional avanzado: $e');
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
          _buildPatternComponent('Progreso', wellbeingStatus['score'], 10, '📈', appColors, theme),
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
                '${((achievement['progress'] as double) * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: appColors?.accentPrimary ?? theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: achievement['progress'] as double,
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
          'mood_sleep': _getCorrelationValue(correlationMatrix, 'moodScore', 'sleepQuality'),
          'energy_exercise': _getCorrelationValue(correlationMatrix, 'energyLevel', 'physicalActivity'),
          'stress_meditation': _getCorrelationValue(correlationMatrix, 'stressLevel', 'meditationMinutes'),
          'mood_social': _getCorrelationValue(correlationMatrix, 'moodScore', 'socialInteraction'),
          'stress_sleep': _getCorrelationValue(correlationMatrix, 'stressLevel', 'sleepQuality'),
          'top_correlations': _extractTopCorrelations(correlationMatrix, significanceTests),
          'correlation_matrix': correlationMatrix,
          'significance_tests': significanceTests,
        };
      }
    }
    
    // Fallback sin datos
    return {
      'mood_sleep': 0.0,
      'energy_exercise': 0.0,
      'stress_meditation': 0.0,
      'mood_social': 0.0,
      'stress_sleep': 0.0,
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
    final key1 = '${factor1}_$factor2';
    final key2 = '${factor2}_$factor1';
    
    if (matrix.containsKey(key1)) {
      return (matrix[key1] as num?)?.toDouble() ?? 0.0;
    } else if (matrix.containsKey(key2)) {
      return (matrix[key2] as num?)?.toDouble() ?? 0.0;
    }
    
    return 0.0;
  }
  
  List<Map<String, dynamic>> _extractTopCorrelations(Map<String, dynamic> matrix, Map<String, dynamic> significance) {
    final correlations = <Map<String, dynamic>>[];
    
    matrix.forEach((key, value) {
      if (value is num && value.abs() > 0.3) {
        final parts = key.split('_');
        if (parts.length >= 2) {
          final isSignificant = significance[key] != null;
          correlations.add({
            'factor1': _formatFactorName(parts[0]),
            'factor2': _formatFactorName(parts[1]),
            'strength': value.toDouble(),
            'is_significant': isSignificant,
          });
        }
      }
    });
    
    correlations.sort((a, b) => (b['strength'] as double).abs().compareTo((a['strength'] as double).abs()));
    return correlations.take(5).toList();
  }
  
  String _formatFactorName(String factor) {
    final nameMap = {
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
    
    correlationMatrix.keys.forEach((key) {
      final parts = key.split('_');
      if (parts.length >= 2) {
        factors.addAll(parts);
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
              const SizedBox(height: 20),
              _buildAdvancedAnomalyDetectionCard(advancedProvider, appColors, theme),
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
    final stability = analysis['stability_score'] ?? 5.0;
    final trend = analysis['stability_trend'] ?? 'stable';
    
    return _buildAnimatedCard(
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
      appColors: appColors,
      theme: theme,
    );
  }
  
  Widget _buildEmotionalRangeCard(AppColors? appColors, ThemeData theme) {
    final analysis = _emotionalAnalysis;
    final emotions = analysis['emotional_range'] ?? [];
    final dominant = analysis['dominant_emotion'] ?? 'Equilibrado';
    
    return _buildAnimatedCard(
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
                color: appColors?.accentPrimary?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
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
      appColors: appColors,
      theme: theme,
    );
  }
  
  Widget _buildResilienceCard(AppColors? appColors, ThemeData theme) {
    final analysis = _emotionalAnalysis;
    final resilience = analysis['resilience_score'] ?? 5.0;
    
    return _buildAnimatedCard(
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
      appColors: appColors,
      theme: theme,
    );
  }
  
  Widget _buildTopCorrelationsCard(AppColors? appColors, ThemeData theme) {
    final analysis = _correlationAnalysis;
    final correlations = analysis['top_correlations'] ?? [];
    
    return _buildAnimatedCard(
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
      appColors: appColors,
      theme: theme,
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
      appColors: appColors,
      theme: theme,
    );
  }
  
  Widget _buildTimePatternsCard(AppColors? appColors, ThemeData theme) {
    final analysis = _patternAnalysis;
    final bestDay = analysis['best_day_of_week'] ?? 'Lunes';
    final bestHour = analysis['best_hour_of_day'] ?? 10;
    final peakTime = analysis['peak_energy_time'] ?? '10:00 - 12:00';
    
    return _buildAnimatedCard(
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
      appColors: appColors,
      theme: theme,
    );
  }
  
  Widget _buildWeeklyPatternsCard(AppColors? appColors, ThemeData theme) {
    final analysis = _patternAnalysis;
    final patterns = analysis['seasonal_patterns'] ?? [];
    final consistency = analysis['weekly_consistency'] ?? 0.0;
    
    return _buildAnimatedCard(
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
      appColors: appColors,
      theme: theme,
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
      appColors: appColors,
      theme: theme,
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
                ? appColors?.positiveMain?.withOpacity(0.1) ?? Colors.green.withOpacity(0.1)
                : appColors?.negativeMain?.withOpacity(0.1) ?? Colors.red.withOpacity(0.1),
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
                  color: appColors?.accentPrimary?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
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
      appColors: appColors,
      theme: theme,
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
      appColors: appColors,
      theme: theme,
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
                color: appColors?.positiveMain?.withOpacity(0.1) ?? Colors.green.withOpacity(0.1),
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
      appColors: appColors,
      theme: theme,
    );
  }

  // Helper methods
  Color _getSilhouetteColor(double score, AppColors? appColors, ThemeData theme) {
    if (score > 0.7) return appColors?.positiveMain ?? Colors.green;
    if (score > 0.5) return appColors?.accentPrimary ?? Colors.blue;
    if (score > 0.25) return Colors.orange;
    return appColors?.negativeMain ?? Colors.red;
  }
}