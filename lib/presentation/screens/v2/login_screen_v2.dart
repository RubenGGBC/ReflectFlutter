// lib/presentation/screens/v2/login_screen_v2.dart - UPDATED WITH PROFILE PICTURE
// ============================================================================
// PANTALLA DE REGISTRO ACTUALIZADA CON FOTO DE PERFIL
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2>
    with TickerProviderStateMixin {

  // Controladores
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // Estado de la UI
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _selectedProfilePicture; // ✅ NUEVO: Ruta de imagen seleccionada

  // Animaciones
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ModernSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: ModernSpacing.xxl),
                    _buildHeader(),
                    const SizedBox(height: ModernSpacing.xxl),
                    _buildForm(),
                    const SizedBox(height: ModernSpacing.lg),
                    if (_errorMessage != null) ...[
                      _buildErrorMessage(),
                      const SizedBox(height: ModernSpacing.md),
                    ],
                    _buildSubmitButton(),
                    const SizedBox(height: ModernSpacing.md),
                    _buildToggleButton(),
                    const SizedBox(height: ModernSpacing.sm),
                    _buildDeveloperLoginButton(),
                    const SizedBox(height: ModernSpacing.lg),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.self_improvement,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: ModernSpacing.md),
        Text(
          _isLogin ? 'Bienvenido de vuelta' : 'Únete a nosotros',
          style: ModernTypography.headlineLarge.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ModernSpacing.sm),
        Text(
          _isLogin
              ? 'Inicia sesión para continuar tu viaje'
              : 'Crea tu cuenta y comienza tu transformación',
          style: ModernTypography.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return ModernCard(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ NUEVO: Selector de foto de perfil para registro
            if (!_isLogin) ...[
              _buildProfilePictureSelector(),
              const SizedBox(height: ModernSpacing.md),
            ],
            if (!_isLogin) ...[
              ModernTextField(
                controller: _nameController,
                labelText: 'Nombre completo',
                prefixIcon: Icons.person_outline,
                validator: (value) => value!.isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: ModernSpacing.md),
            ],
            ModernTextField(
              controller: _emailController,
              labelText: 'Correo electrónico',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) return 'Ingresa tu correo';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Correo no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: ModernSpacing.md),
            ModernTextField(
              controller: _passwordController,
              labelText: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
              suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
              validator: (value) {
                if (value!.isEmpty) return 'Ingresa tu contraseña';
                if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO: Widget para seleccionar foto de perfil
  Widget _buildProfilePictureSelector() {
    return Column(
      children: [
        Text(
          'Foto de perfil (opcional)',
          style: ModernTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ModernSpacing.sm),
        GestureDetector(
          onTap: _selectProfilePicture,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ModernColors.surface,
              border: Border.all(
                color: ModernColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _selectedProfilePicture != null
                ? ClipOval(
              child: Image.file(
                File(_selectedProfilePicture!),
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo,
                  size: 32,
                  color: ModernColors.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 4),
                Text(
                  'Agregar foto',
                  style: ModernTypography.caption.copyWith(
                    color: ModernColors.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedProfilePicture != null) ...[
          const SizedBox(height: ModernSpacing.sm),
          TextButton.icon(
            onPressed: () => setState(() => _selectedProfilePicture = null),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Quitar foto'),
            style: TextButton.styleFrom(
              foregroundColor: ModernColors.error,
            ),
          ),
        ],
      ],
    );
  }

  // ✅ NUEVO: Método para seleccionar foto de perfil
  Future<void> _selectProfilePicture() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final imagePath = await authProvider.selectProfilePicture(context);

      if (imagePath != null) {
        setState(() {
          _selectedProfilePicture = imagePath;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al seleccionar la imagen';
        });
      }
    }
  }

  Widget _buildSubmitButton() {
    final authProvider = context.watch<OptimizedAuthProvider>();

    return ModernButton(
      text: _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
      isLoading: authProvider.isLoading,
      onPressed: _handleSubmit,
      width: double.infinity,
    );
  }

  Widget _buildToggleButton() {
    final authProvider = context.watch<OptimizedAuthProvider>();

    return TextButton(
      onPressed: authProvider.isLoading ? null : () {
        setState(() {
          _isLogin = !_isLogin;
          _errorMessage = null;
          _selectedProfilePicture = null; // ✅ NUEVO: Limpiar foto al cambiar modo
          _formKey.currentState?.reset();
        });
      },
      child: RichText(
        text: TextSpan(
          text: _isLogin
              ? '¿No tienes cuenta? '
              : '¿Ya tienes cuenta? ',
          style: ModernTypography.bodyMedium,
          children: [
            TextSpan(
              text: _isLogin ? 'Regístrate' : 'Inicia sesión',
              style: ModernTypography.bodyMedium.copyWith(
                color: ModernColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperLoginButton() {
    final authProvider = context.watch<OptimizedAuthProvider>();

    return TextButton(
      onPressed: authProvider.isLoading ? null : () async {
        final success = await authProvider.loginAsDeveloper();
        if (success && mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        } else if (mounted) {
          setState(() {
            _errorMessage = authProvider.errorMessage ?? 'Error en el login de desarrollador.';
          });
        }
      },
      child: Text(
        '🚀 Iniciar como Desarrollador',
        style: ModernTypography.bodyMedium.copyWith(
          color: ModernColors.accentGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return ModernCard(
      backgroundColor: ModernColors.error.withOpacity(0.15),
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: ModernColors.error, size: 20),
          const SizedBox(width: ModernSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: ModernTypography.bodyMedium.copyWith(color: ModernColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.',
      style: ModernTypography.caption,
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      bool success = false;

      if (_isLogin) {
        success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // ✅ NUEVO: Incluir foto de perfil en el registro
        success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          profilePicturePath: _selectedProfilePicture, // ✅ NUEVO
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Error desconocido';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error durante ${_isLogin ? 'el login' : 'el registro'}';
        });
      }
    }
  }
}