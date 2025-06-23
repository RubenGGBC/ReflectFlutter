import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class ModelDownloader {
  static const String MODEL_URL = 'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/phi-3.5-mini-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx';
  static const String MODEL_FILENAME = 'phi-3.5-mini-instruct.onnx';
  static const String EXPECTED_SHA256 = ''; // Se actualizará después de la primera descarga

  final Dio _dio = Dio();

  Future<String> downloadModel({
    required Function(double) onProgress,
    required Function(String) onStatusUpdate,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/$MODEL_FILENAME';
      final modelFile = File(modelPath);

      // Verificar si ya existe
      if (await modelFile.exists()) {
        onStatusUpdate('Modelo ya descargado');
        return modelPath;
      }

      onStatusUpdate('Iniciando descarga del modelo Phi-3.5-mini...');

      await _dio.download(
        MODEL_URL,
        modelPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress);
            onStatusUpdate('Descargando: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );

      onStatusUpdate('Verificando integridad del archivo...');

      // Verificar que el archivo se descargó correctamente
      if (await modelFile.exists()) {
        final fileSize = await modelFile.length();
        onStatusUpdate('Descarga completada. Tamaño: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB');
        return modelPath;
      } else {
        throw Exception('Error: El archivo no se creó correctamente');
      }

    } catch (e) {
      throw Exception('Error descargando modelo: $e');
    }
  }

  Future<bool> isModelDownloaded() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelPath = '${directory.path}/$MODEL_FILENAME';
      return await File(modelPath).exists();
    } catch (e) {
      return false;
    }
  }

  Future<String> getModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$MODEL_FILENAME';
  }
}