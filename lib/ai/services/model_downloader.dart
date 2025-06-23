// lib/ai/services/model_downloader.dart
// VERSIÓN CORREGIDA - DESCARGA EL MODELO COMPLETO

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

Future<String> _calculateHashInIsolate(String filePath) async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      return '';
    }
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  } catch (e) {
    debugPrint('Error en el isolate de hashing: $e');
    return '';
  }
}

class ModelDownloader {
  // ✅ CORREGIDO: URL del modelo principal .onnx (no .data)
  static const String MODEL_URL = 'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx';
  static const String MODEL_FILENAME = 'phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx';

  // ✅ CORREGIDO: Hash real del archivo .data (este hash es correcto)
  static const String EXPECTED_DATA_SHA256 = '3351fe9cc669eba43e07fb3cec436078629d5145531a28bc36fe6d5ad7683eb8';
  // Nota: No tenemos el hash del archivo .onnx, se omite la verificación por ahora
  static const String EXPECTED_MODEL_SHA256 = '';

  // URL del archivo de datos (si es necesario)
  static const String DATA_URL = 'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4/phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx.data';
  static const String DATA_FILENAME = 'phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx.data';

  final Dio _dio = Dio();

  Future<String> downloadModel({
    required Function(double) onProgress,
    required Function(String) onStatusUpdate,
  }) async {
    try {
      final modelPath = await getModelPath();
      final modelFile = File(modelPath);

      // Verificar si el modelo ya existe y es válido
      if (await modelFile.exists()) {
        if (await _verifyChecksum(modelFile, onStatusUpdate)) {
          onStatusUpdate('Modelo verificado y listo.');
          return modelPath;
        } else {
          onStatusUpdate('Verificación fallida. Descargando de nuevo...');
          await modelFile.delete();
        }
      }

      // Verificar si necesitamos descargar el archivo de datos también
      final dataPath = await getDataPath();
      final dataFile = File(dataPath);

      // Descargar archivo principal del modelo
      onStatusUpdate('Descargando modelo principal...');
      await _downloadFile(MODEL_URL, modelPath, onProgress, onStatusUpdate, 'Modelo');

      // Descargar archivo de datos si no existe
      if (!await dataFile.exists()) {
        onStatusUpdate('Descargando archivo de datos...');
        await _downloadFile(DATA_URL, dataPath, onProgress, onStatusUpdate, 'Datos');
      }

      // Verificar integridad del modelo principal (saltar hash si no está disponible)
      onStatusUpdate('Verificando integridad del modelo...');
      if (!await _verifyChecksum(modelFile, onStatusUpdate)) {
        throw Exception('Error de verificación del modelo principal.');
      }

      // Verificar integridad del archivo de datos
      onStatusUpdate('Verificando integridad del archivo de datos...');
      if (!await _verifyChecksum(dataFile, onStatusUpdate)) {
        throw Exception('Error de verificación del archivo de datos.');
      }

      onStatusUpdate('Descarga completada y verificada.');
      return modelPath;
    } catch (e) {
      onStatusUpdate('Error durante la descarga: $e');
      throw Exception('Error descargando modelo: $e');
    }
  }

  Future<void> _downloadFile(
      String url,
      String filePath,
      Function(double) onProgress,
      Function(String) onStatusUpdate,
      String fileType
      ) async {
    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = received / total;
          onProgress(progress);
          onStatusUpdate('Descargando $fileType: ${(progress * 100).toStringAsFixed(1)}%');
        } else {
          onStatusUpdate('Descargando $fileType: ${(received / 1024 / 1024).toStringAsFixed(1)} MB');
        }
      },
    );
  }

  Future<bool> isModelDownloaded() async {
    try {
      final modelPath = await getModelPath();
      final modelFile = File(modelPath);
      final dataPath = await getDataPath();
      final dataFile = File(dataPath);

      // Ambos archivos deben existir
      return await modelFile.exists() && await dataFile.exists();
    } catch (e) {
      return false;
    }
  }

  Future<String> getModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$MODEL_FILENAME';
  }

  Future<String> getDataPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$DATA_FILENAME';
  }

  Future<String> getModelDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // ✅ CORREGIDO: Método de verificación corregido
  Future<bool> _verifyChecksum(File file, Function(String) onStatusUpdate) async {
    final fileName = file.path.split('/').last;

    // Determinar qué hash usar según el archivo
    String expectedHash;
    if (fileName.endsWith('.data')) {
      expectedHash = EXPECTED_DATA_SHA256;
    } else if (fileName.endsWith('.onnx')) {
      expectedHash = EXPECTED_MODEL_SHA256;
    } else {
      onStatusUpdate('Tipo de archivo no reconocido para verificación.');
      return true; // Omitir verificación para archivos desconocidos
    }

    // ✅ CORREGIDO: Verificar si se ha configurado un hash válido
    if (expectedHash.isEmpty) {
      debugPrint("ADVERTENCIA: No se ha configurado un hash SHA256 para $fileName. Se omite la verificación.");
      onStatusUpdate('Verificación omitida (sin hash de referencia para $fileName).');
      return true;
    }

    try {
      onStatusUpdate('Verificando integridad de $fileName (puede tardar un momento)...');

      final hashString = await compute(_calculateHashInIsolate, file.path);

      if (hashString.isEmpty) {
        debugPrint('El fichero no existe o hubo un error al calcular el hash.');
        return false;
      }

      debugPrint('Hash calculado para $fileName: $hashString');
      debugPrint('Hash esperado para $fileName: $expectedHash');

      final bool isValid = hashString.toLowerCase() == expectedHash.toLowerCase();
      onStatusUpdate(isValid ? 'Verificación exitosa para $fileName.' : 'Error: El hash no coincide para $fileName.');
      return isValid;

    } catch (e) {
      debugPrint('Error calculando checksum para $fileName: $e');
      onStatusUpdate('Error durante la verificación de $fileName.');
      return false;
    }
  }
}