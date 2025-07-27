// ============================================================================
// daily_detail_screen_v3.dart - DETALLE DIARIO COMPLETO CON TODAS LAS FUNCIONALIDADES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fl_chart/fl_chart.dart';

// Core
import '../../../core/themes/app_theme.dart';

// Data Models
import '../../../data/models/daily_entry_model.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/interactive_moment_model.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/enhanced_goals_provider.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/image_moments_provider.dart';
import '../../providers/advanced_emotion_analysis_provider.dart';

// Screens
import 'daily_review_screen_v3.dart';
import 'calendar_screen_v3.dart';

// Widgets
import '../../widgets/voice_recording_widget.dart';

class DailyDetailScreenV3 extends StatefulWidget {
  final DateTime date;

  const DailyDetailScreenV3({
    super.key,
    required this.date,
  });

  @override
  State<DailyDetailScreenV3> createState() => _DailyDetailScreenV3State();
}

class _DailyDetailScreenV3State extends State<DailyDetailScreenV3>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================

  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _metricsController;
  late AnimationController _pulseController;
  late AnimationController _fabController;

  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _metricsAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fabAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5; // Overview, Métricas, Momentos, Metas, Análisis

  // Estados de la UI
  bool _showAllMetrics = false;
  bool _isVoiceExpanded = false;
  String? _selectedVoiceNote;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _metricsController.dispose();
    _pulseController.dispose();
    _fabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _metricsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    _metricsAnimation = CurvedAnimation(
      parent: _metricsController,
      curve: Curves.elasticOut,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );

    // Iniciar animaciones secuencialmente
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _metricsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabController.forward();
    });
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      // Cargar entrada diaria
      context.read<OptimizedDailyEntriesProvider>().loadEntriesForDateRange(
        user.id,
        widget.date,
        widget.date,
      );

      // Cargar momentos interactivos
      context.read<OptimizedMomentsProvider>().loadMomentsForDate(
        user.id,
        widget.date,
      );

      // Cargar metas del día
      context.read<EnhancedGoalsProvider>().loadGoalsForDate(
        user.id,
        widget.date,
      );

      // Cargar análisis de emociones
      context.read<AdvancedEmotionAnalysisProvider>().analyzeDay(
        user.id,
        widget.date,
      );

    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.currentColors;

    return Scaffold(
      backgroundColor: colors.primaryBg,
      body: Stack(
        children: [
          _buildGradientBackground(colors),
          _buildContent(colors),
          _buildFloatingElements(colors),
        ],
      ),
      floatingActionButton: _buildFAB(colors),
    );
  }

  Widget _buildGradientBackground(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primaryBg,
            colors.secondaryBg,
            colors.primaryBg,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(colors),
          _buildPageIndicator(colors),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                HapticFeedback.lightImpact();
              },
              children: [
                _buildOverviewPage(colors),
                _buildMetricsPage(colors),
                _buildMomentsPage(colors),
                _buildGoalsPage(colors),
                _buildAnalyticsPage(colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_headerAnimation),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.glassBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.borderColor.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(widget.date),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildThemeToggle(colors),
                ],
              ),
              const SizedBox(height: 16),
              _buildDayStatus(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(AppColors colors) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.glassBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.borderColor.withOpacity(0.3),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                colors.isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(colors.isDark),
                color: colors.accentPrimary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayStatus(AppColors colors) {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        final entry = entriesProvider.getEntryForDate(widget.date);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.borderColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              _buildMoodIndicator(colors, entry?.moodScore ?? 5),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayStatusText(entry),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getDaySubtitle(entry),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildQuickActions(colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodIndicator(AppColors colors, int moodScore) {
    final moodColor = _getMoodColor(colors, moodScore);
    final moodEmoji = _getMoodEmoji(moodScore);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: moodColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: moodColor.withOpacity(0.3 + (_pulseAnimation.value * 0.2)),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              moodEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(AppColors colors) {
    return Row(
      children: [
        _buildQuickActionButton(
          colors,
          Icons.edit_note,
          'Editar',
          () => _navigateToReview(),
        ),
        const SizedBox(width: 8),
        _buildQuickActionButton(
          colors,
          Icons.calendar_today,
          'Calendario',
          () => _navigateToCalendar(),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    AppColors colors,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.accentPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colors.accentPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? colors.accentPrimary
                  : colors.borderColor,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================================
  // PÁGINAS DEL DETALLE
  // ============================================================================

  Widget _buildOverviewPage(AppColors colors) {
    return FadeTransition(
      opacity: _contentAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '📊 Resumen del Día'),
            const SizedBox(height: 16),
            _buildOverviewCards(colors),
            const SizedBox(height: 24),
            _buildRecentMoments(colors),
            const SizedBox(height: 24),
            _buildVoiceNotes(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsPage(AppColors colors) {
    return FadeTransition(
      opacity: _metricsAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '📈 Métricas Detalladas'),
            const SizedBox(height: 16),
            _buildMetricsGrid(colors),
            const SizedBox(height: 24),
            _buildMetricsChart(colors),
            const SizedBox(height: 24),
            _buildParametersSection(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentsPage(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(colors, '✨ Momentos del Día'),
          const SizedBox(height: 16),
          _buildMomentsTimeline(colors),
          const SizedBox(height: 24),
          _buildImageMoments(colors),
          const SizedBox(height: 24),
          _buildQuickMoments(colors),
        ],
      ),
    );
  }

  Widget _buildGoalsPage(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(colors, '🎯 Metas y Progreso'),
          const SizedBox(height: 16),
          _buildGoalsList(colors),
          const SizedBox(height: 24),
          _buildRoadmapSection(colors),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPage(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(colors, '📊 Análisis'),
          const SizedBox(height: 16),
          _buildEmotionAnalysis(colors),
          const SizedBox(height: 24),
          _buildBasicInsights(colors),
        ],
      ),
    );
  }

  // ============================================================================
  // COMPONENTES ESPECÍFICOS
  // ============================================================================

  Widget _buildOverviewCards(AppColors colors) {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        final entry = entriesProvider.getEntryForDate(widget.date);
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    colors,
                    'Estado de Ánimo',
                    '${entry?.moodScore ?? 0}/10',
                    Icons.mood,
                    _getMoodColor(colors, entry?.moodScore ?? 5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    colors,
                    'Energía',
                    '${entry?.energyLevel ?? 0}/10',
                    Icons.battery_charging_full,
                    colors.positiveMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    colors,
                    'Estrés',
                    '${entry?.stressLevel ?? 0}/10',
                    Icons.trending_down,
                    colors.negativeMain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    colors,
                    '¿Valió la pena?',
                    entry?.worthIt == true ? 'Sí' : entry?.worthIt == false ? 'No' : 'N/A',
                    Icons.check_circle,
                    entry?.worthIt == true ? colors.positiveMain : colors.textHint,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(
    AppColors colors,
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
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
              Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceNotes(AppColors colors) {
    return Consumer<OptimizedMomentsProvider>(
      builder: (context, momentsProvider, child) {
        final voiceNotes = momentsProvider.getVoiceNotesForDate(widget.date);
        
        if (voiceNotes.isEmpty) {
          return _buildEmptyState(
            colors,
            '🎙️ Sin notas de voz',
            'Toca el botón de micrófono para agregar una nota de voz',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '🎙️ Notas de Voz'),
            const SizedBox(height: 12),
            ...voiceNotes.map((note) => _buildVoiceNoteCard(colors, note)),
          ],
        );
      },
    );
  }

  Widget _buildVoiceNoteCard(AppColors colors, dynamic voiceNote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.accentPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: colors.accentPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota de voz',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatTime(voiceNote.createdAt),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(voiceNote.duration ?? 0),
            style: TextStyle(
              color: colors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersSection(AppColors colors) {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        final entry = entriesProvider.getEntryForDate(widget.date);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '⚙️ Parámetros Adicionales'),
            const SizedBox(height: 12),
            _buildParameterGrid(colors, entry),
          ],
        );
      },
    );
  }

  Widget _buildParameterGrid(AppColors colors, DailyEntryModel? entry) {
    final parameters = [
      {'title': 'Sueño', 'value': '${entry?.sleepHours ?? 0}h', 'icon': Icons.bedtime},
      {'title': 'Agua', 'value': '${entry?.waterIntake ?? 0} vasos', 'icon': Icons.water_drop},
      {'title': 'Ejercicio', 'value': '${entry?.exerciseMinutes ?? 0} min', 'icon': Icons.fitness_center},
      {'title': 'Meditación', 'value': '${entry?.meditationMinutes ?? 0} min', 'icon': Icons.self_improvement},
      {'title': 'Tiempo Pantalla', 'value': '${entry?.screenTimeHours ?? 0}h', 'icon': Icons.phone_android},
      {'title': 'Interacción Social', 'value': '${entry?.socialInteraction ?? 0}/10', 'icon': Icons.people},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: parameters.length,
      itemBuilder: (context, index) {
        final param = parameters[index];
        return _buildParameterCard(
          colors,
          param['title'] as String,
          param['value'] as String,
          param['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildParameterCard(
    AppColors colors,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.accentPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMoments(AppColors colors) {
    return Consumer<ImageMomentsProvider>(
      builder: (context, imageProvider, child) {
        final images = imageProvider.getImagesForDate(widget.date);
        
        if (images.isEmpty) {
          return _buildEmptyState(
            colors,
            '📸 Sin imágenes',
            'Toca + para agregar fotos del día',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '📸 Momentos en Imagen'),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return _buildImageCard(colors, images[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageCard(AppColors colors, dynamic image) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              image.file,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                _formatTime(image.createdAt),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMoments(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(colors, '⚡ Quick Moments'),
        const SizedBox(height: 12),
        _buildQuickMomentsGrid(colors),
      ],
    );
  }

  Widget _buildQuickMomentsGrid(AppColors colors) {
    final quickMoments = [
      {'emoji': '☕', 'label': 'Café'},
      {'emoji': '🚶', 'label': 'Caminar'},
      {'emoji': '📚', 'label': 'Leer'},
      {'emoji': '🎵', 'label': 'Música'},
      {'emoji': '🍎', 'label': 'Comer'},
      {'emoji': '💭', 'label': 'Reflexión'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: quickMoments.length,
      itemBuilder: (context, index) {
        final moment = quickMoments[index];
        return _buildQuickMomentCard(
          colors,
          moment['emoji'] as String,
          moment['label'] as String,
        );
      },
    );
  }

  Widget _buildQuickMomentCard(AppColors colors, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        // Agregar quick moment
        HapticFeedback.selectionClick();
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.borderColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElements(AppColors colors) {
    return Positioned(
      top: 100,
      right: 24,
      child: FadeTransition(
        opacity: _fabAnimation,
        child: VoiceRecordingWidget(
          onRecordingComplete: (path) {
            setState(() {
              _selectedVoiceNote = path;
            });
          },
          colors: colors,
          isExpanded: _isVoiceExpanded,
          onExpandedChanged: (expanded) {
            setState(() {
              _isVoiceExpanded = expanded;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFAB(AppColors colors) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToReview(),
        backgroundColor: colors.accentPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Editar Día'),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  Widget _buildSectionTitle(AppColors colors, String title) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.textHint,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getMoodColor(AppColors colors, int moodScore) {
    if (moodScore >= 8) return colors.positiveMain;
    if (moodScore >= 6) return colors.accentSecondary;
    if (moodScore >= 4) return colors.textHint;
    return colors.negativeMain;
  }

  String _getMoodEmoji(int moodScore) {
    if (moodScore >= 9) return '😄';
    if (moodScore >= 7) return '😊';
    if (moodScore >= 5) return '😐';
    if (moodScore >= 3) return '😔';
    return '😢';
  }

  String _getDayStatusText(DailyEntryModel? entry) {
    if (entry == null) return 'Día sin registrar';
    if (entry.moodScore >= 8) return 'Día excelente';
    if (entry.moodScore >= 6) return 'Buen día';
    if (entry.moodScore >= 4) return 'Día regular';
    return 'Día difícil';
  }

  String _getDaySubtitle(DailyEntryModel? entry) {
    if (entry == null) return 'Toca editar para empezar';
    return 'Estado de ánimo: ${entry.moodScore}/10';
  }

  void _navigateToReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReviewScreenV3(),
      ),
    );
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreenV3(),
      ),
    );
  }

  // Métodos adicionales para construir las secciones faltantes
  Widget _buildRecentMoments(AppColors colors) {
    return Consumer<OptimizedMomentsProvider>(
      builder: (context, momentsProvider, child) {
        final moments = momentsProvider.getMomentsForDate(widget.date);
        
        if (moments.isEmpty) {
          return _buildEmptyState(
            colors,
            '✨ Sin momentos registrados',
            'Los momentos especiales aparecerán aquí',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '✨ Momentos Recientes'),
            const SizedBox(height: 12),
            ...moments.take(3).map((moment) => _buildMomentCard(colors, moment)),
          ],
        );
      },
    );
  }

  Widget _buildMomentCard(AppColors colors, dynamic moment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                moment.emoji ?? '✨',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  moment.title ?? 'Momento sin título',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _formatTime(moment.createdAt),
                style: TextStyle(
                  color: colors.textHint,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (moment.description != null && moment.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              moment.description!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(AppColors colors) {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        final entry = entriesProvider.getEntryForDate(widget.date);
        
        final metrics = [
          {'title': 'Estado de Ánimo', 'value': entry?.moodScore ?? 0, 'max': 10, 'icon': Icons.mood, 'color': _getMoodColor(colors, entry?.moodScore ?? 5)},
          {'title': 'Energía', 'value': entry?.energyLevel ?? 0, 'max': 10, 'icon': Icons.battery_charging_full, 'color': colors.positiveMain},
          {'title': 'Estrés', 'value': entry?.stressLevel ?? 0, 'max': 10, 'icon': Icons.trending_down, 'color': colors.negativeMain},
          {'title': 'Ansiedad', 'value': entry?.anxietyLevel ?? 0, 'max': 10, 'icon': Icons.psychology, 'color': colors.accentSecondary},
          {'title': 'Motivación', 'value': entry?.motivationLevel ?? 0, 'max': 10, 'icon': Icons.local_fire_department, 'color': colors.accentPrimary},
          {'title': 'Productividad', 'value': entry?.workProductivity ?? 0, 'max': 10, 'icon': Icons.work, 'color': colors.positiveMain},
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _buildMetricCard(
              colors,
              metric['title'] as String,
              metric['value'] as int,
              metric['max'] as int,
              metric['icon'] as IconData,
              metric['color'] as Color,
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard(
    AppColors colors,
    String title,
    int value,
    int max,
    IconData icon,
    Color accentColor,
  ) {
    final percentage = value / max;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
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
              Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$value/$max',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: colors.borderColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsChart(AppColors colors) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Consumer<OptimizedAnalyticsProvider>(
        builder: (context, analyticsProvider, child) {
          return LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: colors.borderColor.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: colors.textHint,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = ['Ánimo', 'Energía', 'Estrés', 'Ansiedad'];
                      if (value.toInt() < labels.length) {
                        return Text(
                          labels[value.toInt()],
                          style: TextStyle(
                            color: colors.textHint,
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 3,
              minY: 0,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: _getChartSpots(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      colors.accentPrimary,
                      colors.accentSecondary,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: colors.accentPrimary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        colors.accentPrimary.withOpacity(0.3),
                        colors.accentPrimary.withOpacity(0.0),
                      ],
                      stops: const [0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<FlSpot> _getChartSpots() {
    // Obtener datos de métricas para el gráfico
    final entry = context.read<OptimizedDailyEntriesProvider>().getEntryForDate(widget.date);
    
    return [
      FlSpot(0, (entry?.moodScore ?? 5).toDouble()),
      FlSpot(1, (entry?.energyLevel ?? 5).toDouble()),
      FlSpot(2, (entry?.stressLevel ?? 5).toDouble()),
      FlSpot(3, (entry?.anxietyLevel ?? 5).toDouble()),
    ];
  }

  Widget _buildMomentsTimeline(AppColors colors) {
    return Consumer<OptimizedMomentsProvider>(
      builder: (context, momentsProvider, child) {
        final moments = momentsProvider.getMomentsForDate(widget.date);
        
        if (moments.isEmpty) {
          return _buildEmptyState(
            colors,
            '📝 Sin momentos registrados',
            'Los momentos del día aparecerán en una línea de tiempo',
          );
        }

        return Column(
          children: moments.asMap().entries.map((entry) {
            final index = entry.key;
            final moment = entry.value;
            final isLast = index == moments.length - 1;
            
            return _buildTimelineItem(colors, moment, isLast);
          }).toList(),
        );
      },
    );
  }

  Widget _buildTimelineItem(AppColors colors, dynamic moment, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors.accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: colors.borderColor.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.borderColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatTime(moment.createdAt),
                      style: TextStyle(
                        color: colors.textHint,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      moment.emoji ?? '✨',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  moment.title ?? 'Momento sin título',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (moment.description != null && moment.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    moment.description!,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(AppColors colors) {
    return Consumer<EnhancedGoalsProvider>(
      builder: (context, goalsProvider, child) {
        final goals = goalsProvider.getGoalsForDate(widget.date);
        
        if (goals.isEmpty) {
          return _buildEmptyState(
            colors,
            '🎯 Sin metas para hoy',
            'Las metas del día aparecerán aquí',
          );
        }

        return Column(
          children: goals.map((goal) => _buildGoalCard(colors, goal)).toList(),
        );
      },
    );
  }

  Widget _buildGoalCard(AppColors colors, GoalModel goal) {
    final progress = goal.progress ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  goal.emoji ?? '🎯',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (goal.description?.isNotEmpty == true)
                      Text(
                        goal.description!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: colors.accentPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.borderColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentPrimary),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection(AppColors colors) {
    return Consumer<DailyRoadmapProvider>(
      builder: (context, roadmapProvider, child) {
        final roadmap = roadmapProvider.getRoadmapForDate(widget.date);
        
        if (roadmap.isEmpty) {
          return _buildEmptyState(
            colors,
            '🗺️ Sin roadmap',
            'El roadmap del día aparecerá aquí',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(colors, '🗺️ Roadmap del Día'),
            const SizedBox(height: 12),
            ...roadmap.map((item) => _buildRoadmapItem(colors, item)),
          ],
        );
      },
    );
  }

  Widget _buildRoadmapItem(AppColors colors, dynamic roadmapItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            roadmapItem.isCompleted 
                ? Icons.check_circle 
                : Icons.radio_button_unchecked,
            color: roadmapItem.isCompleted 
                ? colors.positiveMain 
                : colors.textHint,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              roadmapItem.title,
              style: TextStyle(
                color: roadmapItem.isCompleted 
                    ? colors.textSecondary 
                    : colors.textPrimary,
                fontSize: 14,
                decoration: roadmapItem.isCompleted 
                    ? TextDecoration.lineThrough 
                    : null,
              ),
            ),
          ),
          if (roadmapItem.estimatedTime != null)
            Text(
              '${roadmapItem.estimatedTime}min',
              style: TextStyle(
                color: colors.textHint,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionAnalysis(AppColors colors) {
    return Consumer<AdvancedEmotionAnalysisProvider>(
      builder: (context, emotionProvider, child) {
        final analysis = emotionProvider.getAnalysisForDate(widget.date);
        
        if (analysis == null) {
          return _buildEmptyState(
            colors,
            '🧠 Analizando emociones...',
            'El análisis emocional aparecerá aquí',
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.borderColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: colors.accentPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Análisis Emocional',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildEmotionInsight(colors, analysis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmotionInsight(AppColors colors, dynamic analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado emocional predominante:',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          analysis.primaryEmotion ?? 'Neutral',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Recomendaciones:',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          analysis.recommendations ?? 'Mantén un equilibrio emocional saludable.',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInsights(AppColors colors) {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        final recentEntries = entriesProvider.recentEntries;
        
        if (recentEntries.isEmpty) {
          return _buildEmptyState(
            colors,
            '📈 Sin datos suficientes',
            'Los insights aparecerán cuando tengas más entradas',
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.borderColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: colors.accentSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Insights Básicos',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildBasicInsightCard(colors, recentEntries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInsightCard(AppColors colors, List<dynamic> entries) {
    final avgMood = entries.fold<double>(0, (sum, entry) => sum + entry.moodScore) / entries.length;
    final avgEnergy = entries.fold<double>(0, (sum, entry) => sum + entry.energyLevel) / entries.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.accentSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.accentSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promedio semanal:',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estado de ánimo: ${avgMood.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            'Energía: ${avgEnergy.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}