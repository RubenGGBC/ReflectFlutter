// ============================================================================
// presentation/screens/v2/home_screen_v2.dart - VERSIÓN CORREGIDA Y REACTIVA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';

// Modelos (para el casting de tipos)
import '../../../data/models/optimized_models.dart';

// Componentes modernos
import '../components/modern_design_system.dart';
import '../components/analytics_widgets.dart';

// Servicios
import '../../../data/services/optimized_database_service.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Usamos addPostFrameCallback para asegurar que el `context` esté disponible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack
    ));
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      // Manejar el caso de que el usuario no esté logueado
      return;
    };

    try {
      // La carga de datos inicial se dispara aquí
      await Future.wait([
        context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id, limitDays: 30),
        context.read<OptimizedMomentsProvider>().loadTodayMoments(user.id),
        context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id),
      ]);

      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _slideController.forward();
        });
      }

    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observamos los providers para que la UI se reconstruya con los cambios
    final authProvider = context.watch<OptimizedAuthProvider>();
    final entriesProvider = context.watch<OptimizedDailyEntriesProvider>();
    final momentsProvider = context.watch<OptimizedMomentsProvider>();
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();

    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          // Usamos el `isLoading` del provider para mostrar el estado de carga
          child: analyticsProvider.isLoading
              ? _buildLoadingState()
              : user == null
              ? _buildErrorState('Usuario no encontrado. Por favor, inicia sesión de nuevo.')
              : FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              // Pasamos los providers a los widgets que los necesiten
              child: _buildContent(user, entriesProvider, momentsProvider, analyticsProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
          ),
          SizedBox(height: ModernSpacing.md),
          Text(
            'Cargando tu espacio de bienestar...',
            style: ModernTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message, style: ModernTypography.bodyLarge.copyWith(color: Colors.red)),
        )
    );
  }

  Widget _buildContent(
      OptimizedUserModel user,
      OptimizedDailyEntriesProvider entriesProvider,
      OptimizedMomentsProvider momentsProvider,
      OptimizedAnalyticsProvider analyticsProvider
      ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(user),
        SliverPadding(
          padding: const EdgeInsets.all(ModernSpacing.md),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: ModernSpacing.md),
              _buildWellbeingCard(analyticsProvider),
              const SizedBox(height: ModernSpacing.md),
              _buildTodaySection(entriesProvider, momentsProvider),
              const SizedBox(height: ModernSpacing.md),
              _buildMomentsPreview(momentsProvider),
              const SizedBox(height: ModernSpacing.md),
              _buildAnalyticsPreview(entriesProvider),
              const SizedBox(height: ModernSpacing.md),
              _buildInsightsCard(analyticsProvider),
              const SizedBox(height: ModernSpacing.lg),
              _buildQuickActions(),
              const SizedBox(height: ModernSpacing.lg),
            ]),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(OptimizedUserModel user) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          "Hola, ${user.name.split(' ').first}",
          style: ModernTypography.heading3,
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: ModernColors.primaryGradient),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(ModernSpacing.radiusXLarge),
              bottomRight: Radius.circular(ModernSpacing.radiusXLarge),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () { /* Implementar notificaciones */ },
        ),
        const SizedBox(width: ModernSpacing.sm)
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: ModernSpacing.md),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            user.avatarEmoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }


  Widget _buildWellbeingCard(OptimizedAnalyticsProvider analyticsProvider) {
    final wellbeingScore = analyticsProvider.wellbeingScore;
    final wellbeingLevel = analyticsProvider.wellbeingLevel;

    return ModernCard(
      gradient: ModernColors.primaryGradient,
      padding: const EdgeInsets.all(ModernSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 24),
              SizedBox(width: ModernSpacing.md),
              Text('Tu Bienestar Hoy', style: ModernTypography.heading3),
            ],
          ),
          const SizedBox(height: ModernSpacing.lg),
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: wellbeingScore / 10.0,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Text(
                      '$wellbeingScore',
                      style: ModernTypography.heading2.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ModernSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wellbeingLevel, style: ModernTypography.heading3),
                    const SizedBox(height: ModernSpacing.xs),
                    Text(
                      _getWellbeingDescription(wellbeingScore),
                      style: ModernTypography.bodyMedium,
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

  Widget _buildTodaySection(OptimizedDailyEntriesProvider entriesProvider, OptimizedMomentsProvider momentsProvider) {
    final todayEntry = entriesProvider.todayEntry;
    final todayMoments = momentsProvider.todayMoments;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: Colors.white, size: 20),
              SizedBox(width: ModernSpacing.sm),
              Text('Tu Día de Hoy', style: ModernTypography.heading4),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          Row(
            children: [
              Icon(
                todayEntry != null ? Icons.check_circle : Icons.edit_outlined,
                color: todayEntry != null ? ModernColors.success : ModernColors.warning,
                size: 20,
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                todayEntry != null ? 'Reflexión completada' : 'Reflexión pendiente',
                style: ModernTypography.bodyMedium.copyWith(color: todayEntry != null ? ModernColors.success : ModernColors.warning),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: todayMoments.isNotEmpty ? ModernColors.info : ModernColors.textHint,
                size: 20,
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                '${todayMoments.length} momentos registrados',
                style: ModernTypography.bodyMedium.copyWith(color: todayMoments.isNotEmpty ? ModernColors.info : ModernColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsPreview(OptimizedMomentsProvider momentsProvider) {
    final todayMoments = momentsProvider.todayMoments;
    final momentsStats = momentsProvider.getMomentsStats();

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Momentos de Hoy', style: ModernTypography.heading4),
              TextButton(
                onPressed: () {}, // Navegar a pantalla de momentos
                child: const Text('Ver todos'),
              ),
            ],
          ),
          if (todayMoments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: ModernSpacing.md),
                child: Text('No has registrado momentos hoy.', style: ModernTypography.bodyMedium),
              ),
            )
          else ...[
            ...todayMoments.take(3).map((moment) => _buildMomentItem(moment)),
            if (todayMoments.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: ModernSpacing.sm),
                child: Text(
                  'y ${todayMoments.length - 3} más...',
                  style: ModernTypography.bodySmall,
                ),
              ),
          ],
          const SizedBox(height: ModernSpacing.md),
          Row(
            children: [
              _buildStatChip(
                'Total',
                '${momentsStats['total'] ?? 0}',
                ModernColors.info,
              ),
              const SizedBox(width: ModernSpacing.sm),
              _buildStatChip(
                'Positivos',
                '${((momentsStats['positive_ratio'] as double? ?? 0.0) * 100).toInt()}%',
                ModernColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMomentItem(OptimizedInteractiveMomentModel moment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ModernSpacing.xs),
      child: Row(
        children: [
          Text(moment.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: ModernSpacing.md),
          Expanded(
            child: Text(
              moment.text,
              style: ModernTypography.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(moment.timeStr, style: ModernTypography.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.sm, vertical: ModernSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
      ),
      child: Text('$label: $value', style: ModernTypography.caption.copyWith(color: color)),
    );
  }

  Widget _buildAnalyticsPreview(OptimizedDailyEntriesProvider entriesProvider) {
    final periodStats = entriesProvider.getPeriodStats();

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Analytics del Período', style: ModernTypography.heading4),
              TextButton(
                onPressed: () {}, // Navegar a pantalla de analytics
                child: const Text('Ver detalles'),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Entradas',
                  '${periodStats['total_entries'] ?? 0}',
                  Icons.edit_note,
                  ModernColors.info,
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: _buildMetricCard(
                  'Consistencia',
                  '${((periodStats['consistency_rate'] as double? ?? 0.0) * 100).toInt()}%',
                  Icons.trending_up,
                  ModernColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: ModernSpacing.sm),
          Text(value, style: ModernTypography.heading3.copyWith(color: color)),
          Text(label, style: ModernTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(OptimizedAnalyticsProvider analyticsProvider) {
    final insights = analyticsProvider.getInsights();
    if (insights.isEmpty) return const SizedBox.shrink();

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Insights Personalizados', style: ModernTypography.heading4),
          const SizedBox(height: ModernSpacing.md),
          ...insights.take(2).map((insight) => _buildInsightItem(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(Map<String, String> insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ModernSpacing.xs),
      child: Row(
        children: [
          Text(insight['icon']!, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: ModernSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight['title']!, style: ModernTypography.bodyLarge),
                Text(insight['description']!, style: ModernTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acciones Rápidas', style: ModernTypography.heading4),
        const SizedBox(height: ModernSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: ModernSpacing.md,
          mainAxisSpacing: ModernSpacing.md,
          childAspectRatio: 2.5,
          children: [
            ModernButton(
              text: 'Nuevo Momento',
              icon: Icons.add_circle_outline,
              gradient: ModernColors.positiveGradient,
              onPressed: () {},
            ),
            ModernButton(
              text: 'Reflexión',
              icon: Icons.edit_note,
              gradient: ModernColors.warningGradient,
              onPressed: () {},
            ),
            ModernButton(
              text: 'Analytics',
              icon: Icons.analytics,
              gradient: ModernColors.neutralGradient,
              onPressed: () {},
            ),
            ModernButton(
              text: 'Mi Perfil',
              icon: Icons.person_outline,
              isPrimary: false,
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getWellbeingDescription(int score) {
    if (score >= 8) return 'Te sientes muy bien hoy, ¡sigue así!';
    if (score >= 6) return 'Tu bienestar está en buen camino.';
    if (score >= 4) return 'Día promedio, siempre se puede mejorar.';
    return 'Considera dedicar tiempo al autocuidado.';
  }
}