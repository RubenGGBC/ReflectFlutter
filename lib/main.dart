// ============================================================================
// main.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();
  logger.i('🚀 === INICIANDO REFLECTAPP FLUTTER ===');

  try {
    // Inicializar dependencias
    await di.init();
    logger.i('✅ Dependencias inicializadas');

    runApp(const ReflectApp());

  } catch (e) {
    logger.e('❌ Error inicializando aplicación: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error inicializando ReflectApp'),
                Text('$e'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
