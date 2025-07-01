// lib/presentation/screens/v2/home_screen_v2.dart - CORRECTED VERSION
// ============================================================================
// PANTALLA DE INICIO CORREGIDA CON FOTO DE PERFIL Y MENSAJE DE BIENVENIDA
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// Widgets personalizados
import '../../widgets/profile_picture_widget.dart'; // ✅ NUEVO IMPORT

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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _profilePictureAnimation;
  late Animation<Offset> _welcomeTextAnimation;

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
      curve: Curves.easeOutBack,
    ));

    _profilePictureAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _profilePictureController,
        curve: Curves.elasticOut,
      ),
    );

    _welcomeTextAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _welcomeTextController,
      curve: Curves.easeOutBack,
    ));

    // Secuencia de animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
        _profilePictureController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _welcomeTextController.forward();
      }
    });
  }

  void _loadInitialData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      // ✅ MÉTODOS CORREGIDOS - usando los que realmente existen
      try {
        final momentsProvider = context.read<OptimizedMomentsProvider>();
        final analyticsProvider = context.read<OptimizedAnalyticsProvider>();

        // Cargar datos usando los métodos correctos del provider
        momentsProvider.loadTodayMoments(user.id); // ✅ EXISTE
        analyticsProvider.loadCompleteAnalytics(user.id, days: 7); // ✅ EXISTE
      } catch (e) {
        debugPrint('Error loading initial data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final momentsProvider = context.watch<OptimizedMomentsProvider>();
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: Usuario no encontrado.'),
        ),
      );
    }

    // ✅ MOSTRAR LOADING STATE SI ESTÁN CARGANDO DATOS
    final isLoadingData = momentsProvider.isLoading || analyticsProvider.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ModernColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadInitialData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(ModernSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Header siempre visible (con foto de perfil y bienvenida)
                      _buildWelcomeHeader(user),
                      const SizedBox(height: ModernSpacing.xl),

                      // ✅ Mostrar loading o contenido según el estado
                      if (isLoadingData) ...[
                        _buildLoadingContent(),
                      ] else ...[
                        _buildMomentsOverview(),
                        const SizedBox(height: ModernSpacing.lg),
                        _buildReflectionStatus(),
                        const SizedBox(height: ModernSpacing.lg),
                        _buildWellbeingMetrics(),
                        const SizedBox(height: ModernSpacing.lg),
                        _buildTodayInsights(),
                        const SizedBox(height: ModernSpacing.lg),
                      ],

                      // ✅ Acciones rápidas siempre visibles
                      _buildQuickActions(),
                      const SizedBox(height: ModernSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ NUEVO: Widget de estado de carga
  Widget _buildLoadingContent() {
    return Column(
      children: [
        // Loading cards con shimmer effect
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        const SizedBox(height: ModernSpacing.lg),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: ModernSpacing.lg),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  // ✅ Header de bienvenida con foto de perfil
  Widget _buildWelcomeHeader(OptimizedUserModel user) {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ FOTO DE PERFIL CON ANIMACIÓN
          ScaleTransition(
            scale: _profilePictureAnimation,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3B82F6), // Azul
                      Color(0xFF8B5CF6), // Púrpura
                      Color(0xFF10B981), // Verde
                      Color(0xFFF59E0B), // Amarillo
                      Color(0xFFEF4444), // Rojo
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: _buildAvatarContent(user),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: ModernSpacing.md),
          // ✅ MENSAJE DE BIENVENIDA CON ANIMACIÓN
          Expanded(
            child: SlideTransition(
              position: _welcomeTextAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje "Bienvenido"
                  Text(
                    'Bienvenido,',
                    style: ModernTypography.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nombre del usuario
                  Text(
                    user.name,
                    style: ModernTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Saludo contextual
                  Row(
                    children: [
                      Text(
                        _getGreeting(),
                        style: ModernTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getGreetingEmoji(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ✅ ICONO DE CONFIGURACIÓN
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: 'Configuración',
          ),
        ],
      ),
    );
  }

  // ✅ Método para mostrar contenido del avatar
  Widget _buildAvatarContent(OptimizedUserModel user) {
    // Si tiene foto de perfil y el archivo existe
    if (user.hasProfilePicture) {
      return Image.file(
        File(user.profilePicturePath!),
        fit: BoxFit.cover,
        width: 74,
        height: 74,
        errorBuilder: (context, error, stackTrace) {
          return _buildEmojiAvatar(user.avatarEmoji);
        },
      );
    } else {
      return _buildEmojiAvatar(user.avatarEmoji);
    }
  }

  Widget _buildEmojiAvatar(String emoji) {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: ModernColors.primaryGradient,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }

  Widget _buildMomentsOverview() {
    // ✅ USANDO DATOS REALES DEL PROVIDER
    final momentsProvider = context.watch<OptimizedMomentsProvider>();
    final todayMoments = momentsProvider.todayMoments;

    final positiveMoments = todayMoments.where((m) => m.type == 'positive').length;
    final negativeMoments = todayMoments.where((m) => m.type == 'negative').length;
    final neutralMoments = todayMoments.where((m) => m.type == 'neutral').length;
    final totalMoments = todayMoments.length;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: ModernColors.accentBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                'Momentos de hoy',
                style: ModernTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$totalMoments total',
                style: ModernTypography.bodySmall.copyWith(
                  color: ModernColors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMomentCard(
                  icon: Icons.sentiment_very_satisfied,
                  label: 'Positivos',
                  count: positiveMoments,
                  color: ModernColors.success,
                ),
              ),
              const SizedBox(width: ModernSpacing.sm),
              Expanded(
                child: _buildMomentCard(
                  icon: Icons.sentiment_neutral,
                  label: 'Neutrales',
                  count: neutralMoments,
                  color: ModernColors.accentBlue,
                ),
              ),
              const SizedBox(width: ModernSpacing.sm),
              Expanded(
                child: _buildMomentCard(
                  icon: Icons.sentiment_dissatisfied,
                  label: 'Negativos',
                  count: negativeMoments,
                  color: ModernColors.warning,
                ),
              ),
            ],
          ),
          if (totalMoments == 0) ...[
            const SizedBox(height: ModernSpacing.md),
            Container(
              padding: const EdgeInsets.all(ModernSpacing.md),
              decoration: BoxDecoration(
                color: ModernColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: ModernColors.accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  Expanded(
                    child: Text(
                      'Registra tu primer momento del día',
                      style: ModernTypography.bodyMedium.copyWith(
                        color: ModernColors.onSurface.withOpacity(0.8),
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

  Widget _buildMomentCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            count.toString(),
            style: ModernTypography.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: ModernTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionStatus() {
    final hasReflection = false; // Simulamos estado

    return ModernCard(
      child: InkWell(
        onTap: hasReflection ? null : () {
          // Navigator.pushNamed(context, '/daily-review');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(ModernSpacing.md),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: hasReflection
                      ? ModernColors.success.withOpacity(0.2)
                      : ModernColors.warning.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasReflection ? Icons.check_circle : Icons.edit_note,
                  color: hasReflection ? ModernColors.success : ModernColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasReflection ? 'Reflexión completada' : 'Reflexión pendiente',
                      style: ModernTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasReflection
                          ? 'Excelente trabajo registrando tu día 🎉'
                          : 'Dedica unos minutos a reflexionar sobre tu día',
                      style: ModernTypography.bodyMedium.copyWith(
                        color: ModernColors.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasReflection)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: ModernColors.warning,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWellbeingMetrics() {
    // ✅ USANDO DATOS REALES DEL ANALYTICS PROVIDER
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();
    final wellbeingScore = analyticsProvider.wellbeingScore.toDouble(); // Convertir de int a double

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: ModernColors.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: ModernSpacing.sm),
              Text(
                'Bienestar General',
                style: ModernTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.lg),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de fondo
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      backgroundColor: ModernColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ModernColors.surface,
                      ),
                    ),
                  ),
                  // Círculo de progreso animado
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween(begin: 0.0, end: wellbeingScore / 10),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getWellbeingColor(wellbeingScore),
                          ),
                          strokeCap: StrokeCap.round,
                        );
                      },
                    ),
                  ),
                  // Contenido central
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween(begin: 0.0, end: wellbeingScore),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: ModernTypography.headlineLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getWellbeingColor(wellbeingScore),
                            ),
                          );
                        },
                      ),
                      Text(
                        '/10',
                        style: ModernTypography.bodyMedium.copyWith(
                          color: ModernColors.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ModernSpacing.md),
          Container(
            padding: const EdgeInsets.all(ModernSpacing.md),
            decoration: BoxDecoration(
              color: _getWellbeingColor(wellbeingScore).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getWellbeingDescription(wellbeingScore),
              style: ModernTypography.bodyMedium.copyWith(
                color: _getWellbeingColor(wellbeingScore),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayInsights() {
    // ✅ USANDO DATOS REALES DEL ANALYTICS PROVIDER
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();

    try {
      final insights = analyticsProvider.getInsights();
      final highlightedInsights = analyticsProvider.getHighlightedInsights();

      // Combinar insights normales y destacados, tomar los primeros 3
      final allInsights = [...highlightedInsights, ...insights];
      final displayInsights = allInsights.take(3).map((insight) => insight['text'] ?? '').where((text) => text.isNotEmpty).toList();

      if (displayInsights.isEmpty) {
        return const SizedBox.shrink();
      }

      return ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernColors.accentYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: ModernColors.accentYellow,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ModernSpacing.sm),
                Text(
                  'Insights del día',
                  style: ModernTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ModernSpacing.md),
            ...displayInsights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: ModernSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                decoration: BoxDecoration(
                  color: ModernColors.accentYellow.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ModernColors.accentYellow.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: ModernColors.accentYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: ModernSpacing.sm),
                    Expanded(
                      child: Text(
                        insight,
                        style: ModernTypography.bodyMedium.copyWith(
                          color: ModernColors.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      );
    } catch (e) {
      // Si hay error con analytics, mostrar insights genéricos
      debugPrint('Error loading insights: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones rápidas',
          style: ModernTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ModernSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: ModernSpacing.md,
          mainAxisSpacing: ModernSpacing.md,
          childAspectRatio: 2.2,
          children: [
            _buildActionButton(
              title: 'Nuevo Momento',
              icon: Icons.add_circle_outline,
              gradient: ModernColors.positiveGradient,
              onPressed: () {
                // Navigator.pushNamed(context, '/moments');
              },
            ),
            _buildActionButton(
              title: 'Reflexión',
              icon: Icons.edit_note,
              gradient: ModernColors.warningGradient,
              onPressed: () {
                // Navigator.pushNamed(context, '/daily-review');
              },
            ),
            _buildActionButton(
              title: 'Analytics',
              icon: Icons.analytics,
              gradient: ModernColors.neutralGradient,
              onPressed: () {
                // Navigator.pushNamed(context, '/analytics');
              },
            ),
            _buildActionButton(
              title: 'Mi Perfil',
              icon: Icons.person_outline,
              gradient: [
                ModernColors.surface.withOpacity(0.3),
                ModernColors.surface.withOpacity(0.1),
              ],
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: ModernTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 18) return '🌤️';
    return '🌙';
  }

  Color _getWellbeingColor(double score) {
    if (score >= 8) return ModernColors.success;
    if (score >= 6) return ModernColors.accentBlue;
    if (score >= 4) return ModernColors.warning;
    return ModernColors.error;
  }

  String _getWellbeingDescription(double score) {
    if (score >= 8) return 'Te sientes muy bien hoy, ¡sigue así! 🌟';
    if (score >= 6) return 'Tu bienestar está en buen camino 💪';
    if (score >= 4) return 'Día promedio, siempre se puede mejorar 📈';
    return 'Considera dedicar tiempo al autocuidado 💝';
  }
}