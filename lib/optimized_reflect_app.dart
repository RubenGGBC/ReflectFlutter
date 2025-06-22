// lib/optimized_reflect_app.dart - VERSIÓN CON TODAS LAS RUTAS CORREGIDAS

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
import 'presentation/screens/v2/analytics_screen_V2.dart';
import 'presentation/screens/v2/profile_screen_v2.dart';


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
            title: 'Reflect - Tu Compañero de Bienestar',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(),
            home: const AppInitializer(),
            // ✅ RUTAS CORREGIDAS Y COMPLETADAS
            routes: {
              '/login': (context) => const LoginScreenV2(),
              '/main': (context) => const MainNavigationScreenV2(),
              '/moments': (context) => const InteractiveMomentsScreenV2(),
              '/review': (context) => const DailyReviewScreenV2(),
              '/analytics': (context) => const AnalyticsScreenV2(),
              '/profile': (context) => const ProfileScreenV2(),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      fontFamily: 'System',
    );
  }
}

// ============================================================================
// INICIALIZADOR SIMPLE Y FUNCIONAL (SIN CAMBIOS)
// ============================================================================

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  String _status = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _status = 'Inicializando proveedores...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _status = 'Verificando autenticación...');
      final authProvider = context.read<OptimizedAuthProvider>();
      await authProvider.initialize();

      setState(() => _status = 'Configurando tema...');
      await Future.delayed(const Duration(milliseconds: 300));

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Reflect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu compañero de bienestar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}