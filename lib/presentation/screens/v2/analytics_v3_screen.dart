// ============================================================================
// lib/presentation/screens/v2/analytics_v3_screen.dart
// ANALYTICS V3 SCREEN - DARK THEME WITH BLUE-PURPLE GRADIENTS
// BASED ON USER PROGRESSION ANALYTICS SCREEN STYLE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';

// Providers
import '../../providers/analytics_v3_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';

// Components
import 'components/minimal_colors.dart';

class AnalyticsV3Screen extends StatefulWidget {
  const AnalyticsV3Screen({super.key});

  @override
  State<AnalyticsV3Screen> createState() => _AnalyticsV3ScreenState();
}

class _AnalyticsV3ScreenState extends State<AnalyticsV3Screen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  
  int _selectedPeriod = 30;
  final List<int> _periodOptions = [7, 30, 90];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
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
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.linear));
    
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  void _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        final analyticsProvider = Provider.of<AnalyticsV3Provider>(context, listen: false);
        await analyticsProvider.loadAnalytics(currentUser.id, periodDays: _selectedPeriod);
        // Load new analytics methods
        await analyticsProvider.loadAllNewAnalytics(currentUser.id, periodDays: _selectedPeriod);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.primaryBg,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeProvider.primaryBg,
                  themeProvider.surface,
                  themeProvider.surfaceVariant,
                  themeProvider.primaryBg,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(themeProvider),
                  _buildPeriodSelector(themeProvider),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState(themeProvider)
                        : _buildAnalyticsContent(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.borderColor,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: themeProvider.textPrimary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: themeProvider.gradientHeader,
                    ).createShader(bounds),
                    child: Text(
                      'Analytics V3',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Análisis avanzado de bienestar',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: themeProvider.gradientHeader,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.accentPrimary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.insights,
                      color: themeProvider.surface,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeProvider themeProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: _periodOptions.map((period) {
            final isSelected = period == _selectedPeriod;
            return Expanded(
              child: GestureDetector(
                onTap: () => _updatePeriod(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: themeProvider.gradientHeader,
                          )
                        : null,
                    color: isSelected ? null : themeProvider.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : themeProvider.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPeriodLabel(period),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? themeProvider.surface : themeProvider.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _shimmerController.value * 2 * math.pi,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.gradientHeader,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: themeProvider.surface,
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Generando análisis...',
            style: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return Consumer<AnalyticsV3Provider>(
      builder: (context, provider, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            if (provider.error != null) {
              return _buildErrorState(provider.error!, themeProvider);
            }

            if (!provider.hasData) {
              return _buildEmptyState(themeProvider);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Insufficient data warning if needed
                  if (!provider.hasSufficientData)
                    _buildInsufficientDataWarning(provider, themeProvider),
                  if (!provider.hasSufficientData)
                    const SizedBox(height: 20),
                  _buildWellnessScoreCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildQuickStatsRow(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildCorrelationsCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildSleepPatternCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildStressAnalysisCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildGoalAnalyticsCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildProductivityPatternsCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildMoodStabilityCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildLifestyleBalanceCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildEnergyPatternsCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildSocialWellnessCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildHabitConsistencyCard(provider, themeProvider),
                  const SizedBox(height: 20),
                  _buildInsightsCard(provider, themeProvider),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWellnessScoreCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final wellness = provider.wellnessScore;
    if (wellness == null) return const SizedBox();

    // Check if this specific metric has insufficient data
    final hasInsufficientData = provider.hasInsufficientWellnessData;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
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
                    gradient: LinearGradient(
                      colors: themeProvider.gradientHeader,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: themeProvider.surface,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Score de Bienestar',
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hasInsufficientData) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.amber.shade600,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        provider.wellnessLevelDisplay,
                        style: TextStyle(
                          color: hasInsufficientData 
                            ? Colors.amber.shade700 
                            : themeProvider.textSecondary,
                          fontSize: 14,
                          fontWeight: hasInsufficientData 
                            ? FontWeight.w500 
                            : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${wellness.overallScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildWellnessRadarChart(wellness, themeProvider),
            const SizedBox(height: 16),
            _buildComponentScores(wellness.componentScores, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessRadarChart(wellness, ThemeProvider themeProvider) {
    final chartData = Provider.of<AnalyticsV3Provider>(context).wellnessChartData;
    
    if (chartData.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'Sin datos para mostrar',
          style: TextStyle(
            color: themeProvider.textHint,
            fontSize: 14,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              dataEntries: chartData
                  .map((data) => RadarEntry(value: data['value'] as double))
                  .toList(),
              fillColor: themeProvider.accentPrimary.withValues(alpha: 0.2),
              borderColor: themeProvider.accentPrimary,
              borderWidth: 2,
            ),
          ],
          radarBorderData: BorderSide(
            color: themeProvider.borderColor,
            width: 1,
          ),
          gridBorderData: BorderSide(
            color: themeProvider.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
          radarTouchData: RadarTouchData(enabled: false),
          getTitle: (index, angle) => RadarChartTitle(
            text: chartData[index]['category'] as String,
            angle: angle,
            positionPercentageOffset: 0.1,
          ),
          titleTextStyle: TextStyle(
            color: themeProvider.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildComponentScores(Map<String, double> scores, ThemeProvider themeProvider) {
    return Column(
      children: scores.entries.map((entry) {
        final translatedName = _translateComponent(entry.key);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  translatedName,
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: themeProvider.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: entry.value / 10.0,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeProvider.gradientHeader,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.value.toStringAsFixed(1),
                style: TextStyle(
                  color: themeProvider.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickStatsRow(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(child: _buildQuickStat('Sueño', '${provider.sleepPattern?.averageSleepHours.toStringAsFixed(1) ?? 'N/A'}h', Icons.bedtime, themeProvider)),
        const SizedBox(width: 12),
        Expanded(child: _buildQuickStat('Estrés', '${provider.stressManagement?.averageStressLevel.toStringAsFixed(1) ?? 'N/A'}/10', Icons.psychology, themeProvider)),
        const SizedBox(width: 12),
        Expanded(child: _buildQuickStat('Metas', '${((provider.goalAnalytics?.completionRate ?? 0) * 100).toStringAsFixed(0)}%', Icons.flag, themeProvider)),
      ],
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, ThemeProvider themeProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: themeProvider.accentPrimary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: themeProvider.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrelationsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final correlations = provider.activityCorrelations;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
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
                    gradient: LinearGradient(
                      colors: themeProvider.gradientHeader,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: themeProvider.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Correlaciones de Actividades',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (correlations.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(
                  'No hay suficientes datos para mostrar correlaciones',
                  style: TextStyle(
                    color: themeProvider.textHint,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Column(
                children: correlations.take(3).map((correlation) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${correlation.activityName} → ${correlation.targetMetric}',
                                style: TextStyle(
                                  color: themeProvider.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                correlation.insight,
                                style: TextStyle(
                                  color: themeProvider.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(_getCorrelationColor(correlation.correlationStrength)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(correlation.correlationStrength * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: themeProvider.surface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepPatternCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final sleep = provider.sleepPattern;
    if (sleep == null) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
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
                    gradient: const LinearGradient(
                      colors: [MinimalColors.accent, MinimalColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.bedtime,
                    color: themeProvider.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patrones de Sueño',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.sleepPatternDisplay,
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${sleep.averageSleepHours.toStringAsFixed(1)}h',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSleepChart(sleep, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart(sleep, ThemeProvider themeProvider) {
    final chartData = Provider.of<AnalyticsV3Provider>(context).sleepChartData;
    
    if (chartData.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          'Sin datos de sueño',
          style: TextStyle(
            color: themeProvider.textHint,
            fontSize: 14,
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 12,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < chartData.length) {
                    return Text(
                      chartData[value.toInt()]['day'].toString().substring(0, 3),
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: themeProvider.borderColor.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: chartData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value['hours'] as double,
                  gradient: LinearGradient(
                    colors: themeProvider.gradientHeader,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStressAnalysisCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final stress = provider.stressManagement;
    if (stress == null) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
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
                    gradient: const LinearGradient(
                      colors: [MinimalColors.accent, MinimalColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: themeProvider.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis de Estrés',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.stressTrendDisplay,
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stress.averageStressLevel.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stress.highStressDaysCount} días altos',
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (stress.recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recomendaciones:',
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...stress.recommendations.take(2).map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: themeProvider.accentPrimary,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rec,
                              style: TextStyle(
                                color: themeProvider.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalAnalyticsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final goals = provider.goalAnalytics;
    if (goals == null) return const SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
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
                    gradient: const LinearGradient(
                      colors: [MinimalColors.accent, MinimalColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.flag,
                    color: themeProvider.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis de Metas',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider.goalPerformanceDisplay,
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(goals.completionRate * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${goals.completedGoals}/${goals.totalGoals} completadas',
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 12,
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
                  child: _buildGoalStat('En Progreso', goals.inProgressGoals.toString(), Icons.schedule, themeProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGoalStat('Tiempo Promedio', '${goals.averageCompletionTime.toStringAsFixed(0)} días', Icons.timer, themeProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStat(String title, String value, IconData icon, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.surface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: themeProvider.accentPrimary,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final insights = provider.topInsights;
    final recommendations = provider.topRecommendations;

    if (insights.isEmpty && recommendations.isEmpty) {
      return const SizedBox();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.surface.withValues(alpha: 0.3),
              themeProvider.surfaceVariant.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
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
                    gradient: LinearGradient(
                      colors: themeProvider.gradientHeader,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: themeProvider.surface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Insights y Recomendaciones',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (insights.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Insights Clave:',
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...insights.map((insight) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: themeProvider.accentPrimary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recomendaciones:',
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: themeProvider.accentSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeProvider themeProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: themeProvider.negativeMain,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar analytics',
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: themeProvider.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAnalyticsData,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.accentPrimary,
                foregroundColor: themeProvider.surface,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientDataWarning(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Datos Insuficientes para Análisis Completo',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.surface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.motivationalMessage,
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            provider.insufficientDataMessage,
            style: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: themeProvider.textHint,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Sin datos disponibles',
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '🌱 ¡Excelente inicio! Cada día que registras datos mejora la precisión de tus insights.',
                    style: TextStyle(
                      color: themeProvider.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Registra tus datos diarios para ver análisis detallados de tu bienestar',
                    style: TextStyle(
                      color: themeProvider.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePeriod(int newPeriod) {
    setState(() => _selectedPeriod = newPeriod);
    
    final provider = Provider.of<AnalyticsV3Provider>(context, listen: false);
    provider.setPeriodDays(newPeriod);
    
    _loadAnalyticsData();
  }

  String _getPeriodLabel(int days) {
    switch (days) {
      case 7: return '7 días';
      case 30: return '30 días';
      case 90: return '90 días';
      default: return '$days días';
    }
  }

  // ============================================================================
  // NEW ANALYTICS CARD WIDGETS
  // ============================================================================

  Widget _buildProductivityPatternsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final productivity = provider.productivityPatterns;
    if (productivity == null) return const SizedBox();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.1),
              Colors.deepOrange.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
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
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patrones de Productividad',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Análisis de rendimiento y horas pico',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (productivity['peak_hours'] != null)
              _buildDataRow('Hora Pico', '${productivity['peak_hours']}:00', Icons.schedule, themeProvider),
            if (productivity['productivity_score'] != null)
              _buildDataRow('Score Productividad', '${productivity['productivity_score']?.toStringAsFixed(1)}/10', Icons.assessment, themeProvider),
            if (productivity['recommendations'] != null && productivity['recommendations'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        productivity['recommendations'][0] ?? '',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStabilityCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final mood = provider.moodStability;
    if (mood == null) return const SizedBox();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.deepPurple.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.purple.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.purple,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estabilidad del Ánimo',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Variabilidad y patrones emocionales',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (mood['stability_score'] != null)
              _buildDataRow('Estabilidad', '${mood['stability_score']?.toStringAsFixed(1)}/10', Icons.psychology, themeProvider),
            if (mood['mood_variance'] != null)
              _buildDataRow('Variabilidad', '${mood['mood_variance']?.toStringAsFixed(2)}', Icons.show_chart, themeProvider),
            if (mood['triggers'] != null && mood['triggers'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_outlined, color: Colors.purple, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Posibles Desencadenantes:',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...mood['triggers'].take(2).map<Widget>((trigger) => 
                      Text(
                        '• $trigger',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleBalanceCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final lifestyle = provider.lifestyleBalance;
    if (lifestyle == null) return const SizedBox();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.teal.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.balance,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance de Vida',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Equilibrio entre áreas de vida',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lifestyle['balance_score'] != null)
              _buildDataRow('Score Balance', '${lifestyle['balance_score']?.toStringAsFixed(1)}/10', Icons.balance, themeProvider),
            if (lifestyle['life_areas'] != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: Column(
                  children: lifestyle['life_areas'].entries.take(3).map<Widget>((entry) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key.toString().replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                color: themeProvider.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 8,
                            decoration: BoxDecoration(
                              color: themeProvider.surface.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (entry.value as num).toDouble() / 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(entry.value as num).toStringAsFixed(1)}',
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyPatternsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final energy = provider.energyPatterns;
    if (energy == null) return const SizedBox();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.yellow.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.battery_charging_full,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patrones de Energía',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cronotipos y potenciadores de energía',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (energy['chronotype'] != null)
              _buildDataRow('Cronotipo', energy['chronotype'].toString(), Icons.schedule, themeProvider),
            if (energy['peak_energy_time'] != null)
              _buildDataRow('Pico de Energía', '${energy['peak_energy_time']}:00', Icons.battery_full, themeProvider),
            if (energy['energy_boosters'] != null && energy['energy_boosters'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Potenciadores de Energía:',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...energy['energy_boosters'].take(2).map<Widget>((booster) => 
                      Text(
                        '• ${booster['factor']} (${(booster['correlation'] * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialWellnessCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final social = provider.socialWellness;
    if (social == null) return const SizedBox();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.1),
              Colors.pinkAccent.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.pink.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.pink,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienestar Social',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Impacto de las interacciones sociales',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (social['social_wellness_score'] != null)
              _buildDataRow('Score Social', '${social['social_wellness_score']?.toStringAsFixed(1)}/10', Icons.people, themeProvider),
            if (social['social_battery_pattern'] != null)
              _buildDataRow('Patrón Batería Social', social['social_battery_pattern'].toString(), Icons.battery_3_bar, themeProvider),
            if (social['recommendations'] != null && social['recommendations'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.pink, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        social['recommendations'][0] ?? '',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitConsistencyCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final habits = provider.habitConsistency;
    if (habits == null) return const SizedBox();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyan.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: Colors.cyan,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consistencia de Hábitos',
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Seguimiento y efectividad de hábitos',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (habits['consistency_score'] != null)
              _buildDataRow('Score Consistencia', '${habits['consistency_score']?.toStringAsFixed(1)}/10', Icons.track_changes, themeProvider),
            if (habits['longest_streak'] != null)
              _buildDataRow('Racha Más Larga', '${habits['longest_streak']} días', Icons.local_fire_department, themeProvider),
            if (habits['most_effective_habits'] != null && habits['most_effective_habits'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeProvider.surface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.cyan, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Hábitos Más Efectivos:',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...habits['most_effective_habits'].take(2).map<Widget>((habit) => 
                      Text(
                        '• ${habit['habit']} (${(habit['effectiveness'] * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: themeProvider.textSecondary, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for translations and colors
  String _translateComponent(String component) {
    final translations = {
      'mood': 'Estado de Ánimo',
      'energy': 'Energía',
      'stress': 'Estrés',
      'sleep': 'Sueño',
      'anxiety': 'Ansiedad',
      'motivation': 'Motivación',
      'emotional_stability': 'Estabilidad Emocional',
      'life_satisfaction': 'Satisfacción',
    };
    return translations[component] ?? component;
  }

  int _getCorrelationColor(double strength) {
    final absStrength = strength.abs();
    if (absStrength >= 0.7) {
      return strength > 0 ? 0xFF4CAF50 : 0xFFF44336; // Strong: Green/Red
    } else if (absStrength >= 0.3) {
      return strength > 0 ? 0xFF8BC34A : 0xFFFF5722; // Moderate: Light Green/Deep Orange
    } else {
      return 0xFF9E9E9E; // Weak: Grey
    }
  }
}