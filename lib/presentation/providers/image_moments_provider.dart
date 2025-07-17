// ============================================================================
// image_moments_provider.dart - PROVIDER PARA MANEJO DE IMÁGENES EN MOMENTOS
// ============================================================================

import 'dart:io';
import 'dart:typed_data'; // Necesario para Uint8List
import 'package:flutter/material.dart'; // <-- FIX: Importación de Material faltante
import 'package:provider/provider.dart'; // <-- FIX: Importación de Provider faltante
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import '../../data/models/optimized_models.dart';

class ImageMomentsProvider extends ChangeNotifier {

  // ============================================================================
  // ESTADO Y VARIABLES
  // ============================================================================

  final Map<String, String> _imageCache = {};
  bool _isProcessing = false;
  String? _errorMessage;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  // ============================================================================
  // MÉTODOS PÚBLICOS
  // ============================================================================

  /// Procesa y guarda una imagen para un momento
  /// Retorna la ruta de la imagen guardada o null si hay error
  Future<String?> saveImageForMoment({
    required File imageFile,
    required int momentId,
    int maxWidth = 800,
    int maxHeight = 800,
    int quality = 85,
  }) async {
    try {
      _setProcessing(true);
      _clearError();

      // Crear directorio de momentos si no existe
      final momentsDir = await _getMomentsDirectory();
      if (!await momentsDir.exists()) {
        await momentsDir.create(recursive: true);
      }

      // Generar nombre único para la imagen
      final fileName = 'moment_${momentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputPath = path.join(momentsDir.path, fileName);

      // Procesar imagen (redimensionar y comprimir)
      final processedImage = await _processImage(
        imageFile,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );

      if (processedImage != null) {
        // Guardar imagen procesada
        final outputFile = File(outputPath);
        await outputFile.writeAsBytes(processedImage);

        // Agregar a cache
        _imageCache[momentId.toString()] = outputPath;

        return outputPath;
      }

      return null;

    } catch (e) {
      _setError('Error al procesar la imagen: $e');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Obtiene la ruta de imagen de un momento (cache o búsqueda en disco)
  Future<String?> getImageForMoment(int momentId) async {
    try {
      final momentIdStr = momentId.toString();

      // Verificar cache primero
      if (_imageCache.containsKey(momentIdStr)) {
        final cachedPath = _imageCache[momentIdStr]!;
        if (await File(cachedPath).exists()) {
          return cachedPath;
        } else {
          // Limpiar entrada inválida del cache
          _imageCache.remove(momentIdStr);
        }
      }

      // Buscar en directorio de momentos
      final momentsDir = await _getMomentsDirectory();
      if (await momentsDir.exists()) {
        final files = await momentsDir.list().toList();

        for (final file in files) {
          if (file is File && file.path.contains('moment_$momentId')) {
            final imagePath = file.path;
            _imageCache[momentIdStr] = imagePath;
            return imagePath;
          }
        }
      }

      return null;

    } catch (e) {
      _setError('Error al buscar imagen: $e');
      return null;
    }
  }

  /// Elimina la imagen de un momento
  Future<bool> deleteImageForMoment(int momentId) async {
    try {
      final imagePath = await getImageForMoment(momentId);

      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }

        // Remover del cache
        _imageCache.remove(momentId.toString());

        return true;
      }

      return false;

    } catch (e) {
      _setError('Error al eliminar imagen: $e');
      return false;
    }
  }

  /// Limpia todas las imágenes huérfanas (sin momento asociado)
  Future<void> cleanupOrphanedImages(List<int> validMomentIds) async {
    try {
      final momentsDir = await _getMomentsDirectory();
      if (!await momentsDir.exists()) return;

      final files = await momentsDir.list().toList();

      for (final file in files) {
        if (file is File) {
          final fileName = path.basename(file.path);

          // Extraer ID del momento del nombre del archivo
          final regex = RegExp(r'moment_(\d+)_');
          final match = regex.firstMatch(fileName);

          if (match != null) {
            final momentId = int.tryParse(match.group(1)!);

            if (momentId != null && !validMomentIds.contains(momentId)) {
              // Imagen huérfana - eliminar
              await file.delete();
              _imageCache.remove(momentId.toString());
            }
          }
        }
      }

    } catch (e) {
      _setError('Error durante limpieza: $e');
    }
  }

  /// Obtiene el tamaño total ocupado por las imágenes de momentos
  Future<int> getImagesStorageSize() async {
    try {
      int totalSize = 0;
      final momentsDir = await _getMomentsDirectory();

      if (await momentsDir.exists()) {
        final files = await momentsDir.list().toList();

        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            totalSize += stat.size;
          }
        }
      }

      return totalSize;

    } catch (e) {
      return 0;
    }
  }

  /// Formatea el tamaño en bytes a texto legible
  String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  /// Obtiene el directorio de momentos
  Future<Directory> _getMomentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, 'moments_images'));
  }

  /// Procesa una imagen (redimensiona y comprime)
  Future<Uint8List?> _processImage(
      File imageFile, {
        required int maxWidth,
        required int maxHeight,
        required int quality,
      }) async {
    try {
      // Leer imagen original
      final originalBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(originalBytes);

      if (originalImage == null) return null;

      // Calcular nuevas dimensiones manteniendo proporción
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (newWidth > maxWidth || newHeight > maxHeight) {
        final aspectRatio = newWidth / newHeight;

        if (aspectRatio > 1) {
          // Imagen más ancha que alta
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          // Imagen más alta que ancha
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Redimensionar imagen
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Comprimir y codificar como JPEG
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      return Uint8List.fromList(compressedBytes);

    } catch (e) {
      _setError('Error procesando imagen: $e');
      return null;
    }
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

// ============================================================================
// EXTENSIONES PARA EL MODELO DE MOMENTO
// ============================================================================

extension OptimizedInteractiveMomentModelImageExtension on OptimizedInteractiveMomentModel {

  /// Verifica si este momento tiene una imagen asociada
  Future<bool> hasImage(ImageMomentsProvider imageProvider) async {
    // FIX: Añadir comprobación de nulidad para el id
    if (id == null) return false;
    final imagePath = await imageProvider.getImageForMoment(id!);
    return imagePath != null && await File(imagePath).exists();
  }

  /// Obtiene la imagen de este momento
  Future<String?> getImagePath(ImageMomentsProvider imageProvider) async {
    // FIX: Añadir comprobación de nulidad para el id
    if (id == null) return null;
    return await imageProvider.getImageForMoment(id!);
  }
}

// ============================================================================
// WIDGET HELPER PARA MOSTRAR IMÁGENES DE MOMENTOS
// ============================================================================

class MomentImageWidget extends StatelessWidget {
  final int momentId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const MomentImageWidget({
    super.key,
    required this.momentId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageMomentsProvider>(
      builder: (context, imageProvider, child) {
        return FutureBuilder<String?>(
          future: imageProvider.getImageForMoment(momentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlaceholder(isLoading: true);
            }

            if (snapshot.hasData && snapshot.data != null) {
              return ClipRRect(
                borderRadius: borderRadius ?? BorderRadius.zero,
                child: Image.file(
                  File(snapshot.data!),
                  width: width,
                  height: height,
                  fit: fit,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(isError: true);
                  },
                ),
              );
            }

            return _buildPlaceholder();
          },
        );
      },
    );
  }

  Widget _buildPlaceholder({bool isLoading = false, bool isError = false}) {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          isLoading
              ? Icons.image_outlined
              : isError
              ? Icons.broken_image_outlined
              : Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: 32,
        ),
      ),
    );
  }
}

