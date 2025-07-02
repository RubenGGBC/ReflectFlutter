// lib/optimized_reflect_app.dart
// VERSIÓN FINAL CON LÓGICA DE NAVEGACIÓN CORREGIDA + IA + NOTIFICATIONS

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// Dependency Injection optimizado
import 'injection_container_clean.dart' as clean_di;

// Providers
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/extended_daily_entries_provider.dart';
import 'presentation/providers/notifications_provider.dart'; // ✅ NUEVO
import 'presentation/providers/theme_provider.dart';
import 'ai/provider/ai_provider.dart';

// Services
import '../../data/services/notification_service.dart'; // ✅ NUEVO

// Screens
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';
import 'presentation/screens/v2/notifications_settings_screen.dart'; // ✅ NUEVO

// Components
import 'presentation/screens/components/modern_design_system.dart';

class OptimizedReflectApp extends StatelessWidget {
  const OptimizedReflectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ============================================================================
        // CORE PROVIDERS (independientes)
        // ============================================================================
        ChangeNotifierProvider<OptimizedAuthProvider>(
          create: (_) => clean_di.sl<OptimizedAuthProvider>()..initialize(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => clean_di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<AIProvider>(
          create: (_) => clean_di.sl<AIProvider>(),
        ),
        ChangeNotifierProvider<GoalsProvider>(
          create: (_) => clean_di.sl<GoalsProvider>(),
        ),

        // ✅ NUEVO: NotificationsProvider
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => clean_di.sl<NotificationsProvider>()..initialize(),
        ),

        // ============================================================================
        // PROVIDERS DEPENDIENTES (se actualizan cuando el usuario se autentica)
        // ============================================================================
        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedDailyEntriesProvider>(
          create: (_) => clean_di.sl<OptimizedDailyEntriesProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadEntries(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        // ExtendedDailyEntriesProvider con IA
        ChangeNotifierProxyProvider<OptimizedAuthProvider, ExtendedDailyEntriesProvider>(
          create: (_) => clean_di.sl<ExtendedDailyEntriesProvider>(),
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

        // GoalsProvider dependiente del auth
        ChangeNotifierProxyProvider<OptimizedAuthProvider, GoalsProvider>(
          create: (_) => clean_di.sl<GoalsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadUserGoals(auth.currentUser!.id);
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
            // ✅ CONFIGURAR NAVEGACIÓN INICIAL
            home: const AppInitializer(),

            // ✅ RUTAS DE NAVEGACIÓN ACTUALIZADAS
            routes: {
              '/login': (context) => const LoginScreenV2(),
              '/home': (context) => const MainNavigationScreenV2(),
              '/daily-review': (context) => const MainNavigationScreenV2(), // Navegará a la pestaña correcta
              '/goals': (context) => const MainNavigationScreenV2(), // Navegará a goals
              '/notifications-settings': (context) => const NotificationsSettingsScreen(), // ✅ NUEVO
            },

            // ✅ NUEVO: Navegador global para notificaciones
            navigatorKey: AppNavigationService.navigatorKey,
          );
        },
      ),
    );
  }
}

// ============================================================================
// INICIALIZADOR DE LA APP
// ============================================================================

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // ✅ NUEVO: Configurar callback de notificaciones
      NotificationService.onNotificationTap = (payload) {
        AppNavigationService.handleNotificationTap(payload);
      };

      // Otras inicializaciones si es necesario

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Log error pero continuar
      debugPrint('Error en inicialización: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const LoadingScreen();
    }

    return const AuthWrapper();
  }
}

// ============================================================================
// SERVICIO DE NAVEGACIÓN GLOBAL
// ============================================================================

class AppNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Manejar navegación cuando se toca una notificación
  static void handleNotificationTap(String? payload) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (payload) {
      case 'daily_reflection':
      // Navegar a la pantalla de reflexión diaria
        _navigateToReflection(context);
        break;
      case 'evening_checkin':
      // Navegar a momentos o home
        _navigateToMoments(context);
        break;
      case 'weekly_review':
      // Navegar a analytics
        _navigateToAnalytics(context);
        break;
      case 'motivational':
      // Navegar a home
        _navigateToHome(context);
        break;
      case 'test':
      // Mostrar mensaje de prueba
        _showTestMessage(context);
        break;
      default:
      // Navegar a home por defecto
        _navigateToHome(context);
        break;
    }
  }

  static void _navigateToReflection(BuildContext context) {
    // Verificar si el usuario está logueado
    final authProvider = context.read<OptimizedAuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Navegar a la pantalla principal y luego a reflexión diaria
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/daily-review',
          (route) => false,
    );
  }

  static void _navigateToMoments(BuildContext context) {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  static void _navigateToAnalytics(BuildContext context) {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  static void _navigateToHome(BuildContext context) {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (!authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  static void _showTestMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧪 ¡Notificación de prueba funcionando!'),
        backgroundColor: Color(0xFF4ECDC4),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// ============================================================================
// WRAPPER DE AUTENTICACIÓN
// ============================================================================

/// Widget que decide qué pantalla mostrar basado en el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAuthProvider>(
      builder: (context, authProvider, child) {
        // Muestra una pantalla de carga mientras el provider se inicializa
        if (!authProvider.isInitialized) {
          return const LoadingScreen();
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

// ============================================================================
// PANTALLA DE CARGA MEJORADA
// ============================================================================

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.forward();

    // Repetir rotación del indicador de carga
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat(period: const Duration(seconds: 2));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo o ícono de la app con animación
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 40),

                // Título
                const Text(
                  'ReflectFlutter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtítulo con animación
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value * 0.8,
                      child: const Text(
                        'Preparando tu experiencia de reflexión...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),

                // Indicador de carga animado
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Colors.transparent],
                              stops: [0.0, 0.7],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Texto de estado
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    final messages = [
                      'Inicializando notificaciones...',
                      'Configurando servicios...',
                      'Preparando interfaz...',
                      'Casi listo...',
                    ];
                    final index = (_rotationAnimation.value * messages.length).floor() % messages.length;

                    return Text(
                      messages[index],
                      style: TextStyle(
                        color: const Color(0xFF4ECDC4).withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HELPER PARA MANEJO DE ESTADO GLOBAL
// ============================================================================

class AppStateManager {
  static void handleUserLogin(BuildContext context) {
    // Lógica adicional cuando el usuario hace login
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      // Cargar datos iniciales
      context.read<OptimizedDailyEntriesProvider>().loadEntries(user.id);
      context.read<ExtendedDailyEntriesProvider>().loadEntries(user.id);
      context.read<OptimizedMomentsProvider>().loadMoments(user.id);
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id);
      context.read<GoalsProvider>().loadUserGoals(user.id);

      // ✅ NUEVO: Configurar notificaciones después del login
      _setupNotificationsAfterLogin(context);
    }
  }

  static void handleUserLogout(BuildContext context) {
    // Limpiar datos cuando el usuario hace logout
    context.read<ExtendedDailyEntriesProvider>().clearRecommendations();

    // ✅ NUEVO: Limpiar notificaciones al logout si es necesario
    // Las notificaciones pueden seguir activas incluso después del logout
  }

  // ✅ NUEVO: Configurar notificaciones después del login
  static void _setupNotificationsAfterLogin(BuildContext context) {
    try {
      final notificationsProvider = context.read<NotificationsProvider>();
      // Las notificaciones ya están configuradas, pero puedes agregar lógica específica aquí
    } catch (e) {
      debugPrint('Error configurando notificaciones: $e');
    }
  }
}

// ============================================================================
// INTERCEPTOR DE ERRORES GLOBAL
// ============================================================================

class GlobalErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Log del error
    final logger = clean_di.sl<Logger>();

    // Aquí puedes agregar lógica adicional como:
    // - Enviar errores a un servicio de tracking
    // - Mostrar notificaciones al usuario
    // - Reiniciar ciertos providers si es necesario
  }

  static Widget buildErrorWidget(FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Algo salió mal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Por favor, reinicia la aplicación',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Reiniciar la app o navegar a home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}