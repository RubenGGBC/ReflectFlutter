// ============================================================================
// app_v2.dart - VERSIÓN COMPLETA CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/interactive_moments_provider.dart';
import 'presentation/providers/analytics_provider.dart';
import 'presentation/providers/enhanced_analytics_provider.dart';

// Screens V2
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/home_screen_v2.dart';
import 'presentation/screens/v2/interactive_moments_screen_v2.dart';
import 'presentation/screens/v2/daily_review_screen_v2.dart';
import 'presentation/screens/v2/profile_screen_v2.dart';
import 'presentation/screens/v2/calendar_screen_v2.dart';

// Componentes modernos
import 'presentation/screens/components/modern_design_system.dart';
import 'presentation/screens/components/modern_navigation.dart'; // ✅ RESTAURADO: Necesario para navegación

// Services
import 'data/services/database_service.dart';

// Dependency Injection
import 'injection_container.dart' as di;

class ReflectAppV2 extends StatelessWidget {
  const ReflectAppV2({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ CORREGIDO: Quitar ..initialize() para evitar setState durante build
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<InteractiveMomentsProvider>(
          create: (_) => di.sl<InteractiveMomentsProvider>(),
        ),
        ChangeNotifierProvider<AnalyticsProvider>(
          create: (_) => di.sl<AnalyticsProvider>(),
        ),
        ChangeNotifierProvider<EnhancedAnalyticsProvider>(
          create: (_) => di.sl<EnhancedAnalyticsProvider>(),
        ),
        // ✅ NUEVO: Agregar DatabaseService como provider también
        Provider<DatabaseService>(
          create: (_) => di.sl<DatabaseService>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Reflect - Tu Compañero de Bienestar',
            debugShowCheckedModeBanner: false,

            // Tema configurado
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: ModernColors.darkPrimary,
              appBarTheme: const AppBarTheme(
                backgroundColor: ModernColors.darkPrimary,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Página inicial
            home: const AppV2Initializer(),

            // Rutas V2 corregidas
            routes: {
              '/login_v2': (context) => const LoginScreenV2(),
              '/login': (context) => const LoginScreenV2(), // ✅ AGREGADO: Alias para compatibilidad
              '/home_v2': (context) => const HomeScreenV2(),
              '/home': (context) => const HomeScreenV2(), // ✅ AGREGADO: Alias para compatibilidad
              '/moments_v2': (context) => const InteractiveMomentsScreenV2(),
              '/moments': (context) => const InteractiveMomentsScreenV2(), // ✅ AGREGADO: Alias
              '/review_v2': (context) => const DailyReviewScreenV2(),
              '/profile_v2': (context) => const ProfileScreenV2(),
              '/calendar_v2': (context) => const CalendarScreenV2(),
            },

            // Manejo de rutas desconocidas
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreenV2(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget que maneja la inicialización de App V2
class AppV2Initializer extends StatefulWidget {
  const AppV2Initializer({super.key});

  @override
  State<AppV2Initializer> createState() => _AppV2InitializerState();
}

class _AppV2InitializerState extends State<AppV2Initializer> {
  final Logger _logger = Logger();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAppV2();
  }

  Future<void> _initializeAppV2() async {
    _logger.i('🚀 Inicializando ReflectApp V2...');

    try {
      // ✅ CORREGIDO: Esperar a que el context esté disponible antes de inicializar
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // Inicializar providers de forma segura
      final authProvider = context.read<AuthProvider>();
      final themeProvider = context.read<ThemeProvider>();

      await Future.wait([
        authProvider.initialize(),
        themeProvider.initialize(),
      ]);

      _logger.i('✅ ReflectApp V2 inicializada correctamente');

      // Pequeña pausa para mostrar splash
      await Future.delayed(const Duration(milliseconds: 500));

    } catch (e) {
      _logger.e('❌ Error en inicialización V2: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const ModernSplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isInitialized) {
          return const ModernSplashScreen();
        }

        if (authProvider.isLoggedIn) {
          _logger.d('👤 Usuario logueado V2: ${authProvider.currentUser?.name}');
          return const HomeScreenV2();
        } else {
          _logger.d('🔑 Usuario no logueado V2, mostrando login');
          return const LoginScreenV2();
        }
      },
    );
  }
}

/// Pantalla de splash moderna para V2
class ModernSplashScreen extends StatelessWidget {
  const ModernSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernColors.accentBlue,
                    ModernColors.accentPurple, // ✅ CORREGIDO: Ahora este color existe
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.accentBlue.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Título
            const Text(
              'ReflectApp V2',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Subtítulo
            Text(
              'Tu compañero de bienestar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ModernColors.accentBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}