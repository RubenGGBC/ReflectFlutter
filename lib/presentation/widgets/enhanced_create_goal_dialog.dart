// lib/presentation/widgets/enhanced_create_goal_dialog.dart
// ============================================================================
// ENHANCED CREATE GOAL DIALOG - PHASE 1 IMPLEMENTATION
// ============================================================================

import 'package:flutter/material.dart';

import '../../data/models/goal_model.dart';
import '../screens/v2/components/minimal_colors.dart';

class EnhancedCreateGoalDialog extends StatefulWidget {
  final Function(GoalModel) onGoalCreated;

  const EnhancedCreateGoalDialog({
    super.key,
    required this.onGoalCreated,
  });

  @override
  State<EnhancedCreateGoalDialog> createState() => _EnhancedCreateGoalDialogState();
}

class _EnhancedCreateGoalDialogState extends State<EnhancedCreateGoalDialog>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _estimatedDaysController = TextEditingController();
  
  // Selected values
  GoalCategory _selectedCategory = GoalCategory.mindfulness;
  String _selectedDifficulty = 'medium';
  String _selectedUnit = 'días';
  
  bool _isLoading = false;
  int _currentStep = 0;
  
  final List<String> _availableUnits = [
    'días', 'veces', 'minutos', 'horas', 'páginas', 'ejercicios', 'sesiones'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _estimatedDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: _buildStepContent(context),
              ),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear Nuevo Objetivo',
                      style:  TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Define tu próximo logro personal',
                      style:  TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon:  Icon(
                  Icons.close,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentStep ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index <= _currentStep 
                      ? MinimalColors.textPrimary(context) 
                      : MinimalColors.textPrimary(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _getStepWidget(_currentStep),
        ),
      ),
    );
  }

  Widget _getStepWidget(int step) {
    switch (step) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildCategoryStep();
      case 2:
        return _buildTargetStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      key: const ValueKey('basic'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 24),
        
        // Title input
        _buildTextField(
          controller: _titleController,
          label: 'Título del Objetivo',
          hint: 'ej. Meditar todos los días',
          icon: Icons.flag,
        ),
        
        const SizedBox(height: 16),
        
        // Description input
        _buildTextField(
          controller: _descriptionController,
          label: 'Descripción',
          hint: 'Describe qué quieres lograr y por qué es importante',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCategoryStep() {
    return Column(
      key: const ValueKey('category'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría y Dificultad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 24),
        
        // Category selection
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GoalCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: !isSelected 
                      ? MinimalColors.backgroundSecondary(context)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected 
                          ? MinimalColors.textPrimary(context) 
                          : MinimalColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryDisplayName(category),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? MinimalColors.textPrimary(context)
                            : MinimalColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Difficulty selection
        Text(
          'Dificultad',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        
        ...['easy', 'medium', 'hard', 'expert'].map((difficulty) {
          final isSelected = _selectedDifficulty == difficulty;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedDifficulty = difficulty),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2)
                      : MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? MinimalColors.primaryGradient(context)[0]
                        : MinimalColors.textMuted(context).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(difficulty).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getDifficultyIcon(difficulty),
                        color: _getDifficultyColor(difficulty),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDifficultyDisplayName(difficulty),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MinimalColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDifficultyDescription(difficulty),
                            style: TextStyle(
                              fontSize: 12,
                              color: MinimalColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: MinimalColors.primaryGradient(context)[0],
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTargetStep() {
    return Column(
      key: const ValueKey('target'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meta y Tiempo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 24),
        
        // Target value and unit
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _targetValueController,
                label: 'Valor Meta',
                hint: '30',
                icon: Icons.track_changes,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unidad',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: MinimalColors.backgroundSecondary(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        dropdownColor: MinimalColors.backgroundCard(context),
                        style: TextStyle(color: MinimalColors.textPrimary(context)),
                        onChanged: (value) => setState(() => _selectedUnit = value!),
                        items: _availableUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Estimated days
        _buildTextField(
          controller: _estimatedDaysController,
          label: 'Días Estimados (Opcional)',
          hint: 'ej. 30 días para completar',
          icon: Icons.schedule,
          keyboardType: TextInputType.number,
        ),
        
        const SizedBox(height: 24),
        
        // Preview card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview,
                    color: MinimalColors.primaryGradient(context)[0],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vista Previa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _titleController.text.isNotEmpty ? _titleController.text : 'Tu objetivo aquí',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_getCategoryDisplayName(_selectedCategory)} • ${_getDifficultyDisplayName(_selectedDifficulty)}',
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
              if (_targetValueController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Meta: ${_targetValueController.text} $_selectedUnit',
                  style: TextStyle(
                    fontSize: 12,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(color: MinimalColors.textPrimary(context)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
              prefixIcon: Icon(icon, color: MinimalColors.textSecondary(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MinimalColors.primaryGradient(context)[0],
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: MinimalColors.backgroundSecondary(context),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: MinimalColors.primaryGradient(context)[0]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Anterior',
                  style: TextStyle(
                    color: MinimalColors.primaryGradient(context)[0],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextOrSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ?  SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(MinimalColors.textPrimary(context)),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Crear Objetivo' : 'Siguiente',
                        style:  TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrSubmit() {
    if (_currentStep < 2) {
      // Validate current step
      if (_currentStep == 0 && (_titleController.text.isEmpty || _descriptionController.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa título y descripción')),
        );
        return;
      }
      
      setState(() {
        _currentStep++;
      });
    } else {
      _createGoal();
    }
  }

  void _createGoal() async {
    // Validate final step
    if (_targetValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un valor meta')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetValue = int.tryParse(_targetValueController.text) ?? 0;
      final estimatedDays = int.tryParse(_estimatedDaysController.text) ?? 30;
      
      final goal = GoalModel(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 1, // Will be set by the service
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory, // Using selected category for enhanced goals
        targetValue: targetValue,
        currentValue: 0,
        status: GoalStatus.active,
        createdAt: DateTime.now(),
        // Enhanced fields
        durationDays: estimatedDays,
        milestones: [], // Will be auto-generated by service
        metrics: {},
        frequency: FrequencyType.daily,
        tags: [_selectedCategory.name],
        customSettings: {},
        motivationalQuotes: [],
        reminderSettings: {},
        isTemplate: false,
        progressNotes: null,
        lastUpdated: DateTime.now(),
      );

      widget.onGoalCreated(goal);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creando objetivo: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper methods
  String _getCategoryDisplayName(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness: return 'Mindfulness';
      case GoalCategory.stress: return 'Estrés';
      case GoalCategory.sleep: return 'Sueño';
      case GoalCategory.social: return 'Social';
      case GoalCategory.physical: return 'Físico';
      case GoalCategory.emotional: return 'Emocional';
      case GoalCategory.productivity: return 'Productividad';
      case GoalCategory.habits: return 'Hábitos';
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness: return Icons.self_improvement;
      case GoalCategory.stress: return Icons.psychology;
      case GoalCategory.sleep: return Icons.bedtime;
      case GoalCategory.social: return Icons.people;
      case GoalCategory.physical: return Icons.fitness_center;
      case GoalCategory.emotional: return Icons.favorite;
      case GoalCategory.productivity: return Icons.trending_up;
      case GoalCategory.habits: return Icons.repeat;
    }
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'Fácil';
      case 'medium': return 'Medio';
      case 'hard': return 'Difícil';
      case 'expert': return 'Experto';
      default: return 'Medio';
    }
  }

  String _getDifficultyDescription(String difficulty) {
    switch (difficulty) {
      case 'easy': return 'Perfecto para empezar, requiere poco esfuerzo diario';
      case 'medium': return 'Un desafío moderado que requiere constancia';
      case 'hard': return 'Requiere dedicación y disciplina considerable';
      case 'expert': return 'Para objetivos muy ambiciosos, máximo desafío';
      default: return 'Un desafío moderado que requiere constancia';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy': return MinimalColors.success;
      case 'medium': return MinimalColors.warning;
      case 'hard': return MinimalColors.error;
      case 'expert': return MinimalColors.accent;
      default: return MinimalColors.warning;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy': return Icons.sentiment_satisfied;
      case 'medium': return Icons.fitness_center;
      case 'hard': return Icons.local_fire_department;
      case 'expert': return Icons.military_tech;
      default: return Icons.fitness_center;
    }
  }
}