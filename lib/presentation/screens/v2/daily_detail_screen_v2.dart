// ============================================================================
// daily_detail_screen_v2.dart - DETALLE DIARIO CON ESTILO VISUAL MEJORADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Pantallas relacionadas
import 'daily_review_screen_v2.dart';
import 'calendar_screen_v2.dart';

// ============================================================================
// PALETA DE COLORES CONSISTENTE
// ============================================================================
class DetailColors {
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

  // Colores de métricas
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3FFFFFF);
  static const Color textHint = Color(0xFF66FFFFFF);

  // Estados y métricas
  static const Color excellent = Color(0xFF10b981);
  static const Color good = Color(0xFF3b82f6);
  static const Color neutral = Color(0xFFf59e0b);
  static const Color poor = Color(0xFFef4444);
}

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
      backgroundColor: DetailColors.backgroundPrimary,
      body: SafeArea(
        child: Consumer2<OptimizedDailyEntriesProvider, OptimizedAnalyticsProvider>(
          builder: (context, entriesProvider, analyticsProvider, child) {
            final entry = _getEntryForDate(widget.date, entriesProvider.entries);

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: entry != null
                      ? _buildDetailContent(entry)
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
            colors: DetailColors.primaryGradient,
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📖 Detalle del Día',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(widget.date),
                        style: const TextStyle(
                          color: Colors.white70,
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
                        icon: const Icon(Icons.calendar_month, color: Colors.white),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getRelativeDayText(widget.date),
                style: const TextStyle(
                  color: Colors.white,
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

  Widget _buildDetailContent(dynamic entry) {
    return FadeTransition(
      opacity: _contentController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildScoreCard(entry),
            const SizedBox(height: 20),
            _buildReflectionCard(entry),
            const SizedBox(height: 20),
            _buildMetricsSection(entry),
            const SizedBox(height: 20),
            _buildInsightsSection(entry),
            const SizedBox(height: 20),
            _buildActionsSection(),
            const SizedBox(height: 100), // Espacio para FAB
          ],
        ),
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
              color: _getScoreColor(overallScore.round()).withOpacity(0.3),
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
                    const Text(
                      'Puntuación General',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getScoreMessage(overallScore),
                      // FIX: Replaced Colors.white90 with a valid color
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${overallScore.toStringAsFixed(1)}/10',
                  style: const TextStyle(
                    color: Colors.white,
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
        color: Colors.white.withOpacity(0.1),
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
            style: const TextStyle(
              color: Colors.white70,
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
          color: DetailColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
                    gradient: LinearGradient(colors: DetailColors.accentGradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_stories, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Reflexión del Día',
                  style: TextStyle(
                    color: Colors.white,
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
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            if (entry.gratitudeItems != null && entry.gratitudeItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DetailColors.good.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DetailColors.good.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🙏 Gratitud',
                      style: TextStyle(
                        color: DetailColors.good,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.gratitudeItems,
                      style: const TextStyle(
                        color: Colors.white70,
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

  Widget _buildTagsSection(dynamic entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.positiveTags.isNotEmpty) ...[
          const Text(
            '✅ Aspectos Positivos',
            style: TextStyle(
              color: DetailColors.good,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.positiveTags.map<Widget>((tag) => _buildTag(tag, DetailColors.good)).toList(),
          ),
          const SizedBox(height: 12),
        ],

        if (entry.negativeTags.isNotEmpty) ...[
          const Text(
            '❌ Aspectos a Mejorar',
            style: TextStyle(
              color: DetailColors.poor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.negativeTags.map<Widget>((tag) => _buildTag(tag, DetailColors.poor)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(String tag, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildMetricsSection(dynamic entry) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _metricsController, curve: Curves.easeOutCubic)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DetailColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        gradient: LinearGradient(colors: DetailColors.lightGradient),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Métricas de Bienestar',
                      style: TextStyle(
                        color: Colors.white,
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
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _showAllMetrics ? 'Menos' : 'Más',
                      style: const TextStyle(
                        color: Colors.white70,
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
        ? DetailColors.good
        : _getMetricColor(effectiveValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
            style: const TextStyle(
              color: Colors.white,
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
        color: DetailColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: DetailColors.accentGradient),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Insights del Día',
                style: TextStyle(
                  color: Colors.white,
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
        color: insight['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insight['color'].withOpacity(0.3)),
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
                  style: const TextStyle(
                    color: Colors.white70,
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
        color: DetailColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones',
            style: TextStyle(
              color: Colors.white,
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
          gradient: LinearGradient(colors: DetailColors.accentGradient),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
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
                  gradient: LinearGradient(colors: DetailColors.lightGradient.map((c) => c.withOpacity(0.3)).toList()),
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

              const Text(
                'Sin reflexión registrada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'No hay una reflexión registrada para ${_formatDate(widget.date)}',
                style: const TextStyle(
                  color: Colors.white70,
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
                  backgroundColor: DetailColors.accentGradient[0],
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
              gradient: LinearGradient(colors: DetailColors.accentGradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: DetailColors.accentGradient[0].withOpacity(0.3),
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
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  entry != null ? 'Editar' : 'Crear',
                  style: const TextStyle(
                    color: Colors.white,
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
        'color': DetailColors.excellent,
      });
    } else if (moodScore <= 3) {
      insights.add({
        'emoji': '💙',
        'title': 'Día desafiante',
        'description': 'Fue un día difícil, pero has sido fuerte al superarlo.',
        'color': DetailColors.poor,
      });
    }

    // Insight sobre energía vs estrés
    final energyStressBalance = energyLevel - stressLevel;
    if (energyStressBalance >= 3) {
      insights.add({
        'emoji': '⚡',
        'title': 'Gran balance energético',
        'description': 'Tuviste mucha energía y poco estrés. ¡Día productivo!',
        'color': DetailColors.excellent,
      });
    } else if (energyStressBalance <= -3) {
      insights.add({
        'emoji': '😴',
        'title': 'Necesitas descanso',
        'description': 'Alto estrés y poca energía. Considera tomarte un respiro.',
        'color': DetailColors.poor,
      });
    }

    // Insight sobre sueño
    if (sleepQuality >= 8) {
      insights.add({
        'emoji': '😴',
        'title': 'Sueño reparador',
        'description': 'Dormiste muy bien. El buen descanso mejora todo.',
        'color': DetailColors.excellent,
      });
    }

    // Insight sobre día completo
    if (entry.worthIt == true) {
      insights.add({
        'emoji': '✨',
        'title': 'Día que valió la pena',
        'description': 'Consideraste que fue un día valioso. ¡Sigue así!',
        'color': DetailColors.good,
      });
    }

    return insights.isEmpty ? [
      {
        'emoji': '📊',
        'title': 'Reflexión registrada',
        'description': 'Has documentado tu día. Esto te ayuda a crecer.',
        'color': DetailColors.good,
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
    if (score <= 3) return DetailColors.poor;
    if (score <= 5) return DetailColors.neutral;
    if (score <= 7) return DetailColors.good;
    return DetailColors.excellent;
  }

  List<Color> _getScoreGradient(int score) {
    if (score <= 3) return [DetailColors.poor, DetailColors.poor.withOpacity(0.8)];
    if (score <= 5) return [DetailColors.neutral, DetailColors.neutral.withOpacity(0.8)];
    if (score <= 7) return [DetailColors.good, DetailColors.good.withOpacity(0.8)];
    return [DetailColors.excellent, DetailColors.excellent.withOpacity(0.8)];
  }

  String _getScoreMessage(double score) {
    if (score >= 8) return '¡Excelente día!';
    if (score >= 6) return 'Buen día en general';
    if (score >= 4) return 'Día promedio';
    return 'Día desafiante';
  }

  Color _getMetricColor(int value) {
    if (value <= 3) return DetailColors.poor;
    if (value <= 5) return DetailColors.neutral;
    if (value <= 7) return DetailColors.good;
    return DetailColors.excellent;
  }
}
