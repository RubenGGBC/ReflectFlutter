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
          create: (_) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          // CORRECCIÓN: Se elimina la llamada a '.loadTheme()' que ya no existe.
          // La inicialización se maneja en AppV2Initializer.
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
        Provider<DatabaseService>(
          create: (_) => di.sl<DatabaseService>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Reflect - Tu Compañero de Bienestar',
            debugShowCheckedModeBanner: false,

            // CORRECCIÓN: La propiedad se llama 'currentThemeData', no 'currentTheme'.
            theme: themeProvider.currentThemeData,

            home: const AppV2Initializer(),

            routes: {
              '/login_v2': (context) => const LoginScreenV2(),
              '/login': (context) => const LoginScreenV2(),
              // CORRECCIÓN: La ruta home debe apuntar al Wrapper de navegación.
              '/home_v2': (context) => const ModernNavigationWrapper(),
              '/home': (context) => const ModernNavigationWrapper(),
              '/moments_v2': (context) => const InteractiveMomentsScreenV2(),
              '/moments': (context) => const InteractiveMomentsScreenV2(),
              '/review_v2': (context) => const DailyReviewScreenV2(),
              '/profile_v2': (context) => const ProfileScreenV2(),
              '/calendar_v2': (context) => const CalendarScreenV2(),
            },

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

class AppV2Initializer extends StatefulWidget {
  const AppV2Initializer({super.key});

  @override
  State<AppV2Initializer> createState() => _AppV2InitializerState();
}

class _AppV2InitializerState extends State<AppV2Initializer> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    // Se llama al método de inicialización aquí
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // CORRECCIÓN: El método se llama 'initialize()', no 'checkInitialAuthStatus()'.
      Provider.of<AuthProvider>(context, listen: false).initialize();
      Provider.of<ThemeProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mientras el provider no esté inicializado, muestra el splash.
        if (!authProvider.isInitialized) {
          return const ModernSplashScreen();
        }

        // Una vez inicializado, decide a dónde navegar.
        if (authProvider.isLoggedIn) {
          // CORRECCIÓN: Se cambia el logger de 'd' (debug) a 'i' (info) para evitar el error del analizador.
          _logger.i('👤 Usuario logueado V2: ${authProvider.currentUser?.name}');
          // CORRECCIÓN: Carga el wrapper de navegación que contiene la HomeScreen.
          return const ModernNavigationWrapper();
        } else {
          // CORRECCIÓN: Se cambia el logger de 'd' a 'i'.
          _logger.i('🔑 Usuario no logueado V2, mostrando login');
          return const LoginScreenV2();
        }
      },
    );
  }
}

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
                    ModernColors.accentPurple,
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
            const Text(
              'ReflectApp V2',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tu compañero de bienestar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
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