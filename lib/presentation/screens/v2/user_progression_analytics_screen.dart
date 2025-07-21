// lib/presentation/screens/v2/user_progression_analytics_screen.dart
// ============================================================================
// ANALYTICS SCREEN - DISEÑO MINIMALISTA CON FONDO NEGRO Y GRADIENTES AZUL-MORADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers
import '../../providers/analytics_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/advanced_emotion_analysis_provider.dart';

// Componentes
import 'components/minimal_colors.dart';

class UserProgressionAnalyticsScreen extends StatefulWidget {
  const UserProgressionAnalyticsScreen({super.key});

  @override
  State<UserProgressionAnalyticsScreen> createState() => _UserProgressionAnalyticsScreenState();
}

class _UserProgressionAnalyticsScreenState extends State<UserProgressionAnalyticsScreen>
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
  final List<String> _periodLabels = ['7 días', '30 días', '90 días'];
  
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
    
    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  void _loadAnalyticsData() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final advancedProvider = Provider.of<AdvancedEmotionAnalysisProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      setState(() {
        _isLoading = true;
      });
      
      // Load both basic and advanced analytics
      await Future.wait([
        analyticsProvider.loadCompleteAnalytics(user.id, days: _selectedPeriod),
        advancedProvider.performCompleteAdvancedAnalysis(user.id),
      ]);
      
      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: SafeArea(
        child: Consumer2<AnalyticsProvider, AdvancedEmotionAnalysisProvider>(
          builder: (context, analyticsProvider, advancedProvider, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Header similar al home
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  
                  // Period Selector
                  SliverToBoxAdapter(
                    child: _buildPeriodSelector(),
                  ),
                  
                  // Loading indicator
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: _buildLoadingIndicator(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Emotional Personality Card (New)
                          _buildEmotionalPersonalityCard(advancedProvider),
                          const SizedBox(height: 20),
                          
                          // Metric Highlight Cards (New)
                          _buildMetricHighlightCards(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Forecasts de Mood Avanzados (New)
                          _buildMoodForecastsCard(advancedProvider),
                          const SizedBox(height: 20),
                          
                          // Streak Analysis
                          _buildStreakCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Wellbeing Prediction
                          _buildWellbeingCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Dominant Themes
                          _buildDominantThemesCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Priority Recommendations
                          _buildPriorityRecommendationsCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Current Day Analysis
                          _buildCurrentDayAnalysisCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Highlighted Insights
                          _buildHighlightedInsightsCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Stress Alerts
                          _buildStressAlertsCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Next Achievement
                          _buildNextAchievementCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Mood Chart
                          _buildMoodChartCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Dashboard Summary
                          _buildDashboardSummaryCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Correlation Matrix
                          _buildCorrelationMatrix(advancedProvider),
                          const SizedBox(height: 20),
                          
                          // Emotional Clustering
                          _buildEmotionalClustering(advancedProvider),
                          const SizedBox(height: 20),
                          
                          // Habits Analysis
                          _buildHabitsCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Progress Overview
                          _buildProgressOverview(analyticsProvider),
                          const SizedBox(height: 40),
                        ]),
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

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              // Icon con gradiente
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Título con shimmer
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, math.sin(_shimmerAnimation.value * math.pi * 2) * 1),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: MinimalColors.accentGradient(context),
                      ).createShader(bounds),
                      child: const Text(
                        'Tu Progreso Analítico',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Insights avanzados sobre tu bienestar',
                style: TextStyle(
                  fontSize: 16,
                  color: MinimalColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _periodOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final days = entry.value;
          final isSelected = _selectedPeriod == days;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = days;
              });
              _loadAnalyticsData();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? LinearGradient(colors: MinimalColors.accentGradient(context))
                  : null,
                color: isSelected ? null : MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? Colors.transparent 
                    : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _periodLabels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : MinimalColors.textSecondary(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
        ),
      ),
    );
  }

  Widget _buildStreakCard(AnalyticsProvider analyticsProvider) {
    // Use AnalyticsProvider's getStreakData method
    final streakData = analyticsProvider.getStreakData();
    final currentStreak = streakData['current'] as int;
    final longestStreak = streakData['longest'] as int;
    final streakActive = currentStreak > 0;
    final message = streakData['message'] as String;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        streakActive ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Racha de Progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: streakActive ? MinimalColors.accentGradient(context) : [
                            MinimalColors.textMuted(context),
                            MinimalColors.textMuted(context),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        streakActive ? 'Activa' : 'Inactiva',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Streak Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: streakActive 
                        ? MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.2)).toList()
                        : [
                            MinimalColors.backgroundSecondary(context),
                            MinimalColors.backgroundSecondary(context),
                          ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: streakActive 
                        ? MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.5)
                        : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Current Streak
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Racha Actual',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$currentStreak',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              'días',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        width: 1,
                        height: 60,
                        color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      ),
                      
                      // Longest Streak
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Récord Personal',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$longestStreak',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              'días',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Milestones
                _buildMilestoneProgress(currentStreak),
                
                const SizedBox(height: 16),
                
                // Streak Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: MinimalColors.textSecondary(context),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: MinimalColors.textSecondary(context),
                            fontSize: 14,
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
      },
    );
  }

  Widget _buildMilestoneProgress(int currentStreak) {
    final milestones = [
      {'days': 3, 'title': 'Primer Paso', 'emoji': '🌱'},
      {'days': 7, 'title': 'Una Semana', 'emoji': '🔥'},
      {'days': 14, 'title': 'Dos Semanas', 'emoji': '⚡'},
      {'days': 30, 'title': 'Un Mes', 'emoji': '💎'},
      {'days': 60, 'title': 'Dos Meses', 'emoji': '🌟'},
      {'days': 90, 'title': 'Tres Meses', 'emoji': '👑'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso hacia Logros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            final days = milestone['days'] as int;
            final title = milestone['title'] as String;
            final emoji = milestone['emoji'] as String;
            final isAchieved = currentStreak >= days;
            final isCurrent = currentStreak < days && 
                            (index == 0 || currentStreak >= (milestones[index - 1]['days'] as int));
            
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isAchieved 
                  ? LinearGradient(colors: MinimalColors.accentGradient(context))
                  : isCurrent 
                    ? LinearGradient(colors: MinimalColors.lightGradient(context))
                    : null,
                color: (!isAchieved && !isCurrent) ? MinimalColors.backgroundSecondary(context) : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAchieved || isCurrent 
                    ? Colors.transparent 
                    : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: (isAchieved || isCurrent) ? Colors.white : MinimalColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$days días',
                    style: TextStyle(
                      fontSize: 8,
                      color: (isAchieved || isCurrent) ? Colors.white70 : MinimalColors.textTertiary(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWellbeingCard(AnalyticsProvider analyticsProvider) {
    // Use AnalyticsProvider's getWellbeingStatus method
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final score = wellbeingStatus['score'] as int;
    // Additional wellbeing data available if needed
    // final level = wellbeingStatus['level'] as String;
    // final emoji = wellbeingStatus['emoji'] as String;
    // final message = wellbeingStatus['message'] as String;
    // final color = wellbeingStatus['color'] as Color;
    // final progress = wellbeingStatus['progress'] as double;
    
    // Get advanced mood prediction
    final moodPrediction = analyticsProvider.getAdvancedMoodPrediction();
    final hasValidPrediction = moodPrediction['available'] as bool;
    
    double predictionScore = score.toDouble();
    double confidence = 0.0;
    String currentTrend = 'stable';
    
    if (hasValidPrediction) {
      final predictions = moodPrediction['predictions'] as List<dynamic>? ?? [];
      if (predictions.isNotEmpty) {
        final nextPrediction = predictions.first as Map<String, dynamic>;
        predictionScore = (nextPrediction['predicted_mood'] as num?)?.toDouble() ?? score.toDouble();
        confidence = moodPrediction['confidence'] as double? ?? 0.0;
        
        // Determine trend
        if (predictionScore > score + 0.5) {
          currentTrend = 'improving';
        } else if (predictionScore < score - 0.5) {
          currentTrend = 'declining';
        } else {
          currentTrend = 'stable';
        }
      }
    }
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getTrendIcon(currentTrend),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Predicción de Bienestar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTrendLabel(currentTrend),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Prediction Display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.2)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Predicted Score
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Puntuación Prevista',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              predictionScore.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              'de 10',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        width: 1,
                        height: 60,
                        color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      ),
                      
                      // Confidence
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Confianza',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(confidence * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              'precisión',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary(context),
                              ),
                            ),
                          ],
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
  
  // Removed unused _calculateTrendSlope method

  Widget _buildCorrelationMatrix(AdvancedEmotionAnalysisProvider advancedProvider) {
    final correlationMatrix = _calculateRealCorrelationMatrix();
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.grid_view,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Matriz de Correlación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Correlation Matrix Heatmap
                _buildCorrelationHeatmap(correlationMatrix),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCorrelationHeatmap(Map<String, dynamic> correlationMatrix) {
    final variables = ['mood', 'energy', 'stress', 'anxiety'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              const SizedBox(width: 60), // Space for row labels
              ...variables.map((variable) => Expanded(
                child: Center(
                  child: Text(
                    variable.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          
          // Matrix Rows
          ...variables.map((rowVar) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Row Label
                SizedBox(
                  width: 60,
                  child: Text(
                    rowVar.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                ),
                // Correlation Cells
                ...variables.map((colVar) {
                  final correlation = _getCorrelationValue(correlationMatrix, rowVar, colVar);
                  return Expanded(
                    child: Container(
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _getCorrelationColor(correlation, context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          correlation.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: correlation.abs() > 0.5 ? Colors.white : MinimalColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmotionalClustering(AdvancedEmotionAnalysisProvider advancedProvider) {
    final clusteringData = _generateClusteringData(advancedProvider);
    final clusters = clusteringData['clusters'] as List<Map<String, dynamic>>;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
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
                    Text(
                      'Clustering Emocional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Clusters List
                if (clusters.isNotEmpty) ...clusters.take(3).map((cluster) {
                  final clusterMap = cluster;
                  final id = clusterMap['id'] as int? ?? 0;
                  final size = clusterMap['size'] as int? ?? 0;
                  final dominantFeature = clusterMap['dominant_feature'] as String? ?? 'unknown';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: MinimalColors.accentGradient(context),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'C${id + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grupo ${id + 1}: ${dominantFeature.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: MinimalColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$size entradas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: MinimalColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitsCard(AnalyticsProvider analyticsProvider) {
    // final analytics = analyticsProvider.analytics;
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    
    // Calculate real habits data from daily entries
    final habitsData = _calculateHabitsFromEntries(dailyEntries);
    final habits = habitsData['habits'] as List<dynamic>? ?? [];
    final overallScore = (habitsData['overall_score'] as num?)?.toDouble() ?? 0.0;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hábitos Saludables',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(overallScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Score Circle
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: MinimalColors.accentGradient(context)[0],
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(overallScore * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MinimalColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            'puntuación',
                            style: TextStyle(
                              fontSize: 12,
                              color: MinimalColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Individual Habits
                if (habits.isNotEmpty) ...[
                  Text(
                    'Hábitos Individuales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...habits.take(3).map((habit) {
                    final habitMap = habit as Map<String, dynamic>;
                    final name = habitMap['name'] as String? ?? 'Hábito';
                    final consistency = (habitMap['consistency'] as num?)?.toDouble() ?? 0.0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MinimalColors.backgroundSecondary(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: MinimalColors.accentGradient(context),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _getHabitIcon(name),
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MinimalColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: MinimalColors.backgroundSecondary(context),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: FractionallySizedBox(
                                          widthFactor: consistency,
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: MinimalColors.accentGradient(context),
                                              ),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(consistency * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: MinimalColors.textSecondary(context),
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
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Map<String, dynamic> _calculateHabitsFromEntries(List<dynamic> entries) {
    if (entries.isEmpty) {
      return {
        'habits': <Map<String, dynamic>>[],
        'overall_score': 0.0,
      };
    }
    
    final habits = <Map<String, dynamic>>[];
    double totalScore = 0.0;
    int habitCount = 0;
    
    // Sleep habits
    final sleepEntries = entries.where((e) => e.sleepHours != null && e.sleepHours > 0).toList();
    if (sleepEntries.isNotEmpty) {
      final avgSleepHours = sleepEntries.fold<double>(0.0, (sum, e) => sum + (e.sleepHours ?? 0)) / sleepEntries.length;
      final consistency = sleepEntries.length / entries.length;
      final quality = (avgSleepHours >= 7 && avgSleepHours <= 9) ? 1.0 : 0.7;
      
      habits.add({
        'name': 'Sueño Saludable',
        'consistency': consistency * quality,
        'average_value': avgSleepHours,
        'unit': 'horas',
      });
      
      totalScore += consistency * quality;
      habitCount++;
    }
    
    // Exercise habits
    final exerciseEntries = entries.where((e) => e.exerciseMinutes != null && e.exerciseMinutes > 0).toList();
    if (exerciseEntries.isNotEmpty) {
      final avgExercise = exerciseEntries.fold<double>(0.0, (sum, e) => sum + (e.exerciseMinutes ?? 0)) / exerciseEntries.length;
      final consistency = exerciseEntries.length / entries.length;
      final quality = (avgExercise >= 30) ? 1.0 : (avgExercise >= 15) ? 0.8 : 0.6;
      
      habits.add({
        'name': 'Ejercicio Regular',
        'consistency': consistency * quality,
        'average_value': avgExercise,
        'unit': 'minutos',
      });
      
      totalScore += consistency * quality;
      habitCount++;
    }
    
    // Meditation habits
    final meditationEntries = entries.where((e) => e.meditationMinutes != null && e.meditationMinutes > 0).toList();
    if (meditationEntries.isNotEmpty) {
      final avgMeditation = meditationEntries.fold<double>(0.0, (sum, e) => sum + (e.meditationMinutes ?? 0)) / meditationEntries.length;
      final consistency = meditationEntries.length / entries.length;
      final quality = (avgMeditation >= 10) ? 1.0 : (avgMeditation >= 5) ? 0.8 : 0.6;
      
      habits.add({
        'name': 'Meditación',
        'consistency': consistency * quality,
        'average_value': avgMeditation,
        'unit': 'minutos',
      });
      
      totalScore += consistency * quality;
      habitCount++;
    }
    
    // Water intake habits
    final waterEntries = entries.where((e) => e.waterIntake != null && e.waterIntake > 0).toList();
    if (waterEntries.isNotEmpty) {
      final avgWater = waterEntries.fold<double>(0.0, (sum, e) => sum + (e.waterIntake ?? 0)) / waterEntries.length;
      final consistency = waterEntries.length / entries.length;
      final quality = (avgWater >= 8) ? 1.0 : (avgWater >= 6) ? 0.8 : 0.6;
      
      habits.add({
        'name': 'Hidratación',
        'consistency': consistency * quality,
        'average_value': avgWater,
        'unit': 'vasos',
      });
      
      totalScore += consistency * quality;
      habitCount++;
    }
    
    final overallScore = habitCount > 0 ? totalScore / habitCount : 0.0;
    
    return {
      'habits': habits,
      'overall_score': overallScore,
    };
  }

  Widget _buildProgressOverview(AnalyticsProvider analyticsProvider) {
    final analytics = analyticsProvider.analytics;
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>? ?? {};
    final streakData = analytics['streak_data'] as Map<String, dynamic>? ?? {};
    final moodTrends = analytics['mood_trends'] as List<dynamic>? ?? [];
    
    // Extract comprehensive data
    final avgWellbeing = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 5.0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 5.0;
    final avgStress = (basicStats['avg_stress'] as num?)?.toDouble() ?? 5.0;
    // final consistencyRate = (basicStats['consistency_rate'] as num?)?.toDouble() ?? 0.0;
    final currentStreak = streakData['current_streak'] as int? ?? 0;
    
    // Calculate additional metrics
    final expectedEntries = _selectedPeriod;
    final actualConsistency = expectedEntries > 0 ? (totalEntries / expectedEntries).clamp(0.0, 1.0) : 0.0;
    
    // Calculate stress management (inverted stress level)
    final stressManagement = avgStress > 0 ? (10 - avgStress) / 10 : 0.5;
    
    // Calculate recent trend
    final recentEntries = moodTrends.take(7).toList();
    final recentMoodAvg = recentEntries.isNotEmpty
        ? recentEntries.fold<double>(0.0, (sum, entry) => sum + ((entry['mood_score'] as num?)?.toDouble() ?? 0.0)) / recentEntries.length
        : avgMood;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Resumen de Progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Últimos $_selectedPeriod días',
                        style: TextStyle(
                          fontSize: 10,
                          color: MinimalColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      'Bienestar Promedio',
                      '${avgWellbeing.toStringAsFixed(1)}/10',
                      Icons.favorite,
                      avgWellbeing / 10,
                    ),
                    _buildStatCard(
                      'Energía Promedio',
                      '${avgEnergy.toStringAsFixed(1)}/10',
                      Icons.battery_charging_full,
                      avgEnergy / 10,
                    ),
                    _buildStatCard(
                      'Gestión del Estrés',
                      '${(stressManagement * 100).toStringAsFixed(0)}%',
                      Icons.self_improvement,
                      stressManagement,
                    ),
                    _buildStatCard(
                      'Consistencia',
                      '${(actualConsistency * 100).toStringAsFixed(0)}%',
                      Icons.timeline,
                      actualConsistency,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Additional metrics row
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        'Entradas',
                        totalEntries.toString(),
                        Icons.edit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMiniStatCard(
                        'Racha Actual',
                        '$currentStreak días',
                        Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMiniStatCard(
                        'Tendencia',
                        recentMoodAvg > avgMood ? '↗️' : recentMoodAvg < avgMood ? '↘️' : '↔️',
                        Icons.trending_up,
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
  
  Widget _buildMiniStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.05)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
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
                color: MinimalColors.primaryGradient(context)[0],
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: MinimalColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: MinimalColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: MinimalColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  double _getCorrelationValue(Map<String, dynamic> correlationMatrix, String rowVar, String colVar) {
    try {
      final rowData = correlationMatrix[rowVar] as Map<String, dynamic>?;
      if (rowData != null) {
        final value = rowData[colVar] as num?;
        return value?.toDouble() ?? 0.0;
      }
      return rowVar == colVar ? 1.0 : 0.0;
    } catch (e) {
      return rowVar == colVar ? 1.0 : 0.0;
    }
  }

  Color _getCorrelationColor(double correlation, BuildContext context) {
    if (correlation > 0.7) {
      return MinimalColors.lightGradient(context)[0];
    } else if (correlation > 0.3) {
      return MinimalColors.accentGradient(context)[0];
    } else if (correlation > -0.3) {
      return MinimalColors.textMuted(context);
    } else if (correlation > -0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
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

  IconData _getHabitIcon(String habitName) {
    final name = habitName.toLowerCase();
    if (name.contains('sleep') || name.contains('sueño')) return Icons.bedtime;
    if (name.contains('exercise') || name.contains('ejercicio')) return Icons.fitness_center;
    if (name.contains('meditation') || name.contains('meditación')) return Icons.self_improvement;
    if (name.contains('water') || name.contains('agua')) return Icons.water_drop;
    if (name.contains('nutrition') || name.contains('nutrición')) return Icons.restaurant;
    return Icons.check_circle;
  }

  // Removed unused _calculateStreakData method - now using analyticsProvider.getStreakData()

  // Removed unused _isSameDay method

  Map<String, dynamic> _generateClusteringData(AdvancedEmotionAnalysisProvider advancedProvider) {
    // Get real clustering data from advanced analysis
    final analysisData = advancedProvider.analysisResults;
    final emotionalClustering = analysisData['emotional_clustering'] as Map<String, dynamic>? ?? {};
    // final hierarchicalClustering = analysisData['hierarchical_clustering'] as Map<String, dynamic>? ?? {};
    
    // Try to use real clustering data first
    final realClusters = emotionalClustering['clusters'] as List<dynamic>? ?? [];
    
    if (realClusters.isNotEmpty) {
      final clusters = <Map<String, dynamic>>[];
      
      for (int i = 0; i < realClusters.length; i++) {
        final cluster = realClusters[i] as Map<String, dynamic>? ?? {};
        final size = cluster['size'] as int? ?? 0;
        final centroid = cluster['centroid'] as Map<String, dynamic>? ?? {};
        final characteristics = cluster['characteristics'] as List<dynamic>? ?? [];
        
        // Determine cluster name and color based on centroid
        String clusterName = cluster['label'] as String? ?? 'Grupo ${i + 1}';
        Color clusterColor = Colors.blue;
        String dominantFeature = 'equilibrio';
        
        final avgMood = (centroid['mood_score'] as num?)?.toDouble() ?? 5.0;
        final avgEnergy = (centroid['energy_level'] as num?)?.toDouble() ?? 5.0;
        final avgStress = (centroid['stress_level'] as num?)?.toDouble() ?? 5.0;
        
        if (avgMood >= 7.0 && avgEnergy >= 6.0) {
          clusterName = 'Estado Positivo';
          clusterColor = Colors.green;
          dominantFeature = 'mood_alto';
        } else if (avgMood >= 5.0 && avgStress <= 4.0) {
          clusterName = 'Estado Equilibrado';
          clusterColor = Colors.blue;
          dominantFeature = 'equilibrio';
        } else if (avgStress >= 6.0 || avgMood <= 4.0) {
          clusterName = 'Estado Desafiante';
          clusterColor = Colors.red;
          dominantFeature = 'necesita_atencion';
        } else {
          clusterName = 'Estado Neutro';
          clusterColor = Colors.orange;
          dominantFeature = 'mood_neutro';
        }
        
        clusters.add({
          'id': i,
          'name': clusterName,
          'size': size,
          'color': clusterColor,
          'characteristics': characteristics.isNotEmpty ? characteristics : _getDefaultCharacteristics(dominantFeature),
          'percentage': cluster['percentage'] as int? ?? 0,
          'dominant_feature': dominantFeature,
          'centroid': centroid,
        });
      }
      
      return {
        'clusters': clusters,
        'silhouette_score': emotionalClustering['silhouette_score'] ?? 0.0,
        'total_points': emotionalClustering['total_points'] ?? 0,
      };
    }
    
    // Fallback to daily entries analysis
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    
    if (dailyEntries.isEmpty) {
      return {
        'clusters': <Map<String, dynamic>>[],
      };
    }

    // Enhanced clustering based on multiple dimensions
    final clusters = <Map<String, dynamic>>[];
    
    // High wellbeing cluster
    final highWellbeingEntries = dailyEntries.where((e) => 
        (e.moodScore ?? 3.0) >= 4.0 && (e.energyLevel ?? 3.0) >= 4.0 && (e.stressLevel ?? 3.0) <= 3.0
    ).toList();
    
    // Moderate wellbeing cluster
    final moderateWellbeingEntries = dailyEntries.where((e) => 
        (e.moodScore ?? 3.0) >= 3.0 && (e.moodScore ?? 3.0) < 4.0 && 
        (e.energyLevel ?? 3.0) >= 2.5 && (e.stressLevel ?? 3.0) <= 4.0
    ).toList();
    
    // Low wellbeing cluster
    final lowWellbeingEntries = dailyEntries.where((e) => 
        (e.moodScore ?? 3.0) < 3.0 || (e.stressLevel ?? 3.0) > 4.0
    ).toList();
    
    int clusterIndex = 0;
    
    if (highWellbeingEntries.isNotEmpty) {
      clusters.add({
        'id': clusterIndex,
        'name': 'Estado Positivo',
        'size': highWellbeingEntries.length,
        'color': Colors.green,
        'characteristics': ['Buen humor', 'Energía alta', 'Bajo estrés', 'Optimismo'],
        'percentage': (highWellbeingEntries.length / dailyEntries.length * 100).round(),
        'dominant_feature': 'alto_bienestar',
      });
      clusterIndex++;
    }
    
    if (moderateWellbeingEntries.isNotEmpty) {
      clusters.add({
        'id': clusterIndex,
        'name': 'Estado Equilibrado',
        'size': moderateWellbeingEntries.length,
        'color': Colors.blue,
        'characteristics': ['Humor estable', 'Energía moderada', 'Equilibrio', 'Consistencia'],
        'percentage': (moderateWellbeingEntries.length / dailyEntries.length * 100).round(),
        'dominant_feature': 'equilibrio',
      });
      clusterIndex++;
    }
    
    if (lowWellbeingEntries.isNotEmpty) {
      clusters.add({
        'id': clusterIndex,
        'name': 'Estado Desafiante',
        'size': lowWellbeingEntries.length,
        'color': Colors.red,
        'characteristics': ['Necesita apoyo', 'Oportunidad crecimiento', 'Reflexión', 'Autocuidado'],
        'percentage': (lowWellbeingEntries.length / dailyEntries.length * 100).round(),
        'dominant_feature': 'necesita_atencion',
      });
      clusterIndex++;
    }

    return {
      'clusters': clusters,
    };
  }
  
  List<String> _getDefaultCharacteristics(String dominantFeature) {
    switch (dominantFeature) {
      case 'mood_alto':
      case 'alto_bienestar':
        return ['Buen humor', 'Energía alta', 'Optimismo', 'Proactividad'];
      case 'equilibrio':
        return ['Humor estable', 'Energía moderada', 'Equilibrio', 'Consistencia'];
      case 'necesita_atencion':
        return ['Necesita apoyo', 'Oportunidad crecimiento', 'Reflexión', 'Autocuidado'];
      default:
        return ['Humor variable', 'Energía fluctuante', 'Adaptabilidad', 'Crecimiento'];
    }
  }

  Map<String, dynamic> _calculateRealCorrelationMatrix() {
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final advancedProvider = Provider.of<AdvancedEmotionAnalysisProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    
    // Try to get correlations from advanced analysis first
    final analysisData = advancedProvider.analysisResults;
    final comprehensiveStats = analysisData['comprehensive_statistics'] as Map<String, dynamic>? ?? {};
    final correlationMatrix = comprehensiveStats['correlation_matrix'] as Map<String, dynamic>? ?? {};
    
    if (correlationMatrix.isNotEmpty) {
      // Use real correlation data from advanced analysis
      final realCorrelations = <String, Map<String, double>>{};
      
      for (final variable in ['mood_score', 'energy_level', 'stress_level', 'anxiety_level']) {
        final varData = correlationMatrix[variable] as Map<String, dynamic>? ?? {};
        final simplifiedVar = variable.replaceAll('_score', '').replaceAll('_level', '');
        
        realCorrelations[simplifiedVar] = {
          'mood': (varData['mood_score'] as num?)?.toDouble() ?? (variable == 'mood_score' ? 1.0 : 0.0),
          'energy': (varData['energy_level'] as num?)?.toDouble() ?? (variable == 'energy_level' ? 1.0 : 0.0),
          'stress': (varData['stress_level'] as num?)?.toDouble() ?? (variable == 'stress_level' ? 1.0 : 0.0),
          'anxiety': (varData['anxiety_level'] as num?)?.toDouble() ?? (variable == 'anxiety_level' ? 1.0 : 0.0),
        };
      }
      
      return realCorrelations;
    }
    
    if (dailyEntries.length < 2) {
      // Return default matrix if insufficient data
      return {
        'mood': {'mood': 1.0, 'energy': 0.0, 'stress': 0.0, 'anxiety': 0.0},
        'energy': {'mood': 0.0, 'energy': 1.0, 'stress': 0.0, 'anxiety': 0.0},
        'stress': {'mood': 0.0, 'energy': 0.0, 'stress': 1.0, 'anxiety': 0.0},
        'anxiety': {'mood': 0.0, 'energy': 0.0, 'stress': 0.0, 'anxiety': 1.0},
      };
    }

    // Extract values for each variable from daily entries
    final moodValues = dailyEntries.map((e) => (e.moodScore as num?)?.toDouble() ?? 3.0).toList();
    final energyValues = dailyEntries.map((e) => (e.energyLevel as num?)?.toDouble() ?? 3.0).toList();
    final stressValues = dailyEntries.map((e) => (e.stressLevel as num?)?.toDouble() ?? 3.0).toList();
    final anxietyValues = dailyEntries.map((e) => (e.anxietyLevel as num?)?.toDouble() ?? 3.0).toList();

    // Calculate correlations
    final correlations = <String, Map<String, double>>{
      'mood': {
        'mood': 1.0,
        'energy': _calculateCorrelation(moodValues, energyValues),
        'stress': _calculateCorrelation(moodValues, stressValues),
        'anxiety': _calculateCorrelation(moodValues, anxietyValues),
      },
      'energy': {
        'mood': _calculateCorrelation(energyValues, moodValues),
        'energy': 1.0,
        'stress': _calculateCorrelation(energyValues, stressValues),
        'anxiety': _calculateCorrelation(energyValues, anxietyValues),
      },
      'stress': {
        'mood': _calculateCorrelation(stressValues, moodValues),
        'energy': _calculateCorrelation(stressValues, energyValues),
        'stress': 1.0,
        'anxiety': _calculateCorrelation(stressValues, anxietyValues),
      },
      'anxiety': {
        'mood': _calculateCorrelation(anxietyValues, moodValues),
        'energy': _calculateCorrelation(anxietyValues, energyValues),
        'stress': _calculateCorrelation(anxietyValues, stressValues),
        'anxiety': 1.0,
      },
    };

    return correlations;
  }

  double _calculateCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0.0;

    final n = x.length;
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;

    double numerator = 0.0;
    double sumXSquared = 0.0;
    double sumYSquared = 0.0;

    for (int i = 0; i < n; i++) {
      final diffX = x[i] - meanX;
      final diffY = y[i] - meanY;
      
      numerator += diffX * diffY;
      sumXSquared += diffX * diffX;
      sumYSquared += diffY * diffY;
    }

    final denominator = math.sqrt(sumXSquared * sumYSquared);
    
    if (denominator == 0) return 0.0;
    
    return numerator / denominator;
  }

  // ============================================================================
  // NEW CARDS FROM DESIGN IMAGES
  // ============================================================================

  Widget _buildEmotionalPersonalityCard(AdvancedEmotionAnalysisProvider advancedProvider) {
    final analysisData = advancedProvider.analysisResults;
    final emotionalClusters = analysisData['emotional_clustering'] as Map<String, dynamic>? ?? {};
    final statistics = analysisData['comprehensive_statistics'] as Map<String, dynamic>? ?? {};
    
    // Extract real personality data
    final clusters = emotionalClusters['clusters'] as List<dynamic>? ?? [];
    final dominantCluster = clusters.isNotEmpty ? clusters.first as Map<String, dynamic> : {};
    final clusterLabel = dominantCluster['label'] as String? ?? 'Perfil Equilibrado';
    final clusterCharacteristics = dominantCluster['characteristics'] as List<dynamic>? ?? [];
    
    // Calculate emotional stability from statistics
    final correlationMatrix = statistics['correlation_matrix'] as Map<String, dynamic>? ?? {};
    final moodCorrelations = correlationMatrix['mood_score'] as Map<String, dynamic>? ?? {};
    final stabilityScore = (moodCorrelations['energy_level'] as num?)?.toDouble() ?? 0.5;
    
    String personalityType = clusterLabel;
    String description = 'Tu perfil emocional muestra características de equilibrio y estabilidad.';
    
    // Generate description based on cluster characteristics
    if (clusterCharacteristics.isNotEmpty) {
      final mainCharacteristic = clusterCharacteristics.first.toString();
      if (mainCharacteristic.contains('positive') || mainCharacteristic.contains('optimistic')) {
        personalityType = 'Naturalmente Positivo';
        description = 'Tu perfil emocional muestra el patrón "Naturalmente Positivo". Destacas por tu buena capacidad de recuperación y estabilidad emocional. Tu tendencia hacia el optimismo es una gran fortaleza.';
      } else if (mainCharacteristic.contains('stable') || mainCharacteristic.contains('balanced')) {
        personalityType = 'Equilibrio Emocional';
        description = 'Tu perfil muestra un excelente equilibrio emocional. Mantienes una consistencia admirable en tus estados de ánimo y respondes de manera adaptativa a los desafíos.';
      } else if (mainCharacteristic.contains('resilient') || mainCharacteristic.contains('strong')) {
        personalityType = 'Resiliente Adaptativo';
        description = 'Tu perfil destaca por su capacidad de recuperación. Tienes una fuerte habilidad para superar adversidades y mantener una perspectiva positiva.';
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: MinimalColors.primaryGradient(context),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context).first.withValues(alpha: 0.3),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tu Personalidad Emocional',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(stabilityScore * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            personalityType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (clusterCharacteristics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: clusterCharacteristics.take(3).map((characteristic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    characteristic.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricHighlightCards(AnalyticsProvider analyticsProvider) {
    final analytics = analyticsProvider.analytics;
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>? ?? {};
    final streakData = analytics['streak_data'] as Map<String, dynamic>? ?? {};
    final moodTrends = analytics['mood_trends'] as List<dynamic>? ?? [];
    
    // Extract real data from analytics
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 0.0;
    final avgWellbeing = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 0.0;
    final avgEnergy = (basicStats['avg_energy'] as num?)?.toDouble() ?? 0.0;
    final currentStreak = streakData['current_streak'] as int? ?? 0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final consistencyRate = (basicStats['consistency_rate'] as num?)?.toDouble() ?? 0.0;
    
    // Calculate recent energy trend
    final recentEntries = moodTrends.take(7).toList();
    final recentEnergyAvg = recentEntries.isNotEmpty
        ? recentEntries.fold<double>(0.0, (sum, entry) => sum + ((entry['energy_level'] as num?)?.toDouble() ?? 0.0)) / recentEntries.length
        : avgEnergy;
    
    // Determine mood status
    String moodTitle = 'Estado de Ánimo';
    String moodSubtitle = 'Tu mood promedio es ${avgMood.toStringAsFixed(1)}/10';
    IconData moodIcon = Icons.sentiment_satisfied;
    Color moodColor = Colors.blue;
    
    if (avgWellbeing >= 7.5) {
      moodTitle = 'Excelente Estado de Ánimo';
      moodIcon = Icons.sentiment_very_satisfied;
      moodColor = Colors.green;
    } else if (avgWellbeing >= 6.0) {
      moodTitle = 'Buen Estado de Ánimo';
      moodIcon = Icons.sentiment_satisfied;
      moodColor = Colors.blue;
    } else if (avgWellbeing >= 4.0) {
      moodTitle = 'Estado de Ánimo Estable';
      moodIcon = Icons.sentiment_neutral;
      moodColor = Colors.orange;
    } else {
      moodTitle = 'Estado de Ánimo en Mejora';
      moodIcon = Icons.sentiment_dissatisfied;
      moodColor = Colors.red;
    }
    
    // Determine energy status
    String energyTitle = 'Energía';
    String energySubtitle = 'Nivel promedio de energía';
    IconData energyIcon = Icons.battery_3_bar;
    Color energyColor = Colors.yellow;
    
    if (recentEnergyAvg >= 7.0) {
      energyTitle = 'Energía Alta';
      energySubtitle = 'Mantienes excelentes niveles de energía';
      energyIcon = Icons.flash_on_rounded;
      energyColor = Colors.amber;
    } else if (recentEnergyAvg >= 5.0) {
      energyTitle = 'Energía Buena';
      energySubtitle = 'Niveles de energía saludables';
      energyIcon = Icons.battery_charging_full;
      energyColor = Colors.green;
    } else {
      energyTitle = 'Energía Moderada';
      energySubtitle = 'Considera estrategias para aumentar energía';
      energyIcon = Icons.battery_2_bar;
      energyColor = Colors.orange;
    }
    
    // Determine activity status
    String activityTitle = 'Actividad';
    String activitySubtitle = 'Has registrado $totalEntries entradas';
    IconData activityIcon = Icons.bar_chart_rounded;
    Color activityColor = Colors.green;
    
    if (consistencyRate >= 0.8) {
      activityTitle = 'Muy Activo';
      activitySubtitle = 'Excelente consistencia (${(consistencyRate * 100).toStringAsFixed(0)}%)';
      activityIcon = Icons.trending_up;
      activityColor = Colors.green;
    } else if (consistencyRate >= 0.6) {
      activityTitle = 'Activo';
      activitySubtitle = 'Buena consistencia (${(consistencyRate * 100).toStringAsFixed(0)}%)';
      activityIcon = Icons.bar_chart;
      activityColor = Colors.blue;
    } else {
      activityTitle = 'Moderadamente Activo';
      activitySubtitle = 'Oportunidad de mejorar consistencia';
      activityIcon = Icons.show_chart;
      activityColor = Colors.orange;
    }
    
    // Determine streak status
    String streakTitle = 'Racha';
    String streakSubtitle = '$currentStreak días consecutivos';
    IconData streakIcon = Icons.local_fire_department_rounded;
    Color streakColor = Colors.orange;
    
    if (currentStreak >= 30) {
      streakTitle = 'Racha Legendaria';
      streakIcon = Icons.military_tech;
      streakColor = Colors.purple;
    } else if (currentStreak >= 14) {
      streakTitle = 'Racha Impresionante';
      streakIcon = Icons.local_fire_department;
      streakColor = Colors.red;
    } else if (currentStreak >= 7) {
      streakTitle = 'Buena Racha';
      streakIcon = Icons.local_fire_department_outlined;
      streakColor = Colors.orange;
    } else if (currentStreak >= 3) {
      streakTitle = 'Racha Iniciada';
      streakIcon = Icons.whatshot;
      streakColor = Colors.amber;
    } else {
      streakTitle = 'Comenzando Racha';
      streakSubtitle = 'Mantén la consistencia';
      streakIcon = Icons.trending_up;
      streakColor = Colors.blue;
    }

    return Column(
      children: [
        // Mood Card
        _buildHighlightCard(
          icon: moodIcon,
          iconColor: moodColor,
          title: moodTitle,
          subtitle: moodSubtitle,
          gradient: MinimalColors.accentGradient(context),
        ),
        const SizedBox(height: 12),
        
        // Energy Card
        _buildHighlightCard(
          icon: energyIcon,
          iconColor: energyColor,
          title: energyTitle,
          subtitle: energySubtitle,
          gradient: MinimalColors.accentGradient(context),
        ),
        const SizedBox(height: 12),
        
        // Activity Card
        _buildHighlightCard(
          icon: activityIcon,
          iconColor: activityColor,
          title: activityTitle,
          subtitle: activitySubtitle,
          gradient: MinimalColors.accentGradient(context),
        ),
        const SizedBox(height: 12),
        
        // Streak Card
        _buildHighlightCard(
          icon: streakIcon,
          iconColor: streakColor,
          title: streakTitle,
          subtitle: streakSubtitle,
          gradient: MinimalColors.accentGradient(context),
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodForecastsCard(AdvancedEmotionAnalysisProvider advancedProvider) {
    final analysisData = advancedProvider.analysisResults;
    final ensemblePrediction = analysisData['ensemble_prediction'] as Map<String, dynamic>? ?? {};
    final predictions = ensemblePrediction['predictions'] as List<dynamic>? ?? [];
    // final overallConfidence = (ensemblePrediction['ensemble_confidence'] as num?)?.toDouble() ?? 0.0;
    
    // Get time series prediction data
    final timeSeriesData = analysisData['time_series_decomposition'] as Map<String, dynamic>? ?? {};
    final trend = timeSeriesData['trend'] as List<dynamic>? ?? [];
    final seasonal = timeSeriesData['seasonal'] as List<dynamic>? ?? [];
    
    // Generate forecast data from real predictions or fallback
    final forecastData = <Map<String, dynamic>>[];
    
    if (predictions.isNotEmpty) {
      // Use real prediction data
      for (int i = 0; i < math.min(7, predictions.length); i++) {
        final prediction = predictions[i] as Map<String, dynamic>? ?? {};
        final date = DateTime.now().add(Duration(days: i + 1));
        forecastData.add({
          'label': '${date.day}/${date.month}',
          'value': (prediction['predicted_mood'] as num?)?.toDouble() ?? 0.5,
          'confidence': (prediction['confidence'] as num?)?.toDouble() ?? 0.0,
        });
      }
    } else if (trend.isNotEmpty) {
      // Use trend data for forecasting
      final lastTrendValues = trend.skip(math.max(0, trend.length - 7)).toList();
      final avgTrend = lastTrendValues.fold<double>(0.0, (sum, val) => sum + ((val as num?)?.toDouble() ?? 0.0)) / lastTrendValues.length;
      
      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().add(Duration(days: i + 1));
        final seasonalComponent = seasonal.isNotEmpty ? (seasonal[i % seasonal.length] as num?)?.toDouble() ?? 0.0 : 0.0;
        final predictedValue = ((avgTrend + seasonalComponent) / 10.0).clamp(0.0, 1.0);
        
        forecastData.add({
          'label': '${date.day}/${date.month}',
          'value': predictedValue,
          'confidence': 0.7 - (i * 0.05), // Decreasing confidence over time
        });
      }
    } else {
      // Fallback to default forecast
      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().add(Duration(days: i + 1));
        forecastData.add({
          'label': '${date.day}/${date.month}',
          'value': 0.75 + (math.sin(i * 0.5) * 0.15), // Gentle wave pattern
          'confidence': 0.6,
        });
      }
    }
    
    // Get top 2 predictions for display
    final topPredictions = forecastData.take(2).toList();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: MinimalColors.primaryGradient(context),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context).first.withValues(alpha: 0.3),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forecasts de Mood Avanzados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Predicciones basadas en patrones',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _loadAnalyticsData(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildForecastChart(forecastData),
          const SizedBox(height: 16),
          if (topPredictions.isNotEmpty) ...[
            for (final prediction in topPredictions) ...[
              Row(
                children: [
                  Text(
                    prediction['label'] as String,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mood: ${((prediction['value'] as double) * 10).toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((prediction['confidence'] as double) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (prediction != topPredictions.last) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildForecastChart([List<Map<String, dynamic>>? forecastData]) {
    final data = forecastData ?? [
      {'label': '7/7', 'value': 0.8, 'confidence': 0.8},
      {'label': '8/7', 'value': 0.9, 'confidence': 0.75},
      {'label': '9/7', 'value': 0.7, 'confidence': 0.7},
      {'label': '10/7', 'value': 0.8, 'confidence': 0.65},
      {'label': '11/7', 'value': 0.9, 'confidence': 0.6},
      {'label': '12/7', 'value': 0.8, 'confidence': 0.55},
      {'label': '13/7', 'value': 0.9, 'confidence': 0.5},
    ];
    
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((dataPoint) {
          final value = (dataPoint['value'] as double).clamp(0.0, 1.0);
          final confidence = (dataPoint['confidence'] as double).clamp(0.0, 1.0);
          final height = value * 60 + 20;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.8 * confidence),
                      Colors.white.withValues(alpha: 0.6 * confidence),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dataPoint['label'] as String,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============================================================================
  // NEW ANALYTICS PROVIDER METHODS
  // ============================================================================

  Widget _buildDominantThemesCard(AnalyticsProvider analyticsProvider) {
    final themes = analyticsProvider.getDominantThemes();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Temas Dominantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (themes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.primaryGradient(context),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descubre tus patrones',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra más reflexiones para descubrir los temas que más influyen en tu bienestar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: themes.map((theme) {
                final word = theme['word'] as String;
                final count = theme['count'] as int;
                final emoji = theme['emoji'] as String;
                final type = theme['type'] as String;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: type == 'positive' 
                      ? LinearGradient(colors: MinimalColors.accentGradient(context))
                      : null,
                    color: type == 'positive' ? null : MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: type == 'positive' 
                        ? Colors.transparent
                        : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        word,
                        style: TextStyle(
                          color: type == 'positive' ? Colors.white : MinimalColors.textPrimary(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: type == 'positive' 
                            ? Colors.white.withValues(alpha: 0.2)
                            : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: type == 'positive' ? Colors.white : MinimalColors.textSecondary(context),
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
    );
  }

  Widget _buildPriorityRecommendationsCard(AnalyticsProvider analyticsProvider) {
    final recommendations = analyticsProvider.getPriorityRecommendations();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recomendaciones Prioritarias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (recommendations.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.positiveGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: MinimalColors.positiveGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.positiveGradient(context),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Vas muy bien!',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu progreso es excelente. No hay recomendaciones urgentes en este momento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: recommendations.map((rec) {
                final emoji = rec['emoji'] as String;
                final title = rec['title'] as String;
                final description = rec['description'] as String;
                final priority = rec['priority'] as String;
                final actionable = rec['actionable'] as bool;
                
                Color priorityColor;
                switch (priority) {
                  case 'high':
                    priorityColor = Colors.red;
                    break;
                  case 'medium':
                    priorityColor = Colors.orange;
                    break;
                  case 'low':
                    priorityColor = Colors.green;
                    break;
                  default:
                    priorityColor = Colors.grey;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: priorityColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: MinimalColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    priority.toUpperCase(),
                                    style: TextStyle(
                                      color: priorityColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                color: MinimalColors.textSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                            if (actionable)
                              const SizedBox(height: 8),
                            if (actionable)
                              Row(
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: MinimalColors.accentGradient(context)[0],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Acción recomendada',
                                    style: TextStyle(
                                      color: MinimalColors.accentGradient(context)[0],
                                      fontSize: 12,
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
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentDayAnalysisCard(AnalyticsProvider analyticsProvider) {
    final dayAnalysis = analyticsProvider.getCurrentDayAnalysis();
    final hasEntry = dayAnalysis['has_entry'] as bool;
    final mood = (dayAnalysis['mood'] as num).toDouble();
    final energy = (dayAnalysis['energy'] as num).toDouble();
    final stress = (dayAnalysis['stress'] as num).toDouble();
    final message = dayAnalysis['message'] as String;
    final recommendation = dayAnalysis['recommendation'] as String;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Análisis del Día',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 14,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          
          if (hasEntry) ...[
            const SizedBox(height: 20),
            
            // Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn('Estado de Ánimo', mood, Colors.blue),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMetricColumn('Energía', energy, Colors.green),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMetricColumn('Estrés', stress, Colors.red),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String title, double value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: MinimalColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: value / 10,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedInsightsCard(AnalyticsProvider analyticsProvider) {
    final insights = analyticsProvider.getHighlightedInsights();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Insights Destacados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (insights.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.accentGradient(context),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Insights en camino',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Continúa registrando tus reflexiones diarias para obtener insights personalizados sobre tu bienestar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: insights.map((insight) {
                final emoji = insight['emoji'] as String;
                final title = insight['title'] as String;
                final description = insight['description'] as String;
                final type = insight['type'] as String;
                
                Color typeColor;
                switch (type) {
                  case 'achievement':
                    typeColor = Colors.green;
                    break;
                  case 'improvement':
                    typeColor = Colors.orange;
                    break;
                  case 'habit':
                    typeColor = Colors.blue;
                    break;
                  case 'streak':
                    typeColor = Colors.purple;
                    break;
                  default:
                    typeColor = Colors.grey;
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                color: MinimalColors.textSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStressAlertsCard(AnalyticsProvider analyticsProvider) {
    final stressAlerts = analyticsProvider.getStressAlerts();
    final requiresAttention = stressAlerts['requires_attention'] as bool;
    final level = stressAlerts['level'] as String;
    final alertColor = stressAlerts['alert_color'] as Color;
    final alertIcon = stressAlerts['alert_icon'] as String;
    final alertTitle = stressAlerts['alert_title'] as String;
    final recommendations = stressAlerts['recommendations'] as List<String>;
    final avgStress = stressAlerts['avg_stress'] as double;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: requiresAttention 
            ? alertColor.withValues(alpha: 0.5)
            : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alertColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alertIcon,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alertTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level.toUpperCase(),
                  style: TextStyle(
                    color: alertColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stress Level Indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Nivel de Estrés Promedio',
                      style: TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textSecondary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${avgStress.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: avgStress / 10,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: alertColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recommendations
          Text(
            'Recomendaciones:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Column(
            children: recommendations.map((recommendation) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: alertColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 14,
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
    );
  }

  Widget _buildNextAchievementCard(AnalyticsProvider analyticsProvider) {
    final nextAchievement = analyticsProvider.getNextAchievementToUnlock();
    
    if (nextAchievement == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '🏆',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Felicidades!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Has alcanzado todos los logros disponibles',
              style: TextStyle(
                fontSize: 14,
                color: MinimalColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    final emoji = nextAchievement['emoji'] as String;
    final title = nextAchievement['title'] as String;
    final description = nextAchievement['description'] as String;
    final progress = nextAchievement['progress'] as double;
    final current = nextAchievement['current'] as int;
    final target = nextAchievement['target'] as int;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Próximo Logro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Achievement Info
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    '$current / $target',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.accentGradient(context),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(1)}% completado',
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChartCard(AnalyticsProvider analyticsProvider) {
    final moodChartData = analyticsProvider.getMoodChartData();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tendencia del Estado de Ánimo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (moodChartData.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu gráfico está creciendo',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tu estado de ánimo durante unos días más para ver tendencias fascinantes sobre tu bienestar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Chart Area
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSimpleLineChart(moodChartData),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartLegend('Estado de Ánimo', Colors.blue),
                _buildChartLegend('Energía', Colors.green),
                _buildChartLegend('Estrés', Colors.red),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();
    
    final maxMood = data.map((d) => d['mood'] as double).reduce((a, b) => a > b ? a : b);
    final maxEnergy = data.map((d) => d['energy'] as double).reduce((a, b) => a > b ? a : b);
    final maxStress = data.map((d) => d['stress'] as double).reduce((a, b) => a > b ? a : b);
    final maxValue = [maxMood, maxEnergy, maxStress].reduce((a, b) => a > b ? a : b);
    
    return CustomPaint(
      painter: SimpleLineChartPainter(
        data: data,
        maxValue: maxValue,
        moodColor: Colors.blue,
        energyColor: Colors.green,
        stressColor: Colors.red,
      ),
      size: const Size(double.infinity, 200),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: MinimalColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardSummaryCard(AnalyticsProvider analyticsProvider) {
    final summary = analyticsProvider.getDashboardSummary();
    final wellbeingScore = summary['wellbeing_score'] as int;
    final currentStreak = summary['current_streak'] as int;
    final totalEntries = summary['total_entries'] as int;
    final consistencyRate = summary['consistency_rate'] as double;
    final improvementTrend = summary['improvement_trend'] as String;
    final mainMessage = summary['main_message'] as String;
    
    Color trendColor;
    IconData trendIcon;
    switch (improvementTrend) {
      case 'improving':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        break;
      case 'stable':
        trendColor = Colors.blue;
        trendIcon = Icons.trending_flat;
        break;
      case 'needs_attention':
        trendColor = Colors.orange;
        trendIcon = Icons.trending_down;
        break;
      default:
        trendColor = Colors.grey;
        trendIcon = Icons.remove;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.accentGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen del Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Main Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: trendColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  trendIcon,
                  color: trendColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mainMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  'Bienestar',
                  '$wellbeingScore/10',
                  Colors.blue,
                  Icons.favorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryMetric(
                  'Racha',
                  '$currentStreak días',
                  Colors.orange,
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  'Entradas',
                  '$totalEntries',
                  Colors.green,
                  Icons.create,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryMetric(
                  'Consistencia',
                  '${(consistencyRate * 100).toStringAsFixed(0)}%',
                  Colors.purple,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for simple line chart
class SimpleLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final Color moodColor;
  final Color energyColor;
  final Color stressColor;

  SimpleLineChartPainter({
    required this.data,
    required this.maxValue,
    required this.moodColor,
    required this.energyColor,
    required this.stressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    final stepX = width / (data.length - 1);

    // Draw mood line
    paint.color = moodColor;
    final moodPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = height - ((data[i]['mood'] as double) / maxValue * height);
      if (i == 0) {
        moodPath.moveTo(x, y);
      } else {
        moodPath.lineTo(x, y);
      }
    }
    canvas.drawPath(moodPath, paint);

    // Draw energy line
    paint.color = energyColor;
    final energyPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = height - ((data[i]['energy'] as double) / maxValue * height);
      if (i == 0) {
        energyPath.moveTo(x, y);
      } else {
        energyPath.lineTo(x, y);
      }
    }
    canvas.drawPath(energyPath, paint);

    // Draw stress line
    paint.color = stressColor;
    final stressPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = height - ((data[i]['stress'] as double) / maxValue * height);
      if (i == 0) {
        stressPath.moveTo(x, y);
      } else {
        stressPath.lineTo(x, y);
      }
    }
    canvas.drawPath(stressPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}