// ============================================================================
// voice_recording_widget.dart - WIDGET DE GRABACIÓN DE VOZ PARA REFLEXIÓN
// ============================================================================

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/voice_recording_service.dart';
import '../../../injection_container_clean.dart';
import '../screens/v2/components/minimal_colors.dart';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(String)? onRecordingComplete;
  final String? existingRecordingPath;
  final bool isExpanded;
  final VoidCallback? onExpand;

  const VoiceRecordingWidget({
    Key? key,
    this.onRecordingComplete,
    this.existingRecordingPath,
    this.isExpanded = false,
    this.onExpand,
  }) : super(key: key);

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  VoiceRecordingService? _voiceService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeVoiceService();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeVoiceService() async {
    try {
      // Usar el servicio del contenedor de dependencias en lugar de crear uno nuevo
      _voiceService = sl<VoiceRecordingService>();
      
      // El servicio ya está inicializado desde initCriticalServices()
      // pero verificamos si necesita permisos adicionales
      if (!_voiceService!.hasPermission) {
        debugPrint('🎤 Requesting microphone permissions...');
        final permissionGranted = await _voiceService!.requestPermissions();
        debugPrint('🎤 Permission granted: $permissionGranted');
        
        if (!permissionGranted) {
          debugPrint('❌ Microphone permission denied');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permisos de micrófono necesarios para grabación de voz'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing voice service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inicializando grabación de voz: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    // No llamar dispose() en el servicio compartido del DI
    // _voiceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _voiceService == null) {
      return _buildLoadingState();
    }

    return ChangeNotifierProvider.value(
      value: _voiceService!,
      child: Consumer<VoiceRecordingService>(
        builder: (context, voiceService, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MinimalColors.backgroundCard(context),
                  MinimalColors.backgroundSecondary(context),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getBorderColor(voiceService.state),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getShadowColor(voiceService.state),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(voiceService),
                if (widget.isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildRecordingInterface(voiceService),
                  if (voiceService.hasRecording) ...[
                    const SizedBox(height: 16),
                    _buildPlaybackInterface(voiceService),
                  ],
                ],
                if (voiceService.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildErrorMessage(voiceService.errorMessage!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
          const SizedBox(width: 12),
          Text(
            'Inicializando grabación de voz...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(VoiceRecordingService voiceService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getHeaderGradient(voiceService.state),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getHeaderIcon(voiceService.state),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reflexión por Voz',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getStateMessage(voiceService.state),
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (voiceService.state == VoiceRecordingState.recording) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                voiceService.formatDuration(voiceService.recordingDuration),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: widget.onExpand,
            icon: Icon(
              widget.isExpanded ? Icons.expand_less : Icons.expand_more,
              color: MinimalColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInterface(VoiceRecordingService voiceService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Visualización de ondas de audio
          if (voiceService.isRecording)
            Container(
              height: 60,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildWaveform(),
            ),
          
          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!voiceService.isRecording) ...[
                _buildControlButton(
                  icon: Icons.mic,
                  label: 'Grabar',
                  colors: [Colors.red, Colors.red.shade700],
                  onPressed: voiceService.hasPermission 
                      ? () => _startRecording(voiceService)
                      : () => _requestPermissions(voiceService),
                ),
              ] else ...[
                _buildControlButton(
                  icon: voiceService.isPaused ? Icons.play_arrow : Icons.pause,
                  label: voiceService.isPaused ? 'Reanudar' : 'Pausar',
                  colors: [Colors.orange, Colors.orange.shade700],
                  onPressed: () => _togglePause(voiceService),
                ),
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Detener',
                  colors: [Colors.green, Colors.green.shade700],
                  onPressed: () => _stopRecording(voiceService),
                ),
                _buildControlButton(
                  icon: Icons.cancel,
                  label: 'Cancelar',
                  colors: [Colors.grey, Colors.grey.shade700],
                  onPressed: () => _cancelRecording(voiceService),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackInterface(VoiceRecordingService voiceService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundPrimary(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  color: MinimalColors.textSecondary(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Grabación lista',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  voiceService.formatDuration(voiceService.recordingDuration),
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Barra de progreso de reproducción
            if (voiceService.isPlaying)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: voiceService.playbackProgress,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MinimalColors.accentGradient(context)[0],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        voiceService.formatDuration(voiceService.playbackDuration),
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        voiceService.formatDuration(voiceService.totalDuration),
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // Controles de reproducción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: voiceService.isPlaying ? Icons.pause : Icons.play_arrow,
                  label: voiceService.isPlaying ? 'Pausar' : 'Reproducir',
                  colors: MinimalColors.accentGradient(context),
                  onPressed: () => _togglePlayback(voiceService),
                  isCompact: true,
                ),
                _buildControlButton(
                  icon: Icons.stop,
                  label: 'Detener',
                  colors: [Colors.grey, Colors.grey.shade700],
                  onPressed: () => voiceService.stopPlayback(),
                  isCompact: true,
                ),
                _buildControlButton(
                  icon: Icons.delete,
                  label: 'Eliminar',
                  colors: [Colors.red, Colors.red.shade700],
                  onPressed: () => _deleteRecording(voiceService),
                  isCompact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveformPainter(_waveAnimation.value),
          size: const Size(double.infinity, 60),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onPressed,
    bool isCompact = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 8 : 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isCompact ? 16 : 20,
            ),
            if (!isCompact) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de control
  Future<void> _startRecording(VoiceRecordingService voiceService) async {
    await voiceService.startRecording();
    if (voiceService.isRecording) {
      _pulseController.repeat();
      _waveController.repeat();
    }
  }

  Future<void> _stopRecording(VoiceRecordingService voiceService) async {
    await voiceService.stopRecording();
    _pulseController.stop();
    _waveController.stop();
    
    if (voiceService.hasRecording && widget.onRecordingComplete != null) {
      widget.onRecordingComplete!(voiceService.currentRecordingPath!);
    }
  }

  Future<void> _cancelRecording(VoiceRecordingService voiceService) async {
    await voiceService.cancelRecording();
    _pulseController.stop();
    _waveController.stop();
  }

  Future<void> _togglePause(VoiceRecordingService voiceService) async {
    if (voiceService.isPaused) {
      await voiceService.resumeRecording();
      _pulseController.repeat();
      _waveController.repeat();
    } else {
      await voiceService.pauseRecording();
      _pulseController.stop();
      _waveController.stop();
    }
  }

  Future<void> _togglePlayback(VoiceRecordingService voiceService) async {
    if (voiceService.isPlaying) {
      await voiceService.pausePlayback();
    } else {
      await voiceService.startPlayback();
    }
  }

  Future<void> _deleteRecording(VoiceRecordingService voiceService) async {
    // Mostrar confirmación
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        title: Text(
          'Eliminar grabación',
          style: TextStyle(color: MinimalColors.textPrimary(context)),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar esta grabación de voz?',
          style: TextStyle(color: MinimalColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: MinimalColors.textSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await voiceService.deleteRecording();
    }
  }

  Future<void> _requestPermissions(VoiceRecordingService voiceService) async {
    final granted = await voiceService.requestPermissions();
    if (!granted && mounted) {
      final errorMessage = voiceService.errorMessage ?? 'Permisos de micrófono requeridos para grabar';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 7),
          action: Platform.isIOS ? SnackBarAction(
            label: 'Configuración',
            textColor: Colors.white,
            onPressed: () async {
              // En iOS, mostrar cómo acceder a configuración
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Permisos de Micrófono'),
                  content: const Text(
                    'Para habilitar la grabación de voz:\n\n'
                    '1. Ve a Configuración del dispositivo\n'
                    '2. Selecciona Privacidad y Seguridad\n'
                    '3. Toca Micrófono\n'
                    '4. Activa el permiso para Reflect'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ) : null,
        ),
      );
    }
  }

  // Métodos de estilo
  Color _getBorderColor(VoiceRecordingState state) {
    switch (state) {
      case VoiceRecordingState.recording:
        return Colors.red.withValues(alpha: 0.5);
      case VoiceRecordingState.playing:
        return MinimalColors.accentGradient(context)[0].withValues(alpha: 0.5);
      case VoiceRecordingState.error:
        return Colors.red;
      default:
        return MinimalColors.textMuted(context).withValues(alpha: 0.3);
    }
  }

  Color _getShadowColor(VoiceRecordingState state) {
    switch (state) {
      case VoiceRecordingState.recording:
        return Colors.red.withValues(alpha: 0.3);
      case VoiceRecordingState.playing:
        return MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3);
      default:
        return Colors.black.withValues(alpha: 0.2);
    }
  }

  List<Color> _getHeaderGradient(VoiceRecordingState state) {
    switch (state) {
      case VoiceRecordingState.recording:
        return [Colors.red, Colors.red.shade700];
      case VoiceRecordingState.playing:
        return MinimalColors.accentGradient(context);
      case VoiceRecordingState.error:
        return [Colors.red, Colors.red.shade700];
      default:
        return MinimalColors.primaryGradient(context);
    }
  }

  IconData _getHeaderIcon(VoiceRecordingState state) {
    switch (state) {
      case VoiceRecordingState.recording:
        return Icons.mic;
      case VoiceRecordingState.playing:
        return Icons.play_arrow;
      case VoiceRecordingState.paused:
        return Icons.pause;
      case VoiceRecordingState.error:
        return Icons.error;
      default:
        return Icons.keyboard_voice;
    }
  }

  String _getStateMessage(VoiceRecordingState state) {
    switch (state) {
      case VoiceRecordingState.recording:
        return 'Grabando...';
      case VoiceRecordingState.paused:
        return 'Grabación en pausa';
      case VoiceRecordingState.playing:
        return 'Reproduciendo...';
      case VoiceRecordingState.stopped:
        return 'Grabación detenida';
      case VoiceRecordingState.error:
        return 'Error en la grabación';
      default:
        return 'Presiona para expandir y grabar tu reflexión';
    }
  }
}

// Painter personalizado para las ondas de audio
class WaveformPainter extends CustomPainter {
  final double animationValue;

  WaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 20;
    final maxHeight = size.height * 0.8;

    for (int i = 0; i < 20; i++) {
      final x = i * barWidth + barWidth / 2;
      final height = maxHeight * 
          (0.2 + 0.8 * (1 + sin(animationValue * 2 * pi + i * 0.5)) / 2);
      
      final rect = Rect.fromLTWH(
        x - barWidth / 4,
        size.height - height,
        barWidth / 2,
        height,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}