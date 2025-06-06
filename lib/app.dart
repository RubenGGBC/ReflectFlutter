// ============================================================================
// app.dart - VERSIÓN COMPLETA ACTUALIZADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/interactive_moments_provider.dart';
import 'presentation/screens/Login_screen.dart';
import 'presentation/screens/Register_screen.dart';
import 'presentation/screens/interactive_moments_screen.dart';
import 'presentation/screens/calendar_screen.dart';
import 'presentation/screens/daily_review_screen.dart';
import 'presentation/screens/theme_selector_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'injection_container.dart' as di;
import 'presentation/screens/daily_detail_screen.dart';

class ReflectApp extends StatelessWidget {
  const ReflectApp({Key? key}) : super(key: key);

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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReflectApp - Tu espacio de reflexión',
            debugShowCheckedModeBanner: false,

            // Aplicar tema dinámico
            theme: themeProvider.currentThemeData,

            // Configuración inicial
            home: const AppInitializer(),

            // ✅ RUTAS COMPLETAS ACTUALIZADAS
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/interactive_moments': (context) => const InteractiveMomentsScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/daily_review': (context) => const DailyReviewScreen(),
              '/theme_selector': (context) => const ThemeSelectorScreen(),
              '/profile': (context) => const ProfileScreen(),
            },

            // Manejar rutas no encontradas
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget que maneja la inicialización y navegación inicial
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final Logger _logger = Logger();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _logger.i('🔄 Inicializando ReflectApp...');

    try {
      // Esperar a que los providers se inicialicen
      final authProvider = context.read<AuthProvider>();
      final themeProvider = context.read<ThemeProvider>();

      await Future.wait([
        authProvider.initialize(),
        themeProvider.initialize(),
      ]);

      _logger.i('✅ ReflectApp inicializada correctamente');

      // Pequeña pausa para mostrar splash
      await Future.delayed(const Duration(milliseconds: 500));

    } catch (e) {
      _logger.e('❌ Error en inicialización: $e');
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
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mostrar loading si aún está inicializando
        if (!authProvider.isInitialized) {
          return const SplashScreen();
        }

        // Navegar según estado de autenticación
        if (authProvider.isLoggedIn) {
          _logger.d('👤 Usuario logueado: ${authProvider.currentUser?.name}');
          return const InteractiveMomentsScreen();
        } else {
          _logger.d('🔑 Usuario no logueado, mostrando login');
          return const LoginScreen();
        }
      },
    );
  }
}

/// Pantalla de splash mientras se inicializa la app
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono principal con gradiente
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🧘‍♀️',
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Título
            Text(
              'ReflectApp',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Tu santuario zen',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Indicador de carga
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
                strokeWidth: 3,
              ),
            ),

            const SizedBox(height: 16),

            // Texto de carga
            Text(
              'Inicializando...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}