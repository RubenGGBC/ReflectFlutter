// ============================================================================
// LOGIN SCREEN V2 - ESTILO MINIMALISTA NEGRO CON GRADIENTES AZUL-MORADO
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Providers
import '../../providers/optimized_providers.dart';

// Navigation Screen
import 'main_navigation_screen_v2.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// ============================================================================
// MISMA PALETA DE COLORES MINIMALISTA DE HOME Y ANALYTICS
// ============================================================================
class LoginColors {
  // Fondo principal - Negro profundo
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  // Gradientes Azul Oscuro a Morado (idénticos a HomeScreen)
  static const List<Color> primaryGradient = [
    Color(0xFF1e3a8a), // Azul oscuro
    Color(0xFF581c87), // Morado oscuro
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6), // Azul
    Color(0xFF8b5cf6), // Morado
  ];

  static const List<Color> lightGradient = [
    Color(0xFF60a5fa), // Azul claro
    Color(0xFFa855f7), // Morado claro
  ];

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF666666);
}

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedProfilePicture;

  // ============================================================================
  // ANIMACIONES
  // ============================================================================
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.backgroundPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ModernSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: ModernSpacing.xl),
                  _buildHeader(),
                  const SizedBox(height: ModernSpacing.xl),
                  _buildForm(),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildActionButton(),
                  const SizedBox(height: ModernSpacing.md),
                  _buildToggleMode(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: ModernSpacing.md),
                    _buildErrorMessage(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER CON LOGO Y TÍTULO
  // ============================================================================
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo animado
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: LoginColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.primaryGradient[1].withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: ModernSpacing.lg),

        // Título principal con gradiente
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: LoginColors.accentGradient,
          ).createShader(bounds),
          child: Text(
            _isLogin ? 'Bienvenido de vuelta' : 'Únete a Reflect',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: ModernSpacing.sm),

        // Subtítulo
        Text(
          _isLogin
              ? 'Accede a tu espacio de reflexión personal'
              : 'Comienza tu viaje de autodescubrimiento',
          style: const TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================================
  // FORMULARIO PRINCIPAL
  // ============================================================================
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LoginColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (!_isLogin) ...[
              _buildCustomTextField(
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
            _buildCustomTextField(
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
            _buildCustomTextField(
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
      ),
    );
  }

  // ============================================================================
  // CAMPO DE TEXTO PERSONALIZADO
  // ============================================================================
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: LoginColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: LoginColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: LoginColors.textHint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Ingresa tu ${labelText.toLowerCase()}...',
              hintStyle: const TextStyle(
                color: LoginColors.textHint,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // SELECTOR DE FOTO DE PERFIL
  // ============================================================================
  Widget _buildProfilePictureSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto de perfil (opcional)',
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: LoginColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: _selectedProfilePicture != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedProfilePicture!),
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.add_a_photo_outlined,
                  color: LoginColors.textHint,
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
                        : 'Agregar foto',
                    style: const TextStyle(
                      color: LoginColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedProfilePicture != null
                        ? 'Toca para cambiar'
                        : 'Opcional - puedes agregarlo después',
                    style: const TextStyle(
                      color: LoginColors.textHint,
                      fontSize: 14,
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

  // ============================================================================
  // BOTÓN DE ACCIÓN PRINCIPAL
  // ============================================================================
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: LoginColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: LoginColors.primaryGradient[1].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleAuthAction,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: _isLoading
                  ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : Text(
                _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // TOGGLE ENTRE LOGIN Y REGISTRO
  // ============================================================================
  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?',
          style: const TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isLogin = !_isLogin;
              _errorMessage = null;
            });
          },
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: LoginColors.accentGradient,
            ).createShader(bounds),
            child: Text(
              _isLogin ? 'Regístrate' : 'Inicia sesión',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MENSAJE DE ERROR
  // ============================================================================
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFdc2626).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFdc2626).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFdc2626),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFdc2626),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE ACCIÓN
  // ============================================================================
  Future<void> _handleAuthAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<OptimizedAuthProvider>();

    try {
      bool success;

      if (_isLogin) {
        // FIX: Changed from named parameters to positional arguments
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreenV2(),
          ),
        );
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = _isLogin
                ? 'Credenciales incorrectas. Verifica tu email y contraseña.'
                : 'Error al crear la cuenta. Intenta con un email diferente.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión. Intenta nuevamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: LoginColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Foto',
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: LoginColors.lightGradient,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text(
                'Tomar foto',
                style: TextStyle(color: LoginColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: LoginColors.accentGradient,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text(
                'Elegir de galería',
                style: TextStyle(color: LoginColors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedProfilePicture = image.path;
      });
    }
  }
}
