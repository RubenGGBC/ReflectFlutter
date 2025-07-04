// lib/presentation/screens/v2/login_screen_v2.dart
// ✅ VERSIÓN CORREGIDA CON NOMBRES EXACTOS DEL DESIGN SYSTEM

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Providers
import '../../providers/optimized_providers.dart';

// Navigation Screen - ✅ IMPORTACIÓN AGREGADA
import 'main_navigation_screen_v2.dart';

// Componentes modernos - ✅ USANDO TU SISTEMA EXISTENTE
import '../components/modern_design_system.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> with TickerProviderStateMixin {
  // ✅ CONTROLADORES Y ESTADO
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedProfilePicture;

  // ✅ ANIMACIONES
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
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
            colors: ModernColors.primaryGradient, // ✅ USANDO TU GRADIENTE EXISTENTE
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
              ? 'Accede a tu espacio de reflexión personal'
              : 'Comienza tu viaje de autodescubrimiento',
          style: ModernTypography.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            ModernTextField(
              controller: _nameController,
              labelText: 'Nombre completo',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: ModernSpacing.md),
            _buildProfilePictureSelector(),
            const SizedBox(height: ModernSpacing.md),
          ],
          ModernTextField(
            controller: _emailController,
            labelText: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Por favor ingresa tu correo';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: ModernSpacing.md),
          ModernTextField(
            controller: _passwordController,
            labelText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Por favor ingresa tu contraseña';
              }
              if (!_isLogin && (value!.length < 6)) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto de perfil (opcional)',
          style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: ModernSpacing.sm),
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ModernColors.glassPrimary,
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium), // ✅ CORREGIDO
                  border: Border.all(color: ModernColors.borderPrimary),
                ),
                child: _selectedProfilePicture != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium), // ✅ CORREGIDO
                  child: Image.file(
                    File(_selectedProfilePicture!),
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.white60,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: ModernSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedProfilePicture != null
                        ? 'Foto seleccionada'
                        : 'Toca para agregar una foto',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (_selectedProfilePicture != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedProfilePicture = null),
                      child: Text(
                        'Eliminar',
                        style: ModernTypography.bodyMedium.copyWith(
                          color: ModernColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedProfilePicture = pickedFile.path;
      });
    }
  }

  Widget _buildSubmitButton() {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final isLoading = authProvider.isLoading || _isLoading;

    return ModernButton(
      text: _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
      onPressed: isLoading ? null : _handleSubmit,
      isLoading: isLoading,
      isPrimary: true,
    );
  }

  Widget _buildToggleButton() {
    return InkWell(
      onTap: _isLoading ? null : () {
        setState(() {
          _isLogin = !_isLogin;
          _errorMessage = null;
          _selectedProfilePicture = null;
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
          // ✅ ARREGLADO: Navegación corregida usando MaterialPageRoute
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreenV2(),
            ),
          );
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

  // ✅ ARREGLADO: Navegación corregida también aquí
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
        success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          profilePicturePath: _selectedProfilePicture,
        );
      }

      if (success && mounted) {
        // ✅ ARREGLADO: Navegación corregida usando MaterialPageRoute
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreenV2(),
          ),
        );
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