// ============================================================================
// ADVANCED ANALYTICS SCREEN - VERSIÓN COMPLETA Y CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/enhanced_analytics_provider.dart';
import '../components/modern_design_system.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  final int userId;

  const AdvancedAnalyticsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar análisis avanzados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnhancedAnalyticsProvider>().loadCompleteAdvancedAnalytics(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<EnhancedAnalyticsProvider>();

    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: const Text('Análisis Avanzado', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => analytics.loadCompleteAdvancedAnalytics(widget.userId),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ModernColors.accentBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '📊 Bienestar'),
            Tab(text: '😰 Estrés'),
            Tab(text: '📈 Progreso'),
            Tab(text: '🎯 Objetivos'),
          ],
        ),
      ),
      body: analytics.isLoading
          ? const Center(child: CircularProgressIndicator())
          : analytics.errorMessage != null
          ? _buildErrorState(analytics)
          : TabBarView(
        controller: _tabController,
        children: [
          _buildWellbeingTab(analytics),
          _buildStressTab(analytics),
          _buildProgressTab(analytics),
          _buildGoalsTab(analytics),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB DE BIENESTAR
  // ============================================================================

  Widget _buildWellbeingTab(EnhancedAnalyticsProvider analytics) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailedWellbeingAnalysis(analytics),
                const SizedBox(height: 24),
                _buildEmotionalBalance(analytics),
                const SizedBox(height: 24),
                _buildPersonalizedInsights(analytics),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB DE ESTRÉS
  // ============================================================================

  Widget _buildStressTab(EnhancedAnalyticsProvider analytics) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStressAnalysis(analytics),
                const SizedBox(height: 24),
                _buildStressRecommendations(analytics),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB DE PROGRESO
  // ============================================================================

  Widget _buildProgressTab(EnhancedAnalyticsProvider analytics) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHourlyPatterns(analytics),
                const SizedBox(height: 24),
                _buildMoodDeclineDetection(analytics),
                const SizedBox(height: 24),
                _buildProgressTimeline(analytics),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB DE OBJETIVOS
  // ============================================================================

  Widget _buildGoalsTab(EnhancedAnalyticsProvider analytics) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActionPlan(analytics),
                const SizedBox(height: 24),
                _buildGoalsProgress(analytics),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // ANÁLISIS DETALLADO DE BIENESTAR
  // ============================================================================

  Widget _buildDetailedWellbeingAnalysis(EnhancedAnalyticsProvider analytics) {
    final wellbeing = analytics.wellbeingData;
    final components = wellbeing['components'] as Map<String, dynamic>? ?? {};
    final strengths = wellbeing['strengths'] as List? ?? [];
    final improvements = wellbeing['improvement_areas'] as List? ?? [];
    final score = wellbeing['overall_score'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ModernColors.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ModernColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Análisis de Bienestar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score: $score/100',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  wellbeing['level'] ?? 'En Progreso',
                  style: TextStyle(
                    color: _getScoreColor(score),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Componentes del bienestar
          if (components.isNotEmpty) ...[
            const Text(
              'Componentes del Bienestar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...components.entries.map((entry) => _buildComponentBar(
              _getComponentTitle(entry.key),
              entry.value.toDouble(),
            )),
          ],

          const SizedBox(height: 20),

          // Fortalezas y áreas de mejora
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Fortalezas',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...strengths.map((strength) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $strength',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 Mejoras',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...improvements.map((improvement) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $improvement',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ANÁLISIS DE ESTRÉS
  // ============================================================================

  Widget _buildStressAnalysis(EnhancedAnalyticsProvider analytics) {
    final stress = analytics.stressAnalysis;
    final alertLevel = stress['alert_level'] ?? 'normal';
    final alertMessage = stress['alert_message'] ?? 'Niveles normales detectados';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getStressColor(alertLevel).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStressColor(alertLevel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStressIcon(alertLevel),
                  color: _getStressColor(alertLevel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Análisis de Estrés',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStressLevelText(alertLevel),
                      style: TextStyle(
                        color: _getStressColor(alertLevel),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            alertMessage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressRecommendations(EnhancedAnalyticsProvider analytics) {
    final stress = analytics.stressAnalysis;
    final recommendations = stress['recommendations'] as List? ?? [];

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow),
              SizedBox(width: 12),
              Text(
                'Recomendaciones para el Estrés',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.blue)),
                Expanded(
                  child: Text(
                    rec.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================================
  // DETECCIÓN DE DECLIVE DE ÁNIMO
  // ============================================================================

  Widget _buildMoodDeclineDetection(EnhancedAnalyticsProvider analytics) {
    final mood = analytics.moodDeclineAnalysis;
    final concernLevel = mood['concern_level'] ?? 'normal';
    final message = mood['message'] ?? 'Tu ánimo se mantiene estable';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getMoodColor(concernLevel).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMoodColor(concernLevel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMoodIcon(concernLevel),
                  color: _getMoodColor(concernLevel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tendencia de Ánimo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMoodLevelText(concernLevel),
                      style: TextStyle(
                        color: _getMoodColor(concernLevel),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PATRONES HORARIOS
  // ============================================================================

  Widget _buildHourlyPatterns(EnhancedAnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ModernColors.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'Patrones Horarios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Análisis de patrones temporales en desarrollo...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TIMELINE DE PROGRESO
  // ============================================================================

  Widget _buildProgressTimeline(EnhancedAnalyticsProvider analytics) {
    final timeline = analytics.progressTimeline;
    final progressSummary = timeline['progress_summary'] ?? 'Continúa registrando para ver tu progreso';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: Colors.green),
              SizedBox(width: 12),
              Text(
                'Timeline de Progreso',
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
            progressSummary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // EQUILIBRIO EMOCIONAL
  // ============================================================================

  Widget _buildEmotionalBalance(EnhancedAnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.balance, color: Colors.purple),
              SizedBox(width: 12),
              Text(
                'Equilibrio Emocional',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Análisis de equilibrio emocional en desarrollo...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // INSIGHTS PERSONALIZADOS
  // ============================================================================

  Widget _buildPersonalizedInsights(EnhancedAnalyticsProvider analytics) {
    final wellbeing = analytics.wellbeingData;
    final insights = wellbeing['insights'] as List? ?? ['Continúa registrando para obtener insights personalizados'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'Insights Personalizados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    insight.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================================
  // PLAN DE ACCIÓN
  // ============================================================================

  Widget _buildActionPlan(EnhancedAnalyticsProvider analytics) {
    final goals = analytics.personalizedGoals;
    final recommendedGoals = goals['recommended_goals'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist, color: Colors.green),
              SizedBox(width: 12),
              Text(
                'Plan de Acción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendedGoals.isEmpty) ...[
            const Text(
              'No hay objetivos recomendados disponibles',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ] else ...[
            ...recommendedGoals.take(3).map((goal) => _buildGoalCard(goal, analytics)),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsProgress(EnhancedAnalyticsProvider analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'Progreso de Objetivos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Seguimiento detallado de objetivos en desarrollo...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, EnhancedAnalyticsProvider analytics) {
    final title = goal['title'] ?? 'Objetivo';
    final description = goal['description'] ?? '';
    final emoji = goal['emoji'] ?? '🎯';
    final progress = goal['progress_percentage'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 80 ? Colors.green : progress >= 50 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS DE ERROR
  // ============================================================================

  Widget _buildErrorState(EnhancedAnalyticsProvider analytics) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error cargando análisis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analytics.errorMessage ?? 'Error desconocido',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => analytics.loadCompleteAdvancedAnalytics(widget.userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentBlue,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // COMPONENTES AUXILIARES
  // ============================================================================

  Widget _buildComponentBar(String title, double value) {
    final percentage = (value * 100 / 25).clamp(0, 100); // Asumiendo max 25 puntos por componente

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.round()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 80 ? Colors.green :
              percentage >= 60 ? Colors.blue :
              percentage >= 40 ? Colors.orange : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getStressColor(String level) {
    switch (level) {
      case 'low': return Colors.green;
      case 'normal': return Colors.blue;
      case 'moderate': return Colors.orange;
      case 'high': return Colors.red;
      case 'critical': return Colors.red[900]!;
      default: return Colors.blue;
    }
  }

  Color _getMoodColor(String level) {
    switch (level) {
      case 'improving': return Colors.green;
      case 'stable': return Colors.blue;
      case 'normal': return Colors.blue;
      case 'declining': return Colors.orange;
      case 'concerning': return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getStressIcon(String level) {
    switch (level) {
      case 'low': return Icons.sentiment_very_satisfied;
      case 'normal': return Icons.sentiment_satisfied;
      case 'moderate': return Icons.sentiment_neutral;
      case 'high': return Icons.sentiment_dissatisfied;
      case 'critical': return Icons.sentiment_very_dissatisfied;
      default: return Icons.sentiment_satisfied;
    }
  }

  IconData _getMoodIcon(String level) {
    switch (level) {
      case 'improving': return Icons.trending_up;
      case 'stable': return Icons.trending_flat;
      case 'normal': return Icons.trending_flat;
      case 'declining': return Icons.trending_down;
      case 'concerning': return Icons.warning;
      default: return Icons.trending_flat;
    }
  }

  String _getStressLevelText(String level) {
    switch (level) {
      case 'low': return 'Nivel Bajo';
      case 'normal': return 'Nivel Normal';
      case 'moderate': return 'Nivel Moderado';
      case 'high': return 'Nivel Alto';
      case 'critical': return 'Nivel Crítico';
      default: return 'Normal';
    }
  }

  String _getMoodLevelText(String level) {
    switch (level) {
      case 'improving': return 'Mejorando';
      case 'stable': return 'Estable';
      case 'normal': return 'Normal';
      case 'declining': return 'Descendiendo';
      case 'concerning': return 'Preocupante';
      default: return 'Normal';
    }
  }

  String _getComponentTitle(String key) {
    switch (key) {
      case 'consistency': return 'Consistencia';
      case 'emotional_balance': return 'Balance Emocional';
      case 'progress_trend': return 'Tendencia de Progreso';
      case 'diversity': return 'Diversidad';
      case 'stress_management': return 'Gestión de Estrés';
      case 'reflection_quality': return 'Calidad de Reflexión';
      case 'achievements': return 'Logros';
      case 'temporal_stability': return 'Estabilidad Temporal';
      default: return key.replaceAll('_', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ');
    }
  }
}