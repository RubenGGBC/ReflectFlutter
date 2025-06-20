// ============================================================================
// login_screen_v2.dart - VERSIÓN COMPLETA Y CORREGIDA CON DEBUG
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../providers/auth_provider.dart';
import '../../../data/services/database_service.dart';
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
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOutBack));

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
    _particleController.repeat();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernColors.primaryGradient.first,
              ModernColors.primaryGradient.last,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(ModernSpacing.lg),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: ModernSpacing.xxl),
                        _buildLoginForm(),
                        const SizedBox(height: ModernSpacing.xl),
                        _buildBottomActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _heroAnimation,
      child: Column(
        children: [
          const SizedBox(height: ModernSpacing.xxl),

          // Logo animado
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: ModernSpacing.lg),

          // Título
          const Text(
            'ReflectApp V2',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: ModernSpacing.sm),

          // Subtítulo
          Text(
            'Tu espacio de reflexión y bienestar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
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
                // Título del formulario
                const Text(
                  'Bienvenido de vuelta',
                  style: ModernTypography.heading2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: ModernSpacing.lg),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'tu@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: ModernColors.glassSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                const SizedBox(height: ModernSpacing.md),

                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Tu contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: ModernColors.glassSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                ),

                const SizedBox(height: ModernSpacing.md),

                // Recordarme y Olvidé contraseña
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

                // Botón de Login
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernColors.primaryGradient.first,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                    color: Colors.white.withAlpha(51),
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
                    color: Colors.white.withAlpha(51),
                  ),
                ),
              ],
            ),

            const SizedBox(height: ModernSpacing.xl),

            // Botón Crear cuenta
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1),
                padding: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                ),
              ),
              child: const Text(
                'Crear cuenta nueva',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: ModernSpacing.md),

            // Botón Demo
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
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ BOTONES DE DEBUG TEMPORAL (SOLO DESARROLLO)
            if (true) ...[
              const SizedBox(height: ModernSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _debugDatabase,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        foregroundColor: Colors.orange,
                      ),
                      child: const Text('🔍 Debug BD', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: _resetDatabase,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('🔄 Reset User', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
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
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showErrorDialog('Credenciales incorrectas. Por favor, verifica tu email y contraseña.');
        }
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

  // ============================================================================
  // DEBUG METHODS (TEMPORAL - SOLO DESARROLLO)
  // ============================================================================

  void _debugDatabase() async {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Debug de la BD
      final db = await dbService.database;

      // Obtener todos los usuarios
      final users = await db.query('users');

      // Verificar usuario dev específicamente
      final devUser = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: ['dev@reflect.com']
      );

      if (mounted) Navigator.pop(context); // Cerrar loading

      // Mostrar resultados
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔍 DEBUG BASE DE DATOS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text('Total usuarios: ${users.length}'),
                const SizedBox(height: 10),
                const Text('Usuarios encontrados:'),
                ...users.map((user) => Text('• ${user['email']} - ${user['name']}')),
                const SizedBox(height: 10),
                Text(devUser.isNotEmpty
                    ? '✅ Usuario dev@reflect.com: ENCONTRADO'
                    : '❌ Usuario dev@reflect.com: NO ENCONTRADO'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ),
      );

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error debug: $e')),
      );
    }
  }

  void _resetDatabase() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final db = await dbService.database;

      // Eliminar y recrear usuario dev
      await db.delete('users', where: 'email = ?', whereArgs: ['dev@reflect.com']);

      const email = 'dev@reflect.com';
      const password = 'devpassword123';
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      await db.insert('users', {
        'email': email,
        'password_hash': passwordHash,
        'name': 'Alex Developer',
        'avatar_emoji': '👨‍💻',
        'preferences': '{}',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Usuario dev recreado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reset: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ============================================================================
  // DIALOG METHODS
  // ============================================================================

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
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.primaryGradient.first,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Entendido'),
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
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}