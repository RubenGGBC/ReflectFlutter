// ============================================================================
// optimized_reflect_app.dart - APLICACIÓN PRINCIPAL COMPLETAMENTE LIMPIA - FIXED
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Dependency Injection optimizado
import 'data/services/optimized_database_service.dart';
import 'injection_container_clean.dart' as clean_di;

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/theme_provider.dart';

// Screens optimizadas (estas necesitarían ser creadas o actualizadas)
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';
import 'presentation/screens/v2/home_screen_v2.dart';
import 'presentation/screens/v2/interactive_moments_screen_v2.dart';
import 'presentation/screens/v2/daily_review_screen_v2.dart';
import 'presentation/screens/v2/analytics_screen_V2.dart';
import 'presentation/screens/v2/profile_screen_v2.dart';

// Componentes modernos (reutilizados)
import 'presentation/screens/components/modern_design_system.dart';

class OptimizedReflectApp extends StatelessWidget {
  const OptimizedReflectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider<OptimizedAuthProvider>(
          create: (_) => clean_di.sl<OptimizedAuthProvider>(),
        ),

        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => clean_di.sl<ThemeProvider>(),
        ),

        // Daily Entries Provider
        ChangeNotifierProvider<OptimizedDailyEntriesProvider>(
          create: (_) => clean_di.sl<OptimizedDailyEntriesProvider>(),
        ),

        // Interactive Moments Provider
        ChangeNotifierProvider<OptimizedMomentsProvider>(
          create: (_) => clean_di.sl<OptimizedMomentsProvider>(),
        ),

        // Analytics Provider
        ChangeNotifierProvider<OptimizedAnalyticsProvider>(
          create: (_) => clean_di.sl<OptimizedAnalyticsProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Reflect - Optimized',
            debugShowCheckedModeBanner: false,

            // Tema optimizado
            theme: themeProvider.currentThemeData,

            // Pantalla inicial
            home: const OptimizedAppInitializer(),

            // Rutas optimizadas y limpias
            routes: {
              '/auth': (context) => const LoginScreenV2(),
              '/main': (context) => const OptimizedMainNavigationScreen(),
              '/home': (context) => const OptimizedHomeScreen(),
              '/moments': (context) => const OptimizedMomentsScreen(),
              '/review': (context) => const OptimizedDailyReviewScreen(),
              '/analytics': (context) => const OptimizedAnalyticsScreen(),
              '/profile': (context) => const OptimizedProfileScreen(),
            },

            // Manejo de rutas desconocidas
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const OptimizedAuthScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================================
// INICIALIZADOR OPTIMIZADO
// ============================================================================

class OptimizedAppInitializer extends StatefulWidget {
  const OptimizedAppInitializer({super.key});

  @override
  State<OptimizedAppInitializer> createState() => _OptimizedAppInitializerState();
}

class _OptimizedAppInitializerState extends State<OptimizedAppInitializer> {
  final Logger _logger = clean_di.sl<Logger>();
  bool _isInitializing = true;
  String _initializationStep = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _initializeOptimizedApp();
  }

  Future<void> _initializeOptimizedApp() async {
    _logger.i('🚀 Inicializando Reflect App Optimizada...');

    try {
      // Paso 1: Inicializar Auth Provider
      setState(() => _initializationStep = 'Verificando autenticación...');
      final authProvider = context.read<OptimizedAuthProvider>();
      await authProvider.initialize();

      // Paso 2: Inicializar Theme Provider
      setState(() => _initializationStep = 'Cargando tema...');
      final themeProvider = context.read<ThemeProvider>();
      await themeProvider.initialize();

      // Paso 3: Verificar base de datos
      setState(() => _initializationStep = 'Verificando base de datos...');
      await _verifyDatabaseIntegrity();

      // Paso 4: Precargar datos si el usuario está autenticado
      if (authProvider.isLoggedIn && authProvider.currentUser != null) {
        setState(() => _initializationStep = 'Cargando datos del usuario...');
        await _preloadUserData(authProvider.currentUser!.id);
      }

      setState(() => _initializationStep = 'Completado');

      // Navegar a la pantalla apropiada
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToAppropriateScreen();

    } catch (e) {
      _logger.e('❌ Error durante la inicialización: $e');
      setState(() => _initializationStep = 'Error de inicialización');

      // Mostrar error y redirigir a auth
      await Future.delayed(const Duration(seconds: 2));
      _navigateToAuth();
    }
  }

  Future<void> _verifyDatabaseIntegrity() async {
    try {
      final dbService = clean_di.sl<OptimizedDatabaseService>();
      await dbService.optimizeDatabase();
    } catch (e) {
      _logger.w('⚠️ Problema menor con la base de datos: $e');
    }
  }

  Future<void> _preloadUserData(int userId) async {
    try {
      // Cargar datos en paralelo para mejor rendimiento
      await Future.wait([
        context.read<OptimizedDailyEntriesProvider>().loadEntries(userId, limitDays: 30),
        context.read<OptimizedMomentsProvider>().loadTodayMoments(userId),
        context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(userId),
      ]);
    } catch (e) {
      _logger.w('⚠️ Error precargando datos del usuario: $e');
      // No es crítico, la app puede funcionar sin precargar
    }
  }

  void _navigateToAppropriateScreen() {
    final authProvider = context.read<OptimizedAuthProvider>();

    if (authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacementNamed('/auth');
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
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo optimizado
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // FIX: Usar LinearGradient en lugar de List<Color>
                  gradient: LinearGradient(
                    colors: ModernColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primaryGradient.first.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Título
              const Text(
                'Reflect',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tu compañero de bienestar optimizado',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 48),

              // Indicador de progreso
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(
                        ModernColors.primaryGradient.first,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _initializationStep,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FUNCIÓN PRINCIPAL OPTIMIZADA
// ============================================================================

Future<void> runOptimizedReflectApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependencias limpias
  await clean_di.initCleanDependencies();

  // Verificar que todas las dependencias estén listas
  if (!clean_di.areCleanServicesRegistered()) {
    throw Exception('❌ No se pudieron registrar todas las dependencias');
  }

  final logger = clean_di.sl<Logger>();
  logger.i('✅ Reflect App Optimizada iniciada correctamente');

  // Información del container limpio
  final containerInfo = clean_di.getCleanContainerInfo();
  logger.d('📦 Container info: $containerInfo');

  runApp(const OptimizedReflectApp());
}

// ============================================================================
// MAIN FUNCTION OPTIMIZADA
// ============================================================================

void main() async {
  try {
    await runOptimizedReflectApp();
  } catch (e) {
    // Fallback en caso de error crítico
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error crítico de inicialización',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CLASES DE SCREENS PLACEHOLDER (NECESITAN IMPLEMENTACIÓN)
// ============================================================================

// Estas clases son placeholders y necesitarían implementación completa
// basada en las screens existentes pero optimizadas

class OptimizedAuthScreen extends StatelessWidget {
  const OptimizedAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: const Center(
          child: Text(
            'Pantalla de Autenticación Optimizada',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class OptimizedMainNavigationScreen extends StatelessWidget {
  const OptimizedMainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Navegación Principal Optimizada'),
      ),
    );
  }
}

class OptimizedHomeScreen extends StatelessWidget {
  const OptimizedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Screen Optimizada'),
      ),
    );
  }
}

class OptimizedMomentsScreen extends StatelessWidget {
  const OptimizedMomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Moments Screen Optimizada'),
      ),
    );
  }
}

class OptimizedDailyReviewScreen extends StatelessWidget {
  const OptimizedDailyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Daily Review Screen Optimizada'),
      ),
    );
  }
}

class OptimizedAnalyticsScreen extends StatelessWidget {
  const OptimizedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Analytics Screen Optimizada'),
      ),
    );
  }
}

class OptimizedProfileScreen extends StatelessWidget {
  const OptimizedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Screen Optimizada'),
      ),
    );
  }
}