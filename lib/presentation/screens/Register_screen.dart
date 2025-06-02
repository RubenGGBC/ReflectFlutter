// ============================================================================
// presentation/screens/register_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/themed_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Logger _logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _privacyAccepted = false;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context, themeProvider),
            _buildHeroSection(context, themeProvider),
            _buildFormSection(context, themeProvider),
            _buildQuoteSection(context, themeProvider),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón volver
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: themeProvider.currentColors.textSecondary),
            label: Text(
              'Volver',
              style: TextStyle(color: themeProvider.currentColors.textSecondary),
            ),
          ),

          // Indicador de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Paso 1 de 2',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.currentColors.textHint,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 24, height: 4,
                    decoration: BoxDecoration(
                      color: themeProvider.currentColors.accentPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24, height: 4,
                    decoration: BoxDecoration(
                      color: themeProvider.currentColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          // Icono de crecimiento
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: themeProvider.currentColors.positiveMain.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentColors.positiveMain.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 32)),
            ),
          ),

          const SizedBox(height: 16),

          // Título
          Text(
            'Únete a ReflectApp',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Crea tu cuenta y comienza tu viaje de reflexión',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.currentColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
            // Campo Nombre
            CustomTextField(
              controller: _nameController,
              label: '👤 Nombre (opcional)',
              hint: '¿Cómo te llamamos?',
              validator: null, // Opcional
            ),

            const SizedBox(height: 20),

            // Campo Email
            CustomTextField(
              controller: _emailController,
              label: '📧 Email',
              hint: 'tu@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: 20),

            // Campo Password con medidor
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _passwordController,
                  label: '🔒 Contraseña',
                  hint: 'Contraseña segura',
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: themeProvider.currentColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: _validatePassword,
                  onChanged: _onPasswordChanged,
                ),

                // Medidor de fuerza
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPasswordStrengthIndicator(themeProvider),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // Campo Confirmar Password
            CustomTextField(
              controller: _confirmPasswordController,
              label: '🔐 Confirmar contraseña',
              hint: 'Repite tu contraseña',
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: themeProvider.currentColors.textSecondary,
                ),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
              validator: _validateConfirmPassword,
            ),

            const SizedBox(height: 20),

            // Checkbox privacidad
            Row(
              children: [
                Checkbox(
                  value: _privacyAccepted,
                  onChanged: (value) => setState(() => _privacyAccepted = value ?? false),
                  activeColor: themeProvider.currentColors.positiveMain,
                ),
                Expanded(
                  child: Text(
                    'Acepto mantener mis reflexiones privadas 🔐',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.currentColors.textSecondary,
                    ),
                  ),
                ),
              ],
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

            // Botón Crear Cuenta
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ThemedButton(
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                  isLoading: authProvider.isLoading,
                  type: ThemedButtonType.positive,
                  width: double.infinity,
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        authProvider.isLoading ? 'Creando...' : 'Crear cuenta',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(ThemeProvider themeProvider) {
    final colors = [
      themeProvider.currentColors.negativeMain,
      Colors.orange,
      Colors.orange,
      themeProvider.currentColors.positiveMain,
    ];

    final labels = ['🔓 Muy débil', '🔒 Débil', '🔒 Media', '🔐 Fuerte'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barras de fuerza
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < _passwordStrength
                      ? colors[_passwordStrength - 1]
                      : themeProvider.currentColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Texto de fuerza
        if (_passwordStrength > 0)
          Text(
            labels[_passwordStrength - 1],
            style: TextStyle(
              fontSize: 12,
              color: colors[_passwordStrength - 1],
            ),
          ),
      ],
    );
  }

  Widget _buildQuoteSection(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Text(
        '🌸 Tu viaje de autoconocimiento comienza con un solo paso',
        style: TextStyle(
          fontSize: 14,
          color: themeProvider.currentColors.textHint,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(value);
    });
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Longitud
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;

    // Caracteres
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return (strength / 1.5).ceil().clamp(1, 4);
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
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar los términos de privacidad'),
          backgroundColor: context.read<ThemeProvider>().currentColors.negativeMain,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim().isEmpty
          ? _emailController.text.split('@')[0]
          : _nameController.text.trim(),
      avatarEmoji: '🌱',
    );

    if (success && mounted) {
      _logger.i('✅ Registro exitoso, navegando a momentos interactivos');
      Navigator.of(context).pushReplacementNamed('/interactive_moments');
    }
  }
}