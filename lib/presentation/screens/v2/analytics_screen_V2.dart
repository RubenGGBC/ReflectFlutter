// ============================================================================
// presentation/screens/v2/analytics_screen_v2.dart - VERSIÓN CORREGIDA Y REACTIVA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

class AnalyticsScreenV2 extends StatefulWidget {
  const AnalyticsScreenV2({super.key});

  @override
  State<AnalyticsScreenV2> createState() => _AnalyticsScreenV2State();
}

class _AnalyticsScreenV2State extends State<AnalyticsScreenV2>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _fadeController;

  int _selectedPeriod = 30; // días

  final List<int> _periodOptions = [7, 30, 90, 365];
  final List<String> _periodLabels = ['7 días', '30 días', '3 meses', '1 año'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
  }

  Future<void> _loadAnalytics() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    // Disparamos la carga de todos los providers necesarios para esta pantalla
    try {
      await Future.wait([
        context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id, days: _selectedPeriod),
        context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id, limitDays: _selectedPeriod),
        context.read<OptimizedMomentsProvider>().loadMoments(user.id, limitDays: _selectedPeriod),
      ]);
    } catch (e) {
      debugPrint('Error cargando analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos el provider principal de esta pantalla
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildTabBar(),
              Expanded(
                child: analyticsProvider.isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                  opacity: _fadeController,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildMoodTrendsTab(),
                      _buildHabitsTab(),
                      _buildInsightsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: ModernColors.primaryGradient),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '📊 Analytics Avanzados',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _periodOptions.length,
        itemBuilder: (context, index) {
          final period = _periodOptions[index];
          final label = _periodLabels[index];
          final isSelected = _selectedPeriod == period;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedPeriod = period);
              _loadAnalytics();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? ModernColors.primaryGradient.first.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? ModernColors.primaryGradient.first
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? ModernColors.primaryGradient.first
                        : Colors.white70,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: ModernColors.primaryGradient),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'General'),
          Tab(text: 'Tendencias'),
          Tab(text: 'Hábitos'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Analizando tus datos...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    // Leemos los otros providers aquí, ya que sabemos que no están cargando
    final entriesProvider = context.watch<OptimizedDailyEntriesProvider>();
    final momentsProvider = context.watch<OptimizedMomentsProvider>();

    final periodStats = entriesProvider.getPeriodStats(days: _selectedPeriod);
    final momentStats = momentsProvider.getMomentsStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWellbeingCard(periodStats),
          const SizedBox(height: 16),
          _buildStatsGrid(periodStats, momentStats),
          const SizedBox(height: 16),
          _buildConsistencyCard(periodStats),
          const SizedBox(height: 16),
          _buildMoodDistributionCard(),
        ],
      ),
    );
  }

  Widget _buildWellbeingCard(Map<String, dynamic> periodStats) {
    final wellbeingScore = (periodStats['avg_wellbeing'] as double? ?? 0.0) * 10;
    final trend = periodStats['mood_trend'] as String? ?? 'stable';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ModernColors.primaryGradient.map((c) => c.withOpacity(0.2)).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ModernColors.primaryGradient.first.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Puntuación de Bienestar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: wellbeingScore / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(
                                ModernColors.primaryGradient.first,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                wellbeingScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                '/100',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTrendEmoji(trend),
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTrendDescription(trend),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Últimos ${_periodLabels[_periodOptions.indexOf(_selectedPeriod)]}',
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
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map periodStats, Map momentStats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          icon: '📝',
          title: 'Entradas',
          value: '${periodStats['total_entries'] ?? 0}',
          subtitle: 'reflexiones',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: '✨',
          title: 'Momentos',
          value: '${momentStats['total'] ?? 0}',
          subtitle: 'registrados',
          color: Colors.purple,
        ),
        _buildStatCard(
          icon: '🎯',
          title: 'Consistencia',
          value: '${((periodStats['consistency_rate'] as double? ?? 0) * 100).toInt()}%',
          subtitle: 'días activos',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: '😊',
          title: 'Positividad',
          value: '${((momentStats['positive_ratio'] as double? ?? 0) * 100).toInt()}%',
          subtitle: 'momentos +',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard(Map periodStats) {
    final consistencyRate = (periodStats['consistency_rate'] as double? ?? 0) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Consistencia en el Período',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${consistencyRate.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'de días con actividad',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: consistencyRate / 100,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(
                          _getConsistencyColor(consistencyRate),
                        ),
                      ),
                    ),
                    Icon(
                      _getConsistencyIcon(consistencyRate),
                      color: _getConsistencyColor(consistencyRate),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getConsistencyMessage(consistencyRate),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistributionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Distribución de Estados de Ánimo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              '📊 Gráfico de distribución\n(Implementar con fl_chart)',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrendsTab() {
    return const Center(
      child: Text(
        '📈 Tendencias de Ánimo\n(Implementar gráficos de líneas)',
        style: TextStyle(color: Colors.white38, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHabitsTab() {
    return const Center(
      child: Text(
        '🔄 Análisis de Hábitos\n(Implementar tracking de hábitos)',
        style: TextStyle(color: Colors.white38, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInsightsTab() {
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();
    final insights = analyticsProvider.getInsights();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (insights.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'No hay suficientes datos\npara generar insights',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...insights.map((insight) => _buildInsightCard(insight)),
          const SizedBox(height: 20),
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, String> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            insight['icon'] ?? '💡',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['description'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    // ...
    return Container(); // Placeholder
  }

  String _getTrendEmoji(String trend) {
    switch (trend) {
      case 'improving': return '📈';
      case 'declining': return '📉';
      default: return '➡️';
    }
  }

  String _getTrendDescription(String trend) {
    switch (trend) {
      case 'improving': return 'Mejorando';
      case 'declining': return 'Necesita atención';
      default: return 'Estable';
    }
  }

  Color _getConsistencyColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getConsistencyIcon(double percentage) {
    if (percentage >= 80) return Icons.star;
    if (percentage >= 60) return Icons.trending_up;
    return Icons.trending_down;
  }

  String _getConsistencyMessage(double percentage) {
    if (percentage >= 80) return '¡Excelente consistencia! Sigue así.';
    if (percentage >= 60) return 'Buena consistencia, puedes mejorar un poco más.';
    if (percentage >= 40) return 'Consistencia moderada, intenta ser más regular.';
    return 'Intenta establecer una rutina más consistente.';
  }
}