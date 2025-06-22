// lib/main.dart - VERSIÓN SIMPLE Y FUNCIONAL

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

// Imports corregidos
import 'optimized_reflect_app.dart';
import 'injection_container_clean.dart' as clean_di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar FFI para sqflite en desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Configurar orientación
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

  try {
    // Inicializar dependencias
    await clean_di.initCleanDependencies();

    // Verificar que todo esté listo
    if (!clean_di.areCleanServicesRegistered()) {
      throw Exception('Error registrando dependencias');
    }

    final logger = clean_di.sl<Logger>();
    logger.i('✅ App inicializada correctamente');

    // Ejecutar app
    runApp(const OptimizedReflectApp());

  } catch (e) {
    // Fallback si hay problemas
    print('❌ Error inicializando app: $e');
    runApp(const ErrorApp());
  }
}

// ============================================================================
// APP DE ERROR SIMPLE
// ============================================================================

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al inicializar la aplicación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Reiniciar la app
                  main();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}