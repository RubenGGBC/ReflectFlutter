// lib/optimized_reflect_app.dart
// VERSIÓN FINAL CON LÓGICA DE NAVEGACIÓN CORREGIDA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/presentation/screens/components/modern_design_system.dart';

// Dependency Injection optimizado
import 'injection_container_clean.dart' as clean_di;

// Providers
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/theme_provider.dart';
import 'ai/provider/ai_provider.dart';

// Screens
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';

class OptimizedReflectApp extends StatelessWidget {
  const OptimizedReflectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OptimizedAuthProvider>(
          create: (_) => clean_di.sl<OptimizedAuthProvider>()..initialize(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => clean_di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<AIProvider>(
          create: (_) => clean_di.sl<AIProvider>(),

        ),
        ChangeNotifierProvider(create: (_) => clean_di.sl<GoalsProvider>()),

        // ✅ Providers dependientes se crean después del AuthProvider
        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedDailyEntriesProvider>(
          create: (_) => clean_di.sl<OptimizedDailyEntriesProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadEntries(auth.currentUser!.id);
            }
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedMomentsProvider>(
          create: (_) => clean_di.sl<OptimizedMomentsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadMoments(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedAnalyticsProvider>(
          create: (_) => clean_di.sl<OptimizedAnalyticsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadCompleteAnalytics(auth.currentUser!.id);
            }
            return previous!;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReflectFlutter',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentThemeData,
            // ✅ CORRECCIÓN: La lógica de navegación se maneja aquí
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// ✅ NUEVO WIDGET: Decide qué pantalla mostrar basado en el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAuthProvider>(
      builder: (context, authProvider, child) {
        // Muestra una pantalla de carga mientras el provider se inicializa
        if (!authProvider.isInitialized) {
          return const Scaffold(
            backgroundColor: ModernColors.darkPrimary,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // Una vez inicializado, decide a dónde ir
        if (authProvider.isLoggedIn) {
          return const MainNavigationScreenV2();
        } else {
          return const LoginScreenV2();
        }
      },
    );
  }
}
