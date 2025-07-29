// ============================================================================
// daily_review_screen_v3.dart - REVISIÓN DIARIA MODERNA CON UI/UX MEJORADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:io';
import 'dart:math';

// Core
import '../../../core/themes/app_theme.dart' as core_theme;

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/daily_activities_provider.dart';

// Widgets
import '../../widgets/enhanced_ui_components.dart';

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
  // CONTROLADORES Y ESTADO MEJORADOS
  // ============================================================================

  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late AnimationController _fabController;
  late AnimationController _backgroundController;
  
  late Animation<double> _backgroundAnimation;

  int _currentStep = 0;
  final int _totalSteps = 10;

  DateTime _selectedDate = DateTime.now();
  
  // Auto-save timer
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  // Estados del formulario principal mejorados
  final _reflectionController = TextEditingController();
  final _innerReflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _positiveTagsController = TextEditingController();
  final _negativeTagsController = TextEditingController();
  final _notesController = TextEditingController();
  final _voiceNotesController = TextEditingController();

  // Métricas principales (matching v2 structure)
  int _moodScore = 5;
  int _energyLevel = 5;
  int _stressLevel = 5;
  int _anxietyLevel = 5;
  int _motivationLevel = 5;
  int _focusLevel = 5;
  bool? _worthIt;

  // Métricas de bienestar (matching v2)
  int _sleepQuality = 5;
  int _socialInteraction = 5;
  int _physicalActivity = 5;
  int _workProductivity = 5;
  int _socialBattery = 5;
  int _creativeEnergy = 5;
  int _emotionalStability = 5;
  int _lifeSatisfaction = 5;
  int _weatherMoodImpact = 0;

  // Métricas numéricas (matching v2)
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _meditationMinutes = 0;
  int _exerciseMinutes = 0;
  double _screenTimeHours = 4.0;

  // Lists (matching v2)
  List<String> _completedActivitiesToday = [];
  final List<File> _selectedImages = [];
  String? _voiceRecordingPath;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _setupAnimations();
    _loadExistingEntry();
    _setupAutoSave();
  }

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(minutes: 1),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_backgroundController);

    _cardController.forward();
  }


  void _setupAutoSave() {
    // Auto-save every 30 seconds if there are unsaved changes
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (_hasUnsavedChanges && !_isSaving) {
        _autoSave();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _fabController.dispose();
    _backgroundController.dispose();
    
    _reflectionController.dispose();
    _innerReflectionController.dispose();
    _gratitudeController.dispose();
    _positiveTagsController.dispose();
    _negativeTagsController.dispose();
    _notesController.dispose();
    _voiceNotesController.dispose();
    
    super.dispose();
  }

  // ============================================================================
  // NAVIGATION & LOGIC
  // ============================================================================

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _hasUnsavedChanges = true;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _cardController.reset();
      _cardController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _cardController.reset();
      _cardController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _loadExistingEntry() {
    final entriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final todayEntry = entriesProvider.todayEntry;

    if (todayEntry != null) {
      setState(() {
        _reflectionController.text = todayEntry.freeReflection;
        _innerReflectionController.text = todayEntry.innerReflection ?? '';
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
        _completedActivitiesToday = todayEntry.completedActivitiesToday;
      });
    }
  }

  void _autoSave() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      await _saveEntry(showFeedback: false);
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveEntry({bool showFeedback = true}) async {
    setState(() => _isSaving = true);
    
    try {
      final entriesProvider = context.read<OptimizedDailyEntriesProvider>();
      final authProvider = context.read<OptimizedAuthProvider>();
      
      if (authProvider.currentUser == null) return;
      
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
        socialBattery: _socialBattery,
        creativeEnergy: _creativeEnergy,
        emotionalStability: _emotionalStability,
        focusLevel: _focusLevel,
        lifeSatisfaction: _lifeSatisfaction,
        weatherMoodImpact: _weatherMoodImpact,
        gratitudeItems: _gratitudeController.text.trim(),
        voiceRecordingPath: _voiceRecordingPath,
      );
      
      if (success && showFeedback && mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ Entrada guardada exitosamente'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  // ============================================================================
  // BUILD METHOD PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final appColors = themeProvider.isDarkMode 
            ? core_theme.ThemeDefinitions.deepOcean 
            : core_theme.ThemeDefinitions.springLight;
        
        return Theme(
          data: core_theme.AppThemeData.buildTheme(appColors),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: appColors.primaryBg,
            body: LiquidPullToRefresh(
              onRefresh: () async {
                _loadExistingEntry();
                HapticFeedback.lightImpact();
              },
              color: appColors.accentPrimary,
              backgroundColor: appColors.surface,
              child: _buildAnimatedBackground(appColors),
            ),
            floatingActionButton: _buildFloatingActionButton(appColors),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(core_theme.AppColors appColors) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                appColors.primaryBg,
                appColors.secondaryBg,
                appColors.primaryBg,
              ],
              stops: [
                0.0,
                0.5 + 0.3 * sin(_backgroundAnimation.value),
                1.0,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(appColors),
                _buildProgressSection(appColors),
                Expanded(
                  child: _buildPageView(appColors),
                ),
                _buildBottomNavigation(appColors),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(core_theme.AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: appColors.borderColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: appColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Text(
                        'Revisión Diaria',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Text(
                        _formatDate(_selectedDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          _buildThemeToggle(appColors),
          
          if (_isSaving) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(appColors.accentPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeToggle(core_theme.AppColors appColors) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.setTheme(!themeProvider.isDarkMode);
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: appColors.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              appColors.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(core_theme.AppColors appColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          AnimatedStepIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            activeColor: appColors.accentPrimary,
            inactiveColor: appColors.borderColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          AnimatedProgressIndicator(
            progress: (_currentStep + 1) / _totalSteps,
            color: appColors.accentPrimary,
            backgroundColor: appColors.borderColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${_currentStep + 1} de $_totalSteps',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: appColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(core_theme.AppColors appColors) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildWelcomeStep(appColors),          // Step 0
        _buildBasicMoodStep(appColors),        // Step 1
        _buildWellbeingStep(appColors),        // Step 2
        _buildNumericParametersStep(appColors), // Step 3
        _buildReflectionStep(appColors),       // Step 4
        _buildGratitudeStep(appColors),        // Step 5
        _buildTagsStep(appColors),             // Step 6
        _buildActivitiesStep(appColors),       // Step 7
        _buildMomentsStep(appColors),          // Step 8
        _buildReviewStep(appColors),           // Step 9
      ],
    );
  }

  Widget _buildBottomNavigation(core_theme.AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: _currentStep == _totalSteps - 1
                ? ElevatedButton.icon(
                    onPressed: () async {
                      await _saveEntry();
                      if (mounted) Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: appColors.positiveMain,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _nextStep,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(core_theme.AppColors appColors) {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.1 * _fabController.value,
          child: EnhancedFAB(
            onPressed: _hasUnsavedChanges ? _autoSave : null,
            icon: _isSaving ? Icons.save : Icons.auto_awesome,
            label: _isSaving ? 'Guardando...' : 'Auto-guardar',
            isExtended: _hasUnsavedChanges,
            backgroundColor: _hasUnsavedChanges ? appColors.accentPrimary : appColors.borderColor,
            isLoading: _isSaving,
          ),
        );
      },
    );
  }

  // ============================================================================
  // STEP BUILDERS - 10 PASOS MEJORADOS
  // ============================================================================

  Widget _buildWelcomeStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + 0.1 * _pulseController.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: appColors.gradientHeader,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: appColors.shadowColor,
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                Text(
                  '¡Bienvenido a tu espacio de reflexión!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Dedica unos minutos para conectar contigo mismo y reflexionar sobre tu día.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: appColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                GlassmorphicCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: appColors.accentPrimary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Fecha seleccionada',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: appColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(_selectedDate),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: appColors.accentPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: appColors.textHint,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tiempo estimado: 5-10 minutos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: appColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicMoodStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '🎭 Estado de Ánimo Básico',
                  'Evalúa cómo te sientes en este momento',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        EnhancedSlider(
                          label: '😊 Estado de Ánimo General',
                          value: _moodScore.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _moodScore = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.accentPrimary,
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '⚡ Nivel de Energía',
                          value: _energyLevel.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _energyLevel = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.positiveMain,
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '😰 Nivel de Estrés',
                          value: _stressLevel.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _stressLevel = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.negativeMain,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildWorthItQuestion(appColors),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellbeingStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '🧘 Bienestar Integral',
                  'Evalúa diferentes aspectos de tu bienestar',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        EnhancedSlider(
                          label: '😴 Calidad del Sueño',
                          value: _sleepQuality.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _sleepQuality = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '😟 Nivel de Ansiedad',
                          value: _anxietyLevel.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _anxietyLevel = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.negativeMain,
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '🎯 Motivación',
                          value: _motivationLevel.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _motivationLevel = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.positiveMain,
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '🎯 Concentración',
                          value: _focusLevel.toDouble(),
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              _focusLevel = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.accentSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericParametersStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '📊 Métricas del Día',
                  'Registra datos específicos de tu día',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        EnhancedSlider(
                          label: '😴 Horas de Sueño',
                          value: _sleepHours,
                          min: 0,
                          max: 12,
                          divisions: 24,
                          suffix: 'h',
                          onChanged: (value) {
                            setState(() {
                              _sleepHours = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '💧 Vasos de Agua',
                          value: _waterIntake.toDouble(),
                          min: 0,
                          max: 15,
                          divisions: 15,
                          suffix: ' vasos',
                          onChanged: (value) {
                            setState(() {
                              _waterIntake = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '🏃 Ejercicio',
                          value: _exerciseMinutes.toDouble(),
                          min: 0,
                          max: 180,
                          divisions: 36,
                          suffix: ' min',
                          onChanged: (value) {
                            setState(() {
                              _exerciseMinutes = value.round();
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.positiveMain,
                        ),
                        const SizedBox(height: 20),
                        
                        EnhancedSlider(
                          label: '📱 Tiempo de Pantalla',
                          value: _screenTimeHours,
                          min: 0,
                          max: 16,
                          divisions: 32,
                          suffix: 'h',
                          onChanged: (value) {
                            setState(() {
                              _screenTimeHours = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                          activeColor: appColors.negativeMain,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 4,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '📝 Reflexión Personal',
                  'Comparte tus pensamientos y experiencias del día',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GlassmorphicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Cómo fue tu día? ¿Qué destacarías?',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: appColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              Expanded(
                                child: TextField(
                                  controller: _reflectionController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText: 'Escribe tus reflexiones aquí...\n\n• ¿Qué aprendiste hoy?\n• ¿Qué te hizo sentir bien?\n• ¿Hubo algo desafiante?',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: appColors.textHint,
                                      height: 1.5,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  onChanged: (value) {
                                    setState(() => _hasUnsavedChanges = true);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGratitudeStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 5,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '🙏 Gratitud',
                  'Reflexiona sobre lo que agradeces hoy',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GlassmorphicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Por qué estás agradecido/a hoy?',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: appColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              Expanded(
                                child: TextField(
                                  controller: _gratitudeController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: InputDecoration(
                                    hintText: 'Escribe aquí tus agradecimientos...\n\n• Una persona especial\n• Un momento hermoso\n• Una oportunidad\n• Algo que aprendiste',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: appColors.textHint,
                                      height: 1.5,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  onChanged: (value) {
                                    setState(() => _hasUnsavedChanges = true);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: appColors.accentPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sugerencias de gratitud',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: appColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                'Mi salud',
                                'Mi familia',
                                'Un buen día',
                                'Una comida deliciosa',
                                'Música que amo',
                                'Un momento de paz',
                              ].map((suggestion) => GestureDetector(
                                onTap: () {
                                  final currentText = _gratitudeController.text;
                                  final newText = currentText.isEmpty 
                                      ? suggestion 
                                      : '$currentText\n• $suggestion';
                                  _gratitudeController.text = newText;
                                  setState(() => _hasUnsavedChanges = true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: appColors.accentPrimary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: appColors.accentPrimary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    suggestion,
                                    style: TextStyle(
                                      color: appColors.accentPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 6,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '🏷️ Emociones y Tags',
                  'Etiqueta tus emociones y experiencias',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GlassmorphicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✨ Aspectos Positivos',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: appColors.positiveMain,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _positiveTagsController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Ej: alegre, productivo, creativo, relajado...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: appColors.textHint),
                                ),
                                style: TextStyle(color: appColors.textPrimary),
                                onChanged: (value) {
                                  setState(() => _hasUnsavedChanges = true);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        GlassmorphicCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ Aspectos a Mejorar',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: appColors.negativeMain,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _negativeTagsController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Ej: cansado, estresado, distraído, ansioso...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: appColors.textHint),
                                ),
                                style: TextStyle(color: appColors.textPrimary),
                                onChanged: (value) {
                                  setState(() => _hasUnsavedChanges = true);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        GlassmorphicCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    color: appColors.accentPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Emociones Sugeridas',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: appColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              Text(
                                'Positivas',
                                style: TextStyle(
                                  color: appColors.positiveMain,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  'feliz', 'motivado', 'tranquilo', 'inspirado',
                                  'agradecido', 'confiado', 'optimista', 'creativo'
                                ].map((emotion) => _buildEmotionChip(emotion, appColors.positiveMain, appColors)).toList(),
                              ),
                              const SizedBox(height: 12),
                              
                              Text(
                                'A mejorar',
                                style: TextStyle(
                                  color: appColors.negativeMain,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  'triste', 'ansioso', 'cansado', 'frustrado',
                                  'abrumado', 'desmotivado', 'irritable', 'preocupado'
                                ].map((emotion) => _buildEmotionChip(emotion, appColors.negativeMain, appColors)).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 7,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '🎯 Actividades del Día',
                  'Registra las actividades que realizaste',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: Consumer<DailyActivitiesProvider>(
                    builder: (context, activitiesProvider, child) {
                      return GlassmorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Qué actividades realizaste hoy?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: appColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _getAvailableActivities().length,
                                itemBuilder: (context, index) {
                                  final activity = _getAvailableActivities()[index];
                                  final activityName = activity['name']!;
                                  final isSelected = _completedActivitiesToday.contains(activityName);
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _completedActivitiesToday.remove(activityName);
                                        } else {
                                          _completedActivitiesToday.add(activityName);
                                        }
                                        _hasUnsavedChanges = true;
                                      });
                                      HapticFeedback.lightImpact();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? appColors.accentPrimary.withValues(alpha: 0.2)
                                            : appColors.surface.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected 
                                              ? appColors.accentPrimary 
                                              : appColors.borderColor.withValues(alpha: 0.3),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            activity['icon']!,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              activityName,
                                              style: TextStyle(
                                                color: isSelected 
                                                    ? appColors.accentPrimary 
                                                    : appColors.textPrimary,
                                                fontWeight: isSelected 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            if (_completedActivitiesToday.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: appColors.positiveMain.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Actividades completadas (${_completedActivitiesToday.length})',
                                      style: TextStyle(
                                        color: appColors.positiveMain,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _completedActivitiesToday.join(', '),
                                      style: TextStyle(
                                        color: appColors.textPrimary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentsStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 8,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '📸 Momentos Especiales',
                  'Captura momentos importantes del día',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: Column(
                    children: [
                      if (_selectedImages.isEmpty) ...[
                        Expanded(
                          child: GlassmorphicCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 64,
                                  color: appColors.textHint,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Agrega fotos de momentos especiales',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: appColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Captura recuerdos que quieras conservar',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: appColors.textHint,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _selectedImages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _selectedImages.length) {
                                return _buildAddPhotoCard(appColors);
                              }
                              
                              return GlassmorphicCard(
                                padding: EdgeInsets.zero,
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                            _hasUnsavedChanges = true;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: appColors.negativeMain,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera, appColors),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Cámara'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery, appColors),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galería'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep(core_theme.AppColors appColors) {
    return AnimationConfiguration.staggeredList(
      position: 9,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(
                  appColors,
                  '✅ Revisión Final',
                  'Confirma toda la información antes de guardar',
                ),
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildReviewCard(
                          appColors,
                          '🎭 Estado de Ánimo',
                          [
                            'Ánimo: ${_moodScore.toInt()}/10',
                            'Energía: ${_energyLevel.toInt()}/10',
                            'Estrés: ${_stressLevel.toInt()}/10',
                            'Ansiedad: ${_anxietyLevel.toInt()}/10',
                            '¿Valió la pena?: ${_worthIt == null ? "Sin respuesta" : _worthIt! ? "Sí" : "No"}',
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildReviewCard(
                          appColors,
                          '📊 Métricas',
                          [
                            'Sueño: ${_sleepHours.toStringAsFixed(1)}h (Calidad: ${_sleepQuality.toInt()}/10)',
                            'Agua: ${_waterIntake.toInt()} vasos',
                            'Ejercicio: ${_exerciseMinutes.toInt()} min',
                            'Pantalla: ${_screenTimeHours.toStringAsFixed(1)}h',
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_reflectionController.text.isNotEmpty)
                          _buildReviewCard(
                            appColors,
                            '📝 Reflexiones',
                            [_reflectionController.text],
                          ),
                        
                        if (_gratitudeController.text.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildReviewCard(
                            appColors,
                            '🙏 Gratitud',
                            [_gratitudeController.text],
                          ),
                        ],
                        
                        if (_completedActivitiesToday.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildReviewCard(
                            appColors,
                            '🎯 Actividades',
                            _completedActivitiesToday,
                          ),
                        ],
                        
                        if (_selectedImages.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildReviewCard(
                            appColors,
                            '📸 Fotos',
                            ['${_selectedImages.length} ${_selectedImages.length == 1 ? 'foto agregada' : 'fotos agregadas'}'],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================

  Widget _buildStepHeader(core_theme.AppColors appColors, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: appColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWorthItQuestion(core_theme.AppColors appColors) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤔 ¿Valió la pena este día?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: appColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _worthIt = true;
                      _hasUnsavedChanges = true;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _worthIt == true 
                          ? appColors.positiveMain.withValues(alpha: 0.2)
                          : appColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _worthIt == true 
                            ? appColors.positiveMain 
                            : appColors.borderColor.withValues(alpha: 0.3),
                        width: _worthIt == true ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up,
                          color: _worthIt == true 
                              ? appColors.positiveMain 
                              : appColors.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sí',
                          style: TextStyle(
                            color: _worthIt == true 
                                ? appColors.positiveMain 
                                : appColors.textPrimary,
                            fontWeight: _worthIt == true 
                                ? FontWeight.bold 
                                : FontWeight.normal,
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
                    setState(() {
                      _worthIt = false;
                      _hasUnsavedChanges = true;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _worthIt == false 
                          ? appColors.negativeMain.withValues(alpha: 0.2)
                          : appColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _worthIt == false 
                            ? appColors.negativeMain 
                            : appColors.borderColor.withValues(alpha: 0.3),
                        width: _worthIt == false ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_down,
                          color: _worthIt == false 
                              ? appColors.negativeMain 
                              : appColors.textHint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No',
                          style: TextStyle(
                            color: _worthIt == false 
                                ? appColors.negativeMain 
                                : appColors.textPrimary,
                            fontWeight: _worthIt == false 
                                ? FontWeight.bold 
                                : FontWeight.normal,
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

  Widget _buildEmotionChip(String emotion, Color color, core_theme.AppColors appColors) {
    return GestureDetector(
      onTap: () {
        final isPositive = color == appColors.positiveMain;
        final controller = isPositive ? _positiveTagsController : _negativeTagsController;
        final currentText = controller.text;
        
        if (currentText.isEmpty) {
          controller.text = emotion;
        } else {
          controller.text = '$currentText, $emotion';
        }
        
        setState(() => _hasUnsavedChanges = true);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          emotion,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAddPhotoCard(core_theme.AppColors appColors) {
    return GlassmorphicCard(
      onTap: () => _showImagePickerDialog(appColors),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            size: 32,
            color: appColors.accentPrimary,
          ),
          const SizedBox(height: 8),
          Text(
            'Agregar',
            style: TextStyle(
              color: appColors.accentPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(core_theme.AppColors appColors, String title, List<String> items) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: appColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: appColors.textSecondary,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    
    final weekdays = [
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  List<Map<String, String>> _getAvailableActivities() {
    return [
      {'name': 'Ejercicio', 'icon': '🏃'},
      {'name': 'Lectura', 'icon': '📚'},
      {'name': 'Meditación', 'icon': '🧘'},
      {'name': 'Cocinar', 'icon': '👨‍🍳'},
      {'name': 'Trabajo', 'icon': '💼'},
      {'name': 'Estudiar', 'icon': '📖'},
      {'name': 'Socializar', 'icon': '👥'},
      {'name': 'Música', 'icon': '🎵'},
      {'name': 'Arte/Creative', 'icon': '🎨'},
      {'name': 'Naturaleza', 'icon': '🌳'},
      {'name': 'Limpieza', 'icon': '🧹'},
      {'name': 'Familia', 'icon': '👨‍👩‍👧'},
    ];
  }

  void _showImagePickerDialog(core_theme.AppColors appColors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Agregar Foto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: appColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, appColors);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, appColors);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source, core_theme.AppColors appColors) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          _hasUnsavedChanges = true;
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: appColors.negativeMain,
          ),
        );
      }
    }
  }
}