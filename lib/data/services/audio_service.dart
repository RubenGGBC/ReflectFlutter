// ============================================================================
// data/services/audio_service.dart - SERVICIO DE AUDIO REAL
// ============================================================================

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

enum AudioState {
  idle,
  recording,
  playing,
  paused,
  stopped,
}

enum AudioFormat {
  aac,
  wav,
  mp3,
  m4a,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final Logger _logger = Logger();

  AudioState _state = AudioState.idle;
  String? _currentRecordingPath;
  StreamController<AudioState> _stateController = StreamController<AudioState>.broadcast();
  StreamController<Duration> _recordingDurationController = StreamController<Duration>.broadcast();
  StreamController<Duration> _playbackPositionController = StreamController<Duration>.broadcast();
  StreamController<List<double>> _amplitudeController = StreamController<List<double>>.broadcast();

  Timer? _recordingTimer;
  Timer? _amplitudeTimer;
  Duration _recordingDuration = Duration.zero;
  List<double> _amplitudeHistory = [];

  // Getters
  AudioState get state => _state;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration get recordingDuration => _recordingDuration;
  List<double> get amplitudeHistory => List.from(_amplitudeHistory);

  // Streams
  Stream<AudioState> get stateStream => _stateController.stream;
  Stream<Duration> get recordingDurationStream => _recordingDurationController.stream;
  Stream<Duration> get playbackPositionStream => _playbackPositionController.stream;
  Stream<List<double>> get amplitudeStream => _amplitudeController.stream;

  /// Inicializar el servicio de audio
  Future<void> initialize() async {
    _logger.i('🎤 Inicializando AudioService');

    try {
      // Configurar listeners del player
      _player.onPlayerStateChanged.listen((PlayerState state) {
        switch (state) {
          case PlayerState.playing:
            _updateState(AudioState.playing);
            break;
          case PlayerState.paused:
            _updateState(AudioState.paused);
            break;
          case PlayerState.stopped:
          case PlayerState.completed:
            _updateState(AudioState.stopped);
            break;
          case PlayerState.disposed:
            _updateState(AudioState.idle);
            break;
        }
      });

      // Configurar listener de posición
      _player.onPositionChanged.listen((Duration position) {
        _playbackPositionController.add(position);
      });

      _logger.i('✅ AudioService inicializado correctamente');
    } catch (e) {
      _logger.e('❌ Error inicializando AudioService: $e');
      rethrow;
    }
  }

  /// Verificar y solicitar permisos de micrófono
  Future<bool> requestPermissions() async {
    try {
      if (kIsWeb) {
        // En web, usar la API nativa
        final hasPermission = await _recorder.hasPermission();
        return hasPermission;
      }

      // En móvil, usar permission_handler
      final status = await Permission.microphone.request();
      final granted = status == PermissionStatus.granted;

      _logger.i(granted ? '✅ Permisos de micrófono concedidos' : '❌ Permisos de micrófono denegados');
      return granted;
    } catch (e) {
      _logger.e('❌ Error solicitando permisos: $e');
      return false;
    }
  }

  /// Verificar si tiene permisos
  Future<bool> hasPermissions() async {
    try {
      if (kIsWeb) {
        return await _recorder.hasPermission();
      }

      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      _logger.e('❌ Error verificando permisos: $e');
      return false;
    }
  }

  /// Comenzar grabación
  Future<bool> startRecording({
    AudioFormat format = AudioFormat.aac,
    int sampleRate = 44100,
    int bitRate = 128000,
  }) async {
    try {
      if (_state == AudioState.recording) {
        _logger.w('⚠️ Ya se está grabando');
        return false;
      }

      // Verificar permisos
      if (!await hasPermissions()) {
        final granted = await requestPermissions();
        if (!granted) {
          _logger.e('❌ Sin permisos de micrófono');
          return false;
        }
      }

      // Generar path único para la grabación
      _currentRecordingPath = await _generateRecordingPath(format);

      // Configurar grabación
      final recordConfig = RecordConfig(
        encoder: _getEncoder(format),
        sampleRate: sampleRate,
        bitRate: bitRate,
      );

      // Iniciar grabación
      await _recorder.start(recordConfig, path: _currentRecordingPath!);

      _updateState(AudioState.recording);
      _startRecordingTimer();
      _startAmplitudeMonitoring();

      _logger.i('🎤 Grabación iniciada: $_currentRecordingPath');
      return true;

    } catch (e) {
      _logger.e('❌ Error iniciando grabación: $e');
      return false;
    }
  }

  /// Pausar grabación
  Future<bool> pauseRecording() async {
    try {
      if (_state != AudioState.recording) {
        _logger.w('⚠️ No hay grabación activa para pausar');
        return false;
      }

      await _recorder.pause();
      _updateState(AudioState.paused);
      _stopRecordingTimer();
      _stopAmplitudeMonitoring();

      _logger.i('⏸️ Grabación pausada');
      return true;

    } catch (e) {
      _logger.e('❌ Error pausando grabación: $e');
      return false;
    }
  }

  /// Reanudar grabación
  Future<bool> resumeRecording() async {
    try {
      if (_state != AudioState.paused) {
        _logger.w('⚠️ No hay grabación pausada para reanudar');
        return false;
      }

      await _recorder.resume();
      _updateState(AudioState.recording);
      _startRecordingTimer();
      _startAmplitudeMonitoring();

      _logger.i('▶️ Grabación reanudada');
      return true;

    } catch (e) {
      _logger.e('❌ Error reanudando grabación: $e');
      return false;
    }
  }

  /// Detener grabación
  Future<String?> stopRecording() async {
    try {
      if (_state != AudioState.recording && _state != AudioState.paused) {
        _logger.w('⚠️ No hay grabación activa para detener');
        return null;
      }

      final path = await _recorder.stop();
      _updateState(AudioState.stopped);
      _stopRecordingTimer();
      _stopAmplitudeMonitoring();
      _resetRecordingData();

      if (path != null && await File(path).exists()) {
        final file = File(path);
        final size = await file.length();
        final duration = _recordingDuration;

        _logger.i('✅ Grabación completada: $path (${size} bytes, ${duration.inSeconds}s)');
        return path;
      } else {
        _logger.e('❌ Archivo de grabación no encontrado');
        return null;
      }

    } catch (e) {
      _logger.e('❌ Error deteniendo grabación: $e');
      return null;
    }
  }

  /// Reproducir audio
  Future<bool> playAudio(String path) async {
    try {
      if (!await File(path).exists()) {
        _logger.e('❌ Archivo de audio no existe: $path');
        return false;
      }

      await _player.stop(); // Detener cualquier reproducción previa
      await _player.play(DeviceFileSource(path));

      _logger.i('▶️ Reproduciendo audio: $path');
      return true;

    } catch (e) {
      _logger.e('❌ Error reproduciendo audio: $e');
      return false;
    }
  }

  /// Pausar reproducción
  Future<bool> pausePlayback() async {
    try {
      await _player.pause();
      _logger.i('⏸️ Reproducción pausada');
      return true;
    } catch (e) {
      _logger.e('❌ Error pausando reproducción: $e');
      return false;
    }
  }

  /// Reanudar reproducción
  Future<bool> resumePlayback() async {
    try {
      await _player.resume();
      _logger.i('▶️ Reproducción reanudada');
      return true;
    } catch (e) {
      _logger.e('❌ Error reanudando reproducción: $e');
      return false;
    }
  }

  /// Detener reproducción
  Future<bool> stopPlayback() async {
    try {
      await _player.stop();
      _logger.i('⏹️ Reproducción detenida');
      return true;
    } catch (e) {
      _logger.e('❌ Error deteniendo reproducción: $e');
      return false;
    }
  }

  /// Obtener duración del audio
  Future<Duration?> getAudioDuration(String path) async {
    try {
      if (!await File(path).exists()) return null;

      // Crear un player temporal para obtener la duración
      final tempPlayer = AudioPlayer();
      await tempPlayer.setSource(DeviceFileSource(path));

      Duration? duration;
      tempPlayer.onDurationChanged.listen((d) {
        duration = d;
      });

      // Esperar un poco para que se cargue la duración
      await Future.delayed(const Duration(milliseconds: 500));
      await tempPlayer.dispose();

      return duration;
    } catch (e) {
      _logger.e('❌ Error obteniendo duración: $e');
      return null;
    }
  }

  /// Limpiar recursos
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
      await _player.dispose();
      await _stateController.close();
      await _recordingDurationController.close();
      await _playbackPositionController.close();
      await _amplitudeController.close();

      _recordingTimer?.cancel();
      _amplitudeTimer?.cancel();

      _logger.i('🗑️ AudioService limpiado');
    } catch (e) {
      _logger.e('❌ Error limpiando AudioService: $e');
    }
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  void _updateState(AudioState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      _logger.d('🎵 Estado audio: $newState');
    }
  }

  Future<String> _generateRecordingPath(AudioFormat format) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _getFileExtension(format);
    return '${directory.path}/recording_$timestamp.$extension';
  }

  AudioEncoder _getEncoder(AudioFormat format) {
    switch (format) {
      case AudioFormat.aac:
        return AudioEncoder.aacLc;
      case AudioFormat.wav:
        return AudioEncoder.wav;
      case AudioFormat.mp3:
        return AudioEncoder.aacLc; // Fallback, mp3 no siempre disponible
      case AudioFormat.m4a:
        return AudioEncoder.aacLc;
    }
  }

  String _getFileExtension(AudioFormat format) {
    switch (format) {
      case AudioFormat.aac:
        return 'aac';
      case AudioFormat.wav:
        return 'wav';
      case AudioFormat.mp3:
        return 'mp3';
      case AudioFormat.m4a:
        return 'm4a';
    }
  }

  void _startRecordingTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordingDuration = Duration(milliseconds: _recordingDuration.inMilliseconds + 100);
      _recordingDurationController.add(_recordingDuration);
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _startAmplitudeMonitoring() {
    _amplitudeHistory.clear();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) async {
      try {
        final amplitude = await _recorder.getAmplitude();
        final normalizedAmplitude = amplitude.current.clamp(-60.0, 0.0) / -60.0;

        _amplitudeHistory.add(normalizedAmplitude);

        // Mantener solo los últimos 100 valores para el waveform
        if (_amplitudeHistory.length > 100) {
          _amplitudeHistory.removeAt(0);
        }

        _amplitudeController.add(List.from(_amplitudeHistory));
      } catch (e) {
        // Silenciar errores de amplitud para evitar spam en logs
      }
    });
  }

  void _stopAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
  }

  void _resetRecordingData() {
    _recordingDuration = Duration.zero;
    _amplitudeHistory.clear();
    _currentRecordingPath = null;
  }

  /// Formatear duración para mostrar
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Obtener tamaño del archivo en formato legible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}