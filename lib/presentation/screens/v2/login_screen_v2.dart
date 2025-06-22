// ============================================================================
// presentation/screens/v2/login_screen_v2.dart - ACTUALIZADA Y CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

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

  // Controladores de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Estado
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Controladores de animación
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
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
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
            colors: [
              ModernColors.darkPrimary,
              ModernColors.darkSecondary,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ModernSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: ModernSpacing.xl),
                      _buildForm(),
                      const SizedBox(height: ModernSpacing.lg),
                      _buildSubmitButton(),
                      const SizedBox(height: ModernSpacing.md),
                      _buildToggleButton(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: ModernSpacing.md),
                        _buildErrorMessage(),
                      ],
                      const SizedBox(height: ModernSpacing.lg),
                      _buildFooter(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // FIX: Correctly use LinearGradient for the gradient property
            gradient: const LinearGradient(colors: ModernColors.primaryGradient),
            boxShadow: [
              BoxShadow(
                color: ModernColors.primaryGradient.first.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: ModernSpacing.lg),
        Text(
          'Reflect',
          // FIX: Use ModernTypography and fix shader creation
          style: ModernTypography.heading1.copyWith(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: ModernColors.primaryGradient,
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: ModernSpacing.sm),
        Text(
          _isLogin
              ? 'Bienvenido de vuelta a tu espacio'
              : 'Comienza tu viaje de autoconocimiento',
          // FIX: Use ModernTypography
          style: ModernTypography.bodyLarge.copyWith(color: ModernColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ModernCard(
        blur: false,
        backgroundColor: ModernColors.surfaceDark.withOpacity(0.5),
        child: Column(
          children: [
            if (!_isLogin) ...[
              ModernTextField(
                controller: _nameController,
                labelText: 'Nombre completo',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
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


  Widget _buildSubmitButton() {
    // We get the provider but we only use it to get the loading state
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
          _formKey.currentState?.reset();
        });
      },
      child: RichText(
        text: TextSpan(
          text: _isLogin
              ? '¿No tienes cuenta? '
          // FIX: Use ModernTypography
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
      // FIX: Use ModernTypography
      style: ModernTypography.caption,
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleSubmit() async {
    // First, clear any previous error messages
    setState(() => _errorMessage = null);

    // Validate the form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Use the provider to handle the logic
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
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else if (mounted) {
        // If it fails, the provider's errorMessage will be updated.
        // The Consumer/watch will rebuild the UI to show the error.
        setState(() {
          _errorMessage = authProvider.errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error inesperado. Inténtalo de nuevo.';
        });
      }
    }
  }
}
