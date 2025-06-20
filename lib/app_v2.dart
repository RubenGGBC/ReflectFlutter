// ============================================================================
// app_v2.dart - VERSIÓN CORREGIDA
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
    // ✅ CORRECCIÓN: Se usa MultiProvider para proveer las instancias
    // ya inicializadas por GetIt (di.sl).
    return MultiProvider(
      providers: [
        // Provider para servicios que no notifican cambios (si se necesita acceso directo).
        Provider<DatabaseService>.value(value: di.sl<DatabaseService>()),

        // Providers para clases que sí notifican cambios (ChangeNotifier).
        // Obtenemos la instancia única desde el service locator 'di'.
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => di.sl<ThemeProvider>()..initialize(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => di.sl<AuthProvider>()..initialize(),
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Reflect - Tu Compañero de Bienestar',
            debugShowCheckedModeBanner: false,
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
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            home: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (!auth.isInitialized) {
                  return _buildLoadingScreen();
                }
                if (auth.isLoggedIn) {
                  return const ModernNavigationWrapper();
                } else {
                  return const LoginScreenV2();
                }
              },
            ),
            routes: {
              '/login': (context) => const LoginScreenV2(),
              '/home': (context) => const ModernNavigationWrapper(),
              '/moments': (context) => const InteractiveMomentsScreenV2(),
              '/daily-review': (context) => const DailyReviewScreenV2(),
              '/calendar': (context) => const CalendarScreenV2(),
              '/profile': (context) => const ProfileScreenV2(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => _buildErrorScreen(context, settings.name),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ModernColors.primaryGradient,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Reflect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tu Compañero de Bienestar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String? routeName) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: ModernColors.darkPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ruta no encontrada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                routeName != null
                    ? 'La ruta "$routeName" no existe'
                    : 'La página solicitada no se encontró',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Ir al Inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernColors.accentBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
