// ============================================================================
// presentation/widgets/simple_voice_recorder.dart - SIN DEPENDENCIAS EXTERNAS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SimpleVoiceRecorder extends StatefulWidget {
  final Function(String)? onTranscriptionComplete;
  final VoidCallback? onRecordingStart;
  final VoidCallback? onRecordingStop;

  const SimpleVoiceRecorder({
    Key? key,
    this.onTranscriptionComplete,
    this.onRecordingStart,
    this.onRecordingStop,
  }) : super(key: key);

  @override
  State<SimpleVoiceRecorder> createState() => _SimpleVoiceRecorderState();
}

class _SimpleVoiceRecorderState extends State<SimpleVoiceRecorder>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.currentColors.surface.withOpacity(0.8),
            themeProvider.currentColors.surfaceVariant.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeProvider.currentColors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.shadowColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎤 Grabación de Voz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording
                ? 'Grabando... Toca para parar'
                : _isProcessing
                ? 'Procesando audio...'
                : 'Toca para empezar a grabar',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.currentColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Botón de grabación con animación nativa
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedBuilder(
              animation: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: _isRecording
                            ? [
                          themeProvider.currentColors.negativeMain,
                          themeProvider.currentColors.negativeMain.withOpacity(0.7),
                        ]
                            : _isProcessing
                            ? [
                          themeProvider.currentColors.accentSecondary,
                          themeProvider.currentColors.accentSecondary.withOpacity(0.7),
                        ]
                            : [
                          themeProvider.currentColors.accentPrimary,
                          themeProvider.currentColors.accentSecondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _isRecording
                              ? themeProvider.currentColors.negativeMain.withOpacity(0.5)
                              : themeProvider.currentColors.accentPrimary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.stop
                          : _isProcessing
                          ? Icons.hourglass_empty
                          : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Estado visual simple
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeProvider.currentColors.borderColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isRecording ? double.infinity : 0,
              decoration: BoxDecoration(
                color: themeProvider.currentColors.positiveMain,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    if (_isProcessing) return;

    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  void _startRecording() {
    _pulseController.repeat(reverse: true);
    widget.onRecordingStart?.call();

    // Simular grabación por 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (_isRecording && mounted) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    _pulseController.stop();
    widget.onRecordingStop?.call();

    // Simular procesamiento
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Simular transcripción
        final transcriptions = [
          'Hoy tuve una reunión muy productiva',
          'Me siento estresado por el trabajo',
          'Fue un día increíble con mi familia',
          'Necesito tomarme un descanso',
          'Logré completar todas mis tareas',
        ];

        final hour = DateTime.now().hour;
        final transcription = transcriptions[hour % transcriptions.length];

        widget.onTranscriptionComplete?.call(transcription);
      }
    });
  }
}