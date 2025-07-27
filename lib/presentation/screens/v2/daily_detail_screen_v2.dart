// ============================================================================
// daily_detail_screen_v2.dart - DETALLE DIARIO CON ESTILO VISUAL MEJORADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/enhanced_goals_provider.dart';
import '../../providers/daily_roadmap_provider.dart';

// Pantallas relacionadas
import 'daily_review_screen_v2.dart';
import 'calendar_screen_v2.dart';

// Sistema de colores
import 'components/minimal_colors.dart';

class DailyDetailScreenV2 extends StatefulWidget {
  final DateTime date;

  const DailyDetailScreenV2({
    super.key,
    required this.date,
  });

  @override
  State<DailyDetailScreenV2> createState() => _DailyDetailScreenV2State();
}

class _DailyDetailScreenV2State extends State<DailyDetailScreenV2>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================

  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _metricsController;
  late AnimationController _pulseController;

  // Estado de la UI
  bool _showAllMetrics = false;

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

    // Iniciar animaciones secuencialmente
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _metricsController.forward();
    });
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id, days: 30);
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: SafeArea(
        child: Consumer5<OptimizedDailyEntriesProvider, OptimizedAnalyticsProvider, EnhancedGoalsProvider, DailyRoadmapProvider, OptimizedMomentsProvider>(
          builder: (context, entriesProvider, analyticsProvider, goalsProvider, roadmapProvider, momentsProvider, child) {
            final entry = _getEntryForDate(widget.date, entriesProvider.entries);

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: entry != null
                      ? _buildDetailContent(entry, goalsProvider, roadmapProvider, momentsProvider)
                      : _buildEmptyState(),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: MinimalColors.primaryGradient(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, color: MinimalColors.textPrimary(context)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: MinimalColors.accentGradient(context),
                        ).createShader(bounds),
                        child: Text(
                          'Detalle del Día',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(widget.date),
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.1),
                      child: IconButton(
                        onPressed: _navigateToCalendar,
                        icon: Icon(Icons.calendar_month, color: MinimalColors.textPrimary(context)),
                        tooltip: 'Ver calendario',
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Indicador de día relativo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getRelativeDayText(widget.date),
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // CONTENIDO PRINCIPAL
  // ============================================================================

  Widget _buildDetailContent(dynamic entry, EnhancedGoalsProvider goalsProvider, DailyRoadmapProvider roadmapProvider, OptimizedMomentsProvider momentsProvider) {
    return FadeTransition(
      opacity: _contentController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreCard(entry),
            const SizedBox(height: 16),
            _buildReflectionCard(entry),
            const SizedBox(height: 16),
            // Audio Recording Section
            _buildAudioSection(entry),
            const SizedBox(height: 16),
            _buildMetricsSection(entry),
            const SizedBox(height: 16),
            _buildInsightsSection(entry),
            const SizedBox(height: 16),
            _buildInnerReflectionCard(entry),
            const SizedBox(height: 16),
            // Enhanced Activities Section
            _buildEnhancedActivitiesSection(entry),
            const SizedBox(height: 16),
            // Enhanced Goals Section
            _buildEnhancedGoalsSection(entry, goalsProvider),
            const SizedBox(height: 16),
            // Enhanced Roadmap Section
            _buildEnhancedDailyRoadmapSection(roadmapProvider),
            const SizedBox(height: 16),
            _buildMomentsGallerySection(momentsProvider),
            const SizedBox(height: 16),
            _buildDailyPhotosSection(),
            const SizedBox(height: 16),
            _buildProgressSummarySection(entry, goalsProvider),
            const SizedBox(height: 16),
            _buildActionsSection(),
            const SizedBox(height: 100), // Espacio para FAB
          ],
        ),
      ),
    );
  }

  Widget _buildInnerReflectionCard(dynamic entry) {
    if (entry.innerReflection == null || entry.innerReflection.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.gradientShadow(context, alpha: 0.15),
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
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.self_improvement, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Reflexión Interior',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            entry.innerReflection,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildScoreCard(dynamic entry) {
    final moodScore = entry.moodScore ?? 5;
    final energyLevel = entry.energyLevel ?? 5;
    final stressLevel = entry.stressLevel ?? 5;
    final overallScore = (moodScore + energyLevel + (11 - stressLevel)) / 3;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _getScoreGradient(overallScore.round())),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getScoreColor(overallScore.round()).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puntuación General',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getScoreMessage(overallScore),
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${overallScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Métricas principales en fila
            Row(
              children: [
                Expanded(child: _buildMiniMetric('😊', 'Ánimo', moodScore)),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniMetric('⚡', 'Energía', energyLevel)),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniMetric('😰', 'Estrés', stressLevel, isReversed: true)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String emoji, String label, int value, {bool isReversed = false}) {
    final effectiveValue = isReversed ? (11 - value) : value;
    final color = _getMetricColor(effectiveValue);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MinimalColors.textMuted(context).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            '$value/10',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(dynamic entry) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: MinimalColors.gradientShadow(context, alpha: 0.15),
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
                    gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Reflexión del Día',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              entry.freeReflection.isNotEmpty
                  ? entry.freeReflection
                  : 'Sin reflexión registrada para este día.',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 16,
                height: 1.5,
              ),
            ),

            if (entry.gratitudeItems != null && entry.gratitudeItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3b82f6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3b82f6).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🙏 Gratitud',
                      style: TextStyle(
                        color: Color(0xFF3b82f6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.gratitudeItems,
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Tags positivos y negativos
            if ((entry.positiveTags.isNotEmpty) || (entry.negativeTags.isNotEmpty)) ...[
              const SizedBox(height: 16),
              _buildTagsSection(entry),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildTag(String tag, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTagsSection(dynamic entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.positiveTags.isNotEmpty) ...[
          Text(
            '✅ Aspectos Positivos',
            style: TextStyle(
              color: const Color(0xFF3b82f6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.positiveTags.map<Widget>((tag) => _buildTag(tag, const Color(0xFF3b82f6))).toList(),
          ),
          const SizedBox(height: 12),
        ],

        if (entry.negativeTags.isNotEmpty) ...[
          Text(
            '❌ Aspectos a Mejorar',
            style: TextStyle(
              color: const Color(0xFFef4444),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.negativeTags.map<Widget>((tag) => _buildTag(tag, const Color(0xFFef4444))).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsSection(dynamic entry) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _metricsController, curve: Curves.easeOutCubic)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: MinimalColors.lightGradient(context)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Métricas de Bienestar',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllMetrics = !_showAllMetrics;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _showAllMetrics ? 'Menos' : 'Más',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildMetricsGrid(entry),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(dynamic entry) {
    final primaryMetrics = [
      {'title': 'Calidad del Sueño', 'value': entry.sleepQuality ?? 5, 'emoji': '😴', 'unit': '/10'},
      {'title': 'Ansiedad', 'value': entry.anxietyLevel ?? 5, 'emoji': '😰', 'unit': '/10', 'reversed': true},
      {'title': 'Motivación', 'value': entry.motivationLevel ?? 5, 'emoji': '🔥', 'unit': '/10'},
      {'title': 'Actividad Física', 'value': entry.physicalActivity ?? 5, 'emoji': '🏃', 'unit': '/10'},
    ];

    final secondaryMetrics = [
      {'title': 'Interacción Social', 'value': entry.socialInteraction ?? 5, 'emoji': '👥', 'unit': '/10'},
      {'title': 'Productividad', 'value': entry.workProductivity ?? 5, 'emoji': '💼', 'unit': '/10'},
      {'title': 'Horas de Sueño', 'value': entry.sleepHours ?? 8.0, 'emoji': '🛏️', 'unit': 'h'},
      {'title': 'Vasos de Agua', 'value': entry.waterIntake ?? 8, 'emoji': '💧', 'unit': ' vasos'},
      {'title': 'Ejercicio', 'value': entry.exerciseMinutes ?? 0, 'emoji': '🏋️', 'unit': ' min'},
      {'title': 'Tiempo de Pantalla', 'value': entry.screenTimeHours ?? 4.0, 'emoji': '📱', 'unit': 'h'},
    ];

    final metricsToShow = _showAllMetrics
        ? [...primaryMetrics, ...secondaryMetrics]
        : primaryMetrics;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: metricsToShow.length,
        itemBuilder: (context, index) {
          final metric = metricsToShow[index];
          return _buildMetricCard(metric);
        },
      ),
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    final title = metric['title'] as String;
    final value = metric['value'];
    final emoji = metric['emoji'] as String;
    final unit = metric['unit'] as String;
    final isReversed = metric['reversed'] as bool? ?? false;

    final displayValue = value is double ? value.toStringAsFixed(1) : value.toString();
    final numericValue = value is double ? value.toInt() : value as int;
    final effectiveValue = isReversed ? (11 - numericValue) : numericValue;
    final color = title.contains('Horas') || title.contains('Vasos') || title.contains('min')
        ? const Color(0xFF3b82f6)
        : _getMetricColor(effectiveValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            '$displayValue$unit',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(dynamic entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Insights del Día',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ..._generateInsights(entry).map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insight['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(insight['emoji'], style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'],
                  style: TextStyle(
                    color: insight['color'],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  insight['description'],
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit,
                  label: 'Editar',
                  onTap: _editEntry,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.calendar_month,
                  label: 'Calendario',
                  onTap: _navigateToCalendar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // ESTADO VACÍO
  // ============================================================================

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _contentController,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.lightGradient(context).map((c) => c.withValues(alpha: 0.3)).toList()),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: Text(
                    '📝',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Sin reflexión registrada',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'No hay una reflexión registrada para ${_formatDate(widget.date)}',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // FIX: This was a custom button that didn't behave like a standard ElevatedButton.
              // Replaced with a standard ElevatedButton for consistency.
              ElevatedButton.icon(
                onPressed: _createEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MinimalColors.accentGradient(context)[0],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Crear Reflexión',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
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
  // FLOATING ACTION BUTTON
  // ============================================================================

  Widget _buildFloatingActionButton() {
    return Consumer<OptimizedDailyEntriesProvider>(
      builder: (context, entriesProvider, child) {
        final entry = _getEntryForDate(widget.date, entriesProvider.entries);

        // FIX: Replaced 'child' with 'label'
        return FloatingActionButton.extended(
          onPressed: entry != null ? _editEntry : _createEntry,
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  entry != null ? Icons.edit : Icons.add,
                  color: MinimalColors.textPrimary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  entry != null ? 'Editar' : 'Crear',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  dynamic _getEntryForDate(DateTime date, List<dynamic> entries) {
    try {
      return entries.firstWhere(
            (entry) => _isSameDay(entry.entryDate, date),
      );
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Map<String, dynamic>> _generateInsights(dynamic entry) {
    final insights = <Map<String, dynamic>>[];

    final moodScore = entry.moodScore ?? 5;
    final energyLevel = entry.energyLevel ?? 5;
    final stressLevel = entry.stressLevel ?? 5;
    final sleepQuality = entry.sleepQuality ?? 5;

    // Insight sobre el mood
    if (moodScore >= 8) {
      insights.add({
        'emoji': '🌟',
        'title': 'Excelente estado de ánimo',
        'description': 'Tu ánimo estuvo muy alto este día. ¿Qué contribuyó a ello?',
        'color': const Color(0xFF10b981),
      });
    } else if (moodScore <= 3) {
      insights.add({
        'emoji': '💙',
        'title': 'Día desafiante',
        'description': 'Fue un día difícil, pero has sido fuerte al superarlo.',
        'color': const Color(0xFFef4444),
      });
    }

    // Insight sobre energía vs estrés
    final energyStressBalance = energyLevel - stressLevel;
    if (energyStressBalance >= 3) {
      insights.add({
        'emoji': '⚡',
        'title': 'Gran balance energético',
        'description': 'Tuviste mucha energía y poco estrés. ¡Día productivo!',
        'color': const Color(0xFF10b981),
      });
    } else if (energyStressBalance <= -3) {
      insights.add({
        'emoji': '😴',
        'title': 'Necesitas descanso',
        'description': 'Alto estrés y poca energía. Considera tomarte un respiro.',
        'color': const Color(0xFFef4444),
      });
    }

    // Insight sobre sueño
    if (sleepQuality >= 8) {
      insights.add({
        'emoji': '😴',
        'title': 'Sueño reparador',
        'description': 'Dormiste muy bien. El buen descanso mejora todo.',
        'color': const Color(0xFF10b981),
      });
    }

    // Insight sobre día completo
    if (entry.worthIt == true) {
      insights.add({
        'emoji': '✨',
        'title': 'Día que valió la pena',
        'description': 'Consideraste que fue un día valioso. ¡Sigue así!',
        'color': const Color(0xFF3b82f6),
      });
    }

    return insights.isEmpty ? [
      {
        'emoji': '📊',
        'title': 'Reflexión registrada',
        'description': 'Has documentado tu día. Esto te ayuda a crecer.',
        'color': const Color(0xFF3b82f6),
      }
    ] : insights;
  }

  // ============================================================================
  // NAVEGACIÓN Y ACCIONES
  // ============================================================================

  void _editEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReviewScreenV2(),
      ),
    );
  }

  void _createEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyReviewScreenV2(),
      ),
    );
  }

  void _navigateToCalendar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreenV2(),
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _formatDate(DateTime date) {
    final weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    final dayName = weekDays[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} de $monthName de ${date.year}';
  }

  String _getRelativeDayText(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == -1) return 'Ayer';
    if (difference == 1) return 'Mañana';
    if (difference < 0) return 'Hace ${-difference} días';
    return 'En $difference días';
  }

  Color _getScoreColor(int score) {
    if (score <= 3) return const Color(0xFFef4444);
    if (score <= 5) return const Color(0xFFf59e0b);
    if (score <= 7) return const Color(0xFF3b82f6);
    return const Color(0xFF10b981);
  }

  List<Color> _getScoreGradient(int score) {
    if (score <= 3) return [const Color(0xFFef4444), const Color(0xFFef4444).withValues(alpha: 0.8)];
    if (score <= 5) return [const Color(0xFFf59e0b), const Color(0xFFf59e0b).withValues(alpha: 0.8)];
    if (score <= 7) return [const Color(0xFF3b82f6), const Color(0xFF3b82f6).withValues(alpha: 0.8)];
    return [const Color(0xFF10b981), const Color(0xFF10b981).withValues(alpha: 0.8)];
  }

  String _getScoreMessage(double score) {
    if (score >= 8) return '¡Excelente día!';
    if (score >= 6) return 'Buen día en general';
    if (score >= 4) return 'Día promedio';
    return 'Día desafiante';
  }

  Color _getMetricColor(int value) {
    if (value <= 3) return const Color(0xFFef4444);
    if (value <= 5) return const Color(0xFFf59e0b);
    if (value <= 7) return const Color(0xFF3b82f6);
    return const Color(0xFF10b981);
  }

  Widget _buildDailyPhotosSection() {
    // Mock photos for future image integration
    final mockPhotos = [
      {'time': '09:30', 'title': 'Momento matutino'},
      {'time': '14:15', 'title': 'Almuerzo'},
      {'time': '18:45', 'title': 'Atardecer'},
    ];

    if (mockPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fotos del Día',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${mockPhotos.length}',
                  style: TextStyle(
                    color: MinimalColors.accentGradient(context)[0],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockPhotos.length,
              itemBuilder: (context, index) {
                final photo = mockPhotos[index];
                return _buildPhotoPlaceholder(photo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(Map<String, String> photo) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
        ),
        gradient: LinearGradient(
          colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              color: MinimalColors.backgroundCard(context),
              child: Center(
                child: Icon(
                  Icons.photo_rounded,
                  color: MinimalColors.textMuted(context),
                  size: 32,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MinimalColors.textPrimary(context).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  photo['time'] ?? '00:00',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // NEW ENHANCED SECTIONS
  // ============================================================================


  Widget _buildMomentsGallerySection(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.moments
        .where((m) => _isSameDay(m.entryDate, widget.date))
        .toList();
    
    if (todayMoments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.lightGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sentiment_satisfied, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Momentos del Día',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${todayMoments.length}',
                  style: TextStyle(
                    color: MinimalColors.lightGradient(context)[0],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: todayMoments.length,
              itemBuilder: (context, index) {
                final moment = todayMoments[index];
                return _buildMomentCard(moment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentCard(dynamic moment) {
    final color = moment.type == 'positive' 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);
        
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                moment.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Text(
                moment.timeStr,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              moment.text,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${moment.intensity}/10',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummarySection(dynamic entry, EnhancedGoalsProvider goalsProvider) {
    final goals = goalsProvider.goals;
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final activeGoals = goals.where((g) => g.isActive).length;
    
    if (totalGoals == 0) return const SizedBox.shrink();

    final overallProgress = totalGoals > 0 
        ? goals.fold<double>(0.0, (sum, goal) => sum + goal.progress) / totalGoals
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insights, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Resumen de Progreso',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildProgressStat('Metas Activas', '$activeGoals', const Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressStat('Completadas', '$completedGoals', const Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressStat('Progreso Gral.', '${(overallProgress * 100).round()}%', const Color(0xFFF59E0B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return const Color(0xFF10B981);
    if (progress >= 0.5) return const Color(0xFF3B82F6);
    if (progress >= 0.2) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getCompletionColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 50) return const Color(0xFF3B82F6);
    if (percentage >= 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // ============================================================================
  // ENHANCED SECTIONS - NEW IMPLEMENTATIONS
  // ============================================================================

  Widget _buildAudioSection(dynamic entry) {
    if (entry.voiceRecordingPath == null || entry.voiceRecordingPath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Audio Grabado',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reflexión en Audio',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, color: MinimalColors.textMuted(context), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Duración: --:--',
                            style: TextStyle(
                              color: MinimalColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement audio player functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad de audio en desarrollo')),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.headphones, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActivitiesSection(dynamic entry) {
    if (entry.completedActivitiesToday == null || entry.completedActivitiesToday.isEmpty) {
      return const SizedBox.shrink();
    }

    final activities = entry.completedActivitiesToday as List<String>;
    final totalActivities = activities.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.task_alt, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actividades Realizadas',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Has completado $totalActivities actividades hoy',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalActivities',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Activity Cards
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                          activity,
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              'Completada',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.done, color: Color(0xFF10B981), size: 16),
                  ),
                ],
              ),
            );
          }),

          // Productivity insight
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  const Color(0xFF10B981).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    totalActivities >= 5
                        ? '¡Día muy productivo! Has completado muchas tareas.'
                        : totalActivities >= 3
                            ? 'Buen nivel de productividad hoy.'
                            : 'Un comienzo sólido con las actividades de hoy.',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGoalsSection(dynamic entry, EnhancedGoalsProvider goalsProvider) {
    final goals = goalsProvider.goals;
    final activeGoals = goals.where((g) => g.isActive).toList();
    final todayGoals = entry.goalsSummary as List<String>?;
    
    if (activeGoals.isEmpty && (todayGoals == null || todayGoals.isEmpty)) {
      return const SizedBox.shrink();
    }

    // Calculate overall progress
    final overallProgress = activeGoals.isNotEmpty 
        ? activeGoals.fold<double>(0.0, (sum, goal) => sum + goal.progress) / activeGoals.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.track_changes, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metas y Progreso',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Progreso general: ${(overallProgress * 100).round()}%',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(overallProgress).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${activeGoals.length} activas',
                  style: TextStyle(
                    color: _getProgressColor(overallProgress),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Overview Bar
          if (activeGoals.isNotEmpty) ...[
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: overallProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Active Goals with Detailed Progress
          if (activeGoals.isNotEmpty) ...[
            Text(
              'Metas Activas',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...activeGoals.map<Widget>((goal) => _buildDetailedGoalCard(goal)),
          ],
          
          // Daily Goals Notes
          if (todayGoals != null && todayGoals.isNotEmpty) ...[
            if (activeGoals.isNotEmpty) const SizedBox(height: 16),
            Text(
              'Notas del Día',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...todayGoals.map<Widget>((note) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note_alt, color: Color(0xFFF59E0B), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note,
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          // Goals Summary
          if (activeGoals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.accentGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getGoalsInsight(activeGoals),
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Widget _buildDetailedGoalCard(dynamic goal) {
    final progress = goal.progress as double;
    final progressPercentage = (progress * 100).round();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getProgressColor(progress),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getProgressColor(progress).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$progressPercentage%',
                  style: TextStyle(
                    color: _getProgressColor(progress),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (goal.description != null && goal.description.isNotEmpty) ...[
            Text(
              goal.description,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getProgressColor(progress),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${goal.currentValue ?? 0}/${goal.targetValue ?? 100}',
                style: TextStyle(
                  color: MinimalColors.textMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (goal.notes != null && goal.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2, color: MinimalColors.textMuted(context), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      goal.notes,
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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

  Widget _buildEnhancedDailyRoadmapSection(DailyRoadmapProvider roadmapProvider) {
    // Get the roadmap for today's date
    final roadmaps = roadmapProvider.roadmapHistory;
    final todayRoadmap = roadmaps
        .where((r) => _isSameDay(r.targetDate, widget.date))
        .firstOrNull ?? roadmapProvider.currentRoadmap;
    
    if (todayRoadmap == null || todayRoadmap.activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedActivities = todayRoadmap.calculatedCompletedActivities;
    final totalActivities = todayRoadmap.calculatedTotalActivities;
    final completionPercentage = todayRoadmap.calculatedCompletionPercentage.round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.route, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roadmap del Día',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$completedActivities de $totalActivities actividades completadas',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCompletionColor(completionPercentage).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completionPercentage%',
                  style: TextStyle(
                    color: _getCompletionColor(completionPercentage),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily Goal and Notes
          if (todayRoadmap.dailyGoal != null && todayRoadmap.dailyGoal!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFF3B82F6), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meta del Día',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          todayRoadmap.dailyGoal!,
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Morning Notes
          if (todayRoadmap.morningNotes != null && todayRoadmap.morningNotes!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notas Matutinas',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          todayRoadmap.morningNotes!,
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Activities Timeline
          Text(
            'Cronograma de Actividades',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: todayRoadmap.activitiesByTime.length,
              itemBuilder: (context, index) {
                final activity = todayRoadmap.activitiesByTime[index];
                return _buildEnhancedTimelineCard(activity, index == todayRoadmap.activitiesByTime.length - 1);
              },
            ),
          ),

          // Evening Reflection
          if (todayRoadmap.eveningReflection != null && todayRoadmap.eveningReflection!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.nights_stay, color: Color(0xFF8B5CF6), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reflexión Vespertina',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          todayRoadmap.eveningReflection!,
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 13,
                          ),
                        ),
                      ],
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

  Widget _buildEnhancedTimelineCard(dynamic activity, bool isLast) {
    final priorityColor = _getPriorityColor(activity.priority);
    
    return Row(
      children: [
        Container(
          width: 160,
          margin: const EdgeInsets.only(right: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activity.isCompleted 
                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                      : MinimalColors.backgroundCard(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activity.isCompleted 
                        ? const Color(0xFF10B981)
                        : priorityColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activity.timeString,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          activity.isCompleted ? Icons.check_circle : Icons.schedule,
                          color: activity.isCompleted 
                              ? const Color(0xFF10B981)
                              : Colors.white54,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      activity.title,
                      style: TextStyle(
                        color: activity.isCompleted ? Colors.white : MinimalColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Description
                    if (activity.description != null && activity.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        activity.description,
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Category and Duration
                    Row(
                      children: [
                        if (activity.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: MinimalColors.backgroundCard(context).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activity.category,
                              style: TextStyle(
                                color: MinimalColors.textSecondary(context),
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (activity.estimatedDuration != null) ...[
                          Icon(Icons.timer, color: MinimalColors.textMuted(context), size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${activity.estimatedDuration}min',
                            style: TextStyle(
                              color: MinimalColors.textMuted(context),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Notes
                    if (activity.notes != null && activity.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note, color: MinimalColors.textMuted(context), size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                activity.notes,
                                style: TextStyle(
                                  color: MinimalColors.textSecondary(context),
                                  fontSize: 10,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) ...[
          Container(
            width: 2,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MinimalColors.textMuted(context).withValues(alpha: 0.5),
                  MinimalColors.textMuted(context).withValues(alpha: 0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getGoalsInsight(List<dynamic> goals) {
    final highProgressGoals = goals.where((g) => g.progress >= 0.7).length;
    final totalGoals = goals.length;
    
    if (highProgressGoals >= totalGoals * 0.7) {
      return '¡Excelente progreso! La mayoría de tus metas van muy bien.';
    } else if (highProgressGoals >= totalGoals * 0.4) {
      return 'Buen avance en tus metas. Mantén el impulso.';
    } else {
      return 'Hay oportunidades para acelerar el progreso en tus metas.';
    }
  }

  Color _getPriorityColor(dynamic priority) {
    switch (priority.toString()) {
      case 'ActivityPriority.urgent':
        return const Color(0xFFEF4444);
      case 'ActivityPriority.high':
        return const Color(0xFFF59E0B);
      case 'ActivityPriority.medium':
        return const Color(0xFF3B82F6);
      case 'ActivityPriority.low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

}

// ============================================================================
// EXTENSION FOR NULL SAFETY
// ============================================================================

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}
