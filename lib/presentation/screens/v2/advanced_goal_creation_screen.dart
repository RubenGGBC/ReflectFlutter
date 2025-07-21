// lib/presentation/screens/v2/advanced_goal_creation_screen.dart
// ============================================================================
// SIMPLIFIED GOAL CREATION SCREEN - 3 SECTION APPROACH
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/goal_model.dart';
import '../../providers/enhanced_goals_provider.dart';
import '../../providers/optimized_providers.dart';
import 'components/minimal_colors.dart';

class AdvancedGoalCreationScreen extends StatefulWidget {
  const AdvancedGoalCreationScreen({super.key});

  @override
  State<AdvancedGoalCreationScreen> createState() => _AdvancedGoalCreationScreenState();
}

class _AdvancedGoalCreationScreenState extends State<AdvancedGoalCreationScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController(text: '30');
  final _durationController = TextEditingController(text: '30');
  final _customUnitController = TextEditingController();

  // Form state
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Simplified goal configuration
  GoalCategory _selectedCategory = GoalCategory.habits;
  FrequencyType _selectedFrequency = FrequencyType.daily;
  String? _selectedCustomUnit;
  String? _selectedIconCode;
  String? _selectedColorHex;

  final List<String> _commonUnits = [
    'días', 'veces', 'minutos', 'horas', 'páginas', 
    'ejercicios', 'sesiones', 'km', 'repeticiones'
  ];

  final List<String> _commonIcons = [
    'fitness_center', 'self_improvement', 'favorite', 'spa',
    'local_fire_department', 'psychology', 'bedtime', 'people',
    'trending_up', 'repeat', 'star', 'lightbulb'
  ];

  final List<String> _commonColors = [
    '8B5CF6', 'EF4444', '3B82F6', '10B981', 'F59E0B',
    'EC4899', '6366F1', '84CC16', 'F97316', '06B6D4'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _durationController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MinimalColors.backgroundPrimary(context),
              MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
              MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.05),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(context),
                _buildStepIndicator(context),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(context),
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back,
                color: MinimalColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Objetivo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
                Text(
                  'Paso ${_currentStep + 1} de 3',
                  style: TextStyle(
                    fontSize: 14,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final steps = [
      {'title': 'Tu Objetivo', 'icon': Icons.flag},
      {'title': 'Seguimiento', 'icon': Icons.timeline},
      {'title': 'Personalización', 'icon': Icons.palette},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = _currentStep == index;
          final isCompleted = _currentStep > index;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < steps.length - 1 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                gradient: isActive || isCompleted
                    ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                    : null,
                color: !isActive && !isCompleted ? MinimalColors.backgroundCard(context) : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive || isCompleted
                      ? Colors.transparent
                      : MinimalColors.textMuted(context).withValues(alpha: 0.2),
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCompleted ? Icons.check : step['icon'] as IconData,
                    color: isActive || isCompleted
                        ? MinimalColors.textPrimary(context) 
                        : MinimalColors.textSecondary(context),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive || isCompleted
                          ? MinimalColors.textPrimary(context) 
                          : MinimalColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: _getCurrentStepContent(),
        ),
      ),
    );
  }

  Widget _getCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildYourObjectiveStep();
      case 1:
        return _buildTrackingStep();
      case 2:
        return _buildPersonalizationStep();
      default:
        return _buildYourObjectiveStep();
    }
  }

  Widget _buildYourObjectiveStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Tu Objetivo',
          'Define qué quieres lograr',
          Icons.flag,
        ),
        const SizedBox(height: 24),
        
        // Title Field
        _buildInputField(
          'Título del Objetivo',
          _titleController,
          'Ej: Leer 30 minutos diarios',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El título es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // Description Field
        _buildInputField(
          'Descripción',
          _descriptionController,
          'Describe tu objetivo con más detalle...',
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        
        // Category Selection
        _buildCategorySelection(),
        const SizedBox(height: 20),
        
        // Target and Unit
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildInputField(
                'Meta',
                _targetValueController,
                '30',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La meta es obligatoria';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Debe ser un número mayor a 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildUnitSelection(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Seguimiento',
          'Configura cómo hacer seguimiento de tu progreso',
          Icons.timeline,
        ),
        const SizedBox(height: 24),
        
        // Duration
        _buildInputField(
          'Duración (días)',
          _durationController,
          '30',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La duración es obligatoria';
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return 'Debe ser un número mayor a 0';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
        // Frequency Selection
        _buildFrequencySelection(),
        const SizedBox(height: 24),
        
        // Progress Preview
        _buildProgressPreview(),
      ],
    );
  }

  Widget _buildPersonalizationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Personalización',
          'Personaliza el aspecto de tu objetivo',
          Icons.palette,
        ),
        const SizedBox(height: 24),
        
        // Icon Selection
        _buildIconSelection(),
        const SizedBox(height: 24),
        
        // Color Selection
        _buildColorSelection(),
        const SizedBox(height: 24),
        
        // Custom Unit Field
        _buildInputField(
          'Unidad Personalizada (Opcional)',
          _customUnitController,
          'Ej: páginas, km, sesiones...',
        ),
        const SizedBox(height: 24),
        
        // Final Preview
        _buildFinalPreview(),
      ],
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: MinimalColors.textPrimary(context), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: MinimalColors.textPrimary(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: MinimalColors.textMuted(context)),
            filled: true,
            fillColor: MinimalColors.backgroundCard(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: MinimalColors.primaryGradient(context)[0],
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MinimalColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MinimalColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 16,
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
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: !isSelected ? MinimalColors.backgroundCard(context) : null,
                  borderRadius: BorderRadius.circular(20),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildUnitSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unidad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCustomUnit ?? _getSuggestedUnit(_selectedCategory),
              isExpanded: true,
              style: TextStyle(color: MinimalColors.textPrimary(context)),
              dropdownColor: MinimalColors.backgroundCard(context),
              items: _commonUnits.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomUnit = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frecuencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FrequencyType.values.map((frequency) {
            final isSelected = _selectedFrequency == frequency;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFrequency = frequency;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.accentGradient(context))
                      : null,
                  color: !isSelected ? MinimalColors.backgroundCard(context) : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getFrequencyDisplayName(frequency),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? MinimalColors.textPrimary(context) 
                        : MinimalColors.textSecondary(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressPreview() {
    final targetValue = int.tryParse(_targetValueController.text) ?? 30;
    final durationDays = int.tryParse(_durationController.text) ?? 30;
    final unit = _selectedCustomUnit ?? _getSuggestedUnit(_selectedCategory);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Meta: $targetValue $unit',
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          Text(
            'Duración: $durationDays días',
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          Text(
            'Frecuencia: ${_getFrequencyDisplayName(_selectedFrequency)}',
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icono',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonIcons.map((iconCode) {
            final isSelected = _selectedIconCode == iconCode;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIconCode = iconCode;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: !isSelected ? MinimalColors.backgroundCard(context) : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  _getIconFromCode(iconCode),
                  size: 24,
                  color: isSelected 
                      ? MinimalColors.textPrimary(context) 
                      : MinimalColors.textSecondary(context),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonColors.map((colorHex) {
            final color = Color(int.parse('FF$colorHex', radix: 16));
            final isSelected = _selectedColorHex == colorHex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColorHex = colorHex;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? MinimalColors.textPrimary(context) : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ?  Icon(Icons.check, color: MinimalColors.textPrimary(context), size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFinalPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_selectedIconCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconFromCode(_selectedIconCode!),
                    color: MinimalColors.textPrimary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleController.text.isEmpty ? 'Mi Objetivo' : _titleController.text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      _getCategoryDisplayName(_selectedCategory),
                      style: TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_descriptionController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _descriptionController.text,
              style: TextStyle(
                fontSize: 14,
                color: MinimalColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Anterior',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextOrCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ?  SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(MinimalColors.textPrimary(context)),
                        ),
                      )
                    : Text(
                        _currentStep < 2 ? 'Siguiente' : 'Crear Objetivo',
                        style:  TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MinimalColors.textPrimary(context),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrCreate() {
    if (_currentStep < 2) {
      // Validate current step
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Create goal
      _createGoal();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Validate first step manually
        if (_titleController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El título es obligatorio')),
          );
          return false;
        }
        if (_targetValueController.text.isEmpty || int.tryParse(_targetValueController.text) == null || int.parse(_targetValueController.text) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La meta debe ser un número mayor a 0')),
          );
          return false;
        }
        return true;
      case 1:
        if (_durationController.text.isEmpty || int.tryParse(_durationController.text) == null || int.parse(_durationController.text) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La duración debe ser un número mayor a 0')),
          );
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final goalsProvider = context.read<EnhancedGoalsProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      print('🎯 Creando objetivo con modelo simplificado...');

      final goal = GoalModel.createEnhanced(
        userId: user.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetValue: int.parse(_targetValueController.text),
        category: _selectedCategory,
        durationDays: int.parse(_durationController.text),
        frequency: _selectedFrequency,
        customMilestones: null,
        initialMetrics: {},
      ).copyWith(
        customUnit: _customUnitController.text.trim().isEmpty 
            ? _selectedCustomUnit 
            : _customUnitController.text.trim(),
        iconCode: _selectedIconCode,
        colorHex: _selectedColorHex,
      );

      print('📊 Objetivo a crear: ${goal.title}, categoría: ${goal.category.name}');

      await goalsProvider.createGoal(goal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Objetivo creado exitosamente!'),
            backgroundColor: MinimalColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Error creando objetivo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear objetivo: $e'),
            backgroundColor: MinimalColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  String _getSuggestedUnit(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness: return 'sesiones';
      case GoalCategory.stress: return 'veces';
      case GoalCategory.sleep: return 'horas';
      case GoalCategory.social: return 'actividades';
      case GoalCategory.physical: return 'ejercicios';
      case GoalCategory.emotional: return 'momentos';
      case GoalCategory.productivity: return 'tareas';
      case GoalCategory.habits: return 'días';
    }
  }

  String _getFrequencyDisplayName(FrequencyType frequency) {
    switch (frequency) {
      case FrequencyType.daily: return 'Diario';
      case FrequencyType.weekly: return 'Semanal';
      case FrequencyType.monthly: return 'Mensual';
      case FrequencyType.custom: return 'Personalizado';
    }
  }

  IconData _getIconFromCode(String iconCode) {
    switch (iconCode) {
      case 'fitness_center': return Icons.fitness_center;
      case 'self_improvement': return Icons.self_improvement;
      case 'favorite': return Icons.favorite;
      case 'spa': return Icons.spa;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'psychology': return Icons.psychology;
      case 'bedtime': return Icons.bedtime;
      case 'people': return Icons.people;
      case 'trending_up': return Icons.trending_up;
      case 'repeat': return Icons.repeat;
      case 'star': return Icons.star;
      case 'lightbulb': return Icons.lightbulb;
      default: return Icons.flag;
    }
  }
}