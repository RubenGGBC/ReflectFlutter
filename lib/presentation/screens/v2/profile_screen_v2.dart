// lib/presentation/screens/v2/profile_screen_v2.dart
// ============================================================================
// PROFILE SCREEN V2 - ESTILO MINIMALISTA NEGRO CON GRADIENTES AZUL-MORADO
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// ============================================================================
// MISMA PALETA DE COLORES MINIMALISTA DE HOME Y ANALYTICS
// ============================================================================
class ProfileColors {
  // Fondo principal - Negro profundo
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  // Gradientes Azul Oscuro a Morado (idénticos a HomeScreen)
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

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF666666);
}

class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  String _selectedAvatar = '😊';
  String? _selectedProfilePicture;
  bool _useProfilePicture = false;

  // ============================================================================
  // ANIMACIONES
  // ============================================================================
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _avatarController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _avatarAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _avatarController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _avatarAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _avatarController.forward();
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<OptimizedAuthProvider>().currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.name ?? '';
          _bioController.text = user.bio ?? '';
          _selectedAvatar = user.avatarEmoji;
          _selectedProfilePicture = user.profilePicturePath;
          _useProfilePicture = user.hasProfilePicture;
        });
        context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id, days: 90);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final analyticsProvider = context.watch<OptimizedAnalyticsProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: ProfileColors.backgroundPrimary,
        body: Center(
          child: Text(
            'Error: Usuario no encontrado.',
            style: ModernTypography.bodyLarge.copyWith(color: ProfileColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ProfileColors.backgroundPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ModernSpacing.lg),
              child: Column(
                children: [
                  _buildMinimalHeader(),
                  const SizedBox(height: ModernSpacing.xl),
                  _buildProfileCard(),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildStatsCard(analyticsProvider),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildSettingsCard(),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildActionsCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER MINIMALISTA (igual que HomeScreen)
  // ============================================================================
  Widget _buildMinimalHeader() {
    final authProvider = context.watch<OptimizedAuthProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Título con gradiente
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: ProfileColors.accentGradient,
          ).createShader(bounds),
          child: const Text(
            'Mi Perfil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Botón de editar/guardar
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: ProfileColors.lightGradient,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ProfileColors.lightGradient[0].withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: authProvider.isLoading
                  ? null
                  : (_isEditing ? _saveProfile : _toggleEditing),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: authProvider.isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // CARD DE PERFIL PRINCIPAL
  // ============================================================================
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ProfileColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          ScaleTransition(
            scale: _avatarAnimation,
            child: _buildAvatarSection(),
          ),

          const SizedBox(height: 24),

          // Nombre
          _isEditing
              ? _buildEditableField(
            controller: _nameController,
            label: 'Nombre',
            icon: Icons.person_outline,
          )
              : Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Sin nombre',
            style: const TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Bio
          _isEditing
              ? _buildEditableField(
            controller: _bioController,
            label: 'Biografía',
            icon: Icons.description_outlined,
            maxLines: 3,
          )
              : Text(
            _bioController.text.isNotEmpty ? _bioController.text : 'Sin biografía',
            style: TextStyle(
              color: _bioController.text.isNotEmpty
                  ? ProfileColors.textSecondary
                  : ProfileColors.textHint,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECCIÓN DE AVATAR
  // ============================================================================
  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _showAvatarOptions : null,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: ProfileColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: ProfileColors.primaryGradient[1].withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ProfileColors.backgroundCard,
              ),
              child: ClipOval(
                child: _buildAvatarContent(),
              ),
            ),
          ),
        ),

        if (_isEditing) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatarTypeButton(
                icon: Icons.emoji_emotions,
                label: 'Emoji',
                isSelected: !_useProfilePicture,
                onTap: () => setState(() => _useProfilePicture = false),
              ),
              const SizedBox(width: 16),
              _buildAvatarTypeButton(
                icon: Icons.photo_camera,
                label: 'Foto',
                isSelected: _useProfilePicture,
                onTap: _showPhotoOptions,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (_useProfilePicture && _selectedProfilePicture != null) {
      return Image.file(
        File(_selectedProfilePicture!),
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: ProfileColors.accentGradient,
        ),
      ),
      child: Center(
        child: Text(
          _selectedAvatar,
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }

  Widget _buildAvatarTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: ProfileColors.accentGradient)
              : null,
          color: isSelected ? null : ProfileColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // CAMPO EDITABLE
  // ============================================================================
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ProfileColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ProfileColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: ProfileColors.textHint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Ingresa tu $label...',
              hintStyle: const TextStyle(
                color: ProfileColors.textHint,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // CARD DE ESTADÍSTICAS
  // ============================================================================
  Widget _buildStatsCard(OptimizedAnalyticsProvider analyticsProvider) {
    final stats = analyticsProvider.getDashboardSummary();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProfileColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Resumen de Actividad',
            style: TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '🔥',
                  'Racha',
                  '${stats['current_streak'] ?? 0} días',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '📝',
                  'Entradas',
                  '${stats['total_entries'] ?? 0}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '😊',
                  'Mood Promedio',
                  '${(stats['avg_mood'] ?? 0).toStringAsFixed(1)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: ProfileColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: ProfileColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // CONFIGURACIONES Y ACCIONES
  // ============================================================================
  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProfileColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Configuración',
            style: TextStyle(
              color: ProfileColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Gestionar recordatorios',
            onTap: () {
              _showSnackBar('Próximamente disponible');
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidad',
            subtitle: 'Configurar privacidad de datos',
            onTap: () {
              _showSnackBar('Próximamente disponible');
            },
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Ayuda',
            subtitle: 'Centro de soporte',
            onTap: () {
              _showSnackBar('Próximamente disponible');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: ProfileColors.lightGradient,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: ProfileColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: ProfileColors.textSecondary,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: ProfileColors.textHint,
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ProfileColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFdc2626), Color(0xFFef4444)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFdc2626).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLogoutDialog,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE ACCIÓN
  // ============================================================================
  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) _loadUserData();
    });
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    try {
      final success = await authProvider.updateProfile(
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        bio: _bioController.text,
        avatarEmoji: _selectedAvatar,
        profilePicturePath: _useProfilePicture ? _selectedProfilePicture : '',
      );

      if (success) {
        setState(() => _isEditing = false);
        _showSnackBar('✅ Perfil actualizado exitosamente');
      } else {
        _showSnackBar('❌ Error al actualizar perfil', isError: true);
      }
    } catch (e) {
      _showSnackBar('❌ Error al actualizar perfil', isError: true);
    }
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProfileColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Avatar',
              style: TextStyle(
                color: ProfileColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: ['😊', '🤗', '😎', '🥳', '🤓', '😌', '🙂', '😄']
                  .map((emoji) => GestureDetector(
                onTap: () {
                  setState(() => _selectedAvatar = emoji);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedAvatar == emoji
                        ? ProfileColors.accentGradient[0]
                        : ProfileColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProfileColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Foto',
              style: TextStyle(
                color: ProfileColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Tomar foto',
                style: TextStyle(color: ProfileColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Elegir de galería',
                style: TextStyle(color: ProfileColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedProfilePicture = image.path;
        _useProfilePicture = true;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProfileColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '👋 Cerrar Sesión',
          style: TextStyle(color: ProfileColors.textPrimary),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: ProfileColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: ProfileColors.textHint),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFdc2626), Color(0xFFef4444)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<OptimizedAuthProvider>().logout();
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFdc2626)
            : ProfileColors.accentGradient[0],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}