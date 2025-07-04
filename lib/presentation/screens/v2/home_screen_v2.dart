// lib/presentation/screens/v2/home_screen_v2.dart
// ============================================================================
// HOME SCREEN V2 - DISEÑO MINIMALISTA CON FONDO NEGRO Y GRADIENTES AZUL-MORADO
// ✅ ARREGLOS: CENTRADO, BARRAS SEMANALES REALES, LOGROS AL 100%
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
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF4B5563);
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
    _loadInitialData();
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
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      await Future.wait([
        Provider.of<OptimizedMomentsProvider>(context, listen: false).loadTodayMoments(user.id),
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
                  crossAxisAlignment: CrossAxisAlignment.center, // ✅ CENTRAR TODO
                  children: [
                    // 1. ✅ HEADER CON FOTO GRANDE Y BIENVENIDA - CENTRADO
                    _buildCenteredHeader(user),
                    const SizedBox(height: 24),
                    // 🆕 WELLBEING SCORE DE HOY
                    _buildTodaysWellbeingScore(analyticsProvider),
                    const SizedBox(height: 24),
                    // 2. FACE CARD CON MOMENTOS DEL DÍA
                    _buildMomentsFaceCard(momentsProvider),
                    const SizedBox(height: 24),
                    // 3. ✅ GRÁFICO SEMANAL MEJORADO CON DÍAS REALES
                    _buildRealWeeklyChart(analyticsProvider),
                    const SizedBox(height: 24),
                    // 4. ✅ GOALS CERCA DE COMPLETARSE CON ESTADO 100%
                    _buildGoalsWithCompletedState(goalsProvider),
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

            // Saludo de bienvenida - CENTRADO
            AnimatedBuilder( // ✅ ANIMACIÓN PARA EL SALUDO
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(_shimmerAnimation.value * math.pi * 2) * 1), // Movimiento sutil
                  child: ShaderMask(
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
                      textAlign: TextAlign.center, // ✅ CENTRAR TEXTO
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Nombre del usuario - CENTRADO
            Text(
              user.name ?? 'Usuario',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MinimalColors.textPrimary,
              ),
              textAlign: TextAlign.center, // ✅ CENTRAR TEXTO
            ),
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
          colors: MinimalColors.primaryGradient,
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
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                        Icons.timeline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tu Semana',
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

// ✅ DATOS REALES DE LA SEMANA (7 DÍAS DESDE HOY HACIA ATRÁS)
  List<Map<String, dynamic>> _getRealWeeklyData(OptimizedAnalyticsProvider analyticsProvider) {
    final now = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];

    // Obtener datos reales de analytics
    final moodData = analyticsProvider.getMoodChartData();

    // Crear mapa de datos por fecha
    final dataByDate = <String, double>{};
    for (final data in moodData) {
      final dateStr = data['date'] as String? ?? '';
      final mood = (data['mood'] as num? ?? 5.0).toDouble();
      dataByDate[dateStr] = mood;
    }

    // Generar 7 días (de lunes a domingo de esta semana)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Lunes
    final dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
      final isPast = date.isBefore(now) || isToday;

      // Si es un día futuro, no hay datos
      final score = isPast ? (dataByDate[dateStr] ?? 0.0) : 0.0;

      weeklyData.add({
        'dayName': dayNames[i],
        'date': date,
        'score': score,
        'isToday': isToday,
        'isPast': isPast,
        'hasData': score > 0.0, // Agregado para indicar si hay datos para ese día
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
      final hasData = score > 0;

      // Altura basada en el score (0-10 -> 0-100px)
      final height = hasData ? (score / 10.0) * 100 : 0.0;

      return AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500 + (index * 100)),
            curve: Curves.elasticOut,
            width: 24,
            height: height * _fadeAnimation.value,
            decoration: BoxDecoration(
              gradient: hasData
                  ? LinearGradient(
                colors: isToday
                    ? [const Color(0xFF10B981), const Color(0xFF34D399)] // Verde para hoy
                    : MinimalColors.accentGradient,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              )
                  : LinearGradient(
                colors: [
                  MinimalColors.textMuted.withOpacity(0.3),
                  MinimalColors.textMuted.withOpacity(0.1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: hasData
                  ? [
                BoxShadow(
                  color: isToday
                      ? const Color(0xFF10B981).withOpacity(0.4)
                      : MinimalColors.accentGradient[1].withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
            ),
            child: hasData
                ? Center(
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
                : Container(), // Vacío para días sin datos
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
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tus Logros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
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
            ? const Color(0xFF10B981).withOpacity(0.1) // Verde suave para completados
            : MinimalColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withOpacity(0.3) // Borde verde para completados
              : MinimalColors.primaryGradient[0].withOpacity(0.2),
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
                      ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]) // Verde
                      : const LinearGradient(colors: MinimalColors.accentGradient), // Azul-morado
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textSecondary,
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
                      : MinimalColors.accentGradient[0].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted
                      ? '✅ COMPLETADO' // ✅ MENSAJE ESPECIAL PARA 100%
                      : '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white : MinimalColors.accentGradient[0],
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
                backgroundColor: MinimalColors.textMuted.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  MinimalColors.accentGradient[0],
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
    // Incluir tanto los que están cerca (>= 0.8) como los completados (>= 1.0)
    return goalsProvider.activeGoals
        .where((goal) => goal.progress >= 0.8)
        .take(3) // Mostrar hasta 3
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
    final wellbeingData = analyticsProvider.getWellbeingStatus();
    final score = (wellbeingData['score'] as num?)?.toDouble() ?? 7.5;

    return AnimatedBuilder( // ✅ AGREGAR ANIMACIÓN
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value * 0.01), // Animación sutil
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: MinimalColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              // 🎨 SOMBRA DEGRADADA AÑADIDA
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient[0].withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(-5, 10),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient[1].withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(5, 10),
                ),
              ],
            ),
            child: Row(
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
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getScoreDescription(score),
                        style: const TextStyle(
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
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      _getScoreEmoji(score),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildMomentsFaceCard(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.todayMoments;
    final positiveCount = todayMoments.where((m) => m.type == 'positive').length;
    final negativeCount = todayMoments.where((m) => m.type == 'negative').length;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient[0].withOpacity(0.3),
                width: 1,
              ),
              // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                  color: MinimalColors.textMuted.withOpacity(0.3),
                ),
                _buildMomentCounter(
                  icon: Icons.sentiment_dissatisfied,
                  count: negativeCount,
                  label: 'Negativos',
                  // 🔥 COLOR DE NEGATIVOS CAMBIADO A ROJO
                  gradient: [const Color(0xFFb91c1c), const Color(0xFFef4444)],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      color: gradient[0].withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: gradient[1].withOpacity(0.3),
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
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary,
                  ),
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
          ),
        );
      },
    );
  }

  Widget _buildContextualRecommendations(OptimizedUserModel user, OptimizedAnalyticsProvider analyticsProvider) {
    final recommendations = analyticsProvider.getTopRecommendations();

    if (recommendations.isEmpty) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient[0].withOpacity(0.3),
          width: 1,
        ),
        // 🎨 SOMBRA DEGRADADA AÑADIDA
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
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recomendaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.take(2).map((rec) => AnimatedBuilder( // ✅ ANIMACIÓN INDIVIDUAL
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (math.sin(_floatingAnimation.value * math.pi * 2) * 0.02), // Escala sutil
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MinimalColors.primaryGradient[0].withOpacity(0.2),
                      width: 1,
                    ),
                    // ✅ SOMBRAS MEJORADAS
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.backgroundSecondary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: MinimalColors.accentGradient[0].withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        rec['emoji'] ?? '💡',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec['description'] ?? '',
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
                ),
              );
            },
          )).toList(),
        ],
      ),
    );
  }
}