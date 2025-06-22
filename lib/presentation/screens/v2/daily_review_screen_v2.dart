// ============================================================================
// presentation/screens/v2/daily_review_screen_v2.dart - ACTUALIZADA PARA PROVIDERS OPTIMIZADOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

class DailyReviewScreenV2 extends StatefulWidget {
  const DailyReviewScreenV2({super.key});

  @override
  State<DailyReviewScreenV2> createState() => _DailyReviewScreenV2State();
}

class _DailyReviewScreenV2State extends State<DailyReviewScreenV2>
    with TickerProviderStateMixin {

  // Controladores de formulario
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _positiveTagsController = TextEditingController();
  final _negativeTagsController = TextEditingController();

  // Estados del formulario
  int _moodScore = 5;
  int _energyLevel = 5;
  int _stressLevel = 5;
  int _sleepQuality = 5;
  int _anxietyLevel = 5;
  int _motivationLevel = 5;
  int _socialInteraction = 5;
  int _physicalActivity = 5;
  int _workProductivity = 5;
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _meditationMinutes = 0;
  int _exerciseMinutes = 0;
  double _screenTimeHours = 4.0;
  int _weatherMoodImpact = 0;
  int _socialBattery = 5;
  int _creativeEnergy = 5;
  int _emotionalStability = 5;
  int _focusLevel = 5;
  int _lifeSatisfaction = 5;
  bool? _worthIt;

  // Estado de la UI
  int _currentStep = 0;
  bool _isLoading = false;

  // Controladores de animación
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExistingEntry();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _gratitudeController.dispose();
    _positiveTagsController.dispose();
    _negativeTagsController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pageController = PageController();

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadExistingEntry() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final entriesProvider = context.read<OptimizedDailyEntriesProvider>();

    final user = authProvider.currentUser;
    if (user == null) return;

    await entriesProvider.loadEntries(user.id, limitDays: 1);
    final todayEntry = entriesProvider.todayEntry;

    if (todayEntry != null && mounted) {
      // Cargar datos existentes en el formulario
      _reflectionController.text = todayEntry.freeReflection;
      _gratitudeController.text = todayEntry.gratitudeItems ?? '';
      _positiveTagsController.text = todayEntry.positiveTags.join(', ');
      _negativeTagsController.text = todayEntry.negativeTags.join(', ');

      setState(() {
        _moodScore = todayEntry.moodScore ?? 5;
        _energyLevel = todayEntry.energyLevel ?? 5;
        _stressLevel = todayEntry.stressLevel ?? 5;
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
        _weatherMoodImpact = todayEntry.weatherMoodImpact ?? 0;
        _socialBattery = todayEntry.socialBattery ?? 5;
        _creativeEnergy = todayEntry.creativeEnergy ?? 5;
        _emotionalStability = todayEntry.emotionalStability ?? 5;
        _focusLevel = todayEntry.focusLevel ?? 5;
        _lifeSatisfaction = todayEntry.lifeSatisfaction ?? 5;
        _worthIt = todayEntry.worthIt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildReflectionStep(),
                      _buildWellbeingStep(),
                      _buildLifestyleStep(),
                      _buildFinalStep(),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    final monthName = _getMonthName(today.month);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: ModernColors.primaryGradient),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '📝 Reflexión Diaria',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '$dayName, ${today.day} de $monthName',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? ModernColors.primaryGradient.first
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildReflectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '✍️ Reflexión Personal',
            'Comparte cómo ha sido tu día',
          ),

          const SizedBox(height: 24),

          _buildSectionCard(
            title: 'Reflexión libre',
            child: TextField(
              controller: _reflectionController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '¿Cómo ha sido tu día? ¿Qué has aprendido? ¿Cómo te sientes?',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionCard(
            title: 'Aspectos positivos',
            child: TextField(
              controller: _positiveTagsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ejemplo: trabajo productivo, tiempo con familia, ejercicio',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionCard(
            title: 'Desafíos o aspectos a mejorar',
            child: TextField(
              controller: _negativeTagsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ejemplo: estrés laboral, falta de sueño, procrastinación',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionCard(
            title: 'Gratitud',
            child: TextField(
              controller: _gratitudeController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '¿Por qué estás agradecido/a hoy?',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '💖 Bienestar Emocional',
            'Evalúa cómo te has sentido hoy',
          ),

          const SizedBox(height: 24),

          _buildSliderCard('Estado de ánimo general', _moodScore, '😔', '😊', (value) {
            setState(() => _moodScore = value);
          }),

          _buildSliderCard('Nivel de energía', _energyLevel, '🔋', '⚡', (value) {
            setState(() => _energyLevel = value);
          }),

          _buildSliderCard('Nivel de estrés', _stressLevel, '😌', '😰', (value) {
            setState(() => _stressLevel = value);
          }),

          _buildSliderCard('Nivel de ansiedad', _anxietyLevel, '😊', '😟', (value) {
            setState(() => _anxietyLevel = value);
          }),

          _buildSliderCard('Motivación', _motivationLevel, '😴', '🔥', (value) {
            setState(() => _motivationLevel = value);
          }),

          _buildSliderCard('Estabilidad emocional', _emotionalStability, '🌪️', '🧘', (value) {
            setState(() => _emotionalStability = value);
          }),

          _buildSliderCard('Nivel de enfoque', _focusLevel, '🤯', '🎯', (value) {
            setState(() => _focusLevel = value);
          }),

          _buildSliderCard('Satisfacción con la vida', _lifeSatisfaction, '😞', '🌟', (value) {
            setState(() => _lifeSatisfaction = value);
          }),
        ],
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '🏃‍♀️ Estilo de Vida',
            'Registra tus actividades del día',
          ),

          const SizedBox(height: 24),

          _buildSliderCard('Calidad del sueño', _sleepQuality, '😴', '✨', (value) {
            setState(() => _sleepQuality = value);
          }),

          _buildNumberCard('Horas de sueño', _sleepHours, 'horas', 0, 12, (value) {
            setState(() => _sleepHours = value);
          }),

          _buildSliderCard('Interacción social', _socialInteraction, '🏠', '👥', (value) {
            setState(() => _socialInteraction = value);
          }),

          _buildSliderCard('Actividad física', _physicalActivity, '🛋️', '🏃‍♀️', (value) {
            setState(() => _physicalActivity = value);
          }),

          _buildSliderCard('Productividad laboral', _workProductivity, '😴', '🚀', (value) {
            setState(() => _workProductivity = value);
          }),

          _buildNumberCard('Vasos de agua', _waterIntake as double, 'vasos', 0, 20, (value) {
            setState(() => _waterIntake = value.round());
          }),

          _buildNumberCard('Minutos de meditación', _meditationMinutes as double, 'min', 0, 120, (value) {
            setState(() => _meditationMinutes = value.round());
          }),

          _buildNumberCard('Minutos de ejercicio', _exerciseMinutes as double, 'min', 0, 180, (value) {
            setState(() => _exerciseMinutes = value.round());
          }),

          _buildNumberCard('Horas de pantalla', _screenTimeHours, 'horas', 0, 16, (value) {
            setState(() => _screenTimeHours = value);
          }),

          _buildSliderCard('Batería social', _socialBattery, '🔋', '⚡', (value) {
            setState(() => _socialBattery = value);
          }),

          _buildSliderCard('Energía creativa', _creativeEnergy, '🎨', '🌟', (value) {
            setState(() => _creativeEnergy = value);
          }),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            '🎯 Reflexión Final',
            'Evalúa tu día en general',
          ),

          const SizedBox(height: 24),

          _buildSectionCard(
            title: '¿Ha valido la pena este día?',
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWorthItButton(true, '👍 Sí', 'Ha sido un buen día'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWorthItButton(false, '👎 No', 'Podría haber sido mejor'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_worthIt == null)
                  TextButton(
                    onPressed: () => setState(() => _worthIt = null),
                    child: const Text('Prefiero no responder'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildSliderCard('Impacto del clima en el ánimo', _weatherMoodImpact, '☔', '☀️', (value) {
            setState(() => _weatherMoodImpact = value - 5);
          }, min: -5, max: 5, initialValue: _weatherMoodImpact + 5),

          const SizedBox(height: 24),

          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSliderCard(
      String title,
      int value,
      String lowEmoji,
      String highEmoji,
      Function(int) onChanged, {
        int min = 1,
        int max = 10,
        int? initialValue,
      }) {
    final displayValue = initialValue ?? value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernColors.primaryGradient.first.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayValue.toString(),
                  style: TextStyle(
                    color: ModernColors.primaryGradient.first,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text(lowEmoji, style: const TextStyle(fontSize: 20)),
              Expanded(
                child: Slider(
                  value: displayValue.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  activeColor: ModernColors.primaryGradient.first,
                  inactiveColor: Colors.white.withOpacity(0.2),
                  onChanged: (newValue) => onChanged(newValue.round()),
                ),
              ),
              Text(highEmoji, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(
      String title,
      double value,
      String unit,
      double min,
      double max,
      Function(double) onChanged
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ModernColors.primaryGradient.first.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $unit',
                  style: TextStyle(
                    color: ModernColors.primaryGradient.first,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * (unit == 'horas' ? 2 : 1)).round(),
            activeColor: ModernColors.primaryGradient.first,
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItButton(bool value, String title, String description) {
    final isSelected = _worthIt == value;

    return GestureDetector(
      onTap: () => setState(() => _worthIt = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? ModernColors.primaryGradient.first.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ModernColors.primaryGradient.first
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? ModernColors.primaryGradient.first : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? ModernColors.primaryGradient.first : Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final wellbeingScore = _calculateWellbeingScore();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ModernColors.primaryGradient.map((c) => c.withOpacity(0.2)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primaryGradient.first.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Resumen del Día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      wellbeingScore.toStringAsFixed(1),
                      style: TextStyle(
                        color: ModernColors.primaryGradient.first,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Puntuación de\nBienestar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getWellbeingEmoji(wellbeingScore),
                      style: const TextStyle(fontSize: 32),
                    ),
                    Text(
                      _getWellbeingLevel(wellbeingScore),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Anterior',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 16),

          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: Consumer<OptimizedDailyEntriesProvider>(
              builder: (context, entriesProvider, child) {
                return ElevatedButton(
                  onPressed: _isLoading || entriesProvider.isLoading
                      ? null
                      : _currentStep < 3
                      ? _nextStep
                      : _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernColors.primaryGradient.first,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading || entriesProvider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _currentStep < 3 ? 'Siguiente' : 'Guardar Reflexión',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveEntry() async {
    if (_reflectionController.text.trim().isEmpty) {
      _showSnackBar('Por favor completa tu reflexión personal', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final entriesProvider = context.read<OptimizedDailyEntriesProvider>();

      final user = authProvider.currentUser;
      if (user == null) {
        _showSnackBar('Error: Usuario no autenticado', isError: true);
        return;
      }

      final success = await entriesProvider.saveDailyEntry(
        userId: user.id,
        freeReflection: _reflectionController.text.trim(),
        positiveTags: _parseTagsString(_positiveTagsController.text),
        negativeTags: _parseTagsString(_negativeTagsController.text),
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
        gratitudeItems: _gratitudeController.text.trim(),
        weatherMoodImpact: _weatherMoodImpact,
        socialBattery: _socialBattery,
        creativeEnergy: _creativeEnergy,
        emotionalStability: _emotionalStability,
        focusLevel: _focusLevel,
        lifeSatisfaction: _lifeSatisfaction,
      );

      if (success) {
        _showSnackBar('¡Reflexión diaria guardada exitosamente!');

        // Regresar a la pantalla anterior después de un breve delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        _showSnackBar(
          entriesProvider.errorMessage ?? 'Error al guardar la reflexión',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error inesperado: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _parseTagsString(String tagsString) {
    if (tagsString.trim().isEmpty) return [];
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  double _calculateWellbeingScore() {
    final scores = [
      _moodScore,
      _energyLevel,
      (11 - _stressLevel), // Invertir estrés
      _sleepQuality,
      (11 - _anxietyLevel), // Invertir ansiedad
      _motivationLevel,
      _socialInteraction,
      _physicalActivity,
      _workProductivity,
      _socialBattery,
      _creativeEnergy,
      _emotionalStability,
      _focusLevel,
      _lifeSatisfaction,
    ];

    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String _getWellbeingEmoji(double score) {
    if (score >= 8.5) return '🌟';
    if (score >= 7.0) return '😊';
    if (score >= 5.5) return '🙂';
    if (score >= 4.0) return '😐';
    return '😔';
  }

  String _getWellbeingLevel(double score) {
    if (score >= 8.5) return 'Excelente';
    if (score >= 7.0) return 'Muy Bueno';
    if (score >= 5.5) return 'Bueno';
    if (score >= 4.0) return 'Regular';
    return 'Necesita Atención';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}