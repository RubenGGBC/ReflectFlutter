// lib/presentation/screens/v2/home_screen_v2.dart - APPLE DESIGN INSPIRED
// ============================================================================
// PANTALLA DE INICIO CON ESTILO VISUAL DE APPLE + RECOMENDACIONES DE IA
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/extended_daily_entries_provider.dart';

// Modelos
import '../../../data/models/optimized_models.dart';
import '../../../data/models/goal_model.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// Widgets personalizados
import '../../widgets/profile_picture_widget.dart';
import '../../widgets/goals_recommendations_widget.dart';

// ============================================================================
// PALETA DE COLORES INSPIRADA EN MONTEREY DARK
// ============================================================================
class MontereyColors {
  // Colores de fondo - Monterey Dark Theme
  static const Color backgroundPrimary = Color(0xFF0D0B1E);     // Deep Purple Black
  static const Color backgroundSecondary = Color(0xFF1A1625);   // Dark Purple
  static const Color backgroundTertiary = Color(0xFF252035);    // Medium Purple

  // Colores principales - Monterey Gradient Colors
  static const Color primaryPurple = Color(0xFF7C3AED);         // Vibrant Purple
  static const Color primaryMagenta = Color(0xFFD946EF);        // Bright Magenta
  static const Color primaryBlue = Color(0xFF3B82F6);           // Electric Blue
  static const Color primaryCyan = Color(0xFF06B6D4);           // Cyan

  // Colores secundarios - Monterey Accent Colors
  static const Color accentPink = Color(0xFFEC4899);            // Hot Pink
  static const Color accentRose = Color(0xFFF472B6);            // Light Rose
  static const Color accentIndigo = Color(0xFF6366F1);          // Indigo
  static const Color accentViolet = Color(0xFF8B5CF6);          // Violet
  static const Color accentTeal = Color(0xFF14B8A6);            // Teal
  static const Color accentEmerald = Color(0xFF10B981);         // Emerald

  // Colores de superficie - Glass Effect
  static const Color surfacePrimary = Color(0xFF1E1B2E);        // Glass Surface
  static const Color surfaceSecondary = Color(0xFF2A2640);      // Elevated Surface
  static const Color surfaceTertiary = Color(0xFF363152);       // Highest Surface

  // Colores de texto - Dark Theme Typography
  static const Color labelPrimary = Color(0xFFFFFFFF);          // White Text
  static const Color labelSecondary = Color(0xFFB4B4B8);        // Gray Text
  static const Color labelTertiary = Color(0xFF8E8E93);         // Muted Text

  // Gradientes Monterey-style
  static const List<Color> primaryGradient = [Color(0xFF7C3AED), Color(0xFFD946EF)];
  static const List<Color> blueGradient = [Color(0xFF3B82F6), Color(0xFF06B6D4)];
  static const List<Color> pinkGradient = [Color(0xFFEC4899), Color(0xFFF472B6)];
  static const List<Color> purpleGradient = [Color(0xFF8B5CF6), Color(0xFF6366F1)];
  static const List<Color> meshGradient = [Color(0xFF7C3AED), Color(0xFF3B82F6), Color(0xFF06B6D4), Color(0xFFEC4899)];
  static const List<Color> backgroundGradient = [Color(0xFF0D0B1E), Color(0xFF1A1625), Color(0xFF252035)];
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
  late AnimationController _profilePictureController;
  late AnimationController _welcomeTextController;
  late AnimationController _cardsController;
  late AnimationController _pulseController;
  late AnimationController _goalsController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _profilePictureAnimation;
  late Animation<Offset> _welcomeTextAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _goalsAnimation;

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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _profilePictureController.dispose();
    _welcomeTextController.dispose();
    _cardsController.dispose();
    _pulseController.dispose();
    _goalsController.dispose();
    super.dispose();
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
    _profilePictureController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _welcomeTextController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _goalsController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _profilePictureAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _profilePictureController, curve: Curves.easeOutBack),
    );

    _welcomeTextAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeTextController,
      curve: Curves.easeOutCubic,
    ));

    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _goalsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _goalsController, curve: Curves.easeInOut),
    );

    // Animaciones secuenciales más suaves
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () => _slideController.forward());
    Future.delayed(const Duration(milliseconds: 200), () => _profilePictureController.forward());
    Future.delayed(const Duration(milliseconds: 300), () => _welcomeTextController.forward());
    Future.delayed(const Duration(milliseconds: 400), () => _cardsController.forward());
    Future.delayed(const Duration(milliseconds: 500), () => _goalsController.forward());

    _pulseController.repeat(reverse: true);
  }

  void _loadInitialData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<OptimizedMomentsProvider>().loadMoments(user.id);
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id);
      context.read<GoalsProvider>().loadUserGoals(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer6<OptimizedAuthProvider, OptimizedDailyEntriesProvider,
        OptimizedMomentsProvider, OptimizedAnalyticsProvider, GoalsProvider, ExtendedDailyEntriesProvider>(
      builder: (context, authProvider, entriesProvider, momentsProvider,
          analyticsProvider, goalsProvider, extendedDailyProvider, child) {

        return Container(
          // 🌌 FONDO ESTILO MONTEREY DARK - Gradiente dinámico
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: MontereyColors.backgroundGradient,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Header estilo Monterey
                      _buildMontereyStyledHeader(authProvider),
                      const SizedBox(height: 32),

                      // Indicador de estado de IA
                      const AIStatusIndicator(),

                      // Widget de recomendaciones de IA
                      const GoalsRecommendationsWidget(),

                      // Momentos del día estilo Monterey
                      _buildMontereyStyledMomentsSection(momentsProvider),
                      const SizedBox(height: 24),

                      // Estado de reflexión estilo Monterey
                      _buildMontereyStyledReflectionSection(entriesProvider),
                      const SizedBox(height: 24),

                      // Métricas de bienestar estilo Monterey
                      _buildMontereyStyledMetricsSection(analyticsProvider),
                      const SizedBox(height: 24),

                      // Progreso semanal estilo Monterey
                      _buildMontereyStyledWeeklyProgress(analyticsProvider),
                      const SizedBox(height: 24),

                      // Tracker de humor estilo Monterey
                      _buildMontereyStyledMoodTracker(analyticsProvider),
                      const SizedBox(height: 24),

                      // Goals activos estilo Monterey + IA
                      _buildMontereyStyledActiveGoalsSection(goalsProvider, extendedDailyProvider),
                      const SizedBox(height: 24),

                      // Tareas de hoy estilo Monterey
                      _buildMontereyStyledTodayTasks(momentsProvider),
                      const SizedBox(height: 24),

                      // Recomendaciones estilo Monterey
                      _buildMontereyStyledRecommendations(analyticsProvider),
                      const SizedBox(height: 24),

                      // Programas destacados estilo Monterey
                      _buildMontereyStyledFeaturedPrograms(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // 🌌 HEADER ESTILO MONTEREY DARK
  // ============================================================================
  Widget _buildMontereyStyledHeader(OptimizedAuthProvider authProvider) {
    final user = authProvider.currentUser;
    final userName = user?.name ?? 'Usuario';

    return SlideTransition(
      position: _welcomeTextAnimation,
      child: Row(
        children: [
          // Avatar estilo Monterey con glassmorphism
          ScaleTransition(
            scale: _profilePictureAnimation,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: MontereyColors.surfacePrimary,
                border: Border.all(
                  color: MontereyColors.primaryPurple.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MontereyColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: user?.profilePicturePath != null
                    ? Image.file(
                  File(user!.profilePicturePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildMontereyDefaultAvatar(),
                )
                    : _buildMontereyDefaultAvatar(),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Saludo contextual estilo Monterey
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: MontereyColors.labelSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: const TextStyle(
                    color: MontereyColors.labelPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Botón de notificaciones estilo Monterey
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MontereyColors.surfacePrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MontereyColors.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MontereyColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications-settings');
              },
              icon: Icon(
                Icons.notifications_none_rounded,
                color: MontereyColors.primaryBlue,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontereyDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: MontereyColors.primaryGradient,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  // ============================================================================
  // 🌌 MOMENTOS DEL DÍA ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledMomentsSection(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.todayMoments;
    final positiveMoments = todayMoments.where((m) => m.type == 'positive').length;
    final negativeMoments = todayMoments.where((m) => m.type == 'negative').length;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título estilo Monterey
            _buildMontereySectionTitle('Momentos de Hoy', Icons.wb_sunny_outlined),
            const SizedBox(height: 16),

            // Grid estilo Monterey
            Row(
              children: [
                // Momentos positivos
                Expanded(
                  child: _buildMontereyMomentCard(
                    title: 'Positivos',
                    value: positiveMoments.toString(),
                    icon: Icons.sentiment_satisfied_rounded,
                    color: MontereyColors.accentEmerald,
                  ),
                ),
                const SizedBox(width: 16),

                // Momentos por mejorar
                Expanded(
                  child: _buildMontereyMomentCard(
                    title: 'Por mejorar',
                    value: negativeMoments.toString(),
                    icon: Icons.sentiment_neutral_rounded,
                    color: MontereyColors.accentPink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontereySectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: MontereyColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: MontereyColors.labelPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMontereyMomentCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ícono estilo Monterey
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),

          // Valor
          Text(
            value,
            style: const TextStyle(
              color: MontereyColors.labelPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),

          // Título
          Text(
            title,
            style: const TextStyle(
              color: MontereyColors.labelSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.24,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🌌 ESTADO DE REFLEXIÓN ESTILO MONTEREY DARK
  // ============================================================================
  Widget _buildMontereyStyledReflectionSection(OptimizedDailyEntriesProvider entriesProvider) {
    final todayEntry = entriesProvider.todayEntry;
    final isCompleted = todayEntry != null;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MontereyColors.surfacePrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? MontereyColors.accentEmerald.withOpacity(0.3)
                  : MontereyColors.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? MontereyColors.accentEmerald.withOpacity(0.2)
                    : MontereyColors.primaryBlue.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ícono estilo Monterey
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [MontereyColors.accentEmerald.withOpacity(0.8), MontereyColors.accentEmerald]
                        : MontereyColors.blueGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted ? 'Reflexión Completada' : 'Reflexión Pendiente',
                      style: const TextStyle(
                        color: MontereyColors.labelPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Has completado tu reflexión de hoy. ¡Excelente!'
                          : 'Tómate unos minutos para reflexionar sobre tu día.',
                      style: const TextStyle(
                        color: MontereyColors.labelSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de acción estilo Monterey
              if (!isCompleted)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: MontereyColors.blueGradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pushNamed(context, '/daily-review');
                      },
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 🌌 MÉTRICAS DE BIENESTAR ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledMetricsSection(OptimizedAnalyticsProvider analyticsProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título estilo Monterey
            _buildMontereySectionTitle('Métricas de Bienestar', Icons.analytics_outlined),
            const SizedBox(height: 16),

            // Grid de métricas estilo Monterey
            Row(
              children: [
                // Puntuación de bienestar
                Expanded(
                  flex: 2,
                  child: _buildMontereyWellnessScore(analyticsProvider),
                ),
                const SizedBox(width: 16),

                // Métricas secundarias
                Expanded(
                  child: Column(
                    children: [
                      _buildMontereySmallMetricCard(
                        title: 'Racha',
                        value: _getStreakValue(analyticsProvider),
                        icon: Icons.local_fire_department_rounded,
                        color: MontereyColors.accentPink,
                      ),
                      const SizedBox(height: 16),
                      _buildMontereySmallMetricCard(
                        title: 'Humor',
                        value: _getMoodValue(analyticsProvider),
                        icon: Icons.sentiment_satisfied_rounded,
                        color: MontereyColors.accentViolet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMontereyWellnessScore(OptimizedAnalyticsProvider analyticsProvider) {
    final score = _getWellnessScore(analyticsProvider);

    return Container(
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MontereyColors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MontereyColors.primaryPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Círculo de progreso estilo Monterey
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: score / 10,
                  strokeWidth: 6,
                  backgroundColor: MontereyColors.backgroundTertiary,
                  valueColor: const AlwaysStoppedAnimation<Color>(MontereyColors.primaryPurple),
                ),
              ),
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  color: MontereyColors.labelPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'Bienestar',
            style: TextStyle(
              color: MontereyColors.labelSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontereySmallMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: MontereyColors.labelPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: MontereyColors.labelSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🌌 PROGRESO SEMANAL ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledWeeklyProgress(OptimizedAnalyticsProvider analyticsProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MontereyColors.surfacePrimary, // FIX: Use Monterey color
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // FIX: Adjusted shadow for dark theme
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título con ícono estilo Apple
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: MontereyColors.primaryPurple.withOpacity(0.1), // FIX: Use Monterey color
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: MontereyColors.primaryPurple, // FIX: Use Monterey color
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Progreso Semanal',
                    style: TextStyle(
                      color: MontereyColors.labelPrimary, // FIX: Use Monterey color
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico estilo Apple
              _buildMontereyWeeklyChart(), // FIX: Corrected method name
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMontereyWeeklyChart() {
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final values = [0.8, 0.6, 0.9, 0.7, 0.5, 0.8, 0.4];

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isToday = index == DateTime.now().weekday - 1;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Barra estilo Monterey
              Container(
                width: 20,
                height: 64 * values[index],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isToday
                        ? MontereyColors.primaryGradient
                        : [MontereyColors.primaryPurple.withOpacity(0.3), MontereyColors.primaryPurple.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              // Día
              Text(
                days[index],
                style: TextStyle(
                  color: isToday
                      ? MontereyColors.primaryPurple
                      : MontereyColors.labelSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.08,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================================
  // 🌌 TRACKER DE HUMOR ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledMoodTracker(OptimizedAnalyticsProvider analyticsProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MontereyColors.surfacePrimary, // FIX: Use Monterey color
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // FIX: Adjusted shadow for dark theme
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título estilo Apple
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: MontereyColors.accentTeal.withOpacity(0.1), // FIX: Use Monterey color
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.sentiment_satisfied_rounded,
                      color: MontereyColors.accentTeal, // FIX: Use Monterey color
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Tracker de Humor',
                    style: TextStyle(
                      color: MontereyColors.labelPrimary, // FIX: Use Monterey color
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Emojis de humor estilo Apple
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMontereyMoodEmoji('😢', 1, false), // FIX: Corrected method name
                  _buildMontereyMoodEmoji('😕', 2, false), // FIX: Corrected method name
                  _buildMontereyMoodEmoji('😐', 3, false), // FIX: Corrected method name
                  _buildMontereyMoodEmoji('😊', 4, true),  // FIX: Corrected method name (Seleccionado)
                  _buildMontereyMoodEmoji('😄', 5, false), // FIX: Corrected method name
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMontereyMoodEmoji(String emoji, int value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Implementar selección de humor
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? MontereyColors.surfaceSecondary
              : MontereyColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? MontereyColors.primaryBlue
                : MontereyColors.labelTertiary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: MontereyColors.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // 🌌 GOALS ACTIVOS ESTILO MONTEREY + IA
  // ============================================================================
  Widget _buildMontereyStyledActiveGoalsSection(GoalsProvider goalsProvider, ExtendedDailyEntriesProvider extendedProvider) {
    final activeGoals = goalsProvider.activeGoals.take(3).toList();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _goalsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con indicador de IA estilo Apple
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: MontereyColors.accentIndigo.withOpacity(0.1), // FIX: Use Monterey color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: MontereyColors.accentIndigo, // FIX: Use Monterey color
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Goals Activos',
                      style: TextStyle(
                        color: MontereyColors.labelPrimary, // FIX: Use Monterey color
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Indicador de IA estilo Monterey
                    if (extendedProvider.hasNewRecommendations)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: MontereyColors.blueGradient),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/goals'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: MontereyColors.primaryBlue.withOpacity(0.1), // FIX: Use Monterey color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(
                        color: MontereyColors.primaryBlue, // FIX: Use Monterey color
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.08,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goals activos o estado vacío estilo Monterey
            if (activeGoals.isEmpty)
              _buildMontereyEmptyGoalsState()
            else
              ...activeGoals.map((goal) => _buildMontereyGoalCard(goal)).toList(),

            // Resumen de recomendaciones de IA estilo Monterey
            if (extendedProvider.recommendations.isNotEmpty && !extendedProvider.hasNewRecommendations)
              _buildMontereyAIRecommendationsSummary(extendedProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildMontereyEmptyGoalsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MontereyColors.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MontereyColors.primaryPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: MontereyColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: MontereyColors.labelTertiary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay goals activos',
            style: TextStyle(
              color: MontereyColors.labelPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.36,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primer goal para empezar a seguir tu progreso',
            style: TextStyle(
              color: MontereyColors.labelSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: MontereyColors.primaryGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.pushNamed(context, '/goals'),
                child: const Center(
                  child: Text(
                    'Crear Goal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontereyAIRecommendationsSummary(ExtendedDailyEntriesProvider extendedProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MontereyColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: MontereyColors.blueGradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recomendaciones IA Disponibles',
                  style: TextStyle(
                    color: MontereyColors.labelPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.24,
                  ),
                ),
                Text(
                  '${extendedProvider.recommendations.length} goals personalizados listos',
                  style: const TextStyle(
                    color: MontereyColors.labelSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.08,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: MontereyColors.blueGradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Ver',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.08,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontereyGoalCard(dynamic goal) {
    final progress = goal.currentValue / goal.targetValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getMontereyGoalTypeColor(goal.type).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getMontereyGoalTypeColor(goal.type).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del goal estilo Apple
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getMontereyGoalTypeColor(goal.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getGoalTypeIcon(goal.type),
                  color: _getMontereyGoalTypeColor(goal.type),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: MontereyColors.labelPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: _getMontereyGoalTypeColor(goal.type),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de progreso estilo Monterey
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: MontereyColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _getMontereyGoalTypeColor(goal.type),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progreso textual estilo Monterey
          Text(
            '${goal.currentValue} / ${goal.targetValue}',
            style: const TextStyle(
              color: MontereyColors.labelSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.08,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🌌 TAREAS DE HOY ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledTodayTasks(OptimizedMomentsProvider momentsProvider) {
    final tasks = ['Meditar 10 minutos', 'Hacer ejercicio', 'Leer 30 páginas'];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título estilo Monterey
            _buildMontereySectionTitle('Tareas de Hoy', Icons.checklist_rounded),
            const SizedBox(height: 16),

            // Lista de tareas estilo Monterey
            ...tasks.map((task) => _buildMontereyTaskCard(task)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMontereyTaskCard(String task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MontereyColors.accentIndigo.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MontereyColors.accentIndigo.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: MontereyColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: MontereyColors.accentIndigo.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task,
              style: const TextStyle(
                color: MontereyColors.labelPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🌌 RECOMENDACIONES ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledRecommendations(OptimizedAnalyticsProvider analyticsProvider) {
    final recommendations = [
      'Intenta meditar por 5 minutos hoy',
      'Da un paseo de 15 minutos',
      'Escribe 3 cosas por las que estés agradecido',
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título estilo Monterey
            _buildMontereySectionTitle('Recomendaciones Personalizadas', Icons.lightbulb_outline_rounded),
            const SizedBox(height: 16),

            // Lista de recomendaciones estilo Monterey
            ...recommendations.map((rec) => _buildMontereyRecommendationCard(rec)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMontereyRecommendationCard(String recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MontereyColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MontereyColors.primaryBlue.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: MontereyColors.blueGradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(
                color: MontereyColors.labelPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // 🌌 PROGRAMAS DESTACADOS ESTILO MONTEREY
  // ============================================================================
  Widget _buildMontereyStyledFeaturedPrograms() {
    final programs = [
      {
        'title': 'Meditación Diaria',
        'description': 'Programa de 21 días',
        'color': MontereyColors.accentViolet,
        'icon': Icons.spa_rounded,
      },
      {
        'title': 'Hábitos Saludables',
        'description': 'Rutina de bienestar',
        'color': MontereyColors.accentEmerald,
        'icon': Icons.favorite_rounded,
      },
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _cardsAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título estilo Monterey
            _buildMontereySectionTitle('Programas Destacados', Icons.stars_rounded),
            const SizedBox(height: 16),

            // Lista de programas estilo Monterey
            ...programs.map((program) => _buildMontereyProgramCard(program)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMontereyProgramCard(Map<String, dynamic> program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MontereyColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (program['color'] as Color).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (program['color'] as Color).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono estilo Monterey
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [(program['color'] as Color).withOpacity(0.8), program['color']],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              program['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Contenido estilo Monterey
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program['title'],
                  style: const TextStyle(
                    color: MontereyColors.labelPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.32,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  program['description'],
                  style: const TextStyle(
                    color: MontereyColors.labelSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.08,
                  ),
                ),
              ],
            ),
          ),

          // Botón de acción estilo Monterey
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [(program['color'] as Color).withOpacity(0.8), program['color']],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  double _getWellnessScore(OptimizedAnalyticsProvider analytics) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final avgMood = basicStats?['avg_mood'] as double? ?? 7.0;
    return avgMood;
  }

  String _getStreakValue(OptimizedAnalyticsProvider analytics) {
    final streakData = analytics.analytics['streak_data'] as Map<String, dynamic>?;
    final currentStreak = streakData?['current_streak'] as int? ?? 0;
    return currentStreak.toString();
  }

  String _getMoodValue(OptimizedAnalyticsProvider analytics) {
    final basicStats = analytics.analytics['basic_stats'] as Map<String, dynamic>?;
    final avgMood = basicStats?['avg_mood'] as double? ?? 0.0;
    return avgMood.toStringAsFixed(1);
  }

  // Colores Monterey para tipos de goals
  Color _getMontereyGoalTypeColor(dynamic goalType) {
    final typeString = goalType.toString();
    if (typeString.contains('consistency')) return MontereyColors.primaryBlue;
    if (typeString.contains('mood')) return MontereyColors.accentPink;
    if (typeString.contains('positiveMoments')) return MontereyColors.accentEmerald;
    if (typeString.contains('stressReduction')) return MontereyColors.accentViolet;
    return MontereyColors.primaryPurple;
  }

  IconData _getGoalTypeIcon(dynamic goalType) {
    final typeString = goalType.toString();
    if (typeString.contains('consistency')) return Icons.timeline_rounded;
    if (typeString.contains('mood')) return Icons.sentiment_satisfied_rounded;
    if (typeString.contains('positiveMoments')) return Icons.star_rounded;
    if (typeString.contains('stressReduction')) return Icons.spa_rounded;
    return Icons.flag_rounded;
  }
}