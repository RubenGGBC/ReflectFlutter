// ============================================================================
// voice_recording_service.dart - SERVICIO DE GRABACIÓN DE VOZ
// ============================================================================

import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

enum VoiceRecordingState {
  idle,
  recording,
  paused,
  stopped,
  playing,
  error
}

class VoiceRecordingService extends ChangeNotifier {
  // ============================================================================
  // PROPIEDADES Y CONTROLADORES
  // ============================================================================

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  VoiceRecordingState _state = VoiceRecordingState.idle;
  String? _currentRecordingPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  
  String? _errorMessage;
  bool _hasPermission = false;

  // ============================================================================
  // GETTERS
  // ============================================================================

  VoiceRecordingState get state => _state;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackDuration => _playbackDuration;
  Duration get totalDuration => _totalDuration;
  String? get errorMessage => _errorMessage;
  bool get hasPermission => _hasPermission;
  
  bool get isRecording => _state == VoiceRecordingState.recording;
  bool get isPlaying => _state == VoiceRecordingState.playing;
  bool get isPaused => _state == VoiceRecordingState.paused;
  bool get hasRecording => _currentRecordingPath != null && File(_currentRecordingPath!).existsSync();

  // ============================================================================
  // INICIALIZACIÓN Y PERMISOS
  // ============================================================================

  Future<void> initialize() async {
    try {
      _hasPermission = await _checkPermissions();
      
      // Configurar listeners del reproductor
      _player.onDurationChanged.listen((duration) {
        _totalDuration = duration;
        notifyListeners();
      });
      
      _player.onPositionChanged.listen((position) {
        _playbackDuration = position;
        notifyListeners();
      });
      
      _player.onPlayerComplete.listen((_) {
        _stopPlayback();
      });
      
      _setState(VoiceRecordingState.idle);
    } catch (e) {
      _setError('Error inicializando servicio de grabación: $e');
    }
  }

  Future<bool> _checkPermissions() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Permission handler error (platform may not support): $e');
      // Try to continue without explicit permission check on unsupported platforms
      // Most desktop platforms don't need explicit permission requests
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return true; // Assume permission is granted on desktop
      }
      _setError('Error verificando permisos: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    _hasPermission = await _checkPermissions();
    notifyListeners();
    return _hasPermission;
  }

  // ============================================================================
  // GRABACIÓN DE VOZ
  // ============================================================================

  Future<void> startRecording() async {
    if (!_hasPermission) {
      _setError('Permisos de micrófono no concedidos');
      return;
    }

    if (_state == VoiceRecordingState.recording) {
      return;
    }

    try {
      // Generar ruta para el archivo
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_reflection_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = path.join(directory.path, 'voice_recordings', fileName);
      
      // Crear directorio si no existe
      final recordingDir = Directory(path.dirname(_currentRecordingPath!));
      if (!await recordingDir.exists()) {
        await recordingDir.create(recursive: true);
      }

      // Configurar y iniciar grabación
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: _currentRecordingPath!,
      );

      _setState(VoiceRecordingState.recording);
      _startRecordingTimer();
      
    } catch (e) {
      _setError('Error iniciando grabación: $e');
    }
  }

  Future<void> pauseRecording() async {
    if (_state != VoiceRecordingState.recording) return;
    
    try {
      await _recorder.pause();
      _setState(VoiceRecordingState.paused);
      _stopRecordingTimer();
    } catch (e) {
      _setError('Error pausando grabación: $e');
    }
  }

  Future<void> resumeRecording() async {
    if (_state != VoiceRecordingState.paused) return;
    
    try {
      await _recorder.resume();
      _setState(VoiceRecordingState.recording);
      _startRecordingTimer();
    } catch (e) {
      _setError('Error reanudando grabación: $e');
    }
  }

  Future<void> stopRecording() async {
    if (_state != VoiceRecordingState.recording && _state != VoiceRecordingState.paused) {
      return;
    }

    try {
      await _recorder.stop();
      _stopRecordingTimer();
      _setState(VoiceRecordingState.stopped);
      
      // Verificar que el archivo se creó correctamente
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        debugPrint('Grabación guardada en: $_currentRecordingPath');
      } else {
        _setError('Error: archivo de grabación no encontrado');
      }
    } catch (e) {
      _setError('Error deteniendo grabación: $e');
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      _stopRecordingTimer();
      
      // Eliminar archivo si existe
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        await File(_currentRecordingPath!).delete();
      }
      
      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
      _setState(VoiceRecordingState.idle);
    } catch (e) {
      _setError('Error cancelando grabación: $e');
    }
  }

  // ============================================================================
  // REPRODUCCIÓN DE VOZ
  // ============================================================================

  Future<void> startPlayback() async {
    if (_currentRecordingPath == null || !File(_currentRecordingPath!).existsSync()) {
      _setError('No hay grabación para reproducir');
      return;
    }

    try {
      await _player.play(DeviceFileSource(_currentRecordingPath!));
      _setState(VoiceRecordingState.playing);
      _startPlaybackTimer();
    } catch (e) {
      _setError('Error reproduciendo grabación: $e');
    }
  }

  Future<void> pausePlayback() async {
    if (_state != VoiceRecordingState.playing) return;
    
    try {
      await _player.pause();
      _setState(VoiceRecordingState.paused);
      _stopPlaybackTimer();
    } catch (e) {
      _setError('Error pausando reproducción: $e');
    }
  }

  Future<void> resumePlayback() async {
    if (_state != VoiceRecordingState.paused) return;
    
    try {
      await _player.resume();
      _setState(VoiceRecordingState.playing);
      _startPlaybackTimer();
    } catch (e) {
      _setError('Error reanudando reproducción: $e');
    }
  }

  Future<void> stopPlayback() async {
    await _stopPlayback();
  }

  Future<void> _stopPlayback() async {
    try {
      await _player.stop();
      _stopPlaybackTimer();
      _playbackDuration = Duration.zero;
      _setState(VoiceRecordingState.stopped);
    } catch (e) {
      _setError('Error deteniendo reproducción: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_state == VoiceRecordingState.playing || _state == VoiceRecordingState.paused) {
      try {
        await _player.seek(position);
        _playbackDuration = position;
        notifyListeners();
      } catch (e) {
        _setError('Error buscando posición: $e');
      }
    }
  }

  // ============================================================================
  // GESTIÓN DE ARCHIVOS
  // ============================================================================

  Future<void> deleteRecording() async {
    if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
      try {
        await File(_currentRecordingPath!).delete();
        _currentRecordingPath = null;
        _recordingDuration = Duration.zero;
        _playbackDuration = Duration.zero;
        _totalDuration = Duration.zero;
        _setState(VoiceRecordingState.idle);
      } catch (e) {
        _setError('Error eliminando grabación: $e');
      }
    }
  }

  Future<String?> saveRecording(String customName) async {
    if (_currentRecordingPath == null || !File(_currentRecordingPath!).existsSync()) {
      _setError('No hay grabación para guardar');
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${customName}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final newPath = path.join(directory.path, 'voice_recordings', fileName);
      
      await File(_currentRecordingPath!).copy(newPath);
      return newPath;
    } catch (e) {
      _setError('Error guardando grabación: $e');
      return null;
    }
  }

  // ============================================================================
  // TEMPORIZADORES
  // ============================================================================

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
      notifyListeners();
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _startPlaybackTimer() {
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // La posición se actualiza automáticamente por el listener
      notifyListeners();
    });
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  // ============================================================================
  // GESTIÓN DE ESTADO
  // ============================================================================

  void _setState(VoiceRecordingState newState) {
    if (_state != newState) {
      _state = newState;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(VoiceRecordingState.error);
    debugPrint('VoiceRecordingService Error: $error');
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get playbackProgress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _playbackDuration.inMilliseconds / _totalDuration.inMilliseconds;
  }

  // ============================================================================
  // LIMPIEZA
  // ============================================================================

  @override
  void dispose() {
    _stopRecordingTimer();
    _stopPlaybackTimer();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ============================================================================
  // MÉTODOS DE UTILIDAD PARA INTEGRACIÓN
  // ============================================================================

  /// Resetear el estado para una nueva grabación
  Future<void> reset() async {
    await cancelRecording();
    await _stopPlayback();
    _setState(VoiceRecordingState.idle);
  }

  /// Verificar si hay una grabación válida
  bool hasValidRecording() {
    return _currentRecordingPath != null && 
           File(_currentRecordingPath!).existsSync() &&
           _recordingDuration.inSeconds > 0;
  }

  /// Obtener información de la grabación actual
  Map<String, dynamic> getRecordingInfo() {
    return {
      'path': _currentRecordingPath,
      'duration': _recordingDuration.inSeconds,
      'exists': hasValidRecording(),
      'state': _state.toString(),
    };
  }
}