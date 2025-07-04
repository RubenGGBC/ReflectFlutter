// lib/presentation/screens/v2/home_screen_v2.dart
// ============================================================================
// HOME SCREEN V2 - DISEÑO MINIMALISTA CON FONDO NEGRO Y GRADIENTES AZUL-MORADO
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// ============================================================================
// PALETA DE COLORES MINIMALISTA OSCURA
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
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);
}

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadInitialData();
      }
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _floatingController.repeat(reverse: true);
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      await Future.wait([
        Provider.of<OptimizedDailyEntriesProvider>(context, listen: false).loadEntries(user.id),
        Provider.of<OptimizedMomentsProvider>(context, listen: false).loadMoments(user.id),
        Provider.of<GoalsProvider>(context, listen: false).loadUserGoals(user.id),
        Provider.of<OptimizedAnalyticsProvider>(context, listen: false).loadCompleteAnalytics(user.id),
      ]);

      if (!mounted) return;

      setState(() {
        // State update might not be needed if providers handle notifications
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary,
      body: SafeArea(
        child: Consumer4<OptimizedAuthProvider, OptimizedMomentsProvider,
            OptimizedAnalyticsProvider, GoalsProvider>(
          builder: (context, authProvider, momentsProvider,
              analyticsProvider, goalsProvider, child) {

            final user = authProvider.currentUser;
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER CON FOTO GRANDE Y BIENVENIDA
                    _buildMinimalHeader(user),
                    const SizedBox(height: 24),
                    // 🆕 WELLBEING SCORE DE HOY
                    _buildTodaysWellbeingScore(analyticsProvider),
                    const SizedBox(height: 24),
                    // 2. FACE CARD CON MOMENTOS DEL DÍA
                    _buildMomentsFaceCard(momentsProvider),
                    const SizedBox(height: 24),
                    // 3. GRÁFICO SEMANAL MEJORADO
                    _buildEnhancedWeeklyChart(analyticsProvider),
                    const SizedBox(height: 24),
                    // 4. GOALS CERCA DE COMPLETARSE
                    _buildGoalsNearCompletion(goalsProvider),
                    const SizedBox(height: 24),
                    // 5. RECOMENDACIONES CONTEXTUALES MEJORADAS
                    _buildContextualRecommendations(user, analyticsProvider),
                    const SizedBox(height: 32),
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
  // 1. HEADER MINIMALISTA CON FOTO GRANDE
  // ============================================================================
  Widget _buildMinimalHeader(OptimizedUserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // Foto de perfil grande en círculo
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 120,
              height: 120,
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
              child: user.profilePicturePath != null && user.profilePicturePath!.isNotEmpty
                  ? ClipOval(
                child: Image.file(
                  File(user.profilePicturePath!),
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                ),
              )
                  : _buildDefaultAvatar(),
            ),
          ),

          const SizedBox(height: 20),

          // Saludo de bienvenida
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: MinimalColors.accentGradient,
            ).createShader(bounds),
            child: Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nombre del usuario
          Text(
            user.name ?? 'Usuario',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 60,
      ),
    );
  }

  // ============================================================================
  // 🆕 MÉTODO 1: TODAY'S WELLBEING SCORE
  // ============================================================================
  Widget _buildTodaysWellbeingScore(OptimizedAnalyticsProvider analyticsProvider) {
    final wellbeingData = _getTodaysWellbeingScore(analyticsProvider);
    final score = wellbeingData['score'] as int;
    final level = wellbeingData['level'] as String;
    final emoji = wellbeingData['emoji'] as String;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_floatingAnimation.value * math.pi * 2) * 3),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                // Score circular animado
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
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
                            color: MinimalColors.primaryGradient[1].withOpacity(0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Ring exterior con shimmer
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: MinimalColors.accentGradient[0].withOpacity(
                                0.3 + (math.sin(_shimmerAnimation.value * math.pi) * 0.3),
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(width: 24),

                // Información de score
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienestar de Hoy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MinimalColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: MinimalColors.accentGradient,
                        ).createShader(bounds),
                        child: Text(
                          level,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score/10 puntos',
                        style: const TextStyle(
                          fontSize: 14,
                          color: MinimalColors.textTertiary,
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

  Map<String, dynamic> _getTodaysWellbeingScore(OptimizedAnalyticsProvider analyticsProvider) {
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();

    return {
      'score': wellbeingStatus['score'] ?? 5,
      'level': wellbeingStatus['level'] ?? 'Regular',
      'emoji': wellbeingStatus['emoji'] ?? '😐',
      'message': wellbeingStatus['message'] ?? 'Sin datos suficientes',
    };
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  // ============================================================================
  // 2. FACE CARD CON MOMENTOS POSITIVOS Y NEGATIVOS
  // ============================================================================
  Widget _buildMomentsFaceCard(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.todayMoments;
    final positiveMoments = todayMoments.where((m) => m.type == 'positive').length;
    final negativeMoments = todayMoments.where((m) => m.type == 'negative').length;

    return Container(
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
            color: MinimalColors.primaryGradient[1].withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMomentCounter(
                icon: Icons.sentiment_very_satisfied_rounded,
                count: positiveMoments,
                label: 'Positivos',
                gradient: const [Color(0xFF10b981), Color(0xFF059669)],
              ),
              Container(
                width: 1,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              _buildMomentCounter(
                icon: Icons.sentiment_dissatisfied_rounded,
                count: negativeMoments,
                label: 'Negativos',
                gradient: const [Color(0xFFef4444), Color(0xFFdc2626)],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMomentCounter({
    required IconData icon,
    required int count,
    required String label,
    required List<Color> gradient,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradient),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: MinimalColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // 🆕 MÉTODO 4: WEEKLY PROGRESS ENHANCED
  // ============================================================================
  Widget _buildEnhancedWeeklyChart(OptimizedAnalyticsProvider analyticsProvider) {
    final weeklyProgress = _getWeeklyProgress(analyticsProvider);

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
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.2),
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
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              MinimalColors.accentGradient[0],
                              MinimalColors.accentGradient[1],
                              MinimalColors.accentGradient[0],
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
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Progreso Semanal',
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
                        boxShadow: [
                          BoxShadow(
                            color: MinimalColors.accentGradient[1].withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${weeklyProgress['trend']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildEnhancedWeeklyBars(analyticsProvider),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                      .asMap()
                      .entries
                      .map((entry) {
                    final isToday = entry.key == DateTime.now().weekday - 1;
                    return Column(
                      children: [
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? MinimalColors.accentGradient[0]
                                : MinimalColors.textSecondary,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: MinimalColors.accentGradient,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildEnhancedWeeklyBars(OptimizedAnalyticsProvider analyticsProvider) {
    final moodData = analyticsProvider.getMoodChartData();
    // ✅ CORREGIDO
    final values = moodData.isNotEmpty
        ? moodData.take(7).map((data) => (data['mood'] as num? ?? 5.0).toDouble()).toList()
        : [7.5, 8.2, 6.8, 9.1, 7.3, 8.5, 6.9];

    return values.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      final height = (value / 10.0) * 100;

      return AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500 + (index * 100)),
            curve: Curves.elasticOut,
            width: 24,
            height: height * _fadeAnimation.value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MinimalColors.accentGradient[0],
                  MinimalColors.accentGradient[1],
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.accentGradient[1].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          );
        },
      );
    }).toList();
  }

  Map<String, dynamic> _getWeeklyProgress(OptimizedAnalyticsProvider analyticsProvider) {
    final moodData = analyticsProvider.getMoodChartData();

    if (moodData.isEmpty) {
      return {
        'trend': '📊 Sin datos',
        'average': 0.0,
        'improvement': false,
      };
    }

    // ✅ CORREGIDO
    final values = moodData.take(7).map((data) => (data['mood'] as num? ?? 5.0).toDouble()).toList();
    final average = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0.0;

    String trend;
    if (average >= 8.0) {
      trend = '🔥 Excelente';
    } else if (average >= 6.5) {
      trend = '📈 Mejorando';
    } else if (average >= 5.0) {
      trend = '📊 Estable';
    } else {
      trend = '💪 Creciendo';
    }

    return {
      'trend': trend,
      'average': average,
      'improvement': values.length >= 2 ? values.last > values.first : false,
    };
  }

  // ============================================================================
  // 🆕 MÉTODO 2: GOALS NEAR COMPLETION
  // ============================================================================
  Widget _buildGoalsNearCompletion(GoalsProvider goalsProvider) {
    final nearCompletionGoals = _getGoalsNearCompletion(goalsProvider);

    if (nearCompletionGoals.isEmpty) {
      return _buildEmptyGoalsState();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value * 0.02),
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
                  color: MinimalColors.primaryGradient[1].withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: MinimalColors.accentGradient[0].withOpacity(0.2),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                  spreadRadius: 6,
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
                          colors: MinimalColors.accentGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: MinimalColors.accentGradient[1].withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Casi Completados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: MinimalColors.accentGradient[0].withOpacity(
                              0.3 + (math.sin(_shimmerAnimation.value * math.pi) * 0.2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '🔥 ${nearCompletionGoals.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ...nearCompletionGoals.map((goal) => _buildNearCompletionGoalItem(goal)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearCompletionGoalItem(goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.accentGradient[0].withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.accentGradient[1].withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: MinimalColors.lightGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${goal.progressPercentage}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.7 * goal.progress * _fadeAnimation.value,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: MinimalColors.accentGradient,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: MinimalColors.accentGradient[1].withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '¡Solo ${((1 - goal.progress) * 100).toInt()}% más para completar!',
            style: const TextStyle(
              fontSize: 12,
              color: MinimalColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List _getGoalsNearCompletion(GoalsProvider goalsProvider) {
    return goalsProvider.activeGoals
        .where((goal) => goal.progress >= 0.8)
        .take(2)
        .toList();
  }

  Widget _buildEmptyGoalsState() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_floatingAnimation.value * math.pi * 2) * 2),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient.map((c) => c.withOpacity(0.3)).toList(),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.primaryGradient[1].withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: MinimalColors.textSecondary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Próximamente nuevos objetivos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: MinimalColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu progreso será increíble',
                style: TextStyle(
                  fontSize: 14,
                  color: MinimalColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================================
  // 🆕 MÉTODO 3: CONTEXTUAL RECOMMENDATIONS
  // ============================================================================
  Widget _buildContextualRecommendations(
      OptimizedUserModel user,
      OptimizedAnalyticsProvider analyticsProvider
      ) {
    final recommendations = _getContextualRecommendations(analyticsProvider);

    return Container(
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
            color: MinimalColors.lightGradient[0].withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 3,
          ),
          BoxShadow(
            color: MinimalColors.lightGradient[1].withOpacity(0.2),
            blurRadius: 35,
            offset: const Offset(0, 18),
            spreadRadius: 6,
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
                          colors: MinimalColors.lightGradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: MinimalColors.lightGradient[1].withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Recomendado para Ti',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        MinimalColors.lightGradient[0],
                        MinimalColors.lightGradient[1],
                        MinimalColors.lightGradient[0],
                      ],
                      stops: [
                        (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                        _shimmerAnimation.value.clamp(0.0, 1.0),
                        (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: const Text(
                      'IA Personalizada',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;

            return AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _fadeAnimation.value) * 20),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildEnhancedRecommendationItem(recommendation, index),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEnhancedRecommendationItem(Map<String, dynamic> recommendation, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.lightGradient[index % 2].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.lightGradient[index % 2].withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin((_floatingAnimation.value + index * 0.3) * math.pi * 2) * 2),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        MinimalColors.lightGradient[index % 2],
                        MinimalColors.accentGradient[index % 2],
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.lightGradient[index % 2].withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRecommendationIcon(recommendation['type'] ?? 'default'),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] ?? 'Actividad recomendada',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textPrimary,
                  ),
                ),
                if (recommendation['description'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    recommendation['description'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: MinimalColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (recommendation['context'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MinimalColors.lightGradient[index % 2].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recommendation['context'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: MinimalColors.lightGradient[index % 2],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getContextualRecommendations(OptimizedAnalyticsProvider analyticsProvider) {
    final hour = DateTime.now().hour;
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();

    // ✅ CORREGIDO
    final stressLevel = (wellbeingStatus['stress'] as num? ?? 5.0).toDouble();
    final mood = (wellbeingStatus['mood'] as num? ?? 5.0).toDouble();
    final energy = (wellbeingStatus['energy'] as num? ?? 5.0).toDouble();

    List<Map<String, dynamic>> contextualRecommendations = [];

    if (hour >= 6 && hour < 12) { // Mañana
      if (energy < 6) {
        contextualRecommendations.add({
          'title': 'Energiza tu mañana',
          'description': 'Una caminata de 10 minutos te dará el impulso que necesitas',
          'type': 'exercise',
          'context': '☀️ Rutina matutina',
        });
      } else {
        contextualRecommendations.add({
          'title': 'Momento de gratitud',
          'description': 'Anota 3 cosas positivas que esperas de hoy',
          'type': 'mindfulness',
          'context': '🌅 Inicio perfecto',
        });
      }
    } else if (hour >= 12 && hour < 18) { // Tarde
      if (stressLevel >= 7) {
        contextualRecommendations.add({
          'title': 'Pausa de respiración',
          'description': 'Técnica 4-7-8: inhala 4, mantén 7, exhala 8',
          'type': 'meditation',
          'context': '🌤️ Alivio del mediodía',
        });
      } else {
        contextualRecommendations.add({
          'title': 'Conexión social',
          'description': 'Llama a alguien especial o escribe un mensaje positivo',
          'type': 'social',
          'context': '📞 Momento de conexión',
        });
      }
    } else { // Noche
      if (mood < 6) {
        contextualRecommendations.add({
          'title': 'Reflexión nocturna',
          'description': 'Reflexiona sobre un momento positivo del día',
          'type': 'mood',
          'context': '🌙 Cierre positivo',
        });
      } else {
        contextualRecommendations.add({
          'title': 'Preparación para el descanso',
          'description': 'Técnicas de relajación para un mejor sueño',
          'type': 'sleep',
          'context': '😴 Descanso reparador',
        });
      }
    }

    final originalRecommendations = analyticsProvider.getTopRecommendations();
    contextualRecommendations.addAll(originalRecommendations.take(2));

    return contextualRecommendations.toSet().toList().take(3).toList(); // .toSet() to remove duplicates
  }

  IconData _getRecommendationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meditation':
      case 'mindfulness':
        return Icons.self_improvement_rounded;
      case 'exercise':
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'mood':
        return Icons.sentiment_satisfied_rounded;
      case 'stress':
        return Icons.spa_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}