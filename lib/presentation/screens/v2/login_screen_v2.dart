// ============================================================================
// login_screen_v2.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../components/modern_design_system.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _heroController;
  late AnimationController _formController;
  late AnimationController _particleController;

  late Animation<double> _heroAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Hero animation - Gradiente de fondo
    _heroController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Form animation - Elementos del formulario
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Particle animation - Elementos flotantes
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeInOut),
    );

    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic));

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    _heroController.repeat(reverse: true);
    _particleController.repeat();

    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _formController.dispose();
    _particleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0a0e27),
                  const Color(0xFF667eea),
                  _heroAnimation.value * 0.3,
                )!,
                Color.lerp(
                  const Color(0xFF2d1b69),
                  const Color(0xFF764ba2),
                  _heroAnimation.value * 0.2,
                )!,
                Color.lerp(
                  const Color(0xFF11998e),
                  const Color(0xFF38ef7d),
                  _heroAnimation.value * 0.1,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final offset = Offset(
              (index * 0.7 + _particleAnimation.value) % 1.2 - 0.1,
              (index * 0.3 + _particleAnimation.value * 0.5) % 1.2 - 0.1,
            );

            return Positioned(
              left: MediaQuery.of(context).size.width * offset.dx,
              top: MediaQuery.of(context).size.height * offset.dy,
              child: Opacity(
                opacity: 0.1 + (index % 3) * 0.1,
                child: Container(
                  width: 20 + (index % 4) * 10,
                  height: 20 + (index % 4) * 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25), // FIX: withOpacity -> withAlpha
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(12), // FIX: withOpacity -> withAlpha
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: ModernSpacing.xxl),
            _buildHeroSection(),
            const SizedBox(height: ModernSpacing.xxl),
            _buildLoginForm(),
            const SizedBox(height: ModernSpacing.xl),
            _buildBottomActions(),
            const SizedBox(height: ModernSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _formAnimation,
        child: Column(
          children: [
            // Logo animado
            ScaleTransition(
              scale: _formAnimation,
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
                child: const Icon(
                  Icons.self_improvement,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: ModernSpacing.xl),

            // Título principal
            Text(
              'Bienvenido de vuelta',
              style: ModernTypography.heading1.copyWith(
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ModernSpacing.sm),

            // Subtítulo
            Text(
              'Continúa tu viaje de reflexión y crecimiento personal',
              style: ModernTypography.bodyLarge.copyWith(
                color: ModernColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _formAnimation,
        child: ModernCard(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email field con validación en tiempo real
                ModernTextField(
                  controller: _emailController,
                  labelText: 'Correo electrónico',
                  hintText: 'tu@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                const SizedBox(height: ModernSpacing.lg),

                // Password field
                ModernTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                ),

                const SizedBox(height: ModernSpacing.md),

                // Remember me & Forgot password
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: ModernColors.primaryGradient.first,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Text(
                            'Recordarme',
                            style: ModernTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: ModernTypography.bodyMedium.copyWith(
                          color: ModernColors.primaryGradient.first,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ModernSpacing.xl),

                // Login button con loading state
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ModernButton(
                      text: 'Iniciar Sesión',
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      isLoading: authProvider.isLoading,
                      gradient: ModernColors.primaryGradient,
                      width: double.infinity,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _formAnimation,
        child: Column(
          children: [
            // Divider con texto
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.white.withAlpha(51), // FIX: withOpacity -> withAlpha
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.md),
                  child: Text(
                    'o',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: ModernColors.textHint,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.white.withAlpha(51), // FIX: withOpacity -> withAlpha
                  ),
                ),
              ],
            ),

            const SizedBox(height: ModernSpacing.xl),

            // Register button
            ModernButton(
              text: 'Crear cuenta nueva',
              onPressed: () => Navigator.pushNamed(context, '/register'),
              isPrimary: false,
              width: double.infinity,
            ),

            const SizedBox(height: ModernSpacing.md),

            // Demo button
            TextButton(
              onPressed: _createDemoAccount,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.science_outlined,
                    color: ModernColors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  Text(
                    'Probar con cuenta demo',
                    style: ModernTypography.bodyMedium.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Introduce un correo electrónico válido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  // ============================================================================
  // ACTION METHODS
  // ============================================================================

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // FIX: Changed call from named parameters to positional parameters
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navegar con animación suave
        Navigator.pushReplacementNamed(context, '/home');

        // Mostrar mensaje de bienvenida
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: ModernSpacing.sm),
                Text(
                  '¡Bienvenido de vuelta, ${authProvider.currentUser?.name ?? 'Usuario'}!',
                  style: ModernTypography.bodyMedium,
                ),
              ],
            ),
            backgroundColor: ModernColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
            ),
            margin: const EdgeInsets.all(ModernSpacing.md),
          ),
        );
      } else if (mounted) {
        _showErrorDialog('Credenciales incorrectas. Por favor, verifica tu email y contraseña.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error de conexión. Por favor, inténtalo de nuevo.');
      }
    }
  }

  void _createDemoAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF667eea),
        ),
      ),
    );

    try {
      final success = await authProvider.createTestUser();

      if (mounted) {
        Navigator.pop(context); // Cerrar loading

        if (success) {
          Navigator.pushReplacementNamed(context, '/home');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.science, color: Colors.white),
                  SizedBox(width: ModernSpacing.sm),
                  Text('¡Cuenta demo creada! Explora la aplicación'),
                ],
              ),
              backgroundColor: ModernColors.info,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
              ),
              margin: const EdgeInsets.all(ModernSpacing.md),
            ),
          );
        } else {
          _showErrorDialog('Error creando cuenta demo. Inténtalo de nuevo.');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog('Error de conexión. Inténtalo de nuevo.');
      }
    }
  }

  void _showForgotPasswordDialog() {
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
                Icons.help_outline,
                color: ModernColors.info,
                size: 48,
              ),
              const SizedBox(height: ModernSpacing.lg),
              const Text(
                'Recuperar Contraseña',
                style: ModernTypography.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.md),
              const Text(
                'Esta funcionalidad estará disponible próximamente. Por ahora puedes usar la cuenta demo para explorar la aplicación.',
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

  void _showErrorDialog(String message) {
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
                Icons.error_outline,
                color: ModernColors.error,
                size: 48,
              ),
              const SizedBox(height: ModernSpacing.lg),
              const Text(
                'Error de Inicio de Sesión',
                style: ModernTypography.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.md),
              Text(
                message,
                style: ModernTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.xl),
              ModernButton(
                text: 'Intentar de nuevo',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
