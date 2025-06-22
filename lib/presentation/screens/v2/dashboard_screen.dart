// lib/presentation/screens/v2/dashboard_screen.dart
// Dashboard principal completamente arreglado

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/optimized_models.dart';
import '../../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
import '../components/modern_design_system.dart';
import '../../widgets/enhanced_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>(); // ✅ PROVIDER ARREGLADO
    final user = authProvider.currentUser;

    if (user != null) {
      // ✅ PROVIDER ARREGLADO
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id);
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<OptimizedMomentsProvider>().loadMoments(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ModernColors.accentBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '📊 Resumen'),
            Tab(text: '📈 Analytics'),
            Tab(text: '🎯 Objetivos'),
          ],
        ),
      ),
      body: Consumer3<OptimizedAuthProvider, OptimizedAnalyticsProvider, OptimizedDailyEntriesProvider>( // ✅ PROVIDERS ARREGLADOS
        builder: (context, auth, analytics, entries, child) {
          if (auth.currentUser == null) {
            return const Center(
              child: Text(
                'Usuario no autenticado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(auth.currentUser!, analytics, entries),
              _buildAnalyticsTab(auth.currentUser!, analytics),
              _buildGoalsTab(analytics),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryTab(OptimizedUserModel user, OptimizedAnalyticsProvider analytics, OptimizedDailyEntriesProvider entries) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo personalizado
          _buildWelcomeCard(user),
          const SizedBox(height: 20),

          // Stats principales
          _buildMainStats(analytics),
          const SizedBox(height: 20),

          // Entrada de hoy
          _buildTodayEntry(entries),
          const SizedBox(height: 20),

          // Alertas y recomendaciones
          _buildAlertsAndRecommendations(analytics),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(OptimizedUserModel user) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = 'Buenos días';
      emoji = '🌅';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
      emoji = '☀️';
    } else {
      greeting = 'Buenas noches';
      emoji = '🌙';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${user.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¿Cómo te sientes hoy?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                user.avatarEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats(OptimizedAnalyticsProvider analytics) {
    final summary = analytics.getDashboardSummary();
    final wellbeingStatus = analytics.getWellbeingStatus();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu Progreso',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Score principal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                wellbeingStatus['emoji'] ?? '📊',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienestar: ${wellbeingStatus['score']}/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      wellbeingStatus['level'] ?? 'Sin datos',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (wellbeingStatus['score'] as int? ?? 0) / 10,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(wellbeingStatus['score'] as int? ?? 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Stats secundarios
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '🔥',
                'Racha',
                '${summary['current_streak']} días',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '📊',
                'Entradas',
                '${summary['total_entries']}',
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
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
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayEntry(OptimizedDailyEntriesProvider entries) {
    final todayEntry = entries.todayEntry;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: ModernColors.accentBlue),
              const SizedBox(width: 8),
              const Text(
                'Entrada de Hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (todayEntry != null) ...[
            Text(
              'Ya registraste tu día',
              style: TextStyle(
                color: Colors.green.shade400,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            if (todayEntry.moodScore != null)
              Text(
                'Mood: ${todayEntry.moodScore}/10',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ] else ...[
            const Text(
              'Aún no has registrado tu día',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navegar a crear entrada
                _navigateToCreateEntry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentBlue,
              ),
              child: const Text('Registrar Ahora'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertsAndRecommendations(OptimizedAnalyticsProvider analytics) {
    final stressAlerts = analytics.getStressAlerts();
    final recommendations = analytics.getTopRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alertas de estrés
        if (stressAlerts['requires_attention'] == true) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (stressAlerts['alert_color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: stressAlerts['alert_color'] as Color),
            ),
            child: Row(
              children: [
                Text(
                  stressAlerts['alert_icon'] ?? '⚠️',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stressAlerts['alert_title'] ?? 'Alerta',
                        style: TextStyle(
                          color: stressAlerts['alert_color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nivel de estrés: ${stressAlerts['level']}',
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
          ),
          const SizedBox(height: 16),
        ],

        // Recomendaciones
        if (recommendations.isNotEmpty) ...[
          const Text(
            'Recomendaciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.take(2).map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(rec['emoji'] ?? '💡', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildAnalyticsTab(OptimizedUserModel user, OptimizedAnalyticsProvider analytics) {
    return EnhancedDashboard(userId: user.id);
  }

  Widget _buildGoalsTab(OptimizedAnalyticsProvider analytics) {
    final nextAchievement = analytics.getNextAchievementToUnlock();
    final recommendations = analytics.getPriorityRecommendations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Próximo logro
          if (nextAchievement != null) ...[
            const Text(
              'Próximo Logro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        nextAchievement['emoji'] ?? '🏆',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nextAchievement['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              nextAchievement['description'] ?? '',
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${nextAchievement['current']}/${nextAchievement['target']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (nextAchievement['progress'] as double? ?? 0.0),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(ModernColors.accentBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Objetivos recomendados
          const Text(
            'Objetivos Recomendados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map((goal) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(goal['emoji'] ?? '🎯', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal['description'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(goal['priority'] ?? 'low'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityLabel(goal['priority'] ?? 'low'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  void _navigateToCreateEntry() {
    // Implementar navegación a crear entrada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad próximamente disponible'),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green.shade400;
    if (score >= 6) return Colors.blue.shade400;
    if (score >= 4) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red.shade400;
      case 'medium': return Colors.orange.shade400;
      case 'low': return Colors.blue.shade400;
      default: return Colors.grey.shade400;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high': return 'ALTA';
      case 'medium': return 'MEDIA';
      case 'low': return 'BAJA';
      default: return 'INFO';
    }
  }
}