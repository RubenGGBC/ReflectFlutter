// ============================================================================
// presentation/screens/login_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/themed_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context, themeProvider),
            _buildFormSection(context, themeProvider),
            _buildQuoteSection(context, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeProvider themeProvider) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono principal con gradiente
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.currentColors.gradientHeader,
              ),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentColors.accentPrimary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('🧘‍♀️', style: TextStyle(fontSize: 50)),
            ),
          ),

          const SizedBox(height: 24),

          // Título principal
          Text(
            'ReflectApp',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // Subtítulo con separadores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 32, height: 1, color: themeProvider.currentColors.textHint),
              const SizedBox(width: 16),
              Text(
                'Tu santuario zen',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.currentColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 32, height: 1, color: themeProvider.currentColors.textHint),
            ],
          ),

          const SizedBox(height: 8),

          // Decoración
          Text(
            '✧ ✦ ✧',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.currentColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeProvider.currentColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Campo Email
            CustomTextField(
              controller: _emailController,
              label: '📧 Correo electrónico',
              hint: 'tu@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: 20),

            // Campo Password
            CustomTextField(
              controller: _passwordController,
              label: '🔒 Contraseña',
              hint: '••••••••',
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: themeProvider.currentColors.textSecondary,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: 16),

            // Mostrar errores
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.errorMessage != null) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeProvider.currentColors.negativeMain,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Botón Login
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ThemedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  isLoading: authProvider.isLoading,
                  width: double.infinity,
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🚪', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        authProvider.isLoading ? 'Entrando...' : 'Entrar zen',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Separador
            Row(
              children: [
                Expanded(child: Container(height: 1, color: themeProvider.currentColors.borderColor)),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ó',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.currentColors.textHint,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: themeProvider.currentColors.borderColor)),
              ],
            ),

            const SizedBox(height: 20),

            // Botón Registro
            ThemedButton(
              onPressed: _goToRegister,
              type: ThemedButtonType.outlined,
              width: double.infinity,
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.currentColors.positiveMain,
                    ),
                  ),
                ],
              ),
            ),

            // Usuario de prueba
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: TextButton(
                onPressed: _createTestUser,
                child: Text(
                  '🧪 Modo desarrollador',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.currentColors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            '"Un momento de paz puede cambiar tu día"',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.currentColors.textHint,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeProvider.currentColors.positiveMain.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: themeProvider.currentColors.positiveMain.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'Privado y seguro',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.currentColors.positiveMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Introduce un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 3) {
      return 'Contraseña demasiado corta';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _logger.i('✅ Login exitoso, navegando a momentos interactivos');
      Navigator.of(context).pushReplacementNamed('/interactive_moments');
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  Future<void> _createTestUser() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.createTestUser();

    if (success && mounted) {
      // Pre-llenar campos
      _emailController.text = 'zen@reflect.app';
      _passwordController.text = 'reflect123';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🧪 Usuario de prueba creado'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
