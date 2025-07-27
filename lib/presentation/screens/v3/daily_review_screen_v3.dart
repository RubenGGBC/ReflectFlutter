// ============================================================================
// daily_review_screen_v3.dart - REVISIÓN DIARIA COMPLETA CON TODAS LAS FUNCIONALIDADES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Core
import '../../../core/themes/app_theme.dart';

// Data Models
import '../../../data/models/daily_entry_model.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/interactive_moment_model.dart';
import '../../../data/models/tag_model.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/enhanced_goals_provider.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/image_moments_provider.dart';
import '../../providers/daily_activities_provider.dart';
import '../../providers/advanced_emotion_analysis_provider.dart';

// Screens
import 'calendar_screen_v3.dart';
import '../activities_screen.dart';

// Widgets
import '../../widgets/voice_recording_widget.dart';
import '../../widgets/progress_entry_dialog.dart';

class DailyReviewScreenV3 extends StatefulWidget {
  final DateTime? selectedDate;
  
  const DailyReviewScreenV3({
    super.key,
    this.selectedDate,
  });

  @override
  State<DailyReviewScreenV3> createState() => _DailyReviewScreenV3State();
}

class _DailyReviewScreenV3State extends State<DailyReviewScreenV3>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================

  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late AnimationController _fabController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  final int _totalSteps = 10; // Más pasos para funcionalidad completa

  DateTime _selectedDate = DateTime.now();

  // Estados del formulario principal
  final _reflectionController = TextEditingController();
  final _innerReflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _positiveTagsController = TextEditingController();
  final _negativeTagsController = TextEditingController();
  final _notesController = TextEditingController();

  // Métricas principales (0-10)
  int _moodScore = 5;
  int _energyLevel = 5;
  int _stressLevel = 5;
  int _anxietyLevel = 5;
  int _motivationLevel = 5;
  int _focusLevel = 5;
  bool? _worthIt;

  // Métricas de bienestar
  int _sleepQuality = 5;
  int _socialInteraction = 5;
  int _physicalActivity = 5;
  int _workProductivity = 5;
  int _creativityLevel = 5;
  int _spiritualWellness = 5;

  // Métricas numéricas
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _meditationMinutes = 0;
  int _exerciseMinutes = 0;
  double _screenTimeHours = 4.0;
  int _socialMinutes = 60;

  // Métricas avanzadas
  int _socialBattery = 5;
  int _creativeEnergy = 5;
  int _emotionalStability = 5;
  int _lifeSatisfaction = 5;
  int _weatherMoodImpact = 0;
  
  // Estados especiales
  List<String> _selectedTags = [];
  List<String> _completedActivities = [];
  List<String> _goalProgress = [];
  List<File> _selectedImages = [];
  List<String> _voiceRecordings = [];
  List<Map<String, dynamic>> _quickMoments = [];

  // Voice recording state
  bool _isVoiceRecordingExpanded = false;
  String? _currentVoiceRecording;

  // UI state
  bool _isSaving = false;
  bool _showAdvancedMetrics = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _setupAnimations();
    _loadExistingEntry();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    
    _pageController.dispose();
    _progressController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _fabController.dispose();
    
    _reflectionController.dispose();
    _innerReflectionController.dispose();
    _gratitudeController.dispose();
    _positiveTagsController.dispose();
    _negativeTagsController.dispose();
    _notesController.dispose();
    
    super.dispose();
  }

  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _pageController = PageController();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    // Ocultar UI del sistema para experiencia inmersiva
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Iniciar animaciones
    _progressController.forward();
    _cardController.forward();
    _fabController.forward();
  }

  void _loadExistingEntry() {
    final authProvider = context.read<OptimizedAuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      final entriesProvider = context.read<OptimizedDailyEntriesProvider>();
      final existingEntry = entriesProvider.getEntryForDate(_selectedDate);
      
      if (existingEntry != null) {
        _populateFromExistingEntry(existingEntry);
      }
      
      // Cargar datos adicionales
      _loadAdditionalData(user.id);
    }
  }

  void _populateFromExistingEntry(DailyEntryModel entry) {
    setState(() {
      _moodScore = entry.moodScore;
      _energyLevel = entry.energyLevel;
      _stressLevel = entry.stressLevel;
      _anxietyLevel = entry.anxietyLevel ?? 5;
      _motivationLevel = entry.motivationLevel ?? 5;
      _sleepQuality = entry.sleepQuality ?? 5;
      _socialInteraction = entry.socialInteraction ?? 5;
      _physicalActivity = entry.physicalActivity ?? 5;
      _workProductivity = entry.workProductivity ?? 5;
      _worthIt = entry.worthIt;
      
      _sleepHours = entry.sleepHours ?? 8.0;
      _waterIntake = entry.waterIntake ?? 8;
      _meditationMinutes = entry.meditationMinutes ?? 0;
      _exerciseMinutes = entry.exerciseMinutes ?? 0;
      _screenTimeHours = entry.screenTimeHours ?? 4.0;
      
      _reflectionController.text = entry.reflection ?? '';
      _innerReflectionController.text = entry.innerReflection ?? '';
      _gratitudeController.text = entry.gratitude ?? '';
      _notesController.text = entry.notes ?? '';
      
      if (entry.positiveTags != null) {
        _positiveTagsController.text = entry.positiveTags!.join(', ');
      }
      if (entry.negativeTags != null) {
        _negativeTagsController.text = entry.negativeTags!.join(', ');
      }
    });
  }

  void _loadAdditionalData(String userId) {
    // Cargar metas del día
    context.read<EnhancedGoalsProvider>().loadGoalsForDate(userId, _selectedDate);
    
    // Cargar actividades
    context.read<DailyActivitiesProvider>().loadActivitiesForDate(userId, _selectedDate);
    
    // Cargar momentos con imágenes
    context.read<ImageMomentsProvider>().loadImagesForDate(userId, _selectedDate);
    
    // Cargar análisis de emociones previo
    context.read<AdvancedEmotionAnalysisProvider>().analyzeDay(userId, _selectedDate);
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.currentColors;

    return Scaffold(
      backgroundColor: colors.primaryBg,
      body: Stack(
        children: [
          _buildGradientBackground(colors),
          _buildContent(colors),
          _buildProgressIndicator(colors),
          if (_isSaving) _buildSavingOverlay(colors),
        ],
      ),
      floatingActionButton: _buildFAB(colors),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGradientBackground(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryBg,
            colors.secondaryBg,
            colors.primaryBg,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(AppColors colors) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(colors),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
                _progressController.animateTo(index / _totalSteps);
                HapticFeedback.lightImpact();
              },
              children: [
                _buildWelcomeStep(colors),
                _buildBasicMetricsStep(colors),
                _buildAdvancedMetricsStep(colors),
                _buildParametersStep(colors),
                _buildReflectionStep(colors),
                _buildGratitudeStep(colors),
                _buildTagsStep(colors),
                _buildActivitiesStep(colors),
                _buildMomentsStep(colors),
                _buildReviewStep(colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_currentStep > 0) {
                    _previousStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.glassBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: colors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    'Revisión Diaria',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatDate(_selectedDate),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildThemeToggle(colors),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepIndicator(colors),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(AppColors colors) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.glassBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.borderColor.withOpacity(0.3),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                colors.isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(colors.isDark),
                color: colors.accentPrimary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(AppColors colors) {
    return Row(
      children: List.generate(_totalSteps, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isCompleted || isCurrent
                  ? colors.accentPrimary
                  : colors.borderColor.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProgressIndicator(AppColors colors) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressController.value,
            backgroundColor: colors.borderColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentPrimary),
            minHeight: 2,
          );
        },
      ),
    );
  }

  // ============================================================================
  // PASOS DE LA REVISIÓN
  // ============================================================================

  Widget _buildWelcomeStep(AppColors colors) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors.gradientHeader,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '¡Hola! 👋',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Es momento de reflexionar sobre tu día',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tomaremos unos minutos para registrar cómo te sientes, qué has logrado y qué has aprendido.',
                style: TextStyle(
                  color: colors.textHint,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildDateSelector(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicMetricsStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '📊 Métricas Básicas', 
              'Evalúa tu estado general de hoy'),
          const SizedBox(height: 24),
          _buildMetricSlider(
            colors,
            'Estado de Ánimo',
            '¿Cómo te sentiste hoy en general?',
            Icons.mood,
            _moodScore,
            (value) => setState(() => _moodScore = value),
            _getMoodEmoji(_moodScore),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            colors,
            'Nivel de Energía',
            '¿Qué tan energético te sentiste?',
            Icons.battery_charging_full,
            _energyLevel,
            (value) => setState(() => _energyLevel = value),
            _getEnergyEmoji(_energyLevel),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            colors,
            'Nivel de Estrés',
            '¿Qué tan estresado te sentiste?',
            Icons.trending_up,
            _stressLevel,
            (value) => setState(() => _stressLevel = value),
            _getStressEmoji(_stressLevel),
          ),
          const SizedBox(height: 24),
          _buildWorthItQuestion(colors),
        ],
      ),
    );
  }

  Widget _buildAdvancedMetricsStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '🧠 Métricas Avanzadas', 
              'Analiza aspectos más profundos de tu bienestar'),
          const SizedBox(height: 24),
          _buildMetricSlider(
            colors,
            'Nivel de Ansiedad',
            '¿Qué tan ansioso te sentiste?',
            Icons.psychology,
            _anxietyLevel,
            (value) => setState(() => _anxietyLevel = value),
            _getAnxietyEmoji(_anxietyLevel),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            colors,
            'Motivación',
            '¿Qué tan motivado estuviste?',
            Icons.local_fire_department,
            _motivationLevel,
            (value) => setState(() => _motivationLevel = value),
            _getMotivationEmoji(_motivationLevel),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            colors,
            'Nivel de Concentración',
            '¿Qué tan enfocado estuviste?',
            Icons.center_focus_strong,
            _focusLevel,
            (value) => setState(() => _focusLevel = value),
            _getFocusEmoji(_focusLevel),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            colors,
            'Estabilidad Emocional',
            '¿Qué tan estable emocionalmente te sentiste?',
            Icons.balance,
            _emotionalStability,
            (value) => setState(() => _emotionalStability = value),
            _getStabilityEmoji(_emotionalStability),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            colors,
            'Satisfacción con la Vida',
            '¿Qué tan satisfecho estás con tu vida en general?',
            Icons.sentiment_very_satisfied,
            _lifeSatisfaction,
            (value) => setState(() => _lifeSatisfaction = value),
            _getSatisfactionEmoji(_lifeSatisfaction),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '⚙️ Parámetros del Día', 
              'Registra actividades y hábitos específicos'),
          const SizedBox(height: 24),
          _buildParameterCard(colors, 'Horas de Sueño', Icons.bedtime,
              _sleepHours, 0.0, 12.0, 0.5, 'horas',
              (value) => setState(() => _sleepHours = value)),
          const SizedBox(height: 16),
          _buildParameterCard(colors, 'Vasos de Agua', Icons.water_drop,
              _waterIntake.toDouble(), 0.0, 20.0, 1.0, 'vasos',
              (value) => setState(() => _waterIntake = value.toInt())),
          const SizedBox(height: 16),
          _buildParameterCard(colors, 'Minutos de Ejercicio', Icons.fitness_center,
              _exerciseMinutes.toDouble(), 0.0, 300.0, 5.0, 'min',
              (value) => setState(() => _exerciseMinutes = value.toInt())),
          const SizedBox(height: 16),
          _buildParameterCard(colors, 'Minutos de Meditación', Icons.self_improvement,
              _meditationMinutes.toDouble(), 0.0, 120.0, 1.0, 'min',
              (value) => setState(() => _meditationMinutes = value.toInt())),
          const SizedBox(height, 16),
          _buildParameterCard(colors, 'Horas de Pantalla', Icons.phone_android,
              _screenTimeHours, 0.0, 24.0, 0.5, 'horas',
              (value) => setState(() => _screenTimeHours = value)),
          const SizedBox(height: 20),
          _buildQualityMetrics(colors),
        ],
      ),
    );
  }

  Widget _buildReflectionStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '💭 Reflexión del Día', 
              'Comparte tus pensamientos y experiencias'),
          const SizedBox(height: 24),
          _buildTextInput(
            colors,
            'Reflexión General',
            '¿Cómo estuvo tu día? ¿Qué destacarías?',
            _reflectionController,
            maxLines: 4,
            icon: Icons.edit_note,
          ),
          const SizedBox(height: 20),
          _buildTextInput(
            colors,
            'Reflexión Interna',
            '¿Qué emociones experimentaste? ¿Qué aprendiste de ti mismo?',
            _innerReflectionController,
            maxLines: 4,
            icon: Icons.psychology,
          ),
          const SizedBox(height: 24),
          _buildVoiceRecordingSection(colors),
        ],
      ),
    );
  }

  Widget _buildGratitudeStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '🙏 Gratitud', 
              'Reconoce lo positivo de tu día'),
          const SizedBox(height: 24),
          _buildTextInput(
            colors,
            'Por qué estás agradecido hoy',
            'Menciona al menos 3 cosas por las que te sientes agradecido...',
            _gratitudeController,
            maxLines: 5,
            icon: Icons.favorite,
          ),
          const SizedBox(height: 24),
          _buildGratitudeSuggestions(colors),
        ],
      ),
    );
  }

  Widget _buildTagsStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '🏷️ Etiquetas del Día', 
              'Categoriza tu experiencia'),
          const SizedBox(height: 24),
          _buildTagSection(colors, 'Aspectos Positivos', _positiveTagsController,
              _getPositiveTagSuggestions(), colors.positiveMain),
          const SizedBox(height: 24),
          _buildTagSection(colors, 'Aspectos a Mejorar', _negativeTagsController,
              _getNegativeTagSuggestions(), colors.negativeMain),
        ],
      ),
    );
  }

  Widget _buildActivitiesStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '📝 Actividades del Día', 
              'Registra lo que hiciste hoy'),
          const SizedBox(height: 24),
          _buildActivitiesGrid(colors),
          const SizedBox(height: 24),
          _buildGoalsProgress(colors),
        ],
      ),
    );
  }

  Widget _buildMomentsStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '✨ Momentos Especiales', 
              'Captura los momentos importantes'),
          const SizedBox(height: 24),
          _buildQuickMomentsGrid(colors),
          const SizedBox(height: 24),
          _buildImageMomentsSection(colors),
        ],
      ),
    );
  }

  Widget _buildReviewStep(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(colors, '📋 Resumen Final', 
              'Revisa tu entrada antes de guardar'),
          const SizedBox(height: 24),
          _buildReviewSummary(colors),
          const SizedBox(height: 24),
          _buildTextInput(
            colors,
            'Notas Adicionales',
            'Agrega cualquier comentario final...',
            _notesController,
            maxLines: 3,
            icon: Icons.note_add,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // COMPONENTES ESPECÍFICOS
  // ============================================================================

  Widget _buildStepTitle(AppColors colors, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSlider(
    AppColors colors,
    String title,
    String subtitle,
    IconData icon,
    int value,
    Function(int) onChanged,
    String emoji,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colors.accentPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    '$value/10',
                    style: TextStyle(
                      color: colors.accentPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.accentPrimary,
              inactiveTrackColor: colors.borderColor.withOpacity(0.3),
              thumbColor: colors.accentPrimary,
              overlayColor: colors.accentPrimary.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (newValue) {
                onChanged(newValue.toInt());
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItQuestion(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: colors.accentPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¿Valió la pena este día?',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _worthIt = true);
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _worthIt == true
                          ? colors.positiveMain.withOpacity(0.1)
                          : colors.glassBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _worthIt == true
                            ? colors.positiveMain
                            : colors.borderColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '😊',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sí',
                          style: TextStyle(
                            color: _worthIt == true
                                ? colors.positiveMain
                                : colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _worthIt == false
                          ? colors.negativeMain.withOpacity(0.1)
                          : colors.glassBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _worthIt == false
                            ? colors.negativeMain
                            : colors.borderColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '😔',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No',
                          style: TextStyle(
                            color: _worthIt == false
                                ? colors.negativeMain
                                : colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(
    AppColors colors,
    String title,
    IconData icon,
    double value,
    double min,
    double max,
    double divisions,
    String unit,
    Function(double) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: colors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${value % 1 == 0 ? value.toInt() : value} $unit',
                style: TextStyle(
                  color: colors.accentPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.accentPrimary,
              inactiveTrackColor: colors.borderColor.withOpacity(0.3),
              thumbColor: colors.accentPrimary,
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) / divisions).toInt(),
              onChanged: (newValue) {
                onChanged(newValue);
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetrics(AppColors colors) {
    final qualityMetrics = [
      {'title': 'Calidad del Sueño', 'value': _sleepQuality, 'icon': Icons.bedtime, 'onChange': (int value) => setState(() => _sleepQuality = value)},
      {'title': 'Interacción Social', 'value': _socialInteraction, 'icon': Icons.people, 'onChange': (int value) => setState(() => _socialInteraction = value)},
      {'title': 'Actividad Física', 'value': _physicalActivity, 'icon': Icons.directions_run, 'onChange': (int value) => setState(() => _physicalActivity = value)},
      {'title': 'Productividad', 'value': _workProductivity, 'icon': Icons.work, 'onChange': (int value) => setState(() => _workProductivity = value)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calidad de Actividades',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...qualityMetrics.map((metric) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildQualitySlider(
            colors,
            metric['title'] as String,
            metric['icon'] as IconData,
            metric['value'] as int,
            metric['onChange'] as Function(int),
          ),
        )),
      ],
    );
  }

  Widget _buildQualitySlider(
    AppColors colors,
    String title,
    IconData icon,
    int value,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colors.accentSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$value/10',
            style: TextStyle(
              color: colors.accentSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colors.accentSecondary,
                inactiveTrackColor: colors.borderColor.withOpacity(0.3),
                thumbColor: colors.accentSecondary,
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (newValue) {
                  onChanged(newValue.toInt());
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    AppColors colors,
    String title,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: colors.accentPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: colors.textHint,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            color: colors.accentPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(_selectedDate),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _selectDate(colors),
            child: Icon(
              Icons.arrow_drop_down,
              color: colors.accentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingSection(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic,
                color: colors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Nota de Voz',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          VoiceRecordingWidget(
            onRecordingComplete: (path) {
              setState(() {
                _currentVoiceRecording = path;
                _voiceRecordings.add(path);
              });
            },
            colors: colors,
            isExpanded: _isVoiceRecordingExpanded,
            onExpandedChanged: (expanded) {
              setState(() {
                _isVoiceRecordingExpanded = expanded;
              });
            },
          ),
          if (_voiceRecordings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...(_voiceRecordings.map((recording) => _buildVoiceNote(colors, recording))),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceNote(AppColors colors, String recordingPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.glassBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_filled,
            color: colors.accentPrimary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nota de voz ${_voiceRecordings.indexOf(recordingPath) + 1}',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _voiceRecordings.remove(recordingPath);
              });
            },
            child: Icon(
              Icons.delete_outline,
              color: colors.negativeMain,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeSuggestions(AppColors colors) {
    final suggestions = [
      '🏠 Hogar', '👨‍👩‍👧‍👦 Familia', '💼 Trabajo', '🎯 Logros', '☀️ Clima',
      '🍎 Salud', '🎵 Música', '📚 Aprendizaje', '🌅 Nuevo día', '😊 Sonrisas'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugerencias:',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                final currentText = _gratitudeController.text;
                final newText = currentText.isEmpty
                    ? suggestion
                    : '$currentText, $suggestion';
                _gratitudeController.text = newText;
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.glassBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.borderColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagSection(
    AppColors colors,
    String title,
    TextEditingController controller,
    List<String> suggestions,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.borderColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe etiquetas separadas por comas...',
                  hintStyle: TextStyle(
                    color: colors.textHint,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: suggestions.map((tag) {
                  return GestureDetector(
                    onTap: () {
                      final currentTags = controller.text.split(',')
                          .map((t) => t.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();
                      
                      if (!currentTags.contains(tag)) {
                        currentTags.add(tag);
                        controller.text = currentTags.join(', ');
                        HapticFeedback.selectionClick();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesGrid(AppColors colors) {
    return Consumer<DailyActivitiesProvider>(
      builder: (context, activitiesProvider, child) {
        final activities = activitiesProvider.getActivitiesForDate(_selectedDate);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividades Realizadas',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _getActivitySuggestions().length,
              itemBuilder: (context, index) {
                final activity = _getActivitySuggestions()[index];
                final isCompleted = _completedActivities.contains(activity['title']);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isCompleted) {
                        _completedActivities.remove(activity['title']);
                      } else {
                        _completedActivities.add(activity['title'] as String);
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colors.positiveMain.withOpacity(0.1)
                          : colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? colors.positiveMain
                            : colors.borderColor.withOpacity(0.3),
                        width: isCompleted ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activity['emoji'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity['title'] as String,
                          style: TextStyle(
                            color: isCompleted
                                ? colors.positiveMain
                                : colors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: colors.positiveMain,
                            size: 12,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGoalsProgress(AppColors colors) {
    return Consumer<EnhancedGoalsProvider>(
      builder: (context, goalsProvider, child) {
        final goals = goalsProvider.getGoalsForDate(_selectedDate);
        
        if (goals.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.borderColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: colors.textHint,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sin metas para hoy',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Progreso de Metas',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...goals.map((goal) => _buildGoalProgressCard(colors, goal)),
          ],
        );
      },
    );
  }

  Widget _buildGoalProgressCard(AppColors colors, GoalModel goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            goal.emoji ?? '🎯',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: goal.progress ?? 0.0,
                  backgroundColor: colors.borderColor.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.accentPrimary),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${((goal.progress ?? 0.0) * 100).toInt()}%',
            style: TextStyle(
              color: colors.accentPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMomentsGrid(AppColors colors) {
    final quickMoments = [
      {'emoji': '☕', 'label': 'Café', 'category': 'routine'},
      {'emoji': '🚶', 'label': 'Caminar', 'category': 'exercise'},
      {'emoji': '📚', 'label': 'Leer', 'category': 'learning'},
      {'emoji': '🎵', 'label': 'Música', 'category': 'entertainment'},
      {'emoji': '🍎', 'label': 'Comer', 'category': 'health'},
      {'emoji': '💭', 'label': 'Reflexión', 'category': 'mindfulness'},
      {'emoji': '👥', 'label': 'Socializar', 'category': 'social'},
      {'emoji': '🎨', 'label': 'Creatividad', 'category': 'creative'},
      {'emoji': '🌅', 'label': 'Amanecer', 'category': 'nature'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Moments',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: quickMoments.length,
          itemBuilder: (context, index) {
            final moment = quickMoments[index];
            final isSelected = _quickMoments.any((m) => m['label'] == moment['label']);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _quickMoments.removeWhere((m) => m['label'] == moment['label']);
                  } else {
                    _quickMoments.add({
                      ...moment,
                      'timestamp': DateTime.now(),
                    });
                  }
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.accentPrimary.withOpacity(0.1)
                      : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colors.accentPrimary
                        : colors.borderColor.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      moment['emoji'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      moment['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? colors.accentPrimary
                            : colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: colors.accentPrimary,
                        size: 12,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageMomentsSection(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Momentos en Imagen',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: DottedBorder.all(
              color: colors.borderColor.withOpacity(0.5),
              strokeWidth: 2,
              dashPattern: const [6, 3],
            ).borderSide.color,
          ),
          child: _selectedImages.isEmpty
              ? _buildAddImageButton(colors)
              : _buildImagesList(colors),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(AppColors colors) {
    return GestureDetector(
      onTap: () => _addImage(),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: colors.accentPrimary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Agregar fotos del día',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesList(AppColors colors) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          return GestureDetector(
            onTap: () => _addImage(),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: colors.glassBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.borderColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.add,
                color: colors.accentPrimary,
                size: 24,
              ),
            ),
          );
        }

        return Container(
          width: 80,
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImages[index],
                  width: 80,
                  height: 104,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.negativeMain,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewSummary(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de tu día',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(colors, 'Estado de Ánimo', '${_moodScore}/10', _getMoodEmoji(_moodScore)),
          _buildSummaryRow(colors, 'Energía', '${_energyLevel}/10', _getEnergyEmoji(_energyLevel)),
          _buildSummaryRow(colors, 'Estrés', '${_stressLevel}/10', _getStressEmoji(_stressLevel)),
          _buildSummaryRow(colors, '¿Valió la pena?', _worthIt == true ? 'Sí' : _worthIt == false ? 'No' : 'Sin respuesta', _worthIt == true ? '😊' : _worthIt == false ? '😔' : '🤷'),
          const SizedBox(height: 12),
          Divider(color: colors.borderColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          _buildSummaryRow(colors, 'Actividades completadas', '${_completedActivities.length}', '✅'),
          _buildSummaryRow(colors, 'Quick moments', '${_quickMoments.length}', '⚡'),
          _buildSummaryRow(colors, 'Imágenes', '${_selectedImages.length}', '📸'),
          _buildSummaryRow(colors, 'Notas de voz', '${_voiceRecordings.length}', '🎙️'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(AppColors colors, String label, String value, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingOverlay(AppColors colors) {
    return Container(
      color: colors.primaryBg.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.accentPrimary),
              ),
              const SizedBox(height: 16),
              Text(
                'Guardando tu día...',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(AppColors colors) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_currentStep > 0)
            FloatingActionButton(
              heroTag: 'previous',
              onPressed: () => _previousStep(),
              backgroundColor: colors.glassBg,
              foregroundColor: colors.textPrimary,
              child: const Icon(Icons.arrow_back),
            ),
          FloatingActionButton.extended(
            heroTag: 'main',
            onPressed: () => _currentStep < _totalSteps - 1 ? _nextStep() : _saveEntry(),
            backgroundColor: colors.accentPrimary,
            foregroundColor: Colors.white,
            icon: Icon(
              _currentStep < _totalSteps - 1 ? Icons.arrow_forward : Icons.save,
            ),
            label: Text(
              _currentStep < _totalSteps - 1 ? 'Siguiente' : 'Guardar',
            ),
          ),
          if (_currentStep < _totalSteps - 1)
            FloatingActionButton(
              heroTag: 'skip',
              onPressed: () => _skipToEnd(),
              backgroundColor: colors.glassBg.withOpacity(0.5),
              foregroundColor: colors.textSecondary,
              child: const Icon(Icons.skip_next),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS AUXILIARES
  // ============================================================================

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final weekdays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
      HapticFeedback.lightImpact();
    }
  }

  void _skipToEnd() {
    setState(() {
      _currentStep = _totalSteps - 1;
    });
    _pageController.animateToPage(
      _totalSteps - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    HapticFeedback.mediumImpact();
  }

  Future<void> _selectDate(AppColors colors) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: colors.accentPrimary),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadExistingEntry();
    }
  }

  Future<void> _addImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _saveEntry() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final user = authProvider.currentUser;
      
      if (user != null) {
        final entry = DailyEntryModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.id,
          date: _selectedDate,
          moodScore: _moodScore,
          energyLevel: _energyLevel,
          stressLevel: _stressLevel,
          anxietyLevel: _anxietyLevel,
          motivationLevel: _motivationLevel,
          focusLevel: _focusLevel,
          sleepQuality: _sleepQuality,
          socialInteraction: _socialInteraction,
          physicalActivity: _physicalActivity,
          workProductivity: _workProductivity,
          creativityLevel: _creativityLevel,
          spiritualWellness: _spiritualWellness,
          socialBattery: _socialBattery,
          creativeEnergy: _creativeEnergy,
          emotionalStability: _emotionalStability,
          lifeSatisfaction: _lifeSatisfaction,
          weatherMoodImpact: _weatherMoodImpact,
          worthIt: _worthIt,
          sleepHours: _sleepHours,
          waterIntake: _waterIntake,
          meditationMinutes: _meditationMinutes,
          exerciseMinutes: _exerciseMinutes,
          screenTimeHours: _screenTimeHours,
          socialMinutes: _socialMinutes,
          reflection: _reflectionController.text.trim().isEmpty ? null : _reflectionController.text.trim(),
          innerReflection: _innerReflectionController.text.trim().isEmpty ? null : _innerReflectionController.text.trim(),
          gratitude: _gratitudeController.text.trim().isEmpty ? null : _gratitudeController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          positiveTags: _positiveTagsController.text.trim().isEmpty 
              ? null 
              : _positiveTagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
          negativeTags: _negativeTagsController.text.trim().isEmpty 
              ? null 
              : _negativeTagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
          completedActivities: _completedActivities.isEmpty ? null : _completedActivities,
          voiceNotes: _voiceRecordings.isEmpty ? null : _voiceRecordings,
          quickMoments: _quickMoments.isEmpty ? null : _quickMoments,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await context.read<OptimizedDailyEntriesProvider>().saveEntry(entry);

        // Guardar imágenes si las hay
        if (_selectedImages.isNotEmpty) {
          for (final image in _selectedImages) {
            await context.read<ImageMomentsProvider>().addImageMoment(
              user.id,
              image,
              'Momento del día',
              _selectedDate,
            );
          }
        }

        // Actualizar análisis básico
        await context.read<AdvancedEmotionAnalysisProvider>().analyzeDay(user.id, _selectedDate);

        // Feedback háptico de éxito
        HapticFeedback.heavyImpact();

        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Día guardado exitosamente! 🎉'),
              backgroundColor: context.read<ThemeProvider>().currentColors.positiveMain,
            ),
          );
          
          // Regresar a la pantalla anterior
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: context.read<ThemeProvider>().currentColors.negativeMain,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Emojis helpers
  String _getMoodEmoji(int score) {
    if (score >= 9) return '🤩';
    if (score >= 8) return '😄';
    if (score >= 7) return '😊';
    if (score >= 6) return '🙂';
    if (score >= 5) return '😐';
    if (score >= 4) return '😕';
    if (score >= 3) return '😔';
    if (score >= 2) return '😢';
    return '😭';
  }

  String _getEnergyEmoji(int score) {
    if (score >= 9) return '⚡';
    if (score >= 7) return '🔋';
    if (score >= 5) return '🔋';
    if (score >= 3) return '🪫';
    return '😴';
  }

  String _getStressEmoji(int score) {
    if (score >= 8) return '😰';
    if (score >= 6) return '😬';
    if (score >= 4) return '😟';
    if (score >= 2) return '🙂';
    return '😌';
  }

  String _getAnxietyEmoji(int score) {
    if (score >= 8) return '😨';
    if (score >= 6) return '😰';
    if (score >= 4) return '😅';
    if (score >= 2) return '🙂';
    return '😌';
  }

  String _getMotivationEmoji(int score) {
    if (score >= 8) return '🔥';
    if (score >= 6) return '💪';
    if (score >= 4) return '👍';
    if (score >= 2) return '😐';
    return '😴';
  }

  String _getFocusEmoji(int score) {
    if (score >= 8) return '🎯';
    if (score >= 6) return '👁️';
    if (score >= 4) return '🤔';
    if (score >= 2) return '😵‍💫';
    return '🤯';
  }

  String _getStabilityEmoji(int score) {
    if (score >= 8) return '🧘';
    if (score >= 6) return '😌';
    if (score >= 4) return '😐';
    if (score >= 2) return '😔';
    return '😢';
  }

  String _getSatisfactionEmoji(int score) {
    if (score >= 9) return '🥰';
    if (score >= 7) return '😍';
    if (score >= 5) return '😊';
    if (score >= 3) return '😐';
    return '😔';
  }

  List<String> _getPositiveTagSuggestions() {
    return [
      'Productivo', 'Creativo', 'Feliz', 'Motivado', 'Relajado',
      'Sociable', 'Activo', 'Optimista', 'Enfocado', 'Agradecido',
      'Energético', 'Inspirado', 'Tranquilo', 'Confiado', 'Amoroso'
    ];
  }

  List<String> _getNegativeTagSuggestions() {
    return [
      'Estresado', 'Ansioso', 'Cansado', 'Triste', 'Frustrado',
      'Aburrido', 'Abrumado', 'Solitario', 'Preocupado', 'Irritado',
      'Desorganizado', 'Sin energía', 'Desenfocado', 'Inseguro', 'Confundido'
    ];
  }

  List<Map<String, String>> _getActivitySuggestions() {
    return [
      {'emoji': '💼', 'title': 'Trabajo'},
      {'emoji': '📚', 'title': 'Estudiar'},
      {'emoji': '🏃', 'title': 'Ejercicio'},
      {'emoji': '🧘', 'title': 'Meditar'},
      {'emoji': '👥', 'title': 'Socializar'},
      {'emoji': '🍳', 'title': 'Cocinar'},
      {'emoji': '📺', 'title': 'Entretenimiento'},
      {'emoji': '🛒', 'title': 'Compras'},
      {'emoji': '🧹', 'title': 'Limpiar'},
      {'emoji': '🎨', 'title': 'Arte'},
      {'emoji': '🎵', 'title': 'Música'},
      {'emoji': '🌿', 'title': 'Naturaleza'},
    ];
  }
}