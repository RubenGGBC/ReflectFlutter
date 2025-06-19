// ============================================================================
// screens/v2/home_screen_v2.dart - PANTALLA DE INICIO MODERNA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Cargar datos al iniciar
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id != null) {
      Provider.of<InteractiveMomentsProvider>(context, listen: false)
          .loadTodayMoments(authProvider.currentUser!.id!);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(ModernSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: ModernSpacing.xl),
                  _buildDaySummary(),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildQuickActions(),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: ModernColors.primaryGradient.reversed.toList()),
              ),
              child: Center(
                child: Text(user?.avatarEmoji ?? '🧘', style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: ModernSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${user?.name ?? 'Viajero'}',
                    style: ModernTypography.heading2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '¿Listo para reflexionar?',
                    style: ModernTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Acción para notificaciones o menú
              },
              icon: const Icon(Icons.notifications_outlined, color: ModernColors.textSecondary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaySummary() {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, provider, child) {
        final positiveCount = provider.positiveCount;
        final negativeCount = provider.negativeCount;
        final total = provider.totalCount;

        return ModernProgressCard(
          title: 'Resumen de Hoy',
          subtitle: '$total momentos registrados',
          progress: total == 0 ? 0 : positiveCount / total,
          color: ModernColors.primaryGradient.first,
          icon: Icons.pie_chart_outline,
          trailing: '+$positiveCount | -$negativeCount',
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones Rápidas', style: ModernTypography.heading3),
        const SizedBox(height: ModernSpacing.md),
        Row(
          children: [
            Expanded(
              child: ModernCard(
                onTap: () => Navigator.pushNamed(context, '/interactive_moments'),
                padding: const EdgeInsets.all(ModernSpacing.md),
                gradient: ModernColors.positiveGradient,
                child: const Column(
                  children: [
                    Icon(Icons.add_reaction_outlined, color: Colors.white, size: 32),
                    SizedBox(height: ModernSpacing.sm),
                    Text('Añadir Momento', style: ModernTypography.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(width: ModernSpacing.md),
            Expanded(
              child: ModernCard(
                onTap: () => Navigator.pushNamed(context, '/daily_review'),
                padding: const EdgeInsets.all(ModernSpacing.md),
                gradient: ModernColors.negativeGradient,
                child: const Column(
                  children: [
                    Icon(Icons.edit_note, color: Colors.white, size: 32),
                    SizedBox(height: ModernSpacing.sm),
                    Text('Escribir Reflexión', style: ModernTypography.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actividad Reciente', style: ModernTypography.heading3),
        const SizedBox(height: ModernSpacing.md),
        ModernCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildActivityItem(Icons.check_circle_outline, 'Reflexión de ayer completada', '¡Gran trabajo!', ModernColors.success),
              const Divider(color: ModernColors.glassSecondary, height: 1),
              _buildActivityItem(Icons.calendar_today_outlined, 'Viendo tu Calendario', 'Hace 2 días', ModernColors.info),
              const Divider(color: ModernColors.glassSecondary, height: 1),
              _buildActivityItem(Icons.person_outline, 'Perfil actualizado', 'Cambiaste tu avatar', ModernColors.categories['espiritual']!),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: ModernTypography.bodyLarge),
      subtitle: Text(subtitle, style: ModernTypography.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: ModernColors.textHint),
      onTap: () {},
    );
  }
}
