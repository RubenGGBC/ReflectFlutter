// ============================================================================
// injection_container_clean.dart - DEPENDENCY INJECTION OPTIMIZADO - FIXED
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Services optimizados
import 'data/services/optimized_database_service.dart';

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'ai/provider/ai_provider.dart';

// Theme provider (reutilizado del original)
import 'presentation/providers/theme_provider.dart';

final sl = GetIt.instance;

/// Inicializar todas las dependencias de la app limpia
Future<void> initCleanDependencies() async {
  final logger = Logger();
  logger.i('🧹 Inicializando dependencias limpias...');

  try {
    // ============================================================================
    // CORE SERVICES (Singletons - solo una instancia)
    // ============================================================================
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

    sl.registerLazySingleton<OptimizedDatabaseService>(
          () => OptimizedDatabaseService(),
    );

    // ============================================================================
    // PROVIDERS (Factories - nueva instancia cuando se pide)
    // ✅ CORREGIDO: Se cambia de registerLazySingleton a registerFactory para
    // evitar problemas de estado entre Hot Restarts.
    // ============================================================================

    sl.registerFactory<OptimizedAuthProvider>(
          () => OptimizedAuthProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<ThemeProvider>(
          () => ThemeProvider(),
    );

    sl.registerFactory<OptimizedDailyEntriesProvider>(
          () => OptimizedDailyEntriesProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<OptimizedMomentsProvider>(
          () => OptimizedMomentsProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<OptimizedAnalyticsProvider>(
          () => OptimizedAnalyticsProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<AIProvider>(
          () => AIProvider(),
    );

    logger.i('✅ Dependencias limpias inicializadas correctamente');

  } catch (e) {
    logger.e('❌ Error inicializando dependencias limpias: $e');
    rethrow;
  }
}

// ============================================================================
// FUNCIONES DE UTILIDAD (SIN CAMBIOS)
// ============================================================================

/// Verificar que todos los servicios estén registrados
bool areCleanServicesRegistered() {
  try {
    // Verificar servicios core
    sl<Logger>();
    sl<OptimizedDatabaseService>();

    // Verificar providers
    sl<OptimizedAuthProvider>();
    sl<ThemeProvider>();
    sl<OptimizedDailyEntriesProvider>();
    sl<OptimizedMomentsProvider>();
    sl<OptimizedAnalyticsProvider>();
    sl<AIProvider>();

    return true;
  } catch (e) {
    return false;
  }
}

/// Información del contenedor limpio
Map<String, dynamic> getCleanContainerInfo() {
  return {
    'total_services': 8,
    'services_ready': areCleanServicesRegistered(),
    'core_services': [
      'Logger',
      'OptimizedDatabaseService',
    ],
    'providers': [
      'OptimizedAuthProvider',
      'ThemeProvider',
      'OptimizedDailyEntriesProvider',
      'OptimizedMomentsProvider',
      'OptimizedAnalyticsProvider',
      'AIProvider',
    ],
    'removed_legacy': [
      'AnalyticsProvider (legacy)',
      'EnhancedAnalyticsProvider (duplicate)',
      'InteractiveMomentsProvider (legacy)',
      'AuthProvider (legacy)',
      'NotificationsProvider (unused)',
      'AdvancedUserAnalytics (merged)',
    ],
  };
}

/// Resetear contenedor para testing
Future<void> resetCleanContainer() async {
  await sl.reset();
}

/// Inicialización específica para testing
Future<void> initForCleanTesting() async {
  if (sl.isRegistered<OptimizedDatabaseService>()) {
    await resetCleanContainer();
  }
  await initCleanDependencies();
}

// ============================================================================
// EXTENSIONES PARA FACILITAR USO (SIN CAMBIOS)
// ============================================================================

extension CleanGetItExtension on GetIt {
  /// Verificar si un tipo está registrado de forma segura
  bool isRegisteredClean<T extends Object>() {
    try {
      return isRegistered<T>();
    } catch (e) {
      return false;
    }
  }

  /// Obtener instancia de forma segura
  T? getCleanSafe<T extends Object>() {
    try {
      if (isRegistered<T>()) {
        return get<T>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener servicio principal con verificación
  T getCleanService<T extends Object>() {
    if (!isRegistered<T>()) {
      throw Exception('Servicio $T no está registrado. Llama a initCleanDependencies() primero.');
    }
    return get<T>();
  }
}

// ============================================================================
// CONSTANTES DE IDENTIFICACIÓN (SIN CAMBIOS)
// ============================================================================

class CleanDIConstants {
  static const String logger = 'Logger';
  static const String databaseService = 'OptimizedDatabaseService';
  static const String authProvider = 'OptimizedAuthProvider';
  static const String themeProvider = 'ThemeProvider';
  static const String dailyEntriesProvider = 'OptimizedDailyEntriesProvider';
  static const String momentsProvider = 'OptimizedMomentsProvider';
  static const String analyticsProvider = 'OptimizedAnalyticsProvider';
  static const String aiProvider = 'AIProvider';
}

// ============================================================================
// HELPER PARA MIGRACIÓN GRADUAL (SIN CAMBIOS)
// ============================================================================

class DIMigrationHelper {
  static const Map<String, String> _migrationMap = {
    'AuthProvider': 'OptimizedAuthProvider',
    'InteractiveMomentsProvider': 'OptimizedMomentsProvider',
    'AnalyticsProvider': 'OptimizedAnalyticsProvider',
    'DatabaseService': 'OptimizedDatabaseService',
  };

  static String? getOptimizedServiceName(String legacyName) {
    return _migrationMap[legacyName];
  }

  static bool hasOptimizedEquivalent(String legacyName) {
    return _migrationMap.containsKey(legacyName);
  }

  static List<String> getLegacyServicesToRemove() {
    return [
      'AdvancedUserAnalytics',
      'EnhancedAnalyticsProvider',
      'NotificationsProvider',
      'SessionService',
    ];
  }

  static Map<String, dynamic> checkMigrationStatus() {
    final isLegacyPresent = false;
    final isOptimizedPresent = sl.isRegisteredClean<OptimizedAuthProvider>();
    return {
      'legacy_present': isLegacyPresent,
      'optimized_present': isOptimizedPresent,
      'migration_complete': !isLegacyPresent && isOptimizedPresent,
      'conflicts': isLegacyPresent && isOptimizedPresent,
    };
  }
}

// ============================================================================
// CONFIGURACIÓN DE LOGGING OPTIMIZADA (SIN CAMBIOS)
// ============================================================================

class OptimizedLoggingConfig {
  static Logger createProductionLogger() {
    return Logger(
      level: Level.info,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 3,
        lineLength: 80,
        colors: false,
        printEmojis: false,
        printTime: true,
      ),
    );
  }

  static Logger createDevelopmentLogger() {
    return Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      ),
    );
  }

  static Logger createTestingLogger() {
    return Logger(
      level: Level.warning,
      printer: SimplePrinter(),
    );
  }
}

// ============================================================================
// INICIALIZADORES ESPECÍFICOS POR ENTORNO (SIN CAMBIOS)
// ============================================================================

Future<void> initForProduction() async {
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createProductionLogger());
  await initCleanDependencies();
}

Future<void> initForDevelopment() async {
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createDevelopmentLogger());
  await initCleanDependencies();
}

Future<void> initForTesting() async {
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createTestingLogger());
  await initCleanDependencies();
}
