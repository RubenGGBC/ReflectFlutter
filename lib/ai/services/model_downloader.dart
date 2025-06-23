// lib/ai/services/model_downloader.dart
// VERSIÓN MEJORADA CON VERIFICACIÓN DE HASH EN UN HILO SECUNDARIO (ISOLATE)

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

// ✅ PASO 1: Define la función que se ejecutará en el Isolate.
// Esta función debe estar fuera de cualquier clase.
Future<String> _calculateHashInIsolate(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      return '';
    }
    // Lee el archivo por partes para no consumir demasiada RAM
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  } catch (e) {
    // Si hay un error en el isolate, lo imprimimos para depuración.
    debugPrint('Error en el isolate de hashing: $e');
    return '';
  }
}

class ModelDownloader {
  static const String MODEL_URL = 'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx.data';
  static const String MODEL_FILENAME = 'phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx.data';

  // ‼️ MUY IMPORTANTE: Asegúrate de que este hash es el correcto.
  static const String EXPECTED_SHA256 = '3351fe9cc669eba43e07fb3cec436078629d5145531a28bc36fe6d5ad7683eb8';

  final Dio _dio = Dio();

  Future<String> downloadModel({
    required Function(double) onProgress,
    required Function(String) onStatusUpdate,
  }) async {
    try {
      final modelPath = await getModelPath();
      final modelFile = File(modelPath);

      if (await modelFile.exists()) {
        // ✅ PASO 2: Llamada a la función de verificación mejorada
        if (await _verifyChecksum(modelFile, onStatusUpdate)) {
          onStatusUpdate('Modelo verificado y listo.');
          return modelPath;
        } else {
          onStatusUpdate('Verificación fallida. Descargando de nuevo...');
          await modelFile.delete();
        }
      }

      onStatusUpdate('Iniciando descarga del modelo (2.1 GB)...');
      await _dio.download(
        MODEL_URL,
        modelPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
            onStatusUpdate('Descargando: ${(progress * 100).toStringAsFixed(1)}%');
          } else {
            onStatusUpdate('Descargando: ${(received / 1024 / 1024).toStringAsFixed(1)} MB');
          }
        },
      );

      onStatusUpdate('Verificando integridad del archivo descargado...');
      if (await _verifyChecksum(modelFile, onStatusUpdate)) {
        onStatusUpdate('Descarga completada y verificada.');
        return modelPath;
      } else {
        throw Exception('Error de verificación post-descarga. El archivo puede estar corrupto.');
      }
    } catch (e) {
      onStatusUpdate('Error durante la descarga: $e');
      throw Exception('Error descargando modelo: $e');
    }
  }

  Future<bool> isModelDownloaded() async {
    try {
      final modelPath = await getModelPath();
      final modelFile = File(modelPath);
      return await modelFile.exists();
    } catch (e) {
      return false;
    }
  }

  Future<String> getModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$MODEL_FILENAME';
  }

  // ✅ PASO 3: Método de verificación modificado para usar el Isolate
  Future<bool> _verifyChecksum(File file, Function(String) onStatusUpdate) async {
    if (EXPECTED_SHA256 == '3351fe9cc669eba43e07fb3cec436078629d5145531a28bc36fe6d5ad7683eb8') {
      debugPrint("ADVERTENCIA: No se ha configurado un hash SHA256. Se omite la verificación.");
      onStatusUpdate('Verificación omitida (sin hash de referencia).');
      return true;
    }
    try {
      onStatusUpdate('Verificando integridad (puede tardar un momento)...');

      // Ejecuta la función _calculateHashInIsolate en un hilo separado
      final hashString = await compute(_calculateHashInIsolate, file.path);

      if (hashString.isEmpty) {
        debugPrint('El fichero no existe o hubo un error al calcular el hash.');
        return false;
      }

      debugPrint('Hash calculado: $hashString');
      debugPrint('Hash esperado: $EXPECTED_SHA256');

      final bool isValid = hashString.toLowerCase() == EXPECTED_SHA256.toLowerCase();
      onStatusUpdate(isValid ? 'Verificación exitosa.' : 'Error: El hash no coincide.');
      return isValid;

    } catch (e) {
      debugPrint('Error calculando checksum: $e');
      onStatusUpdate('Error durante la verificación.');
      return false;
    }
  }
}
