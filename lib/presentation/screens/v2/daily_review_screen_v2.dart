// ============================================================================
// daily_review_screen_v2.dart - NUEVA VERSIÓN GUIADA E INTERACTIVA
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';

// Pantallas relacionadas
import 'calendar_screen_v2.dart';

// Componentes
import 'components/minimal_colors.dart';
import '../../widgets/voice_recording_widget.dart';

class DailyReviewScreenV2 extends StatefulWidget {
  const DailyReviewScreenV2({super.key});

  @override
  State<DailyReviewScreenV2> createState() => _DailyReviewScreenV2State();
}

class _DailyReviewScreenV2State extends State<DailyReviewScreenV2>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================

  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final int _totalSteps = 5;

  // Estados del formulario
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _positiveTagsController = TextEditingController();
  final _negativeTagsController = TextEditingController();

  // Métricas principales
  int _moodScore = 5;
  int _energyLevel = 5;
  int _stressLevel = 5;
  bool? _worthIt;

  // Métricas de bienestar
  int _sleepQuality = 5;
  int _anxietyLevel = 5;
  int _motivationLevel = 5;
  int _socialInteraction = 5;
  int _physicalActivity = 5;
  int _workProductivity = 5;

  // Métricas numéricas
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _meditationMinutes = 0;
  int _exerciseMinutes = 0;
  double _screenTimeHours = 4.0;

  // Métricas avanzadas
  int _socialBattery = 5;
  int _creativeEnergy = 5;
  int _emotionalStability = 5;
  int _focusLevel = 5;
  int _lifeSatisfaction = 5;
  int _weatherMoodImpact = 0;

  // Voice recording state
  bool _isVoiceRecordingExpanded = false;
  String? _voiceRecordingPath;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExistingEntry();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _reflectionController.dispose();
    _gratitudeController.dispose();
    _positiveTagsController.dispose();
    _negativeTagsController.dispose();
    super.dispose();
  }

  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _pageController = PageController();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeInOut));

    // Start animations with staggered delays
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _updateProgress();
      }
    });
  }

  void _loadExistingEntry() {
    final entriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final todayEntry = entriesProvider.todayEntry;

    if (todayEntry != null) {
      setState(() {
        _reflectionController.text = todayEntry.freeReflection;
        _gratitudeController.text = todayEntry.gratitudeItems ?? '';
        _positiveTagsController.text = todayEntry.positiveTags.join(', ');
        _negativeTagsController.text = todayEntry.negativeTags.join(', ');
        _moodScore = todayEntry.moodScore ?? 5;
        _energyLevel = todayEntry.energyLevel ?? 5;
        _stressLevel = todayEntry.stressLevel ?? 5;
        _worthIt = todayEntry.worthIt;
        _sleepQuality = todayEntry.sleepQuality ?? 5;
        _anxietyLevel = todayEntry.anxietyLevel ?? 5;
        _motivationLevel = todayEntry.motivationLevel ?? 5;
        _socialInteraction = todayEntry.socialInteraction ?? 5;
        _physicalActivity = todayEntry.physicalActivity ?? 5;
        _workProductivity = todayEntry.workProductivity ?? 5;
        _sleepHours = todayEntry.sleepHours ?? 8.0;
        _waterIntake = todayEntry.waterIntake ?? 8;
        _meditationMinutes = todayEntry.meditationMinutes ?? 0;
        _exerciseMinutes = todayEntry.exerciseMinutes ?? 0;
        _screenTimeHours = todayEntry.screenTimeHours ?? 4.0;
        _socialBattery = todayEntry.socialBattery ?? 5;
        _creativeEnergy = todayEntry.creativeEnergy ?? 5;
        _emotionalStability = todayEntry.emotionalStability ?? 5;
        _focusLevel = todayEntry.focusLevel ?? 5;
        _lifeSatisfaction = todayEntry.lifeSatisfaction ?? 5;
        _weatherMoodImpact = todayEntry.weatherMoodImpact ?? 0;
      });
    }
  }

  // ============================================================================
  // MÉTODOS SOFISTICADOS PARA EXPRESIÓN DEL USUARIO
  // ============================================================================

  // Palabras clave para análisis semántico
  static const Map<String, List<String>> _emotionKeywords = {
    'joy': ['feliz', 'alegre', 'contento', 'radiante', 'eufórico', 'dichoso'],
    'sadness': ['triste', 'melancólico', 'decaído', 'desanimado', 'sombrío'],
    'anger': ['enojado', 'furioso', 'irritado', 'molesto', 'rabioso'],
    'fear': ['miedo', 'nervioso', 'ansioso', 'preocupado', 'temeroso'],
    'surprise': ['sorprendido', 'asombrado', 'impactado', 'inesperado'],
    'disgust': ['asco', 'repulsión', 'disgusto', 'desagrado'],
    'calm': ['calmado', 'relajado', 'sereno', 'tranquilo', 'pacífico'],
    'excited': ['emocionado', 'entusiasmado', 'vibrante', 'energético'],
  };

  // Análisis inteligente del texto libre
  Map<String, dynamic> _analyzeReflectionText(String text) {
    if (text.isEmpty) return {'emotions': [], 'sentiment': 0.0, 'complexity': 0};

    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final detectedEmotions = <String>[];
    double sentimentScore = 0.0;
    int positiveWords = 0;
    int negativeWords = 0;

    for (final word in words) {
      for (final emotion in _emotionKeywords.keys) {
        if (_emotionKeywords[emotion]!.contains(word)) {
          detectedEmotions.add(emotion);
          
          // Calcular sentimiento
          if (['joy', 'calm', 'excited'].contains(emotion)) {
            positiveWords++;
          } else if (['sadness', 'anger', 'fear', 'disgust'].contains(emotion)) {
            negativeWords++;
          }
        }
      }
    }

    if (positiveWords + negativeWords > 0) {
      sentimentScore = (positiveWords - negativeWords) / (positiveWords + negativeWords);
    }

    return {
      'emotions': detectedEmotions.toSet().toList(),
      'sentiment': sentimentScore,
      'complexity': words.length,
      'wordCount': words.length,
    };
  }

  // Sugerencias inteligentes basadas en el estado actual
  List<String> _getSmartSuggestions() {
    final suggestions = <String>[];
    
    if (_moodScore <= 4) {
      suggestions.addAll([
        '¿Qué pequeña cosa podrías hacer ahora para sentirte un poco mejor?',
        '¿Hay alguien con quien te gustaría hablar?',
        'Describe un momento feliz de hoy, por pequeño que sea.',
      ]);
    }
    
    if (_stressLevel >= 7) {
      suggestions.addAll([
        '¿Qué está causando más estrés en este momento?',
        'Describe tu técnica favorita para relajarte.',
        '¿Qué harías si tuvieras una hora libre ahora mismo?',
      ]);
    }
    
    if (_energyLevel <= 3) {
      suggestions.addAll([
        '¿Qué actividad te da más energía normalmente?',
        'Describe cómo te sientes físicamente en este momento.',
        '¿Qué necesitas para recargar tu energía?',
      ]);
    }

    // Sugerencias generales si no hay específicas
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Describe el mejor momento de tu día.',
        '¿Qué aprendiste sobre ti mismo hoy?',
        'Si tuvieras que darle un consejo a alguien que tuvo un día como el tuyo, ¿qué le dirías?',
        '¿Qué te gustaría recordar de este día en el futuro?',
      ]);
    }

    return suggestions..shuffle();
  }

  // Obtener el emoji basado en múltiples métricas
  String _getSmartEmoji() {
    final avgMood = (_moodScore + (10 - _stressLevel) + _energyLevel) / 3;
    
    if (avgMood >= 8) return '😊';
    if (avgMood >= 7) return '🙂';
    if (avgMood >= 6) return '😐';
    if (avgMood >= 5) return '😕';
    if (avgMood >= 4) return '😔';
    return '😢';
  }

  // ============================================================================
  // NAVEGACIÓN
  // ============================================================================

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
      HapticFeedback.lightImpact();
    }
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _totalSteps);
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _reflectionController.text.trim().isNotEmpty;
      case 1:
        return _moodScore > 0;
      case 2:
        return _energyLevel > 0 && _stressLevel > 0;
      case 3:
        return true; // Métricas opcionales
      case 4:
        return _worthIt != null;
      default:
        return false;
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedTheme(
          duration: const Duration(milliseconds: 300),
          data: themeProvider.currentThemeData,
          child: Scaffold(
            backgroundColor: MinimalColors.backgroundPrimary(context),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MinimalColors.backgroundPrimary(context),
                    MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
                    MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildProgressIndicator(),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentStep = index;
                            });
                            _updateProgress();
                          },
                          children: [
                            _buildReflectionStep(),    // Paso 1: Reflexión libre
                            _buildMoodStep(),          // Paso 2: Estado de ánimo
                            _buildWellbeingStep(),     // Paso 3: Bienestar básico
                            _buildMetricsStep(),       // Paso 4: Métricas detalladas
                            _buildFinalStep(),         // Paso 5: Evaluación final
                          ],
                        ),
                      ),
                      _buildBottomActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // HEADER Y PROGRESO
  // ============================================================================

  Widget _buildHeader() {
    final now = DateTime.now();
    final weekDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

    final dayName = weekDays[now.weekday - 1];
    final monthName = months[now.month - 1];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack)),
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: MinimalColors.primaryGradient(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      iconSize: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: MinimalColors.primaryGradient(context),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reflexión del Día',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '$dayName, ${now.day} de $monthName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: _navigateToCalendar,
                            icon: const Icon(Icons.calendar_month, color: Colors.white),
                            iconSize: 20,
                            tooltip: 'Ver todas las reflexiones',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildQuickStepsIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Comparte tus pensamientos del día';
      case 1: return 'Evalúa tu estado emocional';
      case 2: return 'Mide tu bienestar general';
      case 3: return 'Registra métricas específicas';
      case 4: return 'Reflexiona sobre el valor del día';
      default: return '';
    }
  }

  Widget _buildQuickStepsIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStepTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: MinimalColors.accentGradient(context),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_currentStep + 1}/$_totalSteps',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MinimalColors.backgroundCard(context),
              MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
              MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: List.generate(_totalSteps, (index) {
                final isCompleted = index <= _currentStep;
                final isActive = index == _currentStep;

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: isActive ? 8 : 6,
                    margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 12 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: isCompleted
                          ? LinearGradient(
                              colors: isActive 
                                  ? MinimalColors.primaryGradient(context)
                                  : MinimalColors.accentGradient(context),
                            )
                          : null,
                      color: isCompleted
                          ? null
                          : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context).map(
                    (c) => c.withValues(alpha: 0.1)
                  ).toList(),
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: MinimalColors.primaryGradient(context),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.timeline,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Paso ${_currentStep + 1} de $_totalSteps',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.accentGradient(context),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PASO 1: REFLEXIÓN LIBRE
  // ============================================================================

  Widget _buildReflectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            icon: '✍️',
            title: 'Reflexión Personal',
            subtitle: 'Comparte cómo ha sido tu día',
            child: Column(
              children: [
                _buildReflectionField(),
                const SizedBox(height: 16),
                _buildVoiceRecordingWidget(),
                const SizedBox(height: 16),
                _buildGratitudeField(),
                const SizedBox(height: 16),
                _buildTagsFields(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionField() {
    final analysis = _analyzeReflectionText(_reflectionController.text);
    final suggestions = _getSmartSuggestions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto principal mejorado
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundSecondary(context),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.primaryGradientStatic,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: MinimalColors.textPrimary(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reflexión Libre',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_reflectionController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getSentimentGradient(analysis['sentiment']),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getSmartEmoji()} ${analysis['wordCount']} palabras',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              TextField(
                controller: _reflectionController,
                maxLines: 6,
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: _getPersonalizedHint(),
                  hintStyle: TextStyle(
                    color: MinimalColors.textMuted(context),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        
        // Análisis emocional en tiempo real
        if (_reflectionController.text.isNotEmpty && analysis['emotions'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emociones detectadas:',
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: (analysis['emotions'] as List<String>).map((emotion) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEmotionColor(emotion),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getEmotionEmoji(emotion)} ${_translateEmotion(emotion)}',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

        // Sugerencias inteligentes
        if (_reflectionController.text.isEmpty || _reflectionController.text.length < 20)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MinimalColors.lightGradient(context)[0].withValues(alpha: 0.1),
                    MinimalColors.lightGradient(context)[1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: MinimalColors.lightGradient(context)[0],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sugerencias para reflexionar:',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...suggestions.take(2).map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        _reflectionController.text = '$suggestion\n\n';
                        _reflectionController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _reflectionController.text.length),
                        );
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MinimalColors.backgroundCard(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: MinimalColors.lightGradient(context)[0],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  color: MinimalColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Métodos auxiliares para el campo de reflexión mejorado
  String _getPersonalizedHint() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return '¿Cómo empezaste tu día? ¿Qué esperas que suceda hoy?';
    } else if (hour < 17) {
      return '¿Cómo va tu día hasta ahora? ¿Qué ha sido lo más destacado?';
    } else {
      return '¿Cómo ha sido tu día? ¿Qué has aprendido sobre ti mismo?';
    }
  }

  List<Color> _getSentimentGradient(double sentiment) {
    if (sentiment > 0.3) {
      return MinimalColors.positiveGradient(context);
    } else if (sentiment < -0.3) {
      return MinimalColors.negativeGradient(context);
    } else {
      return MinimalColors.neutralGradient(context);
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'joy': return Colors.amber;
      case 'calm': return Colors.blue;
      case 'excited': return Colors.orange;
      case 'sadness': return Colors.indigo;
      case 'anger': return Colors.red;
      case 'fear': return Colors.purple;
      case 'surprise': return Colors.teal;
      case 'disgust': return Colors.brown;
      default: return Colors.grey;
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'joy': return '😊';
      case 'calm': return '😌';
      case 'excited': return '🤩';
      case 'sadness': return '😢';
      case 'anger': return '😠';
      case 'fear': return '😨';
      case 'surprise': return '😲';
      case 'disgust': return '🤢';
      default: return '🙂';
    }
  }

  String _translateEmotion(String emotion) {
    switch (emotion) {
      case 'joy': return 'Alegría';
      case 'calm': return 'Calma';
      case 'excited': return 'Emoción';
      case 'sadness': return 'Tristeza';
      case 'anger': return 'Enojo';
      case 'fear': return 'Miedo';
      case 'surprise': return 'Sorpresa';
      case 'disgust': return 'Disgusto';
      default: return emotion;
    }
  }

  Widget _buildVoiceRecordingWidget() {
    return VoiceRecordingWidget(
      isExpanded: _isVoiceRecordingExpanded,
      existingRecordingPath: _voiceRecordingPath,
      onExpand: () {
        setState(() {
          _isVoiceRecordingExpanded = !_isVoiceRecordingExpanded;
        });
      },
      onRecordingComplete: (path) {
        setState(() {
          _voiceRecordingPath = path;
        });
        
        // Opcionalmente, mostrar un mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Grabación de voz guardada exitosamente'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildGratitudeField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.positiveGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.positiveGradient(context)[1].withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.positiveGradientStatic,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: MinimalColors.textPrimary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gratitud y Apreciación',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_gratitudeController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.positiveGradientStatic,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '💚 Gratitud',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _gratitudeController,
            maxLines: 3,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '¿Por qué estás agradecido hoy? Menciona personas, momentos o experiencias...',
              hintStyle: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsFields() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _positiveTagsController,
              style: TextStyle(color: MinimalColors.textPrimary(context)),
              decoration: const InputDecoration(
                labelText: '✅ Aspectos positivos',
                labelStyle: TextStyle(color: Colors.green),
                hintText: 'ej: productivo, feliz',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _negativeTagsController,
              style: TextStyle(color: MinimalColors.textPrimary(context)),
              decoration: const InputDecoration(
                labelText: '❌ Aspectos a mejorar',
                labelStyle: TextStyle(color: Colors.red),
                hintText: 'ej: estresado, cansado',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // PASO 2: ESTADO DE ÁNIMO
  // ============================================================================

  Widget _buildMoodStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            icon: '😊',
            title: 'Estado de Ánimo',
            subtitle: 'Evalúa cómo te sientes hoy',
            child: Column(
              children: [
                _buildMoodSelector(),
                const SizedBox(height: 24),
                _buildMoodInsight(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moodEmojis = ['😢', '😟', '😐', '🙂', '😊', '😄', '😆', '🤩', '😍', '🥳'];
    final moodLabels = ['Muy mal', 'Mal', 'Regular-', 'Regular', 'Bien', 'Muy bien', 'Genial', 'Fantástico', 'Increíble', 'Perfecto'];

    return Column(
      children: [
        // Emoji grande actual
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _getMoodGradient(_moodScore)),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: _getMoodColor(_moodScore).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              moodEmojis[(_moodScore - 1).clamp(0, 9)],
              style: TextStyle(fontSize: 60),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Label del estado
        Text(
          moodLabels[(_moodScore - 1).clamp(0, 9)],
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 24),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getMoodColor(_moodScore),
            inactiveTrackColor: Colors.white24,
            thumbColor: _getMoodColor(_moodScore),
            overlayColor: _getMoodColor(_moodScore).withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _moodScore.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _moodScore = value.round();
              });
              HapticFeedback.lightImpact();
            },
          ),
        ),

        // Indicadores numéricos
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) {
            final number = index + 1;
            final isSelected = number == _moodScore;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _moodScore = number;
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? _getMoodColor(_moodScore) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _getMoodColor(_moodScore) : Colors.white24,
                  ),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMoodInsight() {
    String insight = '';
    Color insightColor = Colors.white70;

    if (_moodScore <= 3) {
      insight = 'Parece que ha sido un día difícil. Recuerda que los días difíciles también forman parte del crecimiento.';
      insightColor = Colors.red.shade300;
    } else if (_moodScore <= 6) {
      insight = 'Un día promedio. Pequeños cambios pueden hacer una gran diferencia mañana.';
      insightColor = Colors.orange.shade300;
    } else {
      insight = '¡Qué buen día! Reflexiona sobre qué lo hizo especial para repetirlo.';
      insightColor = Colors.green.shade300;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insightColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: insightColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                color: insightColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PASO 3: BIENESTAR BÁSICO
  // ============================================================================

  Widget _buildWellbeingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            icon: '⚡',
            title: 'Bienestar General',
            subtitle: 'Evalúa tu energía y estrés del día',
            child: Column(
              children: [
                _buildInteractiveSlider(
                  title: 'Nivel de Energía',
                  value: _energyLevel,
                  emoji: '⚡',
                  gradientColors: MinimalColors.positiveGradient(context),
                  onChanged: (value) => setState(() => _energyLevel = value),
                ),

                const SizedBox(height: 24),

                _buildInteractiveSlider(
                  title: 'Nivel de Estrés',
                  value: _stressLevel,
                  emoji: '😰',
                  gradientColors: MinimalColors.negativeGradient(context),
                  onChanged: (value) => setState(() => _stressLevel = value),
                  isReversed: true, // Mayor valor = peor
                ),

                const SizedBox(height: 24),

                _buildEnergyStressBalance(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSlider({
    required String title,
    required int value,
    required String emoji,
    required List<Color> gradientColors,
    required Function(int) onChanged,
    bool isReversed = false,
  }) {
    // final effectiveValue = isReversed ? (11 - value) : value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withValues(alpha: 0.1),
            gradientColors[1].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradientColors[0].withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value/10',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: gradientColors[0],
              inactiveTrackColor: Colors.white24,
              thumbColor: gradientColors[1],
              overlayColor: gradientColors[0].withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (newValue) {
                onChanged(newValue.round());
                HapticFeedback.lightImpact();
              },
            ),
          ),

          Text(
            _getSliderLabel(title, value, isReversed),
            style: TextStyle(
              color: gradientColors[0],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getSliderLabel(String title, int value, bool isReversed) {
    if (title.contains('Energía')) {
      if (value <= 3) return 'Muy baja energía';
      if (value <= 6) return 'Energía moderada';
      return 'Alta energía';
    } else if (title.contains('Estrés')) {
      if (value <= 3) return 'Muy relajado';
      if (value <= 6) return 'Algo de tensión';
      return 'Muy estresado';
    }
    return '';
  }

  Widget _buildEnergyStressBalance() {
    final balance = _energyLevel - _stressLevel;
    final balanceColor = balance > 2
        ? Colors.green
        : balance < -2
        ? Colors.red
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: balanceColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Balance Energía-Estrés',
            style: TextStyle(
              color: balanceColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (balance + 9) / 18, // Normalizar de -9 a 9 => 0 a 1
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(balanceColor),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            _getBalanceMessage(balance),
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getBalanceMessage(int balance) {
    if (balance > 3) return 'Excelente balance: mucha energía, poco estrés';
    if (balance > 0) return 'Buen balance general';
    if (balance > -3) return 'Balance neutral: energía y estrés equilibrados';
    return 'Desequilibrio: alto estrés, poca energía';
  }

  // ============================================================================
  // PASO 4: MÉTRICAS DETALLADAS
  // ============================================================================

  Widget _buildMetricsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            icon: '📊',
            title: 'Métricas Detalladas',
            subtitle: 'Opcional: registra métricas específicas',
            child: Column(
              children: [
                _buildMetricsGrid(),
                const SizedBox(height: 20),
                _buildNumericMetrics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {'title': 'Calidad del Sueño', 'value': _sleepQuality, 'emoji': '😴', 'key': 'sleep'},
      {'title': 'Ansiedad', 'value': _anxietyLevel, 'emoji': '😰', 'key': 'anxiety'},
      {'title': 'Motivación', 'value': _motivationLevel, 'emoji': '🔥', 'key': 'motivation'},
      {'title': 'Interacción Social', 'value': _socialInteraction, 'emoji': '👥', 'key': 'social'},
      {'title': 'Actividad Física', 'value': _physicalActivity, 'emoji': '🏃', 'key': 'physical'},
      {'title': 'Productividad', 'value': _workProductivity, 'emoji': '💼', 'key': 'work'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(metric);
      },
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    final title = metric['title'] as String;
    final value = metric['value'] as int;
    final emoji = metric['emoji'] as String;
    final key = metric['key'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (starIndex) {
              final isActive = starIndex < (value / 2).ceil();
              return Icon(
                Icons.star,
                size: 16,
                color: isActive ? Colors.amber : Colors.white24,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$value/10',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showMetricSlider(title, value, key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Ajustar',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericMetrics() {
    return Column(
      children: [
        _buildNumericSlider(
          title: 'Horas de sueño',
          value: _sleepHours,
          emoji: '🛏️',
          unit: 'horas',
          min: 0,
          max: 12,
          onChanged: (value) => setState(() => _sleepHours = value),
        ),
        const SizedBox(height: 16),
        _buildNumericSlider(
          title: 'Vasos de agua',
          value: _waterIntake.toDouble(),
          emoji: '💧',
          unit: 'vasos',
          min: 0,
          max: 15,
          isInteger: true,
          onChanged: (value) => setState(() => _waterIntake = value.round()),
        ),
        const SizedBox(height: 16),
        _buildNumericSlider(
          title: 'Tiempo de pantalla',
          value: _screenTimeHours,
          emoji: '📱',
          unit: 'horas',
          min: 0,
          max: 16,
          onChanged: (value) => setState(() => _screenTimeHours = value),
        ),
      ],
    );
  }

  Widget _buildNumericSlider({
    required String title,
    required double value,
    required String emoji,
    required String unit,
    required double min,
    required double max,
    required Function(double) onChanged,
    bool isInteger = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.lightGradient(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isInteger
                      ? '${value.round()} $unit'
                      : '${value.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MinimalColors.lightGradient(context)[0],
              inactiveTrackColor: Colors.white24,
              thumbColor: MinimalColors.lightGradient(context)[1],
              overlayColor: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: isInteger ? (max - min).round() : null,
              onChanged: (newValue) {
                onChanged(newValue);
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PASO 5: EVALUACIÓN FINAL
  // ============================================================================

  Widget _buildFinalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepCard(
            icon: '🎯',
            title: 'Reflexión Final',
            subtitle: 'Evalúa el valor general de tu día',
            child: Column(
              children: [
                _buildWorthItQuestion(),
                const SizedBox(height: 24),
                _buildDaySummary(),
                const SizedBox(height: 24),
                _buildNavigationOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItQuestion() {
    return Column(
      children: [
        Text(
          '¿Ha valido la pena este día?',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _worthIt = true);
                  HapticFeedback.mediumImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: _worthIt == true
                        ? LinearGradient(colors: MinimalColors.positiveGradient(context))
                        : null,
                    color: _worthIt == true ? null : MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _worthIt == true
                          ? Colors.green
                          : Colors.white.withValues(alpha: 0.3),
                      width: _worthIt == true ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '👍',
                        style: TextStyle(fontSize: _worthIt == true ? 40 : 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sí, ha valido la pena',
                        style: TextStyle(
                          color: _worthIt == true ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: _worthIt == true ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _worthIt = false);
                  HapticFeedback.mediumImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: _worthIt == false
                        ? LinearGradient(colors: MinimalColors.negativeGradient(context))
                        : null,
                    color: _worthIt == false ? null : MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _worthIt == false
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.3),
                      width: _worthIt == false ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '👎',
                        style: TextStyle(fontSize: _worthIt == false ? 40 : 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No, podría mejorar',
                        style: TextStyle(
                          color: _worthIt == false ? Colors.white : Colors.white70,
                          fontSize: 14,
                          fontWeight: _worthIt == false ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaySummary() {
    final overallScore = (_moodScore + _energyLevel + (11 - _stressLevel)) / 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _getMoodGradient(overallScore.round())),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getMoodColor(overallScore.round()).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Puntuación del Día',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${overallScore.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getDayMessage(overallScore),
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayMessage(double score) {
    if (score >= 8) return '¡Excelente día! Sigue así 🌟';
    if (score >= 6) return 'Buen día en general 👍';
    if (score >= 4) return 'Día promedio, hay espacio para mejorar 📈';
    return 'Día difícil, mañana será mejor 💪';
  }

  Widget _buildNavigationOptions() {
    return Column(
      children: [
        const Text(
          'Después de guardar puedes:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          icon: Icons.calendar_month,
          title: 'Ver todas las reflexiones',
          subtitle: 'Navegar por el calendario del año',
          onTap: () {
            _saveReflection().then((success) {
              if (success) {
                _navigateToCalendar();
              }
            });
          },
        ),
        const SizedBox(height: 12),
        _buildNavigationButton(
          icon: Icons.analytics,
          title: 'Ver análisis y tendencias',
          subtitle: 'Explorar patrones en tus datos',
          onTap: () {
            _saveReflection().then((success) {
              if (success && mounted) {
                Navigator.pushReplacementNamed(context, '/analytics');
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: MinimalColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: MinimalColors.textMuted(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // WIDGETS HELPER
  // ============================================================================

  Widget _buildStepCard({
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack)),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MinimalColors.backgroundCard(context),
              MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.08),
              MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context).map(
                      (c) => c.withValues(alpha: 0.15)
                    ).toList(),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.primaryGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: MinimalColors.textPrimary(context),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: MinimalColors.textSecondary(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: MinimalColors.primaryGradient(context)[0],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ACCIONES INFERIORES
  // ============================================================================

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MinimalColors.textPrimary(context),
                    side: BorderSide.none,
                    backgroundColor: MinimalColors.backgroundCard(context).withValues(alpha: 0.8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: MinimalColors.textPrimary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Anterior',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MinimalColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: _canContinue()
                    ? LinearGradient(colors: MinimalColors.accentGradient(context))
                    : null,
                color: !_canContinue() 
                    ? MinimalColors.textMuted(context).withValues(alpha: 0.3)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _canContinue()
                    ? [
                        BoxShadow(
                          color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: MinimalColors.accentGradient(context)[1].withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: _canContinue()
                    ? (_currentStep == _totalSteps - 1 ? _saveReflection : _nextStep)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentStep == _totalSteps - 1)
                      const Icon(
                        Icons.save_rounded,
                        size: 20,
                        color: Colors.white,
                      )
                    else
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _currentStep == _totalSteps - 1 ? 'Guardar Reflexión' : 'Continuar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  Future<bool> _saveReflection() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final entriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      _showErrorSnackBar('Error: usuario no autenticado');
      return false;
    }

    try {
      _showLoadingDialog();

      final success = await entriesProvider.saveDailyEntry(
        userId: authProvider.currentUser!.id,
        freeReflection: _reflectionController.text.trim(),
        positiveTags: _positiveTagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        negativeTags: _negativeTagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        worthIt: _worthIt,
        moodScore: _moodScore,
        energyLevel: _energyLevel,
        stressLevel: _stressLevel,
        sleepQuality: _sleepQuality,
        anxietyLevel: _anxietyLevel,
        motivationLevel: _motivationLevel,
        socialInteraction: _socialInteraction,
        physicalActivity: _physicalActivity,
        workProductivity: _workProductivity,
        sleepHours: _sleepHours,
        waterIntake: _waterIntake,
        meditationMinutes: _meditationMinutes,
        exerciseMinutes: _exerciseMinutes,
        screenTimeHours: _screenTimeHours,
        gratitudeItems: _gratitudeController.text.trim().isEmpty ? null : _gratitudeController.text.trim(),
        weatherMoodImpact: _weatherMoodImpact,
        socialBattery: _socialBattery,
        creativeEnergy: _creativeEnergy,
        emotionalStability: _emotionalStability,
        focusLevel: _focusLevel,
        lifeSatisfaction: _lifeSatisfaction,
        voiceRecordingPath: _voiceRecordingPath,
      );

      if (mounted) Navigator.pop(context); // Cerrar loading

      if (success) {
        _showSuccessSnackBar('¡Reflexión guardada exitosamente!');
        return true;
      } else {
        _showErrorSnackBar('Error al guardar la reflexión');
        return false;
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Cerrar loading
      _showErrorSnackBar('Error inesperado al guardar');
      return false;
    }
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreenV2(),
      ),
    );
  }

  void _showMetricSlider(String title, int currentValue, String key) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: MinimalColors.backgroundPrimary(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            StatefulBuilder(
              builder: (context, setModalState) {
                int tempValue = currentValue;
                return Column(
                  children: [
                    Text(
                      '$tempValue/10',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: MinimalColors.accentGradient(context)[0],
                        inactiveTrackColor: Colors.white24,
                        thumbColor: MinimalColors.accentGradient(context)[1],
                        overlayColor: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.2),
                        trackHeight: 8,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                      ),
                      child: Slider(
                        value: tempValue.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) {
                          setModalState(() {
                            tempValue = value.round();
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          switch (key) {
                            case 'sleep': _sleepQuality = tempValue; break;
                            case 'anxiety': _anxietyLevel = tempValue; break;
                            case 'motivation': _motivationLevel = tempValue; break;
                            case 'social': _socialInteraction = tempValue; break;
                            case 'physical': _physicalActivity = tempValue; break;
                            case 'work': _workProductivity = tempValue; break;
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        child: Text(
                          'Confirmar',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  Color _getMoodColor(int score) {
    if (score <= 3) return Colors.red;
    if (score <= 6) return Colors.orange;
    return Colors.green;
  }

  List<Color> _getMoodGradient(int score) {
    if (score <= 3) return MinimalColors.negativeGradient(context);
    if (score <= 6) return MinimalColors.neutralGradient(context);
    return MinimalColors.positiveGradient(context);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}