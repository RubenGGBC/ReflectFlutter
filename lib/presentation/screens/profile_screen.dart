// ============================================================================
// presentation/screens/profile_screen.dart - Pantalla de Perfil
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/themed_button.dart';
import '../widgets/themed_container.dart';
import '../../data/services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  // Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  // Estado
  bool _isLoading = false;
  bool _isEditing = false;
  String _selectedAvatar = '🧘‍♀️';
  Map<String, dynamic> _userStats = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E1A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileCard(authProvider),
                    const SizedBox(height: 16),
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    _buildActionsCard(authProvider),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 4),
                Text('Volver', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const Expanded(
            child: Text(
              '👤 Mi Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider authProvider) {
    final user = authProvider.currentUser!;

    return ThemedContainer(
      child: Column(
        children: [
          // Avatar y datos básicos
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: _isEditing ? _showAvatarSelector : null,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _selectedAvatar,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Información básica
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing) ...[
                      CustomTextField(
                        controller: _nameController,
                        label: 'Nombre',
                        hint: 'Tu nombre',
                      ),
                    ] else ...[
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bio
          if (_isEditing) ...[
            CustomTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Cuéntanos sobre ti...',
              maxLines: 3,
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF141B2D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3A8A)),
              ),
              child: Text(
                user.bio?.isNotEmpty == true ? user.bio! : 'Sin descripción',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              if (_isEditing) ...[
                Expanded(
                  child: ThemedButton(
                    onPressed: _cancelEdit,
                    type: ThemedButtonType.outlined,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThemedButton(
                    onPressed: _saveProfile,
                    isLoading: _isLoading,
                    child: const Text('Guardar'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ThemedButton(
                    onPressed: _startEdit,
                    type: ThemedButtonType.outlined,
                    child: const Text('Editar Perfil'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Grid de estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '📝',
                  value: _userStats['total_entries']?.toString() ?? '0',
                  label: 'Entradas',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '✨',
                  value: _userStats['positive_count']?.toString() ?? '0',
                  label: 'Positivos',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🔥',
                  value: _userStats['streak_days']?.toString() ?? '0',
                  label: 'Racha',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '💭',
                  value: _userStats['total_words']?.toString() ?? '0',
                  label: 'Palabras',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🎭',
                  value: _userStats['avg_mood_score']?.toStringAsFixed(1) ?? '5.0',
                  label: 'Mood Prom.',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '📅',
                  value: _userStats['entries_this_month']?.toString() ?? '0',
                  label: 'Este Mes',
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
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B82F6),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(AuthProvider authProvider) {
    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Acciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Botón de logout
          ThemedButton(
            onPressed: () => _showLogoutDialog(authProvider),
            type: ThemedButtonType.negative,
            width: double.infinity,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🚪', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text('Cerrar Sesión'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE NEGOCIO
  // ============================================================================

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _selectedAvatar = user.avatarEmoji;
    }
  }

  Future<void> _loadUserStats() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final stats = await _databaseService.getUserComprehensiveStatistics(
          authProvider.currentUser!.id!
      );

      setState(() {
        _userStats = stats;
      });

    } catch (e) {
      _logger.e('Error cargando estadísticas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startEdit() {
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    _loadUserData(); // Recargar datos originales
    setState(() => _isEditing = false);
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();

    setState(() => _isLoading = true);

    try {
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        avatarEmoji: _selectedAvatar,
        bio: _bioController.text.trim(),
      );

      if (success) {
        setState(() => _isEditing = false);
        _showMessage('✅ Perfil actualizado correctamente');
        await _loadUserStats(); // Recargar estadísticas
      } else {
        _showMessage('❌ Error actualizando perfil', isError: true);
      }

    } catch (e) {
      _logger.e('Error guardando perfil: $e');
      _showMessage('❌ Error guardando perfil', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAvatarSelector() {
    const avatars = [
      '🧘‍♀️', '🧘‍♂️', '🦋', '🌸', '🌟', '✨',
      '🌿', '🌊', '🔮', '💎', '🦄', '🐱',
      '🐶', '🐰', '🦊', '🐼', '🐨', '🦉'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        title: const Text(
          'Elige tu avatar',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 280,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              final avatar = avatars[index];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAvatar = avatar);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedAvatar == avatar
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141B2D),
        title: const Text(
          '🚪 Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ThemedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            type: ThemedButtonType.negative,
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}