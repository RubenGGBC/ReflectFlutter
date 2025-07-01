// lib/presentation/screens/v2/profile_screen_v2.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/optimized_providers.dart';
import '../components/modern_design_system.dart';

class ProfileScreenV2 extends StatefulWidget {
  const ProfileScreenV2({super.key});

  @override
  State<ProfileScreenV2> createState() => _ProfileScreenV2State();
}

class _ProfileScreenV2State extends State<ProfileScreenV2> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isEditing = false;
  String _selectedAvatar = '🧘‍♀️';
  String? _selectedProfilePicture;
  bool _useProfilePicture = false;

  late AnimationController _fadeController, _slideController, _avatarController;
  late Animation<double> _fadeAnimation, _avatarAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _availableAvatars = [
    '🧘‍♀️', '🧘‍♂️', '😊', '😎', '🌟', '🦋', '🌸', '🌺', '🎨', '📚', '🎵', '⚡', '🌈', '🦄', '🐱', '🦊', '🌙', '☀️', '🔥', '❄️', '🌊', '🌿', '🍃', '💎'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _avatarController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    _avatarAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
        _avatarController.forward();
      }
    });
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<OptimizedAuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
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
      return Scaffold(body: Center(child: Text('Error: Usuario no encontrado.', style: ModernTypography.bodyLarge)));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: ModernColors.primaryGradient)),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ModernSpacing.lg),
                child: Column(
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: ModernSpacing.xl),
                    _buildProfileCard(),
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
      ),
    );
  }

  Widget _buildAppBar() {
    final authProvider = context.watch<OptimizedAuthProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Mi Perfil', style: ModernTypography.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        IconButton(
          icon: authProvider.isLoading
              ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
          onPressed: authProvider.isLoading ? null : (_isEditing ? _saveProfile : _toggleEditing),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          ScaleTransition(scale: _avatarAnimation, child: _buildAvatarSection()),
          const SizedBox(height: 24),
          _isEditing
              ? _buildEditableField(controller: _nameController, label: 'Nombre', icon: Icons.person_outline)
              : Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _isEditing
              ? _buildEditableField(controller: _bioController, label: 'Biografía', icon: Icons.description_outlined, maxLines: 3)
              : Text(_bioController.text.isEmpty ? 'Sin biografía' : _bioController.text,
              style: TextStyle(color: _bioController.text.isEmpty ? Colors.white54 : Colors.white, fontSize: 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _showAvatarOptions : null,
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF10B981), Color(0xFFF59E0B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              padding: const EdgeInsets.all(3),
              child: ClipOval(child: _buildAvatarContent()),
            ),
          ),
        ),
        if (_isEditing) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatarTypeButton(icon: Icons.emoji_emotions, label: 'Emoji', isSelected: !_useProfilePicture, onTap: () => setState(() => _useProfilePicture = false)),
              const SizedBox(width: 16),
              _buildAvatarTypeButton(icon: Icons.photo_camera, label: 'Foto', isSelected: _useProfilePicture, onTap: () => _showPhotoOptions()),
            ],
          ),
          const SizedBox(height: 8),
          Text(_useProfilePicture ? 'Toca para cambiar foto' : 'Toca para cambiar emoji', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (_useProfilePicture && _selectedProfilePicture != null && _selectedProfilePicture!.isNotEmpty) {
      return Image.file(File(_selectedProfilePicture!), fit: BoxFit.cover, width: 113, height: 113,
          errorBuilder: (context, error, stackTrace) => _buildEmojiAvatar());
    } else {
      return _buildEmojiAvatar();
    }
  }

  Widget _buildEmojiAvatar() {
    return Container(
      width: 113, height: 113,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: ModernColors.primaryGradient)),
      child: Center(child: Text(_selectedAvatar, style: const TextStyle(fontSize: 48))),
    );
  }

  Widget _buildAvatarTypeButton({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white.withOpacity(0.4) : Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions() {
    if (_useProfilePicture) _showPhotoOptions();
    else _showEmojiSelector();
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(padding: EdgeInsets.all(20), child: Text('📸 Foto de perfil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _selectProfilePicture();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galería', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  await _selectProfilePicture();
                },
              ),
              if (_selectedProfilePicture != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Quitar foto', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedProfilePicture = null;
                      _useProfilePicture = false;
                    });
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(20), child: Text('Selecciona tu avatar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 12, mainAxisSpacing: 12),
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
                        color: isSelected ? ModernColors.primaryGradient.first.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                        border: Border.all(color: isSelected ? ModernColors.primaryGradient.first : Colors.transparent, width: 2),
                      ),
                      child: Center(child: Text(avatar, style: const TextStyle(fontSize: 24))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProfilePicture() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final imagePath = await authProvider.selectProfilePicture(context);
      if (imagePath != null) {
        setState(() {
          _selectedProfilePicture = imagePath;
          _useProfilePicture = true;
        });
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar la imagen', isError: true);
    }
  }

  Widget _buildEditableField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1)),
      child: TextField(
        controller: controller, maxLines: maxLines, style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70), border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }


  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1), width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚙️ Configuración', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSettingItem(Icons.notifications_outlined, 'Notificaciones', 'Gestionar alertas', () {}),
          _buildSettingItem(Icons.palette_outlined, 'Tema', 'Personalizar apariencia', () {}),
          _buildSettingItem(Icons.download_outlined, 'Exportar datos', 'Descargar tu información', () {}),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.white54, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1), width: 1)),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.2), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditing() => setState(() {
    _isEditing = !_isEditing;
    if (!_isEditing) _loadUserData();
  });

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
        _showSnackBar('Perfil actualizado exitosamente');
      } else {
        _showSnackBar('Error al actualizar perfil', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error al actualizar perfil', isError: true);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('👋 Cerrar Sesión', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<OptimizedAuthProvider>().logout();
              if (mounted) Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green, duration: const Duration(seconds: 3)),
    );
  }
}