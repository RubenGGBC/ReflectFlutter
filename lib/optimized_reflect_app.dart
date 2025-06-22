// lib/optimized_reflect_app.dart - APLICACIÓN ARREGLADA COMPLETAMENTE

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Dependency Injection optimizado
import 'injection_container_clean.dart' as clean_di;

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/theme_provider.dart';

// Screens que SÍ EXISTEN
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';

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
            home: const AppInitializer(), // ✅ INICIALIZADOR SIMPLE
            routes: {
              '/login': (context) => const LoginScreenV2(),
              '/main': (context) => const MainNavigationScreenV2(),
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
// INICIALIZADOR SIMPLE Y FUNCIONAL
// ============================================================================

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
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

      // Inicializar Auth Provider
      setState(() => _status = 'Verificando autenticación...');
      final authProvider = context.read<OptimizedAuthProvider>();
      await authProvider.initialize();

      setState(() => _status = 'Configurando tema...');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _status = 'Completado');
      await Future.delayed(const Duration(milliseconds: 500));

      // Decidir a dónde navegar
      if (mounted) {
        if (authProvider.isLoggedIn && authProvider.currentUser != null) {
          // Usuario ya logueado → Ir a navegación principal
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreenV2()),
          );
        } else {
          // Usuario no logueado → Ir a login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreenV2()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Error: ${e.toString()}');
        // En caso de error, ir a login
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreenV2()),
        );
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
              // Logo/Icon
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

              // Título
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

              // Indicador de progreso
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              ),
              const SizedBox(height: 24),

              // Estado
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