// ============================================================================
// profile_screen_v2.dart - NUEVA VERSIÓN CON MEJORAS UI SEGÚN ESPECIFICACIONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../components/modern_design_system.dart';

class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2>
    with TickerProviderStateMixin {
  late AnimationController _avatarController;
  late AnimationController _statsController;
  late AnimationController _cardController;

  late Animation<double> _avatarAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _cardAnimation;

  String selectedAvatar = '🧘‍♀️';

  final List<String> avatarEmojis = [
    '🧘‍♀️', '🧘‍♂️', '🌟', '✨', '🦋', '🌸', '🌱', '💫',
    '🌺', '🍃', '🌙', '☀️', '🌈', '💎', '🔮', '🕯️'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _avatarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _avatarAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    _avatarController.repeat(reverse: true);
    _cardController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _statsController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0a0e27),
              Color(0xFF2d1b69),
              Color(0xFF667eea),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ModernSpacing.lg),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: ModernSpacing.xl),
                _buildProfileCard(),
                const SizedBox(height: ModernSpacing.lg),
                _buildStatsGrid(),
                const SizedBox(height: ModernSpacing.lg),
                _buildAchievements(),
                const SizedBox(height: ModernSpacing.lg),
                _buildSettings(),
                const SizedBox(height: ModernSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(_cardAnimation),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Text(
              'Mi Perfil',
              style: ModernTypography.heading2,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _showEditProfileDialog,
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return FadeTransition(
      opacity: _cardAnimation,
      child: ScaleTransition(
        scale: _cardAnimation,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            if (user == null) return const SizedBox();

            return ModernCard(
              padding: const EdgeInsets.all(ModernSpacing.xl),
              child: Column(
                children: [
                  // Avatar personalizable animado
                  GestureDetector(
                    onTap: _showAvatarSelector,
                    child: ScaleTransition(
                      scale: _avatarAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: ModernColors.primaryGradient,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.primaryGradient.first.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            selectedAvatar,
                            style: const TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: ModernSpacing.lg),

                  // Información del usuario
                  Text(
                    user.name,
                    style: ModernTypography.heading2,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: ModernSpacing.sm),

                  Text(
                    user.email,
                    style: ModernTypography.bodyMedium.copyWith(
                      color: ModernColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: ModernSpacing.lg),

                  // Badge de nivel
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ModernSpacing.lg,
                      vertical: ModernSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: ModernColors.positiveGradient,
                      ),
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusRound),
                    ),
                    child: Text(
                      '⭐ Reflexionador Nivel ${_calculateUserLevel()}',
                      style: ModernTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Transform.scale(
                    scale: _statsAnimation.value,
                    child: ModernProgressCard(
                      title: 'Días Activos',
                      subtitle: 'Este mes',
                      progress: 0.75 * _statsAnimation.value,
                      color: ModernColors.success,
                      icon: Icons.calendar_today,
                      trailing: '23/30',
                    ),
                  ),
                ),
                const SizedBox(width: ModernSpacing.md),
                Expanded(
                  child: Transform.scale(
                    scale: _statsAnimation.value,
                    child: ModernProgressCard(
                      title: 'Momentos Capturados',
                      subtitle: 'Total',
                      progress: 0.85 * _statsAnimation.value,
                      color: ModernColors.info,
                      icon: Icons.timeline,
                      trailing: '342',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: ModernSpacing.md),

            Row(
              children: [
                Expanded(
                  child: Transform.scale(
                    scale: _statsAnimation.value,
                    child: ModernProgressCard(
                      title: 'Racha Actual',
                      subtitle: 'Días consecutivos',
                      progress: 0.60 * _statsAnimation.value,
                      color: ModernColors.warning,
                      icon: Icons.local_fire_department,
                      trailing: '12',
                    ),
                  ),
                ),
                const SizedBox(width: ModernSpacing.md),
                Expanded(
                  child: Transform.scale(
                    scale: _statsAnimation.value,
                    child: ModernProgressCard(
                      title: 'Balance Positivo',
                      subtitle: 'Promedio',
                      progress: 0.90 * _statsAnimation.value,
                      color: ModernColors.primaryGradient.first,
                      icon: Icons.sentiment_very_satisfied,
                      trailing: '87%',
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievements() {
    return FadeTransition(
      opacity: _cardAnimation,
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏆 Logros Desbloqueados',
              style: ModernTypography.heading3,
            ),

            const SizedBox(height: ModernSpacing.lg),

            _buildAchievementItem(
              '🌟',
              'Primer Paso',
              'Completaste tu primera reflexión',
              true,
            ),

            _buildAchievementItem(
              '🔥',
              'En Racha',
              'Mantuviste una racha de 7 días',
              true,
            ),

            _buildAchievementItem(
              '💎',
              'Reflexionador Constante',
              'Completaste 30 días de reflexiones',
              false,
            ),

            _buildAchievementItem(
              '🌈',
              'Maestro del Balance',
              'Mantuviste balance positivo por 14 días',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String emoji, String title, String description, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ModernSpacing.md),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked
                  ? ModernColors.success.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
              border: Border.all(
                color: unlocked
                    ? ModernColors.success
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: unlocked ? null : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),

          const SizedBox(width: ModernSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: unlocked ? Colors.white : ModernColors.textSecondary,
                  ),
                ),
                Text(
                  description,
                  style: ModernTypography.bodySmall.copyWith(
                    color: unlocked ? ModernColors.textSecondary : ModernColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          if (unlocked)
            const Icon(
              Icons.check_circle,
              color: ModernColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return FadeTransition(
      opacity: _cardAnimation,
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚙️ Configuración',
              style: ModernTypography.heading3,
            ),

            const SizedBox(height: ModernSpacing.lg),

            _buildSettingItem(
              Icons.palette_outlined,
              'Personalizar Tema',
              'Cambia los colores y estilos',
                  () => _showThemeSelector(),
            ),

            _buildSettingItem(
              Icons.notifications_outlined,
              'Notificaciones',
              'Configura recordatorios diarios',
                  () => Navigator.pushNamed(context, '/notifications'),
            ),

            _buildSettingItem(
              Icons.backup_outlined,
              'Exportar Datos',
              'Descarga tus reflexiones',
                  () => _showExportDialog(),
            ),

            _buildSettingItem(
              Icons.info_outline,
              'Acerca de',
              'Información de la aplicación',
                  () => _showAboutDialog(),
            ),

            const SizedBox(height: ModernSpacing.lg),

            // Logout button
            ModernButton(
              text: 'Cerrar Sesión',
              onPressed: _handleLogout,
              isPrimary: false,
              width: double.infinity,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ModernSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
              ),
              child: Icon(
                icon,
                color: ModernColors.textSecondary,
                size: 20,
              ),
            ),

            const SizedBox(width: ModernSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ModernTypography.bodyLarge,
                  ),
                  Text(
                    subtitle,
                    style: ModernTypography.bodySmall,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: ModernColors.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DIALOG METHODS
  // ============================================================================

  void _showAvatarSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎭 Elige tu Avatar',
                style: ModernTypography.heading3,
              ),

              const SizedBox(height: ModernSpacing.lg),

              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: ModernSpacing.md,
                  crossAxisSpacing: ModernSpacing.md,
                ),
                itemCount: avatarEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = avatarEmojis[index];
                  final isSelected = selectedAvatar == emoji;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatar = emoji;
                      });
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: ModernAnimations.medium,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ModernColors.primaryGradient.first.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                        border: Border.all(
                          color: isSelected
                              ? ModernColors.primaryGradient.first
                              : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: ModernSpacing.lg),

              ModernButton(
                text: 'Cerrar',
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '✏️ Editar Perfil',
                style: ModernTypography.heading3,
              ),

              const SizedBox(height: ModernSpacing.lg),

              ModernTextField(
                controller: nameController,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
              ),

              const SizedBox(height: ModernSpacing.md),

              ModernTextField(
                controller: emailController,
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: ModernSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  Expanded(
                    child: ModernButton(
                      text: 'Guardar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎨 Personalizar Tema',
                style: ModernTypography.heading3,
              ),

              const SizedBox(height: ModernSpacing.lg),

              const Text(
                'Esta funcionalidad estará disponible próximamente. Podrás personalizar colores, fuentes y efectos visuales.',
                style: ModernTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ModernSpacing.xl),

              ModernButton(
                text: 'Entendido',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.download_outlined,
                color: ModernColors.info,
                size: 48,
              ),

              const SizedBox(height: ModernSpacing.lg),

              Text(
                '📥 Exportar Datos',
                style: ModernTypography.heading3,
              ),

              const SizedBox(height: ModernSpacing.md),

              const Text(
                'Descarga todas tus reflexiones y momentos en formato JSON para hacer respaldo o migrar a otra aplicación.',
                style: ModernTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ModernSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  Expanded(
                    child: ModernButton(
                      text: 'Exportar',
                      onPressed: () {
                        Navigator.pop(context);
                        // Implementar lógica de exportación
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📁 Datos exportados exitosamente'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: ModernColors.info,
                size: 48,
              ),

              const SizedBox(height: ModernSpacing.lg),

              Text(
                'ReflectApp v2.0',
                style: ModernTypography.heading3,
              ),

              const SizedBox(height: ModernSpacing.md),

              const Text(
                'Tu compañero de reflexión y crecimiento personal. Captura momentos, reflexiona sobre tu día y cultiva una mentalidad positiva.',
                style: ModernTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ModernSpacing.lg),

              const Text(
                '✨ Nueva versión con UI moderna\n🎨 Sistema de diseño mejorado\n📊 Estadísticas visuales\n🏆 Sistema de logros',
                style: ModernTypography.bodySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ModernSpacing.xl),

              ModernButton(
                text: 'Cerrar',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  int _calculateUserLevel() {
    // Lógica simplificada para calcular el nivel del usuario
    // basado en días activos, momentos capturados, etc.
    return 3; // Por ahora retornamos un valor fijo
  }

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout,
                color: ModernColors.warning,
                size: 48,
              ),

              const SizedBox(height: ModernSpacing.lg),

              Text(
                '¿Cerrar Sesión?',
                style: ModernTypography.heading3,
              ),

              const SizedBox(height: ModernSpacing.md),

              const Text(
                '¿Estás seguro de que deseas cerrar sesión? Perderás el acceso a tus reflexiones hasta que vuelvas a iniciar sesión.',
                style: ModernTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ModernSpacing.xl),

              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context, false),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.md),
                  Expanded(
                    child: ModernButton(
                      text: 'Cerrar Sesión',
                      onPressed: () => Navigator.pop(context, true),
                      gradient: ModernColors.negativeGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      }
    }
  }
}