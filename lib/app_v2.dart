// ============================================================================
// app_v2.dart - VERSIÓN COMPLETA Y FUNCIONAL
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/interactive_moments_provider.dart';
import 'presentation/providers/analytics_provider.dart'; // ✅ NUEVO

// Screens V2
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/home_screen_v2.dart';
import 'presentation/screens/v2/interactive_moments_screen_v2.dart';
import 'presentation/screens/v2/daily_review_screen_v2.dart';
import 'presentation/screens/v2/profile_screen_v2.dart';
import 'presentation/screens/v2/calendar_screen_v2.dart';

// Componentes modernos
import 'presentation/screens/components/modern_design_system.dart';
import 'presentation/screens/components/modern_navigation.dart';

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
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => di.sl<AuthProvider>()..initialize(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => di.sl<ThemeProvider>()..initialize(),
        ),
        ChangeNotifierProvider<InteractiveMomentsProvider>(
          create: (_) => di.sl<InteractiveMomentsProvider>(),
        ),
        // ✅ NUEVO: Analytics Provider
        ChangeNotifierProvider<AnalyticsProvider>(
          create: (_) => AnalyticsProvider(di.sl<DatabaseService>()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReflectApp v2 - Tu espacio de reflexión',
            debugShowCheckedModeBanner: false,
            theme: ModernTheme.darkTheme,

            // ✅ CONFIGURACIÓN INICIAL CORRECTA
            home: const AppInitializerV2(),

            // ✅ RUTAS ACTUALIZADAS
            routes: _buildRoutes(),

            // Manejar rutas no encontradas
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

  // ✅ RUTAS COMPLETAS Y ACTUALIZADAS
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/login': (context) => const LoginScreenV2(),
      '/home': (context) => const ModernNavigationWrapper(),
      '/interactive_moments': (context) => const InteractiveMomentsScreenV2(),
      '/daily_review': (context) => const DailyReviewScreenV2(),
      '/profile': (context) => const ProfileScreenV2(),
      '/calendar': (context) => const CalendarScreenV2(),
    };
  }
}

// ============================================================================
// INICIALIZADOR DE APP V2 - VERSIÓN CORREGIDA
// ============================================================================

class AppInitializerV2 extends StatefulWidget {
  const AppInitializerV2({super.key});

  @override
  State<AppInitializerV2> createState() => _AppInitializerV2State();
}

class _AppInitializerV2State extends State<AppInitializerV2> with TickerProviderStateMixin {
  final Logger _logger = Logger();
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeApp();
  }

  void _setupAnimation() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoController.forward();
  }

  Future<void> _initializeApp() async {
    _logger.i('🚀 Inicializando ReflectApp V2...');

    try {
      // Pequeña pausa para mostrar splash
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // Inicializar providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      await Future.wait([
        authProvider.initialize(),
        themeProvider.initialize(),
      ]);

      _logger.i('✅ Providers inicializados correctamente');

      if (!mounted) return;

      // Navegar según estado de autenticación
      if (authProvider.isLoggedIn) {
        _logger.i('👤 Usuario logueado, navegando a home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _logger.i('🔑 Usuario no logueado, navegando a login');
        Navigator.pushReplacementNamed(context, '/login');
      }

    } catch (e) {
      _logger.e('❌ Error en inicialización: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
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
            colors: ModernColors.primaryGradient,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _logoScale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Colors.white,
                    size: 60,
                  ),
                ),

                const SizedBox(height: ModernSpacing.xl),

                // Título
                const Text(
                  'ReflectApp',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: ModernSpacing.sm),

                // Subtítulo
                Text(
                  'Tu espacio de reflexión',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: ModernSpacing.xxl),

                // Indicador de carga
                CircularProgressIndicator(
                  color: Colors.white.withValues(alpha: 0.8),
                  strokeWidth: 2,
                ),

                const SizedBox(height: ModernSpacing.lg),

                Text(
                  'Inicializando...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}