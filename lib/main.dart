// ============================================================================
// main.dart - VERSIÓN SIMPLIFICADA SIN ERRORES DE NOTIFICACIONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'injection_container.dart' as di;

/// Punto de entrada principal de la aplicación
void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();

  try {
    logger.i('🚀 Iniciando ReflectApp...');

    // Configurar orientación (solo portrait)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configurar UI del sistema
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Inicializar dependencias de forma segura
    await _initializeDependenciesSafely();

    logger.i('✅ ReflectApp inicializado correctamente');

    // Ejecutar aplicación
    runApp(const ReflectApp());

  } catch (e, stackTrace) {
    logger.e('❌ Error crítico iniciando ReflectApp: $e');
    logger.e('📋 Stack trace: $stackTrace');

    // Ejecutar aplicación con pantalla de error
    runApp(_buildErrorApp(e.toString()));
  }
}

/// Inicializar dependencias de forma segura
Future<void> _initializeDependenciesSafely() async {
  final logger = Logger();

  try {
    logger.i('🔧 Inicializando dependencias...');

    // Inicializar contenedor de dependencias
    await di.init();

    // Verificar dependencias

    

    logger.i('✅ Dependencias inicializadas correctamente');

  } catch (e) {
    logger.e('❌ Error inicializando dependencias: $e');

    // Re-intentar una vez más
    logger.w('🔄 Reintentando inicialización...');

    try {
      await di.init();
      logger.i('✅ Dependencias inicializadas en segundo intento');
    } catch (retryError) {
      logger.e('❌ Error en segundo intento: $retryError');
      throw Exception('Error crítico en inicialización de dependencias');
    }
  }
}

/// Construir aplicación de error en caso de fallo crítico
Widget _buildErrorApp(String error) {
  return MaterialApp(
    title: 'ReflectApp - Error',
    debugShowCheckedModeBanner: false,
    home: ErrorScreen(error: error),
  );
}

/// Pantalla de error para fallos críticos
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de error
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // Título
              Text(
                'Error de Inicialización',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Mensaje de error
              Text(
                'ReflectApp no pudo inicializarse correctamente.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Detalles del error (expandible)
              ExpansionTile(
                title: const Text('Detalles técnicos'),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botón de reintentar
              ElevatedButton.icon(
                onPressed: () => _restartApp(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón de modo seguro
              OutlinedButton.icon(
                onPressed: () => _startSafeMode(),
                icon: const Icon(Icons.security),
                label: const Text('Modo Seguro'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade700,
                  side: BorderSide(color: Colors.orange.shade300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartApp() {
    // En una implementación real, esto reiniciaría la app
    // Por ahora, solo mostramos un mensaje
    print('🔄 Reintentando inicialización...');
  }

  void _startSafeMode() {
    // En una implementación real, esto iniciaría en modo seguro
    print('🛡️ Iniciando modo seguro...');
  }
}

/// Pantalla de splash/loading mejorada
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // Simular carga
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Simular tiempo de carga
      await Future.delayed(const Duration(seconds: 3));

      // Navegar a pantalla principal
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Manejar error de inicialización
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ErrorScreen(error: e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.self_improvement,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Título
                    Text(
                      'ReflectApp',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      'Tu espacio de reflexión zen',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Preparando tu experiencia zen...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}