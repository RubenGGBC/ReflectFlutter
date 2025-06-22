// ============================================================================
// injection_container_clean.dart - DEPENDENCY INJECTION OPTIMIZADO - FIXED
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Services optimizados
import 'data/services/optimized_database_service.dart';

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';

// Theme provider (reutilizado del original)
import 'presentation/providers/theme_provider.dart';

final sl = GetIt.instance;

/// Inicializar todas las dependencias de la app limpia
Future<void> initCleanDependencies() async {
  final logger = Logger();
  logger.i('🧹 Inicializando dependencias limpias...');

  try {
    // ============================================================================
    // CORE SERVICES
    // ============================================================================

    // Logger optimizado
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

    // Database Service optimizado - SINGLETON
    sl.registerLazySingleton<OptimizedDatabaseService>(
          () => OptimizedDatabaseService(),
    );

    // ============================================================================
    // PROVIDERS PRINCIPALES
    // ============================================================================

    // Auth Provider optimizado
    sl.registerLazySingleton<OptimizedAuthProvider>(
          () => OptimizedAuthProvider(sl<OptimizedDatabaseService>()),
    );

    // Theme Provider (reutilizado)
    sl.registerLazySingleton<ThemeProvider>(
          () => ThemeProvider(),
    );

    // Daily Entries Provider
    sl.registerLazySingleton<OptimizedDailyEntriesProvider>(
          () => OptimizedDailyEntriesProvider(sl<OptimizedDatabaseService>()),
    );

    // Interactive Moments Provider
    sl.registerLazySingleton<OptimizedMomentsProvider>(
          () => OptimizedMomentsProvider(sl<OptimizedDatabaseService>()),
    );

    // Analytics Provider
    sl.registerLazySingleton<OptimizedAnalyticsProvider>(
          () => OptimizedAnalyticsProvider(sl<OptimizedDatabaseService>()),
    );

    logger.i('✅ Dependencias limpias inicializadas correctamente');

  } catch (e) {
    logger.e('❌ Error inicializando dependencias limpias: $e');
    rethrow;
  }
}

// ============================================================================
// FUNCIONES DE UTILIDAD
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

    return true;
  } catch (e) {
    return false;
  }
}

/// Información del contenedor limpio
Map<String, dynamic> getCleanContainerInfo() {
  return {
    'total_services': 7, // Número exacto de servicios registrados
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
// EXTENSIONES PARA FACILITAR USO
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
// CONSTANTES DE IDENTIFICACIÓN
// ============================================================================

class CleanDIConstants {
  static const String logger = 'Logger';
  static const String databaseService = 'OptimizedDatabaseService';
  static const String authProvider = 'OptimizedAuthProvider';
  static const String themeProvider = 'ThemeProvider';
  static const String dailyEntriesProvider = 'OptimizedDailyEntriesProvider';
  static const String momentsProvider = 'OptimizedMomentsProvider';
  static const String analyticsProvider = 'OptimizedAnalyticsProvider';
}

// ============================================================================
// HELPER PARA MIGRACIÓN GRADUAL
// ============================================================================

/// Migrar gradualmente desde el container legacy al limpio
class DIMigrationHelper {
  static const Map<String, String> _migrationMap = {
    'AuthProvider': 'OptimizedAuthProvider',
    'InteractiveMomentsProvider': 'OptimizedMomentsProvider',
    'AnalyticsProvider': 'OptimizedAnalyticsProvider',
    'DatabaseService': 'OptimizedDatabaseService',
  };

  /// Obtener el nombre del servicio optimizado
  static String? getOptimizedServiceName(String legacyName) {
    return _migrationMap[legacyName];
  }

  /// Verificar si un servicio legacy tiene equivalente optimizado
  static bool hasOptimizedEquivalent(String legacyName) {
    return _migrationMap.containsKey(legacyName);
  }

  /// Listar servicios que se pueden eliminar
  static List<String> getLegacyServicesToRemove() {
    return [
      'AdvancedUserAnalytics', // Funcionalidad integrada en OptimizedAnalyticsProvider
      'EnhancedAnalyticsProvider', // Duplicado, funcionalidad en OptimizedAnalyticsProvider
      'NotificationsProvider', // No se usa en V2
      'SessionService', // Integrado en OptimizedAuthProvider
    ];
  }

  /// Verificar integridad de la migración
  static Map<String, dynamic> checkMigrationStatus() {
    // FIX: Cambiar AuthProvider por OptimizedAuthProvider
    final isLegacyPresent = false; // No chequeamos legacy en el container limpio
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
// CONFIGURACIÓN DE LOGGING OPTIMIZADA
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
// INICIALIZADORES ESPECÍFICOS POR ENTORNO
// ============================================================================

/// Inicializar para producción
Future<void> initForProduction() async {
  // Registrar logger de producción
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createProductionLogger());

  // Registrar servicios optimizados
  await initCleanDependencies();
}

/// Inicializar para desarrollo
Future<void> initForDevelopment() async {
  // Registrar logger de desarrollo
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createDevelopmentLogger());

  // Registrar servicios optimizados
  await initCleanDependencies();
}

/// Inicializar para testing
Future<void> initForTesting() async {
  // Limpiar container existente
  await resetCleanContainer();

  // Registrar logger de testing
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createTestingLogger());

  // Registrar servicios optimizados
  await initCleanDependencies();
}