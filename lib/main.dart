// ============================================================================
// main.dart - VERSIÓN FINAL Y CORREGIDA - IMPORTS FIXED
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

// FIX: Corregir imports - usar los archivos correctos
import 'optimized_reflect_app.dart'; // En lugar de 'app_v2.dart'
import 'injection_container_clean.dart' as clean_di; // En lugar de 'injection_container.dart'

/// Punto de entrada principal de la aplicación
void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar FFI para sqflite en plataformas de escritorio
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final logger = Logger();

  try {
    logger.i('🚀 Iniciando ReflectApp Optimizada...');

    // Configurar orientación (solo portrait)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configurar UI del sistema
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // FIX: Usar el contenedor de dependencias limpio
    await clean_di.initCleanDependencies();

    // >>>>> CORRECCIÓN CLAVE <<<<<
    // Espera a que todos los singletons asíncronos (como OptimizedDatabaseService)
    // estén completamente inicializados y listos para ser usados.
    await GetIt.instance.allReady();

    logger.i('✅ ReflectApp Optimizada inicializada correctamente');

    // FIX: Usar OptimizedReflectApp en lugar de ReflectAppV2
    runApp(const OptimizedReflectApp());

  } catch (e, stackTrace) {
    logger.e('❌ Error crítico iniciando ReflectApp: $e',
        error: e, stackTrace: stackTrace);
    runApp(_buildErrorApp(e.toString()));
  }
}

/// Construir aplicación de error en caso de fallo crítico
Widget _buildErrorApp(String error) {
  return MaterialApp(
    title: 'ReflectApp - Error',
    debugShowCheckedModeBanner: false,
    home: ErrorScreen(error: error),
  );
}

/// Pantalla de error para fallos críticos
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Error de Inicialización',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'ReflectApp no pudo inicializarse correctamente.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text('Detalles técnicos'),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FUNCIÓN PRINCIPAL ALTERNATIVA (para compatibilidad)
// ============================================================================

/// Ejecutar la aplicación optimizada directamente
Future<void> runOptimizedApp() async {
  await runOptimizedReflectApp();
}

/// Ejecutar la aplicación usando el método integrado
Future<void> runIntegratedOptimizedApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de plataforma
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Configuración del sistema
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    // Inicializar y ejecutar usando el método integrado
    await runOptimizedReflectApp();
  } catch (e) {
    // Fallback en caso de error
    runApp(_buildErrorApp('Error inicializando la aplicación: $e'));
  }
}