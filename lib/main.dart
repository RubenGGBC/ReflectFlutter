// ============================================================================
// main.dart - VERSIÓN FINAL Y CORREGIDA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart'; // FIX: Import GetIt para el allReady
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'app_v2.dart';
import 'injection_container.dart' as di;

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
    logger.i('🚀 Iniciando ReflectApp v2...');

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

    // Inicializar dependencias
    await di.init();

    // >>>>> CORRECCIÓN CLAVE <<<<<
    // Espera a que todos los singletons asíncronos (como DatabaseService)
    // estén completamente inicializados y listos para ser usados.
    await GetIt.instance.allReady();

    logger.i('✅ ReflectApp v2 inicializado correctamente');

    // Ahora es seguro ejecutar la aplicación
    runApp(const ReflectAppV2());

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
