// ============================================================================
// injection_container.dart - VERSIÓN COMPLETA CORREGIDA
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Services
import 'data/services/database_service.dart';
import 'data/services/advanced_user_analytics.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/interactive_moments_provider.dart';
import 'presentation/providers/analytics_provider.dart';
import 'presentation/providers/enhanced_analytics_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final logger = Logger();
  logger.i('🔧 Inicializando contenedor de dependencias...');

  try {
    // ============================================================================
    // CORE SERVICES
    // ============================================================================

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

    // Database Service - Singleton
    sl.registerLazySingleton<DatabaseService>(() => DatabaseService());

    // Advanced User Analytics Service
    sl.registerLazySingleton<AdvancedUserAnalytics>(
          () => AdvancedUserAnalytics(sl<DatabaseService>()),
    );

    // ============================================================================
    // PROVIDERS - ¡ESTA SECCIÓN ESTABA FALTANDO!
    // ============================================================================

    // Auth Provider - Singleton
    sl.registerLazySingleton<AuthProvider>(
          () => AuthProvider(sl<DatabaseService>()),
    );

    // Theme Provider - Singleton
    sl.registerLazySingleton<ThemeProvider>(
          () => ThemeProvider(),
    );

    // Interactive Moments Provider - Singleton
    sl.registerLazySingleton<InteractiveMomentsProvider>(
          () => InteractiveMomentsProvider(sl<DatabaseService>()),
    );

    // Analytics Provider - Singleton
    sl.registerLazySingleton<AnalyticsProvider>(
          () => AnalyticsProvider(sl<DatabaseService>()),
    );

    // Enhanced Analytics Provider - Singleton
    sl.registerLazySingleton<EnhancedAnalyticsProvider>(
          () => EnhancedAnalyticsProvider(sl<DatabaseService>()),
    );

    logger.i('✅ Contenedor de dependencias inicializado correctamente');

  } catch (e) {
    logger.e('❌ Error inicializando dependencias: $e');
    rethrow;
  }
}

// ============================================================================
// FUNCIONES AUXILIARES PARA DEPENDENCY INJECTION
// ============================================================================

/// Verificar si todos los servicios están registrados
bool areAllServicesRegistered() {
  try {
    // Verificar servicios core
    sl<DatabaseService>();
    sl<Logger>();
    sl<AdvancedUserAnalytics>();

    // Verificar providers
    sl<AuthProvider>();
    sl<ThemeProvider>();
    sl<InteractiveMomentsProvider>();
    sl<AnalyticsProvider>();
    sl<EnhancedAnalyticsProvider>();

    return true;
  } catch (e) {
    return false;
  }
}

/// Obtener información del contenedor
Map<String, dynamic> getContainerInfo() {
  return {
    'total_services': sl.allReady().length,
    'services_ready': areAllServicesRegistered(),
    'registered_types': [
      'DatabaseService',
      'Logger',
      'AdvancedUserAnalytics',
      'AuthProvider',
      'ThemeProvider',
      'InteractiveMomentsProvider',
      'AnalyticsProvider',
      'EnhancedAnalyticsProvider',
    ],
  };
}

extension on Future<void> {
  get length => null;
}

/// Resetear contenedor (útil para testing)
Future<void> resetContainer() async {
  await sl.reset();
}

/// Inicialización para testing
Future<void> initForTesting() async {
  if (sl.isRegistered<DatabaseService>()) {
    await resetContainer();
  }
  await init();
}

// ============================================================================
// CONSTANTES DE CONFIGURACIÓN
// ============================================================================

class DIConstants {
  static const String databaseService = 'DatabaseService';
  static const String logger = 'Logger';
  static const String advancedAnalytics = 'AdvancedUserAnalytics';
  static const String authProvider = 'AuthProvider';
  static const String themeProvider = 'ThemeProvider';
  static const String momentsProvider = 'InteractiveMomentsProvider';
  static const String analyticsProvider = 'AnalyticsProvider';
  static const String enhancedAnalyticsProvider = 'EnhancedAnalyticsProvider';
}

// ============================================================================
// EXTENSION PARA FACILITAR EL USO
// ============================================================================

extension GetItExtension on GetIt {
  /// Verificar si un tipo está registrado de forma segura
  bool isRegisteredSafe<T extends Object>() {
    try {
      return isRegistered<T>();
    } catch (e) {
      return false;
    }
  }

  /// Obtener instancia de forma segura
  T? getSafe<T extends Object>() {
    try {
      if (isRegistered<T>()) {
        return get<T>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}