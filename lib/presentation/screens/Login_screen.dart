// ============================================================================
// MODERN LOGIN SCREEN - Rediseñado para ser más intuitivo y clean
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with TickerProviderStateMixin {

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF667eea),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildHeroSection(),
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                  const SizedBox(height: 32),
                  _buildBottomActions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Logo animado
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // Título principal
          const Text(
            'ReflectApp',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Subtítulo
          Text(
            'Tu momento de paz diario',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título del formulario
              const Text(
                'Bienvenido de vuelta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Inicia sesión para continuar tu viaje zen',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email field
              _buildModernTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),

              const SizedBox(height: 20),

              // Password field
              _buildModernTextField(
                controller: _passwordController,
                label: 'Contraseña',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: _validatePassword,
              ),

              const SizedBox(height: 16),

              // Remember me & Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF667eea),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Text(
                        'Recordarme',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Implement forgot password
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667eea),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Login button
              _buildModernButton(
                onPressed: _isLoading ? null : _login,
                text: 'Iniciar Sesión',
                isLoading: _isLoading,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Colors.grey[500],
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[500],
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton({
    required VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        )
            : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFF667eea), width: 2),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : const Color(0xFF667eea),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Divider with text
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'o',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Register button
          _buildModernButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            text: 'Crear cuenta nueva',
            isPrimary: false,
          ),

          const SizedBox(height: 16),

          // Demo button
          TextButton(
            onPressed: _createTestUser,
            child: Text(
              '🧪 Probar con cuenta demo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Introduce un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // Actions
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate login delay
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Implement actual login logic with AuthProvider
      // final authProvider = context.read<AuthProvider>();
      // final success = await authProvider.login(
      //   _emailController.text,
      //   _passwordController.text,
      //   rememberMe: _rememberMe,
      // );

      // For now, just navigate
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createTestUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement test user creation
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creando usuario de prueba: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}