// ============================================================================
// presentation/screens/v2/profile_screen_v2.dart - ACTUALIZADA PARA PROVIDERS OPTIMIZADOS - FIXED
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// Servicios
import '../../../data/services/optimized_database_service.dart';

class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2>
    with TickerProviderStateMixin {

  // Controladores de formulario
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  // Estado
  bool _isEditing = false;
  bool _isLoading = false;
  String _selectedAvatar = '🧘‍♀️';
  Map<String, dynamic> _userStats = {};

  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Lista de avatares disponibles
  final List<String> _availableAvatars = [
    '🧘‍♀️', '🧘‍♂️', '😊', '😎', '🌟', '🦋', '🌸', '🌺',
    '🎨', '📚', '🎵', '⚡', '🌈', '🦄', '🐱', '🦊',
    '🌙', '☀️', '🔥', '❄️', '🌊', '🌿', '🍃', '💎'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
    _loadUserStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
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

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _loadUserData() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio;
      _selectedAvatar = user.avatarEmoji;
    }
  }

  Future<void> _loadUserStats() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    try {
      // Cargar estadísticas del usuario usando analytics provider
      final analyticsProvider = context.read<OptimizedAnalyticsProvider>();
      await analyticsProvider.loadCompleteAnalytics(user.id, days: 90);

      // Cargar estadísticas adicionales usando la base de datos directamente
      final dbService = OptimizedDatabaseService();
      final analytics = await dbService.getUserAnalytics(user.id, days: 90);

      if (mounted) {
        setState(() {
          _userStats = {
            ...analytics,
            'member_since': user.createdAt,
            'last_activity': user.lastLogin,
          };
        });
      }
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // FIX: Usar LinearGradient en lugar de Gradient directamente
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                        _buildStatsCard(),
                        const SizedBox(height: 16),
                        _buildAchievementsCard(),
                        const SizedBox(height: 16),
                        _buildPreferencesCard(),
                        const SizedBox(height: 16),
                        _buildActionsCard(),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          // FIX: Usar LinearGradient
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ModernColors.primaryGradient,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '👤 Mi Perfil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: _isEditing ? _saveProfile : _toggleEditing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar del usuario
          GestureDetector(
            onTap: _isEditing ? _showAvatarSelector : null,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // FIX: Usar LinearGradient
                gradient: LinearGradient(
                  colors: ModernColors.primaryGradient,
                ),
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
                  _selectedAvatar,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 8),
            const Text(
              'Toca para cambiar avatar',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Nombre del usuario
          _isEditing
              ? _buildEditableField(
            controller: _nameController,
            label: 'Nombre',
            icon: Icons.person_outline,
          )
              : Text(
            _nameController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Bio del usuario
          _isEditing
              ? _buildEditableField(
            controller: _bioController,
            label: 'Biografía',
            icon: Icons.description_outlined,
            maxLines: 3,
          )
              : Text(
            _bioController.text.isEmpty
                ? 'Sin biografía'
                : _bioController.text,
            style: TextStyle(
              color: _bioController.text.isEmpty
                  ? Colors.white38
                  : Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Información de miembro
          _buildMemberInfo(),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMemberInfo() {
    final user = context.read<OptimizedAuthProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    final memberSince = user.createdAt;
    final daysSinceMember = DateTime.now().difference(memberSince).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Miembro desde',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${_formatDate(memberSince)} ($daysSinceMember días)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_userStats.isEmpty) {
      return _buildLoadingCard('Cargando estadísticas...');
    }

    final basicStats = _userStats['basic_stats'] as Map<String, dynamic>? ?? {};
    final streakData = _userStats['streak_data'] as Map<String, dynamic>? ?? {};

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
              Icon(Icons.analytics, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Estadísticas Personales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primera fila de estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '📝',
                  value: '${basicStats['total_entries'] ?? 0}',
                  label: 'Entradas',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🔥',
                  value: '${streakData['current_streak'] ?? 0}',
                  label: 'Racha Actual',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🏆',
                  value: '${streakData['longest_streak'] ?? 0}',
                  label: 'Mejor Racha',
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Segunda fila de estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '😊',
                  value: '${((basicStats['avg_mood'] as double?) ?? 0).toStringAsFixed(1)}',
                  label: 'Mood Prom.',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '⚡',
                  value: '${((basicStats['avg_energy'] as double?) ?? 0).toStringAsFixed(1)}',
                  label: 'Energía Prom.',
                  color: Colors.yellow,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🧘',
                  value: '${((basicStats['total_meditation'] as double?) ?? 0).toInt()}',
                  label: 'Min. Meditación',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
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
          Text(icon, style: const TextStyle(fontSize: 20)),
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
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
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
              Icon(Icons.emoji_events, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Logros Desbloqueados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildAchievements(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievements() {
    final achievements = _calculateAchievements();

    return achievements.map((achievement) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: achievement['unlocked']
              ? achievement['color'].withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: achievement['unlocked']
                ? achievement['color']
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement['icon'],
              style: TextStyle(
                fontSize: 16,
                // FIX: Usar solo opacity en el estilo del texto
                color: Colors.white.withOpacity(achievement['unlocked'] ? 1.0 : 0.3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              achievement['name'],
              style: TextStyle(
                color: achievement['unlocked']
                    ? achievement['color']
                    : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _calculateAchievements() {
    final basicStats = _userStats['basic_stats'] as Map<String, dynamic>? ?? {};
    final streakData = _userStats['streak_data'] as Map<String, dynamic>? ?? {};

    final totalEntries = basicStats['total_entries'] as int? ?? 0;
    final currentStreak = streakData['current_streak'] as int? ?? 0;
    final longestStreak = streakData['longest_streak'] as int? ?? 0;
    final avgMood = basicStats['avg_mood'] as double? ?? 0;
    final totalMeditation = basicStats['total_meditation'] as double? ?? 0;

    return [
      {
        'icon': '🌱',
        'name': 'Primer Paso',
        'unlocked': totalEntries >= 1,
        'color': Colors.green,
      },
      {
        'icon': '📚',
        'name': 'Escritor',
        'unlocked': totalEntries >= 10,
        'color': Colors.blue,
      },
      {
        'icon': '🔥',
        'name': 'Constante',
        'unlocked': currentStreak >= 7,
        'color': Colors.orange,
      },
      {
        'icon': '💎',
        'name': 'Dedicado',
        'unlocked': longestStreak >= 30,
        'color': Colors.purple,
      },
      {
        'icon': '😊',
        'name': 'Optimista',
        'unlocked': avgMood >= 7,
        'color': Colors.yellow,
      },
      {
        'icon': '🧘',
        'name': 'Zen',
        'unlocked': totalMeditation >= 300,
        'color': Colors.indigo,
      },
      {
        'icon': '🏆',
        'name': 'Maestro',
        'unlocked': totalEntries >= 100,
        'color': Colors.amber,
      },
    ];
  }

  Widget _buildPreferencesCard() {
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
              Icon(Icons.settings, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Preferencias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildPreferenceItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Recordatorios diarios',
            onTap: () {
              // Implementar configuración de notificaciones
            },
          ),

          _buildPreferenceItem(
            icon: Icons.palette_outlined,
            title: 'Tema',
            subtitle: 'Personalizar apariencia',
            onTap: () {
              // Implementar selector de tema
            },
          ),

          _buildPreferenceItem(
            icon: Icons.backup_outlined,
            title: 'Respaldo de datos',
            subtitle: 'Exportar y sincronizar',
            onTap: () {
              // Implementar backup
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white54, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white54,
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionsCard() {
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
              Icon(Icons.settings_applications, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Acciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                'Exportar mis datos',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDeleteDataDialog,
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text(
                'Eliminar todos mis datos',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.white),
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
      ),
    );
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('El nombre no puede estar vacío', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<OptimizedAuthProvider>();

      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarEmoji: _selectedAvatar,
      );

      if (success) {
        setState(() => _isEditing = false);
        _showSnackBar('Perfil actualizado exitosamente');
      } else {
        _showSnackBar(
          authProvider.errorMessage ?? 'Error al actualizar perfil',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error inesperado: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAvatarSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Selecciona tu avatar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _availableAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _availableAvatars[index];
                  final isSelected = avatar == _selectedAvatar;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = avatar);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? ModernColors.primaryGradient.first.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: isSelected
                              ? ModernColors.primaryGradient.first
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    _showSnackBar('Función de exportación en desarrollo');
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          '⚠️ Eliminar todos los datos',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción eliminará permanentemente todos tus datos, incluyendo entradas, momentos y estadísticas. ¿Estás seguro?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar Todo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    // Implementar eliminación de datos
    _showSnackBar('Función de eliminación en desarrollo');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          '👋 Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.primaryGradient.first,
            ),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}