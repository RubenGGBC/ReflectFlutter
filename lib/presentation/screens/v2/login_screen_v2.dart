// lib/presentation/screens/v2/login_screen_v2.dart
// ✅ ENHANCED LOGIN SCREEN WITH APP THEME SYSTEM

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// Providers
import '../../providers/optimized_providers.dart';

// Navigation Screen
import 'main_navigation_screen_v2.dart';
import 'welcome_onboarding_screen.dart';

// ✅ NEW: App Theme System
import '../../../core/themes/app_theme.dart';
import '../components/modern_design_system.dart';

// ✅ NEW: Test Data Seeder
import '../../../test_data/simple_test_data.dart';
import '../../../test_data/test_data_seeder.dart';
import '../../../data/services/optimized_database_service.dart';
import '../../../injection_container_clean.dart' as clean_di;

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
    // ✅ NEW: Use app theme system
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? ThemeDefinitions.deepOcean;
    
    return Scaffold(
      backgroundColor: appColors.primaryBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: appColors.gradientHeader,
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
                    const SizedBox(height: ModernSpacing.sm),
                    _buildAdminButton(),
                    const SizedBox(height: ModernSpacing.md),
                    _buildWelcomeScreenButton(),
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
    final appColors = Theme.of(context).extension<AppColors>() ?? ThemeDefinitions.deepOcean;
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: appColors.accentPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: appColors.accentPrimary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.self_improvement,
            size: 40,
            color: appColors.accentPrimary,
          ),
        ),
        const SizedBox(height: ModernSpacing.md),
        Text(
          _isLogin ? 'Bienvenido de vuelta' : 'Únete a nosotros',
          style: ModernTypography.headlineLarge.copyWith(
            color: appColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ModernSpacing.sm),
        Text(
          _isLogin
              ? 'Accede a tu espacio de reflexión personal'
              : 'Comienza tu viaje de autodescubrimiento',
          style: ModernTypography.bodyLarge.copyWith(
            color: appColors.textSecondary,
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
          style: ModernTypography.bodyMedium.copyWith(
            color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white,
          ),
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
                  color: Theme.of(context).extension<AppColors>()?.glassBg ?? Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
                  border: Border.all(
                    color: Theme.of(context).extension<AppColors>()?.borderColor ?? Colors.white.withOpacity(0.2),
                  ),
                ),
                child: _selectedProfilePicture != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium), // ✅ CORREGIDO
                  child: Image.file(
                    File(_selectedProfilePicture!),
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.add_a_photo_outlined,
                  color: Theme.of(context).extension<AppColors>()?.textHint ?? Colors.white60,
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
                      color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (_selectedProfilePicture != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedProfilePicture = null),
                      child: Text(
                        'Eliminar',
                        style: ModernTypography.bodyMedium.copyWith(
                          color: Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red,
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
          style: ModernTypography.bodyMedium.copyWith(
            color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white,
          ),
          children: [
            TextSpan(
              text: _isLogin ? 'Regístrate' : 'Inicia sesión',
              style: ModernTypography.bodyMedium.copyWith(
                color: Theme.of(context).extension<AppColors>()?.accentPrimary ?? Colors.blue,
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
          color: Theme.of(context).extension<AppColors>()?.accentSecondary ?? Colors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAdminButton() {
    final authProvider = context.watch<OptimizedAuthProvider>();

    return TextButton(
      onPressed: authProvider.isLoading ? null : () async {
        await _showAdminDialog();
      },
      child: Text(
        '🔧 Administrador - Sembrar Datos',
        style: ModernTypography.bodyMedium.copyWith(
          color: Theme.of(context).extension<AppColors>()?.accentSecondary ?? Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWelcomeScreenButton() {
    final authProvider = context.watch<OptimizedAuthProvider>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: ModernSpacing.md),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const WelcomeOnboardingScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).extension<AppColors>()?.accentPrimary ?? Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.launch, size: 20),
            const SizedBox(width: ModernSpacing.sm),
            Text(
              '🎯 Probar Welcome Screen',
              style: ModernTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return ModernCard(
      backgroundColor: (Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red).withOpacity(0.15),
      padding: const EdgeInsets.all(ModernSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.error_outline, 
            color: Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red, 
            size: 20,
          ),
          const SizedBox(width: ModernSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: ModernTypography.bodyMedium.copyWith(
                color: Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad.',
      style: ModernTypography.caption.copyWith(
        color: Theme.of(context).extension<AppColors>()?.textHint ?? Colors.white.withOpacity(0.6),
      ),
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
        final user = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          profilePicturePath: _selectedProfilePicture,
        );
        success = user != null;
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

  // ============================================================================
  // FUNCIONALIDAD DE ADMINISTRADOR - SEMBRAR DATOS DE PRUEBA
  // ============================================================================

  Future<void> _showAdminDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
        title: Text(
          '🔧 Panel de Administrador',
          style: ModernTypography.headlineSmall.copyWith(
            color: Theme.of(context).extension<AppColors>()?.textPrimary ?? Colors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selecciona el tipo de datos de prueba a sembrar:',
                style: ModernTypography.bodyMedium.copyWith(
                  color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
                ),
              ),
              const SizedBox(height: ModernSpacing.md),
              _buildSeedButton(
                '🧪 Crear Usuario de Prueba',
                'Generar datos de ejemplo para desarrollo',
                () => _seedUserData(),
              ),
              const SizedBox(height: ModernSpacing.md),
              _buildSeedButton(
                '🧹 Limpiar Datos',
                'Eliminar todos los datos de prueba',
                () => _clearAllData(),
                isDestructive: true,
              ),
              const SizedBox(height: ModernSpacing.md),
              _buildSeedButton(
                '🎯 Probar Onboarding',
                'Limpiar usuarios y mostrar welcome screen',
                () => _testOnboarding(),
                isDestructive: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: ModernTypography.bodyMedium.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedButton(
    String title,
    String description,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive
              ? Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red
              : Theme.of(context).extension<AppColors>()?.accentPrimary ?? Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(ModernSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: ModernTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: ModernTypography.bodySmall.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seedUserData() async {
    Navigator.pop(context); // Cerrar dialog
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: ModernSpacing.md),
            Text(
              'Creando usuario y poblando datos...',
              style: ModernTypography.bodyMedium.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textPrimary ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Obtener servicios
      final databaseService = clean_di.sl<OptimizedDatabaseService>();
      final authProvider = context.read<OptimizedAuthProvider>();
      
      // Usar los métodos específicos que crean usuario y hacen login automático
      Map<String, dynamic> result;
      
      // Create a simple test user and login
      final success = await authProvider.loginAsDeveloper();
      
      if (success) {
        // Get the current user ID and seed test data
        final currentUserId = authProvider.currentUser?.id ?? 1;
        final seeder = TestDataSeeder(databaseService);
        await seeder.seedTestData(currentUserId);
        
        result = {
          'success': true,
          'auto_login': true,
          'user_name': 'Test User',
          'user_email': 'developer@test.com',
          'user_password': 'developer',
          'stats': {
            'totalDailyEntries': 30,
            'totalInteractiveMoments': 45,
            'totalGoals': 4,
          }
        };
      } else {
        result = {
          'success': false,
          'error': 'Failed to create test user',
        };
      }
      
      Navigator.pop(context); // Cerrar loading
      
      if (result['success']) {
        // Si el login automático fue exitoso, navegar directamente
        if (result['auto_login'] == true && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreenV2(),
            ),
          );
        } else {
          // Mostrar éxito con opción de login manual
          _showSuccessDialog(result);
        }
      } else {
        // Mostrar error
        _showErrorDialog(result['error']);
      }
      
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _testOnboarding() async {
    Navigator.pop(context); // Close dialog
    
    try {
      final databaseService = clean_di.sl<OptimizedDatabaseService>();
      final authProvider = context.read<OptimizedAuthProvider>();
      
      // Clear all users to trigger first-time user flow
      await databaseService.clearAllUsers();
      
      // Force check first time user
      await authProvider.checkFirstTimeUser();
      
      // Navigate directly to welcome screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WelcomeOnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    Navigator.pop(context); // Cerrar dialog
    
    // Confirmar acción
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
        title: Text(
          '⚠️ Confirmar Limpieza',
          style: ModernTypography.headlineSmall.copyWith(
            color: Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar todos los datos de prueba? Esta acción no se puede deshacer.',
          style: ModernTypography.bodyMedium.copyWith(
            color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: ModernTypography.bodyMedium.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: ModernSpacing.md),
              Text(
                'Limpiando datos...',
                style: ModernTypography.bodyMedium.copyWith(
                  color: Theme.of(context).extension<AppColors>()?.textPrimary ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

      try {
        // Limpiar datos
        final databaseService = clean_di.sl<OptimizedDatabaseService>();
        final seeder = TestDataSeeder(databaseService);
        
        await seeder.clearTestData(1); // Usuario desarrollador
        
        Navigator.pop(context); // Cerrar loading
        
        // Mostrar éxito
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
            title: Text(
              '✅ Datos Limpiados',
              style: ModernTypography.headlineSmall.copyWith(
                color: Theme.of(context).extension<AppColors>()?.accentSecondary ?? Colors.green,
              ),
            ),
            content: Text(
              'Todos los datos de prueba han sido eliminados exitosamente.',
              style: ModernTypography.bodyMedium.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
      } catch (e) {
        Navigator.pop(context); // Cerrar loading
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final stats = result['stats'] as Map<String, dynamic>? ?? {};
    final userName = result['user_name'] as String? ?? 'Usuario';
    final userEmail = result['user_email'] as String? ?? '';
    final userPassword = result['user_password'] as String? ?? '';
    final autoLogin = result['auto_login'] as bool? ?? false;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
        title: Text(
          autoLogin ? '✅ Usuario Creado y Conectado' : '✅ Usuario Creado',
          style: ModernTypography.headlineSmall.copyWith(
            color: Theme.of(context).extension<AppColors>()?.accentSecondary ?? Colors.green,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                autoLogin 
                  ? 'Usuario creado y sesión iniciada automáticamente'
                  : 'Usuario creado exitosamente. Usa las credenciales para iniciar sesión.',
                style: ModernTypography.bodyMedium.copyWith(
                  color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
                ),
              ),
              const SizedBox(height: ModernSpacing.md),
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).extension<AppColors>()?.surfaceVariant ?? Colors.grey[800],
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👤 $userName',
                      style: ModernTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).extension<AppColors>()?.textPrimary ?? Colors.white,
                      ),
                    ),
                    Text(
                      '📧 $userEmail',
                      style: ModernTypography.bodySmall.copyWith(
                        color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
                      ),
                    ),
                    Text(
                      '🔑 $userPassword',
                      style: ModernTypography.bodySmall.copyWith(
                        color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (stats.isNotEmpty) ...[
                const SizedBox(height: ModernSpacing.md),
                Text(
                  'Datos generados:',
                  style: ModernTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).extension<AppColors>()?.textPrimary ?? Colors.white,
                  ),
                ),
            const SizedBox(height: ModernSpacing.sm),
            Text(
              '📅 Entradas diarias: ${stats['totalDailyEntries']}',
              style: ModernTypography.bodySmall.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
              ),
            ),
            Text(
              '💭 Momentos interactivos: ${stats['totalInteractiveMoments']}',
              style: ModernTypography.bodySmall.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
              ),
            ),
            Text(
              '🎯 Metas: ${stats['totalGoals']}',
              style: ModernTypography.bodySmall.copyWith(
                color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
              ),
            ),
              ],
              if (!autoLogin) ...[
                const SizedBox(height: ModernSpacing.sm),
                Text(
                  'El auto-login falló. Usa las credenciales mostradas para iniciar sesión manualmente.',
                  style: ModernTypography.bodySmall.copyWith(
                    color: Theme.of(context).extension<AppColors>()?.accentSecondary ?? Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!autoLogin && userEmail.isNotEmpty && userPassword.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Intentar login manual
                _emailController.text = userEmail;
                _passwordController.text = userPassword;
                await _handleSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).extension<AppColors>()?.accentPrimary ?? Colors.blue,
              ),
              child: const Text('Iniciar Sesión'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).extension<AppColors>()?.surface ?? Colors.grey[900],
        title: Text(
          '❌ Error',
          style: ModernTypography.headlineSmall.copyWith(
            color: Theme.of(context).extension<AppColors>()?.negativeMain ?? Colors.red,
          ),
        ),
        content: Text(
          'Error al sembrar datos: $error',
          style: ModernTypography.bodyMedium.copyWith(
            color: Theme.of(context).extension<AppColors>()?.textSecondary ?? Colors.white70,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}