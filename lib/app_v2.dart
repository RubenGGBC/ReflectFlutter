// ============================================================================
// app_v2.dart - VERSIÓN SIN EL PROVIDER DE NOTIFICACIONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/interactive_moments_provider.dart';
// import 'presentation/providers/notifications_provider.dart'; // FIX: Removed notifications provider

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
        // ChangeNotifierProvider<NotificationsProvider>(  // FIX: Removed notifications provider
        //   create: (_) => di.sl<NotificationsProvider>()..initialize(),
        // ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReflectApp v2 - Tu espacio de reflexión',
            debugShowCheckedModeBanner: false,
            theme: ModernTheme.darkTheme,
            initialRoute: '/splash',
            routes: _buildRoutes(),
            builder: (context, child) {
              return _AppWrapper(child: child);
            },
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/splash': (context) => const SplashScreenV2(),
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
// WRAPPER PARA CONFIGURACIONES GLOBALES
// ============================================================================

class _AppWrapper extends StatelessWidget {
  final Widget? child;

  const _AppWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: child ?? const SizedBox(),
    );
  }
}

// ============================================================================
// SPLASH SCREEN MODERNA (Debería estar en su propio archivo)
// ============================================================================

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({super.key});

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoController.forward();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      if (authProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
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
            colors: [
              Color(0xFF0a0e27),
              Color(0xFF2d1b69),
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _logoScale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: ModernColors.primaryGradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ModernColors.primaryGradient.first.withOpacity(0.3),
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
                const SizedBox(height: ModernSpacing.lg),
                Text('ReflectApp', style: ModernTypography.heading1.copyWith(fontSize: 42)),
                Text('Tu espacio de reflexión', style: ModernTypography.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
