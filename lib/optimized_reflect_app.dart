// lib/optimized_reflect_app.dart
// ✅ VERSIÓN ACTUALIZADA CON COACH IA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Dependency Injection optimizado
import 'injection_container_clean.dart' as clean_di;

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/theme_provider.dart';

// Screens para las rutas
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';
import 'presentation/screens/v2/interactive_moments_screen_v2.dart';
import 'presentation/screens/v2/daily_review_screen_v2.dart';
import 'presentation/screens/v2/analytics_screen_v2.dart';
import 'presentation/screens/v2/profile_screen_v2.dart';
import 'presentation/screens/v2/ai_coach_screen.dart'; // ✅ NUEVA PANTALLA

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
            title: 'ReflectFlutter',
            debugShowCheckedModeBanner: false,

            // ✅ RUTAS ACTUALIZADAS
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const _SplashScreen(),
              '/login': (context) => const LoginScreenV2(),
              '/auth': (context) => const LoginScreenV2(),
              '/main': (context) => const MainNavigationScreenV2(),

              // ✅ RUTAS INDIVIDUALES PARA NAVEGACIÓN DIRECTA (OPCIONAL)
              '/home': (context) => const MainNavigationScreenV2(),
              '/moments': (context) => const InteractiveMomentsScreenV2(),
              '/daily-review': (context) => const DailyReviewScreenV2(),
              '/analytics': (context) => const AnalyticsScreenV2(),
              '/ai-coach': (context) => const AICoachScreenV2(), // ✅ NUEVA RUTA
              '/profile': (context) => const ProfileScreenV2(),
            },

            // ✅ MANEJO DE RUTAS NO ENCONTRADAS
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const MainNavigationScreenV2(),
              );
            },
          );
        },
      ),
    );
  }
}

// ✅ PANTALLA DE SPLASH MEJORADA
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _status = 'Inicializando...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _status = 'Inicializando proveedores...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() => _status = 'Verificando autenticación...');
      final authProvider = context.read<OptimizedAuthProvider>();
      await authProvider.initialize();

      setState(() => _status = 'Configurando tema...');
      await Future.delayed(const Duration(milliseconds: 400));

      setState(() => _status = 'Preparando Coach IA...');
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() => _status = 'Completado');
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        if (authProvider.isLoggedIn && authProvider.currentUser != null) {
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Error: ${e.toString()}');
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
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
                      // ✅ LOGO PRINCIPAL
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.shade400,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade400.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ✅ NOMBRE DE LA APP
                      const Text(
                        'ReflectFlutter',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ✅ SUBTÍTULO
                      Text(
                        'Tu compañero de bienestar con IA',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // ✅ INDICADOR DE PROGRESO
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.purple.shade400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ✅ ESTADO ACTUAL
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}