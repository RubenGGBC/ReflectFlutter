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
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/image_moments_provider.dart'; // ✅ NUEVO
import 'presentation/providers/analytics_provider.dart'; // ✅ PROVIDER AÑADIDO
import 'presentation/providers/advanced_emotion_analysis_provider.dart'; // ✅ NUEVO PROVIDER AVANZADO
import 'ai/provider/ai_provider.dart';
import 'ai/provider/predective_analysis_provider.dart'; // ✅ NUEVO: Análisis Predictivo
import 'ai/provider/chat_provider.dart'; // ✅ NUEVO: Chat con IA
import 'ai/provider/mental_health_chat_provider.dart'; // ✅ NUEVO: Mental Health Chat
import 'presentation/providers/challenges_provider.dart'; // ✅ HIGH PRIORITY ENHANCEMENT
import 'presentation/providers/streak_provider.dart'; // ✅ HIGH PRIORITY ENHANCEMENT

// Screens
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';
import 'presentation/screens/v2/welcome_onboarding_screen.dart';

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

        // ✅ NUEVO: ImageMomentsProvider
        ChangeNotifierProvider<ImageMomentsProvider>(
          create: (_) => clean_di.sl<ImageMomentsProvider>(),
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

        ChangeNotifierProxyProvider<OptimizedAuthProvider, AnalyticsProvider>(
          create: (_) => clean_di.sl<AnalyticsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadCompleteAnalytics(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        // ✅ NUEVO: AnalyticsProviderOptimized
        ChangeNotifierProxyProvider<OptimizedAuthProvider, AnalyticsProviderOptimized>(
          create: (_) => clean_di.sl<AnalyticsProviderOptimized>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.generarAnalisisCompleto(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        // ✅ NUEVO: PredictiveAnalysisProvider
        ChangeNotifierProxyProvider<OptimizedAuthProvider, PredictiveAnalysisProvider>(
          create: (_) => clean_di.sl<PredictiveAnalysisProvider>(),
          update: (context, auth, previous) {
            // Este provider se activa cuando hay usuario autenticado
            // pero no carga datos automáticamente (solo cuando se llama explícitamente)
            return previous!;
          },
        ),

        // ✅ NUEVO: ChatProvider - Depende del AIProvider
        ChangeNotifierProxyProvider<AIProvider, ChatProvider>(
          create: (_) => clean_di.sl<ChatProvider>(),
          update: (context, ai, previous) {
            // El ChatProvider se inicializa automáticamente cuando AIProvider está disponible
            // El database service se obtiene a través del injection container
            return previous!;
          },
        ),

        // ✅ NUEVO: MentalHealthChatProvider - Independent mental health chat
        ChangeNotifierProvider<MentalHealthChatProvider>(
          create: (_) => clean_di.sl<MentalHealthChatProvider>(),
        ),

        // ✅ HIGH PRIORITY ENHANCEMENTS: New providers
        ChangeNotifierProvider<ChallengesProvider>(
          create: (_) => clean_di.sl<ChallengesProvider>(),
        ),

        ChangeNotifierProvider<StreakProvider>(
          create: (_) => clean_di.sl<StreakProvider>(),
        ),

        // ✅ NUEVO: AdvancedEmotionAnalysisProvider
        ChangeNotifierProxyProvider<OptimizedAuthProvider, AdvancedEmotionAnalysisProvider>(
          create: (_) => clean_di.sl<AdvancedEmotionAnalysisProvider>(),
          update: (context, auth, previous) {
            // Este provider se activa cuando hay usuario autenticado
            // pero no carga datos automáticamente (solo cuando se llama explícitamente)
            return previous!;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReflectFlutter',
            debugShowCheckedModeBanner: false,
            theme: ModernTheme.darkTheme,

            // ✅ CORRECCIÓN: Definir la ruta inicial y las rutas nombradas
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/onboarding': (context) => const WelcomeOnboardingScreen(),
              '/login': (context) => const LoginScreenV2(),
              '/main': (context) => const MainNavigationScreenV2(),
            },
          );
        },
      ),
    );
  }
}

// Wrapper para decidir la pantalla inicial
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    await authProvider.checkFirstTimeUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAuthProvider>(
      builder: (context, auth, child) {
        // Loading state
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check for first time user
        if (auth.isFirstTimeUser) {
          return const WelcomeOnboardingScreen();
        }

        // Single profile per device - skip login screen
        if (auth.isLoggedIn) {
          return const MainNavigationScreenV2();
        } else {
          // This shouldn't happen with single profile per device
          // but fallback to onboarding if no user found
          return const WelcomeOnboardingScreen();
        }
      },
    );
  }
}

// ============================================================================
// HELPER PARA LOGGING
// ============================================================================

final Logger _logger = clean_di.sl<Logger>();

void logProvider(String providerName, String action) {
  _logger.d('🔄 Provider: $providerName - Action: $action');
}

// ============================================================================
// EJEMPLO DE USO DE LOGGING
// ============================================================================

void exampleUsage() {
  logProvider('OptimizedAuthProvider', 'Initializing...');
  // ...
  logProvider('OptimizedAuthProvider', 'User logged in');
}

// ============================================================================
// VERIFICACIÓN DE ESTADO DE PROVIDERS
// ============================================================================

void checkProviderStatus(BuildContext context) {
  final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
  final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);

  _logger.i('Provider Status Check:');
  _logger.i('  - AuthProvider Logged In: ${authProvider.isLoggedIn}');
  _logger.i('  - DailyEntriesProvider Entries Loaded: ${dailyEntriesProvider.entries.isNotEmpty}');
}

// ============================================================================
// INICIALIZACIÓN DE SERVICIOS CRÍTICOS
// ============================================================================

Future<void> initializeCriticalServices() async {
  await clean_di.initCriticalServices();
}