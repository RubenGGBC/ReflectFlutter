// lib/presentation/screens/v2/home_screen_v2.dart
// ============================================================================
// HOME SCREEN V2 - DISEÑO MINIMALISTA CON FONDO NEGRO Y GRADIENTES AZUL-MORADO
// ✅ ARREGLOS: CENTRADO, BARRAS SEMANALES REALES, LOGROS AL 100%
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/image_moments_provider.dart';
// import '../../providers/challenges_provider.dart'; // Removed
import '../../providers/streak_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/recommended_activities_provider.dart';
import '../../providers/hopecore_quotes_provider.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// Enhancement widgets
import '../../widgets/home_enhancement_widgets.dart';
import '../../widgets/hopecore_quotes_carousel.dart';

// Componentes
import 'components/minimal_colors.dart';
import 'recommended_activities_screen.dart';
import 'daily_review_screen_v2.dart';

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

  // State for expandable moments widget
  bool _isMomentsExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Schedule data loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
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

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

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

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _floatingController, curve: Curves.linear));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _floatingController.repeat();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        // ✅ FIX: Load data with proper error handling and retry logic
        final futures = <Future>[];
        
        // Load critical data first
        futures.add(Provider.of<OptimizedDailyEntriesProvider>(context, listen: false).loadEntries(user.id, limitDays: 30));
        futures.add(Provider.of<OptimizedMomentsProvider>(context, listen: false).loadTodayMoments(user.id));
        
        // Wait for critical data
        await Future.wait(futures);
        if (!mounted) return;
        
        // Load remaining data
        final secondaryFutures = <Future>[];
        secondaryFutures.add(Provider.of<OptimizedAnalyticsProvider>(context, listen: false).loadCompleteAnalytics(user.id, days: 30));
        secondaryFutures.add(Provider.of<GoalsProvider>(context, listen: false).loadUserGoals(user.id));
        secondaryFutures.add(Provider.of<StreakProvider>(context, listen: false).loadStreakData(user.id));
        secondaryFutures.add(Provider.of<HopecoreQuotesProvider>(context, listen: false).initialize());
        
        // Load secondary data with timeout
        await Future.wait(secondaryFutures).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Continue with partial data if timeout
            return [];
          },
        );
      }
    } catch (e) {
      // Log error but don't break the UI
      print('⚠️ Error loading initial data: $e');
      // Try to reload critical data only
      if (mounted) {
        final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
        final user = authProvider.currentUser;
        if (user != null) {
          try {
            await Provider.of<OptimizedMomentsProvider>(context, listen: false).loadTodayMoments(user.id);
          } catch (_) {
            // Fail silently
          }
        }
      }
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedTheme(
          duration: const Duration(milliseconds: 300),
          data: themeProvider.currentThemeData,
          child: Scaffold(
            backgroundColor: MinimalColors.backgroundPrimary(context),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MinimalColors.backgroundPrimary(context),
                    MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
                    MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
        child: SafeArea(
          child: Consumer<StreakProvider>(
            builder: (context, streakProvider, _) {
              return Consumer<HopecoreQuotesProvider>(
                builder: (context, quotesProvider, _) {
                  return Consumer6<OptimizedAuthProvider, OptimizedMomentsProvider,
                      OptimizedAnalyticsProvider, GoalsProvider, ImageMomentsProvider, RecommendedActivitiesProvider>(
                    builder: (context, authProvider, momentsProvider,
                        analyticsProvider, goalsProvider, imageProvider, activitiesProvider, child) {

            final user = authProvider.currentUser;
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3b82f6)),
                ),
              );
            }

            return Stack(
              children: [
                // Animated background particles
                ...List.generate(3, (index) =>
                  AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 100 + (index * 200) + (math.sin(_floatingAnimation.value * math.pi * 2 + index) * 20),
                        right: 50 + (index * 100) + (math.cos(_floatingAnimation.value * math.pi * 2 + index) * 30),
                        child: Container(
                          width: 20 + (index * 10),
                          height: 20 + (index * 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                MinimalColors.accentGradient(context)[index % 2].withValues(alpha: 0.1),
                                MinimalColors.lightGradient(context)[index % 2].withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // ✅ CENTRAR TODO
                      children: [
                    // 1. ✅ HEADER CON FOTO GRANDE Y BIENVENIDA - CENTRADO
                    _buildCenteredHeader(user),
                    const SizedBox(height: 16),
                    // 🆕 THEME TOGGLE BUTTON
                    _buildThemeToggleButton(),
                    const SizedBox(height: 24),
                    // 🆕 HOPECORE QUOTES CAROUSEL
                    HopecoreQuotesCarousel(animationController: _fadeController),
                    const SizedBox(height: 24),
                    // 🆕 WELLBEING SCORE DE HOY
                    _buildTodaysWellbeingScore(analyticsProvider),
                    const SizedBox(height: 24),
                    // 2. FACE CARD CON MOMENTOS DEL DÍA
                    _buildMomentsFaceCard(momentsProvider),
                    const SizedBox(height: 16),
                    // 🆕 PHOTO GALLERY WIDGET
                    _buildWeeklyPhotosWidget(momentsProvider, imageProvider),
                    const SizedBox(height: 16),
                    // 3. ✅ GRÁFICO SEMANAL MEJORADO CON DÍAS REALES
                    _buildRealWeeklyChart(analyticsProvider),
                    const SizedBox(height: 24),
                    // 5. 🎯 PERSONALIZED CHALLENGES
                    // PersonalizedChallengesWidget removed
                    const SizedBox(height: 24),
                    // 6. 📊 MOOD CALENDAR HEATMAP
                    MoodCalendarHeatmapWidget(animationController: _slideController),
                    const SizedBox(height: 24),
                    // 7. 🔥 STREAK TRACKER
                    StreakTrackerWidget(animationController: _pulseController),
                    const SizedBox(height: 24),
                    // 9. ✅ GOALS CERCA DE COMPLETARSE CON ESTADO 100%
                    _buildGoalsWithCompletedState(goalsProvider),
                    const SizedBox(height: 24),
                    // 10. RECOMENDACIONES CONTEXTUALES MEJORADAS
                    _buildContextualRecommendations(user, analyticsProvider, activitiesProvider),
                    const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // ✅ 1. HEADER CENTRADO CON FOTO GRANDE
  // ============================================================================
  Widget _buildCenteredHeader(OptimizedUserModel user) {
    return SlideTransition(
      position: _slideAnimation,
      child: Center( // ✅ CENTRAR COMPLETAMENTE
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ CENTRAR VERTICALMENTE
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ CENTRAR HORIZONTALMENTE
          children: [
            // Foto de perfil grande en círculo - CENTRADA
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
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

            // Saludo de bienvenida - CENTRADO
            AnimatedBuilder( // ✅ ANIMACIÓN PARA EL SALUDO
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(_shimmerAnimation.value * math.pi * 2) * 1), // Movimiento sutil
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: MinimalColors.accentGradientStatic,
                    ).createShader(bounds),
                    child: Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center, // ✅ CENTRAR TEXTO
                    ),
                  ),
                );
              },
            ),

            // Nombre del usuario - CENTRADO (solo si existe)
            if (user.name != null && user.name!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                user.name!,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),);
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradientStatic,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Buenos días';
    } else if (hour < 18) {
      return '☀️ Buenas tardes';
    } else {
      return '🌙 Buenas noches';
    }
  }

// ============================================================================
// ✅ 2. GRÁFICO SEMANAL CON DÍAS REALES DE LA SEMANA
// ============================================================================
  Widget _buildRealWeeklyChart(OptimizedAnalyticsProvider analyticsProvider) {
    final weeklyData = _getRealWeeklyData(analyticsProvider);
    final weeklyProgress = _getWeeklyProgress(analyticsProvider);

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
              // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradientStatic,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tu Semana',
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
                          colors: MinimalColors.accentGradientStatic,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: MinimalColors.accentGradient(context)[1].withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${weeklyProgress['trend']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ BARRAS DE PROGRESO SEMANAL CON DÍAS REALES
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildRealWeeklyBars(weeklyData),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ DÍAS DE LA SEMANA CON INDICADOR DE HOY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: weeklyData.asMap().entries.map((entry) {
                    final dayData = entry.value;
                    final isToday = dayData['isToday'] as bool;
                    final dayName = dayData['dayName'] as String;

                    return Column(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? MinimalColors.accentGradient(context)[0]
                                : MinimalColors.textSecondary(context),
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
                                colors: MinimalColors.accentGradientStatic,
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

// ✅ DATOS REALES DE LA SEMANA (7 DÍAS DESDE HOY HACIA ATRÁS)
  List<Map<String, dynamic>> _getRealWeeklyData(OptimizedAnalyticsProvider analyticsProvider) {
    final now = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];

    // Obtener datos reales de daily entries
    final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final dailyEntries = dailyEntriesProvider.entries;

    // Crear mapa de datos por fecha
    final dataByDate = <String, Map<String, dynamic>>{};
    for (final entry in dailyEntries) {
      final date = entry.entryDate;
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // ✅ FIX: Calcular un score de bienestar más robusto
      final moodScore = (entry.moodScore as num?)?.toDouble() ?? 5.0;
      final energyLevel = (entry.energyLevel as num?)?.toDouble() ?? 5.0;
      final stressLevel = (entry.stressLevel as num?)?.toDouble() ?? 5.0;
      final lifeSatisfaction = (entry.lifeSatisfaction as num?)?.toDouble() ?? 5.0;
      
      // Calcular score promedio de bienestar (mood, energy, life satisfaction, stress invertido)
      final wellbeingScore = (
        moodScore + 
        energyLevel + 
        lifeSatisfaction + 
        (10.0 - stressLevel.clamp(1.0, 10.0))
      ) / 4.0;
      
      dataByDate[dateStr] = {
        'mood': moodScore,
        'energy': energyLevel,
        'stress': stressLevel,
        'review': wellbeingScore.clamp(1.0, 10.0), // Score de bienestar calculado
        'hasEntry': true,
      };
    }

    // Generar 7 días (de lunes a domingo de esta semana)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Lunes
    final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
      final isPast = date.isBefore(now) || isToday;

      // Obtener datos de la entrada si existe
      final dayData = dataByDate[dateStr];
      final hasEntry = dayData?['hasEntry'] ?? false;
      final mood = dayData?['mood'] ?? 0.0;
      final review = dayData?['review'] ?? 0.0;

      // ✅ FIX: Score solo si hay entrada real, otherwise 0
      final score = hasEntry && review > 0 ? review.clamp(0.0, 10.0) : 0.0;

      weeklyData.add({
        'dayName': dayNames[i],
        'date': date,
        'score': score,
        'isToday': isToday,
        'isPast': isPast,
        'hasData': hasEntry && score > 0, // ✅ FIX: Datos válidos solo si score > 0
        'mood': mood,
        'review': review,
        'energy': dayData?['energy'] ?? 0.0,
        'stress': dayData?['stress'] ?? 0.0,
      });
    }

    return weeklyData;
  }

// ✅ BARRAS CON DATOS REALES DE LA SEMANA
  List<Widget> _buildRealWeeklyBars(List<Map<String, dynamic>> weeklyData) {
    return weeklyData.asMap().entries.map((entry) {
      final index = entry.key;
      final dayData = entry.value;
      final score = dayData['score'] as double;
      final isToday = dayData['isToday'] as bool;
      final hasData = dayData['hasData'] as bool; // ✅ FIX: Use hasData flag
      final date = dayData['date'] as DateTime;

      // ✅ FIX: Altura mínima y máxima para mejor visualización
      double height;
      if (hasData && score > 0) {
        // Mapear score de 1-10 a altura de 20-100px para mejor visualización
        height = 20 + ((score.clamp(1.0, 10.0) - 1.0) / 9.0) * 80;
      } else {
        height = 8.0; // Altura mínima para días sin datos
      }

      return AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return GestureDetector(
            onTap: () => _navigateToDailyReview(date),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500 + (index * 100)),
              curve: Curves.elasticOut,
              width: 24,
              height: height * _fadeAnimation.value,
              decoration: BoxDecoration(
                gradient: hasData
                    ? LinearGradient(
                  colors: isToday
                      ? [const Color(0xFF10B981), const Color(0xFF34D399)] // Verde para hoy
                      : MinimalColors.accentGradient(context),
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
                    : LinearGradient(
                  colors: [
                    MinimalColors.textMuted(context).withValues(alpha: 0.3),
                    MinimalColors.textMuted(context).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: hasData
                    ? [
                  BoxShadow(
                    color: isToday
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : MinimalColors.accentGradient(context)[1].withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: hasData && height > 30 // ✅ FIX: Solo mostrar texto si hay espacio
                  ? Center(
                child: Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
                  : Container(), // Vacío para días sin datos o barras muy pequeñas
            ),
          );
        },
      );
    }).toList();
  }

  Map<String, dynamic> _getWeeklyProgress(OptimizedAnalyticsProvider analyticsProvider) {
    // ✅ FIX: Usar los datos reales de la semana en lugar de analytics
    final weeklyData = _getRealWeeklyData(analyticsProvider);
    
    if (weeklyData.isEmpty) {
      return {
        'trend': '📊 Sin datos',
        'average': 0.0,
        'improvement': false,
      };
    }

    // ✅ FIX: Obtener scores solo de días con datos
    final validDays = weeklyData.where((day) => day['hasData'] == true).toList();
    
    if (validDays.isEmpty) {
      return {
        'trend': '🌱 Comenzando',
        'average': 0.0,
        'improvement': false,
      };
    }
    
    final values = validDays.map((day) => (day['score'] as num).toDouble()).toList();
    final average = values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0.0;

    String trend;
    if (average >= 8.0) {
      trend = '🔥 Excelente';
    } else if (average >= 6.5) {
      trend = '📈 Mejorando';
    } else if (average >= 5.0) {
      trend = '📊 Estable';
    } else if (validDays.length >= 3) {
      trend = '💪 Creciendo';
    } else {
      trend = '🌱 Comenzando';
    }

    return {
      'trend': trend,
      'average': average,
      'improvement': values.length >= 2 ? values.last > values.first : false,
    };
  }

// ============================================================================
// ✅ 3. GOALS CON ESTADO COMPLETADO AL 100%
// ============================================================================
  Widget _buildGoalsWithCompletedState(GoalsProvider goalsProvider) {
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
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.accentGradientStatic,
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
                      'Tus Logros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...nearCompletionGoals.map((goal) => _buildGoalCard(goal)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(dynamic goal) {
    // ✅ DETECTAR SI ESTÁ AL 100% COMPLETADO
    final isCompleted = goal.progress >= 1.0 || goal.isCompleted;
    final progress = goal.progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF10B981).withValues(alpha: 0.1) // Verde suave para completados
            : MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.3) // Borde verde para completados
              : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ✅ ICONO DIFERENTE PARA COMPLETADOS
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]) // Verde
                      : LinearGradient(colors: MinimalColors.accentGradient(context)), // Azul-morado
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.flag,
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
                      goal.title ?? 'Objetivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ ESTADO VISUAL DIFERENTE PARA COMPLETADOS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981) // Verde sólido para completados
                      : MinimalColors.accentGradient(context)[0].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted
                      ? '✅ COMPLETADO' // ✅ MENSAJE ESPECIAL PARA 100%
                      : '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white : MinimalColors.accentGradient(context)[0],
                  ),
                ),
              ),
            ],
          ),

          if (!isCompleted) ...[
            const SizedBox(height: 12),
            // Barra de progreso solo para los no completados
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  MinimalColors.accentGradient(context)[0],
                ),
                minHeight: 6,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            // ✅ MENSAJE DE CELEBRACIÓN PARA COMPLETADOS
            Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  '¡Felicitaciones! Objetivo alcanzado',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List _getGoalsNearCompletion(GoalsProvider goalsProvider) {
    // Mostrar todos los objetivos activos, priorizando los que están cerca de completarse
    final allActiveGoals = goalsProvider.activeGoals.toList();

    // Si no hay objetivos activos, retornar lista vacía
    if (allActiveGoals.isEmpty) return [];

    // Ordenar por progreso (mayor progreso primero) y tomar hasta 3
    allActiveGoals.sort((a, b) => b.progress.compareTo(a.progress));

    return allActiveGoals.take(3).toList();
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
                    colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
                  ),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  color: MinimalColors.textSecondary(context),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Próximamente nuevos objetivos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ============================================================================
// OTROS MÉTODOS AUXILIARES
// ============================================================================

  Widget _buildTodaysWellbeingScore(OptimizedAnalyticsProvider analyticsProvider) {
    return Consumer2<OptimizedMomentsProvider, OptimizedDailyEntriesProvider>(
      builder: (context, momentsProvider, dailyEntriesProvider, child) {
        // ✅ FIX: Combinar datos de momentos y entrada diaria para score más preciso
        final todayMoments = momentsProvider.todayMoments;
        final todayEntry = dailyEntriesProvider.todayEntry;
        
        double score = 0.0;
        bool hasData = false;
        
        // Priorizar entrada diaria si existe
        if (todayEntry != null) {
          score = todayEntry.wellbeingScore;
          hasData = true;
        }
        // Sino, usar momentos del día
        else if (todayMoments.isNotEmpty) {
          score = _calculateWeightedMoodFromMoments(todayMoments);
          hasData = true;
        }

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseAnimation.value * 0.01),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                      blurRadius: 25,
                      offset: const Offset(-5, 10),
                    ),
                    BoxShadow(
                      color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
                      blurRadius: 25,
                      offset: const Offset(5, 10),
                    ),
                  ],
                ),
                child: hasData && score > 0
                    ? _buildScoreContent(score)
                    : _buildNoDataContent(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScoreContent(double score) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienestar de Hoy',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _getScoreDescription(score),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Text(
              _getScoreEmoji(score),
              style: TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienestar de Hoy',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sin datos aún',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Añade un momento para ver tu puntaje.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: const Center(
            child: Icon(
              Icons.add_chart,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  String _getScoreDescription(double score) {
    if (score >= 8.5) return 'Excelente día';
    if (score >= 7.0) return 'Muy buen día';
    if (score >= 5.5) return 'Día promedio';
    if (score >= 4.0) return 'Día desafiante';
    return 'Día difícil';
  }

  String _getScoreEmoji(double score) {
    if (score >= 8.5) return '🌟';
    if (score >= 7.0) return '😊';
    if (score >= 5.5) return '🙂';
    if (score >= 4.0) return '😐';
    return '😔';
  }

  /// Calculate weighted average mood from today's moments
  /// Uses intensity as weight: (sum of mood_value * intensity) / total_intensity
  double _calculateWeightedMoodFromMoments(List<OptimizedInteractiveMomentModel> moments) {
    if (moments.isEmpty) return 0.0;

    double totalWeightedMood = 0.0;
    double totalIntensity = 0.0;

    for (final moment in moments) {
      // Convert moment type to mood value
      double moodValue;
      switch (moment.type) {
        case 'positive':
          moodValue = 7.0 + (moment.intensity / 10.0) * 3.0; // 7.0-10.0 range
          break;
        case 'negative':
          moodValue = 4.0 - (moment.intensity / 10.0) * 3.0; // 1.0-4.0 range
          break;
        default: // neutral
          moodValue = 5.0 + ((moment.intensity - 5.0) / 10.0) * 2.0; // 4.0-6.0 range
      }

      // Apply intensity as weight
      final intensity = moment.intensity.toDouble();
      totalWeightedMood += moodValue * intensity;
      totalIntensity += intensity;
    }

    if (totalIntensity == 0) return 5.0; // Default neutral score

    // Calculate weighted average and scale to 0-10 range
    final weightedAverage = totalWeightedMood / totalIntensity;
    return weightedAverage.clamp(0.0, 10.0);
  }

  Widget _buildMomentsFaceCard(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.todayMoments;
    final positiveCount = todayMoments.where((m) => m.type == 'positive').length;
    final negativeCount = todayMoments.where((m) => m.type == 'negative').length;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Column(
            children: [
              // Tappable counter widget
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMomentsExpanded = !_isMomentsExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMomentCounter(
                        icon: Icons.sentiment_very_satisfied,
                        count: positiveCount,
                        label: 'Positivos',
                        gradient: [const Color(0xFF10B981), const Color(0xFF34D399)],
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      ),
                      _buildMomentCounter(
                        icon: Icons.sentiment_dissatisfied,
                        count: negativeCount,
                        label: 'Negativos',
                        gradient: [const Color(0xFFb91c1c), const Color(0xFFef4444)],
                      ),
                    ],
                  ),
                ),
              ),
              // Expandable moments detail widget
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isMomentsExpanded ? null : 0,
                child: _isMomentsExpanded 
                  ? _buildExpandedMomentsWidget(momentsProvider)
                  : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandedMomentsWidget(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.todayMoments;
    final positiveMoments = todayMoments.where((m) => m.type == 'positive').toList();
    final negativeMoments = todayMoments.where((m) => m.type == 'negative').toList();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: MinimalColors.primaryGradient(context)[0],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Momentos de Hoy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Two-column layout for good/bad moments
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Positive moments
                  Expanded(
                    child: _buildMomentsColumn(
                      title: 'Momentos Buenos',
                      moments: positiveMoments,
                      gradient: [const Color(0xFF10B981), const Color(0xFF34D399)],
                      icon: Icons.sentiment_very_satisfied,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column - Negative moments
                  Expanded(
                    child: _buildMomentsColumn(
                      title: 'Momentos Malos',
                      moments: negativeMoments,
                      gradient: [const Color(0xFFb91c1c), const Color(0xFFef4444)],
                      icon: Icons.sentiment_dissatisfied,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMomentsColumn({
    required String title,
    required List<OptimizedInteractiveMomentModel> moments,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column header
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${moments.length}',
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
        // Moments list
        if (moments.isEmpty)
          _buildEmptyMomentsState(gradient)
        else
          ...moments.map((moment) => _buildMomentCard(moment, gradient)),
      ],
    );
  }

  Widget _buildMomentCard(OptimizedInteractiveMomentModel moment, List<Color> gradient) {
    return Consumer<ImageMomentsProvider>(
      builder: (context, imageProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: gradient[0].withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    moment.emoji ?? '📝',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      moment.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: MinimalColors.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Show image if available
              FutureBuilder<String?>(
                future: imageProvider.getImageForMoment(moment.id ?? 0),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(snapshot.data!),
                          width: double.infinity,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Time stamp
              const SizedBox(height: 4),
              Text(
                _formatMomentTime(moment.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: MinimalColors.textTertiary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyMomentsState(List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient[0].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient[0].withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_neutral,
            color: gradient[0].withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin momentos aún',
            style: TextStyle(
              fontSize: 12,
              color: MinimalColors.textTertiary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMomentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Widget _buildMomentCounter({
    required IconData icon,
    required int count,
    required String label,
    required List<Color> gradient,
  }) {
    return AnimatedBuilder( // ✅ ANIMACIÓN PARA CADA CONTADOR
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value * 0.03), // Animación de pulso
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradient),
                  // ✅ SOMBRAS MEJORADAS PARA CONTADORES
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: gradient[1].withValues(alpha: 0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              // ✅ ANIMACIÓN PARA EL NÚMERO
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  count.toString(),
                  key: ValueKey(count), // Key para animar cambios
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// ============================================================================
// 🆕 WIDGET DE FOTOS SEMANALES
// ============================================================================
  Widget _buildWeeklyPhotosWidget(OptimizedMomentsProvider momentsProvider, ImageMomentsProvider imageProvider) {
    final weeklyMoments = _getWeeklyMomentsWithImages(momentsProvider);

    if (weeklyMoments.isEmpty) {
      return _buildEmptyPhotosWidget();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 20),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: MinimalColors.accentGradientStatic,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fotos de la Semana',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MinimalColors.textPrimary(context),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: MinimalColors.lightGradientStatic,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${weeklyMoments.length}',
                          style: TextStyle(
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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weeklyMoments.length,
                      itemBuilder: (context, index) {
                        final moment = weeklyMoments[index];
                        return _buildPhotoCard(moment, imageProvider, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoCard(OptimizedInteractiveMomentModel moment, ImageMomentsProvider imageProvider, int index) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * (50 * (index + 1)), 0),
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: FutureBuilder<String?>(
              future: imageProvider.getImageForMoment(moment.id ?? 0),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(snapshot.data!),
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPhotoPlaceholder(moment.emoji ?? '📷');
                          },
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Emoji and type indicator
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Column(
                          children: [
                            Text(
                              moment.emoji ?? '📷',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _getMomentTypeGradient(moment.type ?? 'neutral'),
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return _buildPhotoPlaceholder(moment.emoji ?? '📷');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoPlaceholder(String emoji) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value * 0.05),
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.photo_camera,
                  color: MinimalColors.textSecondary(context),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyPhotosWidget() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_floatingAnimation.value * math.pi * 2) * 3),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
                    ),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: MinimalColors.textSecondary(context),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Agrega fotos a tus momentos',
                  style: TextStyle(
                    fontSize: 14,
                    color: MinimalColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Captura instantes especiales de tu semana',
                  style: TextStyle(
                    fontSize: 12,
                    color: MinimalColors.textTertiary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<OptimizedInteractiveMomentModel> _getWeeklyMomentsWithImages(OptimizedMomentsProvider momentsProvider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return momentsProvider.moments
        .where((moment) {
          final momentDate = moment.createdAt;
          return momentDate.isAfter(weekStart) && momentDate.isBefore(weekEnd);
        })
        .take(6) // Limit to 6 photos for better UI
        .toList();
  }

  List<Color> _getMomentTypeGradient(String type) {
    switch (type) {
      case 'positive':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'negative':
        return [const Color(0xFFb91c1c), const Color(0xFFef4444)];
      default:
        return [const Color(0xFFf59e0b), const Color(0xFFfbbf24)];
    }
  }

// ============================================================================
// 🆕 THEME TOGGLE BUTTON
// ============================================================================
  Widget _buildThemeToggleButton() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseAnimation.value * 0.02),
              child: GestureDetector(
                onTap: () async {
                  await themeProvider.toggleTheme();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.isDarkMode
                          ? [const Color(0xFFfbbf24), const Color(0xFFf59e0b)]
                          : [const Color(0xFF1e3a8a), const Color(0xFF581c87)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.gradientShadow(context, alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        themeProvider.isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// ============================================================================
// RECOMENDACIONES CONTEXTUALES MEJORADAS
// ============================================================================
  Widget _buildContextualRecommendations(OptimizedUserModel user, OptimizedAnalyticsProvider analyticsProvider, RecommendedActivitiesProvider activitiesProvider) {
    final dailyActivities = activitiesProvider.dailyRecommendations;

    if (dailyActivities.isEmpty) {
      return Container();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecommendedActivitiesScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            width: 1,
          ),
          // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MinimalColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        '${dailyActivities.length} actividades para hoy',
                        style: TextStyle(
                          fontSize: 14,
                          color: MinimalColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: MinimalColors.primaryGradient(context)[0],
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dailyActivities.take(2).map((activity) => AnimatedBuilder( // ✅ ANIMACIÓN INDIVIDUAL
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (math.sin(_floatingAnimation.value * math.pi * 2) * 0.02), // Escala sutil
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MinimalColors.backgroundSecondary(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                        width: 1,
                      ),
                      // ✅ SOMBRAS MEJORADAS
                      boxShadow: [
                        BoxShadow(
                          color: MinimalColors.backgroundSecondary(context).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: activity.gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity.iconData,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: MinimalColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.formattedDuration,
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
                  ),
                );
              },
            )).toList(),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // NAVIGATION TO DAILY REVIEW
  // ============================================================================
  void _navigateToDailyReview(DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyReviewScreenV2(),
      ),
    );
  }
}