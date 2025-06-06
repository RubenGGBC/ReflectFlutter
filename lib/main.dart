// ============================================================================
// main.dart - VERSIÓN CORREGIDA
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Inicializar soporte para base de datos en escritorio
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Inicializar dependencias
    await di.init();

    runApp(const ReflectApp());

  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error inicializando ReflectApp'),
                Text('$e'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}