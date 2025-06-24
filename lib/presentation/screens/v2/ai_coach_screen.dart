// lib/presentation/screens/v2/ai_coach_screen_v3.dart
// PANTALLA COMPLETAMENTE REDISEÑADA PARA ANÁLISIS IA RICO

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../ai/models/ai_response_model.dart';
import '../../../data/models/optimized_models.dart';
import '../../../data/services/optimized_database_service.dart';
import '../../providers/optimized_providers.dart';
import '../../../ai/provider/ai_provider.dart';
import '../components/modern_design_system.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen>
    with TickerProviderStateMixin {

  // Controladores de animación
  late AnimationController _heroController;
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late AnimationController _progressController;
  late AnimationController _scoreController;

  // Animaciones
  late Animation<double> _heroAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _pulseController.dispose();
    _cardController.dispose();
    _progressController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    // Animación principal del hero
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack),
    );

    // Animación de pulso para el cerebro IA
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animaciones de cards
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );

    // Animación de progreso
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Animación de puntuación
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );

    // Iniciar animaciones
    _heroController.forward();
    _pulseController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Consumer2<OptimizedAuthProvider, AIProvider>(
        builder: (context, authProvider, aiProvider, child) {
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            return _buildUnauthenticatedView();
          }

          return _buildMainView(authProvider, aiProvider);
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ModernColors.primaryGradient,
        ),
      ),
      child: const Center(
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: ModernColors.accentBlue),
              SizedBox(height: 16),
              Text('Inicia sesión para acceder a tu Coach IA',
                  style: ModernTypography.heading3,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainView(OptimizedAuthProvider auth, AIProvider ai) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.darkPrimary,
            ModernColors.darkSecondary,
          ],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroHeader(auth, ai),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Estado principal basado en el AI Provider
                if (!ai.isInitialized && !ai.isInitializing)
                  _buildEnhancedInitializeCard(ai),

                if (ai.isInitializing)
                  _buildEnhancedProgressCard(ai),

                if (ai.errorMessage != null)
                  _buildEnhancedErrorCard(ai),

                if (ai.isInitialized && !ai.isInitializing && ai.lastSummary == null)
                  _buildEnhancedReadyCard(auth, ai),

                if (ai.lastSummary != null)
                  _buildCompleteAnalysisDisplay(ai.lastSummary!),

                const SizedBox(height: 32),
                _buildInsightsPreview(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(OptimizedAuthProvider auth, AIProvider ai) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _heroAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _heroAnimation.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                      Color(0xFF9333EA),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.psychology,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Hola, ${auth.currentUser?.name ?? 'Usuario'}!',
                        style: ModernTypography.heading2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu Coach de Bienestar Personal',
                        style: ModernTypography.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      if (ai.isInitialized) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ai.isGenAIAvailable ? '🤖 IA Nativa' : '🧠 Análisis Inteligente',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedInitializeCard(AIProvider ai) {
    return SlideTransition(
      position: _cardSlideAnimation,
      child: FadeTransition(
        opacity: _cardFadeAnimation,
        child: ModernCard(
          gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Icon(
                  Icons.download_for_offline,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '🚀 Activa tu Coach IA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Descarga el modelo de IA (2.1 GB) para obtener análisis completamente privados y sin conexión.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Beneficios en chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBenefitChip('🔒 100% Privado'),
                  _buildBenefitChip('📱 Sin Internet'),
                  _buildBenefitChip('🧠 IA Avanzada'),
                ],
              ),

              const SizedBox(height: 32),
              _buildGradientButton(
                text: 'Descargar y Activar',
                icon: Icons.rocket_launch,
                onPressed: () => _confirmAndStartDownload(ai),
                gradient: const [Colors.white, Color(0xFFF8F9FA)],
                textColor: const Color(0xFF667eea),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProgressCard(AIProvider ai) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        // Sincronizar animación con progreso real
        if (ai.initProgress > 0) {
          _progressController.animateTo(ai.initProgress);
        }

        return ModernCard(
          gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: ai.initProgress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '${(ai.initProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                ai.status,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Barra de progreso lineal con gradiente
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(0.3),
                ),
                child: LinearProgressIndicator(
                  value: ai.initProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Tu IA se está preparando para ofrecerte insights únicos y personalizados ✨',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedErrorCard(AIProvider ai) {
    return ModernCard(
      gradient: const [Color(0xFFff6b6b), Color(0xFFee5253)],
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ups, algo salió mal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ai.errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            text: 'Reintentar',
            icon: Icons.refresh,
            onPressed: () => ai.initializeAI(),
            gradient: const [Colors.white, Color(0xFFF8F9FA)],
            textColor: const Color(0xFFff6b6b),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedReadyCard(OptimizedAuthProvider auth, AIProvider ai) {
    return ModernCard(
      gradient: const [Color(0xFF4ecdc4), Color(0xFF44a08d)],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Tu Coach está listo!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ai.isGenAIAvailable ? 'Modo nativo activo' : 'Modo compatible activo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Genera un análisis personalizado de tu semana con insights únicos y sugerencias motivacionales.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            text: 'Analizar mi Semana',
            icon: Icons.insights,
            onPressed: () => _generateSummary(auth, ai),
            gradient: const [Colors.white, Color(0xFFF8F9FA)],
            textColor: const Color(0xFF4ecdc4),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteAnalysisDisplay(AIResponseModel summary) {
    // Iniciar animación de score cuando se muestre el análisis
    if (summary.wellnessScore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scoreController.forward();
      });
    }

    return Column(
      children: [
        // Header del análisis con métricas rápidas
        _buildAnalysisHeader(summary),

        const SizedBox(height: 16),

        // Puntuación de bienestar destacada (si existe)
        if (summary.wellnessScore != null)
          _buildWellnessScoreCard(summary.wellnessScore!),

        const SizedBox(height: 16),

        // Resumen principal
        _buildSummarySection(
          title: '📖 Resumen de tu Semana',
          content: summary.summary,
          gradient: const [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          icon: Icons.menu_book,
        ),

        const SizedBox(height: 16),

        // Momento destacado (si existe)
        if (summary.highlightedMoment != null)
          _buildHighlightedMomentCard(summary.highlightedMoment!),

        const SizedBox(height: 16),

        // Métricas y correlaciones en grid (si hay datos ricos)
        if (summary.hasRichData)
          _buildMetricsGrid(summary),

        const SizedBox(height: 16),

        // Insights mejorados
        _buildEnhancedInsightsSection(summary.insights),

        const SizedBox(height: 16),

        // Sugerencias con prioridad
        _buildEnhancedSuggestionsSection(summary.suggestions),

        const SizedBox(height: 16),

        // Celebraciones específicas (si existen)
        if (summary.celebrationMoments != null && summary.celebrationMoments!.isNotEmpty)
          _buildCelebrationsCard(summary.celebrationMoments!),

        const SizedBox(height: 16),

        // Enfoque para próxima semana (si existe)
        if (summary.nextWeekFocus != null)
          _buildNextWeekFocusCard(summary.nextWeekFocus!),

        const SizedBox(height: 24),

        // Botón para generar nuevo análisis
        _buildRegenerateButton(),
      ],
    );
  }

  Widget _buildAnalysisHeader(AIResponseModel summary) {
    return ModernCard(
      gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Análisis Semanal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      summary.quickMetricsSummary,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Barra de tiempo transcurrido desde el análisis
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Generado ${_getTimeAgo(summary.generatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScoreCard(double score) {
    final percentage = score / 10.0;
    final color = _getScoreColor(score);

    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return ModernCard(
          gradient: [color, color.withOpacity(0.8)],
          child: Column(
            children: [
              const Text(
                '⭐ Puntuación de Bienestar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: percentage * _scoreAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        (score * _scoreAnimation.value).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '/10',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getScoreMessage(score),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightedMomentCard(String moment) {
    return ModernCard(
      gradient: const [Color(0xFFfeca57), Color(0xFFff9f43)],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '✨ Momento Destacado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              moment,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(AIResponseModel summary) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Métricas de la Semana',
            style: ModernTypography.heading3,
          ),
          const SizedBox(height: 16),

          // Primera fila de métricas
          Row(
            children: [
              // Días registrados
              if (summary.weeklyMetrics?['daysWithReflections'] != null)
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.calendar_today,
                    title: 'Días',
                    value: '${summary.weeklyMetrics!['daysWithReflections']}/7',
                    color: const Color(0xFF3B82F6),
                  ),
                ),

              const SizedBox(width: 12),

              // Estado de ánimo promedio
              if (summary.weeklyMetrics?['averageMood'] != null)
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.mood,
                    title: 'Ánimo',
                    value: '${summary.weeklyMetrics!['averageMood'].toStringAsFixed(1)}/10',
                    color: const Color(0xFF10B981),
                  ),
                ),

              const SizedBox(width: 12),

              // Correlación más fuerte
              if (summary.strongestCorrelation != null)
                Expanded(
                  child: _buildMetricCard(
                    icon: Icons.insights,
                    title: 'Correlación',
                    value: '${(summary.strongestCorrelation!.value * 100).toStringAsFixed(0)}%',
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
            ],
          ),

          // Días pico y desafiante
          if (summary.peakDay != null || summary.challengingDay != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (summary.peakDay != null)
                  Expanded(
                    child: _buildDayCard(
                      day: summary.peakDay!['day'],
                      reason: summary.peakDay!['reason'],
                      icon: Icons.trending_up,
                      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                  ),

                if (summary.peakDay != null && summary.challengingDay != null)
                  const SizedBox(width: 12),

                if (summary.challengingDay != null)
                  Expanded(
                    child: _buildDayCard(
                      day: summary.challengingDay!['day'],
                      reason: summary.challengingDay!['reason'],
                      icon: Icons.trending_down,
                      gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard({
    required String day,
    required String reason,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            day,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required String content,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return ModernCard(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInsightsSection(List<String> insights) {
    return ModernCard(
      gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                '💡 Insights Clave',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEnhancedSuggestionsSection(List<String> suggestions) {
    return ModernCard(
      gradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.recommend, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                '🎯 Sugerencias Personalizadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            final priority = _getSuggestionPriority(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    priority['icon'],
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                priority['label'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCelebrationsCard(List<String> celebrations) {
    return ModernCard(
      gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.celebration, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                '🎉 Momentos para Celebrar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...celebrations.map((celebration) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    celebration,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.5,
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

  Widget _buildNextWeekFocusCard(String focus) {
    return ModernCard(
      gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '🔮 Enfoque para la Próxima Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              focus,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegenerateButton() {
    return Center(
      child: _buildGradientButton(
        text: 'Generar Nuevo Análisis',
        icon: Icons.refresh,
        onPressed: () {
          final authProvider = context.read<OptimizedAuthProvider>();
          final aiProvider = context.read<AIProvider>();
          _generateSummary(authProvider, aiProvider);
        },
        gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
        textColor: Colors.white,
      ),
    );
  }

  Widget _buildInsightsPreview() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚀 Próximamente en tu Coach IA',
            style: ModernTypography.heading3,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.trending_up,
            title: 'Correlaciones Automáticas',
            description: 'Descubre conexiones entre tus actividades y estados de ánimo',
            color: ModernColors.accentBlue,
          ),
          _buildFeatureItem(
            icon: Icons.search,
            title: 'Búsqueda Semántica',
            description: 'Busca por sentimientos y conceptos en tus reflexiones',
            color: ModernColors.accentGreen,
          ),
          _buildFeatureItem(
            icon: Icons.notifications_active,
            title: 'Notificaciones Empáticas',
            description: 'Recordatorios inteligentes basados en tu estado actual',
            color: ModernColors.accentOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ModernTypography.heading4),
                const SizedBox(height: 4),
                Text(description, style: ModernTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> gradient,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares
  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF10B981); // Verde excelente
    if (score >= 6.5) return const Color(0xFF3B82F6); // Azul bueno
    if (score >= 5.0) return const Color(0xFFF59E0B); // Naranja regular
    return const Color(0xFFEF4444); // Rojo necesita atención
  }

  String _getScoreMessage(double score) {
    if (score >= 8.5) return '¡Excelente bienestar! Estás en tu mejor momento 🚀';
    if (score >= 7.0) return 'Muy buen nivel de bienestar, sigue así 💪';
    if (score >= 6.0) return 'Bienestar sólido con oportunidades de mejora ⚖️';
    if (score >= 4.0) return 'Momento de enfocarse en el autocuidado 🌱';
    return 'Es importante priorizar tu bienestar esta semana 💙';
  }

  Map<String, dynamic> _getSuggestionPriority(int index) {
    switch (index) {
      case 0:
        return {'label': 'ALTA', 'icon': Icons.priority_high};
      case 1:
        return {'label': 'MEDIA', 'icon': Icons.trending_up};
      default:
        return {'label': 'EXPLORAR', 'icon': Icons.explore};
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'hace un momento';
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace ${difference.inHours} h';
    return 'hace ${difference.inDays} días';
  }

  void _confirmAndStartDownload(AIProvider ai) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ModernColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.download, color: ModernColors.accentBlue),
            SizedBox(width: 12),
            Text('Confirmar Descarga', style: ModernTypography.heading3),
          ],
        ),
        content: const Text(
          'Se descargará el modelo de IA (aprox. 2.1 GB). Se recomienda usar Wi-Fi para evitar cargos de datos.\n\n¿Deseas continuar?',
          style: ModernTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ai.initializeAI();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSummary(OptimizedAuthProvider auth, AIProvider ai) async {
    try {
      final dbService = OptimizedDatabaseService();
      final weeklyData = await dbService.getWeeklyDataForAI(auth.currentUser!.id);

      await ai.generateWeeklySummary(
        weeklyEntries: weeklyData['entries'],
        weeklyMoments: weeklyData['moments'],
        userName: auth.currentUser!.name,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generando análisis: $e'),
          backgroundColor: ModernColors.error,
        ),
      );
    }
  }
}