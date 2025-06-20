// ============================================================================
// HOME SCREEN V2 - CON ANALYTICS MEJORADOS INTEGRADOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../../providers/enhanced_analytics_provider.dart'; // ✅ NUEVO
import '../components/modern_design_system.dart';
import '../../../data/services/database_service.dart';
import '../../providers/analytics_provider.dart';
import '../components/analytics_widgets.dart';
import '../v2/advanced_analytics_screen.dart'; // ✅ NUEVO
import '../../widgets/improved_dashboard.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // DATOS REALES DEL USUARIO
  Map<String, dynamic> _userStats = {};
  bool _isLoadingStats = true;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRealUserData();
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ============================================================================
  // CARGAR DATOS REALES DEL USUARIO
  // ============================================================================

  // ✅ POR ESTE método corregido:
  Future<void> _loadRealUserData() async {
    // Mover todo a postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final momentsProvider = Provider.of<InteractiveMomentsProvider>(context, listen: false);
      final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
      final enhancedAnalyticsProvider = Provider.of<EnhancedAnalyticsProvider>(context, listen: false);

      if (authProvider.currentUser?.id == null) return;

      if (mounted) setState(() => _isLoadingStats = true);

      try {
        final userId = authProvider.currentUser!.id!;

        // Cargar analytics mejorados
        await enhancedAnalyticsProvider.loadCompleteAdvancedAnalytics(userId);

        await Future.wait([
          momentsProvider.loadTodayMoments(userId),
          analyticsProvider.loadCompleteAnalytics(userId),
          _loadUserStatistics(userId),
        ]);

      } catch (e) {
        debugPrint('Error cargando datos: $e');
      } finally {
        if (mounted) setState(() => _isLoadingStats = false);
      }
    });
  }

  Future<void> _loadUserStatistics(int userId) async {
    try {
      final stats = await _databaseService.getUserStatistics(userId);
      setState(() {
        _userStats = stats;
      });
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
      setState(() {
        _userStats = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: _isLoadingStats
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        _buildModernAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnhancedWelcomeCard(), // ✅ MEJORADO
                const SizedBox(height: 24),
                _buildAdvancedAnalyticsSummary(), // ✅ NUEVO
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildTodayMomentsSection(),
                const SizedBox(height: 24),
                _buildImprovedDashboard(),
                const SizedBox(height: 100), // Espacio para navegación
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // APP BAR MODERNA
  // ============================================================================

  Widget _buildModernAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: ModernColors.primaryGradient,
            ),
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            final userName = auth.currentUser?.name ?? 'Usuario';
            final greeting = _getGreeting();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TARJETA DE BIENVENIDA MEJORADA
  // ============================================================================

  Widget _buildEnhancedWelcomeCard() {
    return Consumer<EnhancedAnalyticsProvider>(
      builder: (context, enhancedAnalytics, child) {
        final progressSummary = enhancedAnalytics.getProgressSummary();
        final quickMetrics = enhancedAnalytics.getQuickMetrics();
        final alerts = enhancedAnalytics.getCriticalAlerts();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con score principal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu Bienestar Hoy',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${quickMetrics['wellbeing_score']}/100',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getTrendIcon(progressSummary['trend']),
                            color: _getTrendColor(progressSummary['trend']),
                            size: 24,
                          ),
                        ],
                      ),
                      Text(
                        progressSummary['motivational_message'] ?? 'Sigue adelante',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progressSummary['level'] ?? 'En Progreso',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Métricas rápidas
              Row(
                children: [
                  Expanded(
                    child: _buildQuickMetric(
                      'Estrés',
                      quickMetrics['stress_level'] ?? 'Normal',
                      Icons.favorite,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickMetric(
                      'Ánimo',
                      quickMetrics['mood_trend'] ?? 'Estable',
                      Icons.mood,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickMetric(
                      'Objetivos',
                      '${quickMetrics['active_goals']}',
                      Icons.tablet,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              // Mostrar alertas críticas si las hay
              if (alerts.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${alerts.length} alerta${alerts.length > 1 ? 's' : ''} requiere${alerts.length > 1 ? 'n' : ''} atención',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToAdvancedAnalytics,
                        child: const Text(
                          'Ver detalles',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
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
      },
    );
  }

  Widget _buildQuickMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // RESUMEN DE ANALYTICS AVANZADOS
  // ============================================================================

  Widget _buildAdvancedAnalyticsSummary() {
    return Consumer<EnhancedAnalyticsProvider>(
      builder: (context, enhancedAnalytics, child) {
        if (enhancedAnalytics.isLoading) {
          return _buildLoadingCard('Cargando análisis avanzado...');
        }

        final recommendations = enhancedAnalytics.getIntelligentRecommendations();
        final componentsData = enhancedAnalytics.getWellbeingComponentsChartData();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Análisis Inteligente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToAdvancedAnalytics,
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      color: ModernColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfico de componentes de bienestar
            _buildWellbeingComponentsPreview(componentsData),

            const SizedBox(height: 16),

            // Recomendaciones principales
            if (recommendations.isNotEmpty) ...[
              const Text(
                'Recomendaciones para Ti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...recommendations.take(2).map((rec) => _buildRecommendationCard(rec)),
            ],
          ],
        );
      },
    );
  }

  // ❌ BUSCAR este método y corregir:
  Widget _buildWellbeingComponentsPreview(List<Map<String, dynamic>> components) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ModernColors.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ModernColors.accentBlue, width: 3),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.donut_small, color: Colors.white, size: 24),
                  Text(
                    'Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Componentes de Bienestar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ CORREGIR esta parte que causa el error:
                ...components.take(3).map((component) {
                  final name = component['name'] ?? 'Componente';
                  final emoji = component['emoji'] ?? '📊';
                  final value = (component['value'] as num?)?.toDouble() ?? 0.0;
                  final colorString = component['color'] ?? '0xFF3B82F6';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _parseColor(colorString).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (value / 25).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _parseColor(colorString),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ✅ AGREGAR este método auxiliar:
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return Colors.blue; // Color por defecto
    }
  }
  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(
            recommendation['emoji'] ?? '💡',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] ?? 'Recomendación',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  recommendation['description'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ACCIONES RÁPIDAS
  // ============================================================================

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Nuevo Momento',
                icon: Icons.add_reaction_outlined,
                color: Colors.green,
                onTap: () {
                  // Navegar a crear momento interactivo
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Análisis Detallado',
                icon: Icons.analytics,
                color: Colors.blue,
                onTap: _navigateToAdvancedAnalytics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Revisión Diaria',
                icon: Icons.checklist,
                color: Colors.purple,
                onTap: () {
                  // TODO: Navegar a revisión diaria
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SECCIÓN DE MOMENTOS DEL DÍA
  // ============================================================================

  Widget _buildTodayMomentsSection() {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, moments, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Momentos de Hoy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${moments.totalCount} momentos',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (moments.isLoading) ...[
              _buildLoadingCard('Cargando momentos del día...'),
            ] else if (moments.moments.isEmpty) ...[
              _buildEmptyMomentsCard(),
            ] else ...[
              _buildMomentsGrid(moments.moments),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMomentsGrid(List moments) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: moments.length.clamp(0, 4), // Mostrar máximo 4
      itemBuilder: (context, index) {
        final moment = moments[index];
        return _buildMomentCard(moment);
      },
    );
  }

  Widget _buildMomentCard(dynamic moment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: moment.type == 'positive'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  moment.type == 'positive' ? '+' : '-',
                  style: TextStyle(
                    color: moment.type == 'positive' ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              moment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMomentsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.sentiment_neutral, color: Colors.white54, size: 48),
            SizedBox(height: 12),
            Text(
              'No hay momentos registrados hoy',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Registra tu primer momento del día',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DASHBOARD MEJORADO
  // ============================================================================

  Widget _buildImprovedDashboard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 0;
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard General',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (analytics.isLoading) ...[
              _buildLoadingCard('Cargando dashboard...'),
            ] else ...[
              ImprovedDashboard(userId: userId),
            ],
          ],
        );
      },
    );
  }

  // ============================================================================
  // WIDGETS AUXILIARES
  // ============================================================================

  Widget _buildLoadingCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // NAVEGACIÓN
  // ============================================================================

  void _navigateToAdvancedAnalytics() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdvancedAnalyticsScreen(
            userId: authProvider.currentUser!.id!,
          ),
        ),
      );
    }
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  IconData _getTrendIcon(String? trend) {
    switch (trend) {
      case 'up': return Icons.trending_up;
      case 'down': return Icons.trending_down;
      case 'stable':
      default: return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String? trend) {
    switch (trend) {
      case 'up': return Colors.green;
      case 'down': return Colors.red;
      case 'stable':
      default: return Colors.blue;
    }
  }
}