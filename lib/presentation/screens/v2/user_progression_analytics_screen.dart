// lib/presentation/screens/v2/user_progression_analytics_screen.dart
// ============================================================================
// ANALYTICS SCREEN - DISEÑO MINIMALISTA CON FONDO NEGRO Y GRADIENTES AZUL-MORADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

// Providers
import '../../providers/analytics_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/advanced_emotion_analysis_provider.dart';

// ============================================================================
// PALETA DE COLORES MINIMALISTA OSCURA (IGUAL QUE HOME)
// ============================================================================
class MinimalColors {
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

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF4B5563);
}

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
      backgroundColor: MinimalColors.backgroundPrimary,
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
                          // Streak Analysis
                          _buildStreakCard(analyticsProvider),
                          const SizedBox(height: 20),
                          
                          // Wellbeing Prediction
                          _buildWellbeingCard(analyticsProvider),
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
                    gradient: const LinearGradient(
                      colors: MinimalColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient[1].withOpacity(0.4),
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
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: MinimalColors.accentGradient,
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
              
              const Text(
                'Insights avanzados sobre tu bienestar',
                style: TextStyle(
                  fontSize: 16,
                  color: MinimalColors.textSecondary,
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
                  ? const LinearGradient(colors: MinimalColors.accentGradient)
                  : null,
                color: isSelected ? null : MinimalColors.backgroundCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? Colors.transparent 
                    : MinimalColors.primaryGradient[0].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _periodLabels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : MinimalColors.textSecondary,
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
    return Container(
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
        ),
      ),
    );
  }

  Widget _buildStreakCard(AnalyticsProvider analyticsProvider) {
    final streakData = _calculateStreakData(analyticsProvider);
    final currentStreak = streakData['current'] as int;
    final longestStreak = streakData['longest'] as int;
    final streakActive = streakData['active'] as bool;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
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
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                    const Text(
                      'Racha de Progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: streakActive ? MinimalColors.accentGradient : [
                            MinimalColors.textMuted,
                            MinimalColors.textMuted,
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
                        ? MinimalColors.primaryGradient.map((c) => c.withOpacity(0.2)).toList()
                        : [
                            MinimalColors.backgroundSecondary,
                            MinimalColors.backgroundSecondary,
                          ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: streakActive 
                        ? MinimalColors.primaryGradient[0].withOpacity(0.5)
                        : MinimalColors.textMuted.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Current Streak
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Racha Actual',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$currentStreak',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'días',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        width: 1,
                        height: 60,
                        color: MinimalColors.textMuted.withOpacity(0.3),
                      ),
                      
                      // Longest Streak
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Récord Personal',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$longestStreak',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'días',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary,
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
        const Text(
          'Progreso hacia Logros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary,
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
                  ? const LinearGradient(colors: MinimalColors.accentGradient)
                  : isCurrent 
                    ? const LinearGradient(colors: MinimalColors.lightGradient)
                    : null,
                color: (!isAchieved && !isCurrent) ? MinimalColors.backgroundSecondary : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAchieved || isCurrent 
                    ? Colors.transparent 
                    : MinimalColors.textMuted.withOpacity(0.3),
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
                      color: (isAchieved || isCurrent) ? Colors.white : MinimalColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$days días',
                    style: TextStyle(
                      fontSize: 8,
                      color: (isAchieved || isCurrent) ? Colors.white70 : MinimalColors.textTertiary,
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
    final analytics = analyticsProvider.analytics;
    final predictionData = analytics['wellbeing_prediction'] as Map<String, dynamic>? ?? {};
    final currentTrend = predictionData['trend'] as String? ?? 'stable';
    final predictionScore = (predictionData['predicted_score'] as num?)?.toDouble() ?? 5.0;
    final confidence = (predictionData['confidence'] as num?)?.toDouble() ?? 0.0;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
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
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                    const Text(
                      'Predicción de Bienestar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                      colors: MinimalColors.primaryGradient.map((c) => c.withOpacity(0.2)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: MinimalColors.primaryGradient[0].withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Predicted Score
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Puntuación Prevista',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              predictionScore.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'de 10',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        width: 1,
                        height: 60,
                        color: MinimalColors.textMuted.withOpacity(0.3),
                      ),
                      
                      // Confidence
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Confianza',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'precisión',
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary,
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
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
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
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                    const Text(
                      'Matriz de Correlación',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
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
          colors: MinimalColors.primaryGradient.map((c) => c.withOpacity(0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient[0].withOpacity(0.3),
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
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MinimalColors.textPrimary,
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
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MinimalColors.textPrimary,
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
                        color: _getCorrelationColor(correlation),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          correlation.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: correlation.abs() > 0.5 ? Colors.white : MinimalColors.textPrimary,
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
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
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
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                    const Text(
                      'Clustering Emocional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Clusters List
                if (clusters.isNotEmpty) ...clusters.take(3).map((cluster) {
                  final clusterMap = cluster as Map<String, dynamic>;
                  final id = clusterMap['id'] as int? ?? 0;
                  final size = clusterMap['size'] as int? ?? 0;
                  final dominantFeature = clusterMap['dominant_feature'] as String? ?? 'unknown';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.accentGradient.map((c) => c.withOpacity(0.1)).toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MinimalColors.accentGradient[0].withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: MinimalColors.accentGradient,
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: MinimalColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$size entradas',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MinimalColors.textSecondary,
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
    final analytics = analyticsProvider.analytics;
    final habitsData = analytics['habits_analysis'] as Map<String, dynamic>? ?? {};
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
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
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
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                    const Text(
                      'Hábitos Saludables',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                        colors: MinimalColors.accentGradient.map((c) => c.withOpacity(0.3)).toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: MinimalColors.accentGradient[0],
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(overallScore * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MinimalColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'puntuación',
                            style: TextStyle(
                              fontSize: 12,
                              color: MinimalColors.textSecondary,
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
                  const Text(
                    'Hábitos Individuales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary,
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
                        color: MinimalColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MinimalColors.textMuted.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: MinimalColors.accentGradient,
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MinimalColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: MinimalColors.backgroundSecondary,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: FractionallySizedBox(
                                          widthFactor: consistency,
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: MinimalColors.accentGradient,
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
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: MinimalColors.textSecondary,
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

  Widget _buildProgressOverview(AnalyticsProvider analyticsProvider) {
    final analytics = analyticsProvider.analytics;
    final basicStats = analytics['basic_stats'] as Map<String, dynamic>? ?? {};
    final avgWellbeing = (basicStats['avg_wellbeing'] as num?)?.toDouble() ?? 5.0;
    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final avgMood = (basicStats['avg_mood'] as num?)?.toDouble() ?? 5.0;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
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
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
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
                    const Text(
                      'Resumen de Progreso',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
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
                      'Entradas Totales',
                      totalEntries.toString(),
                      Icons.edit,
                      (totalEntries / (_selectedPeriod * 1.0)).clamp(0.0, 1.0),
                    ),
                    _buildStatCard(
                      'Estado de Ánimo',
                      '${avgMood.toStringAsFixed(1)}/10',
                      Icons.mood,
                      avgMood / 10,
                    ),
                    _buildStatCard(
                      'Consistencia',
                      '${((totalEntries / _selectedPeriod) * 100).toStringAsFixed(0)}%',
                      Icons.timeline,
                      totalEntries / _selectedPeriod,
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

  Widget _buildStatCard(String title, String value, IconData icon, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.accentGradient.map((c) => c.withOpacity(0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.accentGradient[0].withOpacity(0.3),
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
                  gradient: const LinearGradient(
                    colors: MinimalColors.accentGradient,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: MinimalColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: MinimalColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: MinimalColors.accentGradient,
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

  Color _getCorrelationColor(double correlation) {
    if (correlation > 0.7) {
      return MinimalColors.lightGradient[0];
    } else if (correlation > 0.3) {
      return MinimalColors.accentGradient[0];
    } else if (correlation > -0.3) {
      return MinimalColors.textMuted;
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

  Map<String, dynamic> _calculateStreakData(AnalyticsProvider analyticsProvider) {
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    
    if (dailyEntries.isEmpty) {
      return {
        'current': 0,
        'longest': 0,
        'active': false,
      };
    }

    // Sort entries by date (most recent first)
    final sortedEntries = dailyEntries.toList()
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    // Calculate current streak
    int currentStreak = 0;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check if there's an entry for today or yesterday
    bool hasRecentEntry = sortedEntries.any((entry) {
      final entryDate = entry.entryDate;
      return _isSameDay(entryDate, today) || _isSameDay(entryDate, yesterday);
    });

    if (hasRecentEntry) {
      DateTime currentDate = today;
      
      // Count consecutive days with entries
      for (int i = 0; i < 365; i++) { // Max 365 days back
        final checkDate = currentDate.subtract(Duration(days: i));
        final hasEntryForDate = sortedEntries.any((entry) => _isSameDay(entry.entryDate, checkDate));
        
        if (hasEntryForDate) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    for (final entry in sortedEntries.reversed) {
      if (lastDate == null) {
        tempStreak = 1;
        lastDate = entry.entryDate;
      } else {
        final daysDifference = entry.entryDate.difference(lastDate).inDays;
        
        if (daysDifference == 1) {
          tempStreak++;
        } else {
          longestStreak = math.max(longestStreak, tempStreak);
          tempStreak = 1;
        }
        lastDate = entry.entryDate;
      }
    }
    
    longestStreak = math.max(longestStreak, tempStreak);

    return {
      'current': currentStreak,
      'longest': longestStreak,
      'active': currentStreak > 0,
    };
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Map<String, dynamic> _generateClusteringData(AdvancedEmotionAnalysisProvider advancedProvider) {
    // Get analytics data
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    
    if (dailyEntries.isEmpty) {
      return {
        'clusters': <Map<String, dynamic>>[],
      };
    }

    // Simple clustering based on mood patterns
    final highMoodEntries = dailyEntries.where((e) => (e.moodScore ?? 3.0) >= 4.0).length;
    final mediumMoodEntries = dailyEntries.where((e) => (e.moodScore ?? 3.0) >= 2.5 && (e.moodScore ?? 3.0) < 4.0).length;
    final lowMoodEntries = dailyEntries.where((e) => (e.moodScore ?? 3.0) < 2.5).length;
    
    final clusters = <Map<String, dynamic>>[];
    
    if (highMoodEntries > 0) {
      clusters.add({
        'id': 'high_mood',
        'name': 'Estado Positivo',
        'size': highMoodEntries,
        'color': Colors.green,
        'characteristics': ['Buen humor', 'Energía alta', 'Optimismo'],
        'percentage': (highMoodEntries / dailyEntries.length * 100).round(),
      });
    }
    
    if (mediumMoodEntries > 0) {
      clusters.add({
        'id': 'medium_mood',
        'name': 'Estado Neutro',
        'size': mediumMoodEntries,
        'color': Colors.orange,
        'characteristics': ['Humor estable', 'Energía moderada', 'Equilibrio'],
        'percentage': (mediumMoodEntries / dailyEntries.length * 100).round(),
      });
    }
    
    if (lowMoodEntries > 0) {
      clusters.add({
        'id': 'low_mood',
        'name': 'Estado Desafiante',
        'size': lowMoodEntries,
        'color': Colors.red,
        'characteristics': ['Humor bajo', 'Necesita apoyo', 'Reflexión'],
        'percentage': (lowMoodEntries / dailyEntries.length * 100).round(),
      });
    }

    return {
      'clusters': clusters,
    };
  }

  Map<String, dynamic> _calculateRealCorrelationMatrix() {
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;
    
    if (dailyEntries.length < 2) {
      // Return default matrix if insufficient data
      return {
        'mood': {'mood': 1.0, 'energy': 0.0, 'stress': 0.0, 'anxiety': 0.0},
        'energy': {'mood': 0.0, 'energy': 1.0, 'stress': 0.0, 'anxiety': 0.0},
        'stress': {'mood': 0.0, 'energy': 0.0, 'stress': 1.0, 'anxiety': 0.0},
        'anxiety': {'mood': 0.0, 'energy': 0.0, 'stress': 0.0, 'anxiety': 1.0},
      };
    }

    // Extract values for each variable
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
}