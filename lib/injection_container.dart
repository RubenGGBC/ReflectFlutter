// ============================================================================
// injection_container.dart - VERSIÓN FINAL SIN NOTIFICACIONES
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:untitled3/presentation/providers/analytics_provider.dart';

import 'data/services/database_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/interactive_moments_provider.dart';
// import 'presentation/providers/notifications_provider.dart'; // FIX: Removed notifications provider

final sl = GetIt.instance;

Future<void> init() async {
  final logger = Logger();
  logger.i('🔧 Inicializando contenedor de dependencias...');

  try {
    // ============================================================================
    // Core Services
    // ============================================================================

    // Database Service - Singleton
    sl.registerLazySingleton<DatabaseService>(() => DatabaseService());

    // Logger - Singleton
    sl.registerLazySingleton<Logger>(() => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      ),
    ));

    // ============================================================================
    // Providers
    // ============================================================================

    // Auth Provider - Singleton
    sl.registerLazySingleton<AuthProvider>(
          () => AuthProvider(sl<DatabaseService>()),
    );

    // Theme Provider - Singleton
    sl.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
    sl.registerLazySingleton<AnalyticsProvider>(
          () => AnalyticsProvider(sl<DatabaseService>()),
    );
    // Interactive Moments Provider - Singleton
    sl.registerLazySingleton<InteractiveMomentsProvider>(
          () => InteractiveMomentsProvider(sl<DatabaseService>()),
    );

    // Notifications Provider - Singleton  // FIX: Removed notifications provider
    // sl.registerLazySingleton<NotificationsProvider>(
    //       () => NotificationsProvider(),
    // );

    logger.i('✅ Contenedor de dependencias inicializado');

  } catch (e) {
    logger.e('❌ Error inicializando dependencias: $e');
    rethrow;
  }
}
