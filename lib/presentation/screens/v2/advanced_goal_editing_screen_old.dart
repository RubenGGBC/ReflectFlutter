// lib/presentation/screens/v2/advanced_goal_editing_screen.dart
// ============================================================================
// ADVANCED GOAL EDITING SCREEN WITH FULL CUSTOMIZATION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/goal_model.dart';
import '../../providers/enhanced_goals_provider.dart';
import 'components/minimal_colors.dart';

class AdvancedGoalEditingScreen extends StatefulWidget {
  final GoalModel goal;

  const AdvancedGoalEditingScreen({
    super.key,
    required this.goal,
  });

  @override
  State<AdvancedGoalEditingScreen> createState() => _AdvancedGoalEditingScreenState();
}

class _AdvancedGoalEditingScreenState extends State<AdvancedGoalEditingScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetValueController;
  late TextEditingController _currentValueController;
  late TextEditingController _estimatedDaysController;
  late TextEditingController _customUnitController;
  late TextEditingController _colorHexController;
  late TextEditingController _motivationalQuoteController;
  late TextEditingController _progressNotesController;

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Goal configuration
  late GoalCategory _selectedCategory;
  late GoalType _selectedType;
  late GoalDifficulty _selectedDifficulty;
  late GoalPriority _selectedPriority;
  late GoalFrequency _selectedFrequency;
  late GoalVisibility _selectedVisibility;
  late GoalStatus _selectedStatus;
  
  String? _selectedCustomUnit;
  String? _selectedIconCode;
  String? _selectedColorHex;
  DateTime? _startDate;
  DateTime? _endDate;
  
  List<String> _tags = [];
  List<String> _motivationalQuotes = [];
  Map<String, dynamic> _customSettings = {};
  Map<String, dynamic> _reminderSettings = {};

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
    _initializeFromGoal();
    _setupAnimations();
  }

  void _initializeFromGoal() {
    final goal = widget.goal;
    
    // Initialize controllers
    _titleController = TextEditingController(text: goal.title);
    _descriptionController = TextEditingController(text: goal.description);
    _targetValueController = TextEditingController(text: goal.targetValue.toString());
    _currentValueController = TextEditingController(text: goal.currentValue.toString());
    _estimatedDaysController = TextEditingController(text: goal.estimatedDays.toString());
    _customUnitController = TextEditingController(text: goal.customUnit ?? '');
    _colorHexController = TextEditingController(text: goal.colorHex ?? '');
    _motivationalQuoteController = TextEditingController();
    _progressNotesController = TextEditingController(text: goal.progressNotes ?? '');
    
    // Initialize selections
    _selectedCategory = goal.category;
    _selectedType = goal.type;
    _selectedDifficulty = goal.difficulty;
    _selectedPriority = goal.priority;
    _selectedFrequency = goal.frequency;
    _selectedVisibility = goal.visibility;
    _selectedStatus = goal.status;
    
    _selectedCustomUnit = goal.customUnit;
    _selectedIconCode = goal.iconCode;
    _selectedColorHex = goal.colorHex;
    _startDate = goal.startDate;
    _endDate = goal.endDate;
    
    _tags = List.from(goal.tags);
    _motivationalQuotes = List.from(goal.motivationalQuotes);
    _customSettings = Map.from(goal.customSettings);
    _reminderSettings = Map.from(goal.reminderSettings);

    // Add listeners to detect changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _targetValueController.addListener(_onFieldChanged);
    _currentValueController.addListener(_onFieldChanged);
    _estimatedDaysController.addListener(_onFieldChanged);
    _customUnitController.addListener(_onFieldChanged);
    _colorHexController.addListener(_onFieldChanged);
    _progressNotesController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    _estimatedDaysController.dispose();
    _customUnitController.dispose();
    _colorHexController.dispose();
    _motivationalQuoteController.dispose();
    _progressNotesController.dispose();
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
                _buildHeader(context),
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
          IconButton(
            onPressed: _handleBackPressed,
            icon: Icon(
              Icons.arrow_back,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Objetivo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
                Text(
                  widget.goal.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: MinimalColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_hasChanges) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: MinimalColors.primaryGradient(context)[0],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Cambios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(context),
            const SizedBox(height: 32),
            _buildProgressSection(context),
            const SizedBox(height: 32),
            _buildCategoryAndTypeSection(context),
            const SizedBox(height: 32),
            _buildConfigurationSection(context),
            const SizedBox(height: 32),
            _buildCustomizationSection(context),
            const SizedBox(height: 32),
            _buildAdvancedSection(context),
            const SizedBox(height: 100), // Space for action buttons
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Información Básica',
      [
        _buildTextField(
          controller: _titleController,
          label: 'Título del Objetivo',
          hint: 'Ej: Meditar todos los días',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El título es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Descripción',
          hint: 'Describe tu objetivo en detalle...',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La descripción es requerida';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _progressNotesController,
          label: 'Notas de Progreso',
          hint: 'Reflexiones y observaciones...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return _buildSection(
      context,
      'Progreso y Metas',
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _currentValueController,
                label: 'Progreso Actual',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Número válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _targetValueController,
                label: 'Valor Objetivo',
                hint: '30',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Número válido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _estimatedDaysController,
                label: 'Días Estimados',
                hint: '30',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Número válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatusDropdown(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(context),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final currentValue = int.tryParse(_currentValueController.text) ?? 0;
    final targetValue = int.tryParse(_targetValueController.text) ?? 1;
    final progress = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: MinimalColors.primaryGradient(context)[0],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: MinimalColors.backgroundCard(context),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndTypeSection(BuildContext context) {
    return _buildSection(
      context,
      'Categoría y Tipo',
      [
        _buildSectionTitle('Categoría'),
        _buildCategoryGrid(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Tipo de Objetivo'),
        _buildTypeGrid(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Dificultad'),
                  _buildDifficultyDropdown(context),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Prioridad'),
                  _buildPriorityDropdown(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigurationSection(BuildContext context) {
    return _buildSection(
      context,
      'Configuración',
      [
        _buildSectionTitle('Frecuencia'),
        _buildFrequencyGrid(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Visibilidad'),
        _buildVisibilityDropdown(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Fechas del Objetivo'),
        _buildDatePickers(context),
      ],
    );
  }

  Widget _buildCustomizationSection(BuildContext context) {
    return _buildSection(
      context,
      'Personalización',
      [
        _buildSectionTitle('Unidad de Medida'),
        _buildUnitSelector(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Icono'),
        _buildIconSelector(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Color'),
        _buildColorSelector(context),
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    return _buildSection(
      context,
      'Configuración Avanzada',
      [
        _buildSectionTitle('Etiquetas'),
        _buildTagsInput(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Frases Motivacionales'),
        _buildMotivationalQuotesInput(context),
        const SizedBox(height: 16),
        _buildSectionTitle('Recordatorios'),
        _buildReminderSettings(context),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
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
            fontSize: 14,
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
            hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
            filled: true,
            fillColor: MinimalColors.backgroundPrimary(context),
            border: OutlineInputBorder(
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
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MinimalColors.textPrimary(context),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<GoalStatus>(
          value: _selectedStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: MinimalColors.backgroundPrimary(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
          ),
          dropdownColor: MinimalColors.backgroundCard(context),
          style: TextStyle(color: MinimalColors.textPrimary(context)),
          items: GoalStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    size: 18,
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(_getStatusDisplayName(status)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && value != _selectedStatus) {
              setState(() {
                _selectedStatus = value;
                _hasChanges = true;
              });
            }
          },
        ),
      ],
    );
  }

  // Reuse the same UI building methods from the creation screen
  Widget _buildCategoryGrid(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: GoalCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedCategory = category;
            _hasChanges = true;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                  : null,
              color: !isSelected 
                  ? MinimalColors.backgroundPrimary(context)
                  : null,
              borderRadius: BorderRadius.circular(12),
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
                  size: 18,
                  color: isSelected 
                      ? Colors.white 
                      : MinimalColors.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Colors.white 
                        : MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeGrid(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: GoalType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedType = type;
            _hasChanges = true;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: MinimalColors.accentGradient(context))
                  : null,
              color: !isSelected 
                  ? MinimalColors.backgroundPrimary(context)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              type.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white 
                    : MinimalColors.textSecondary(context),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyDropdown(BuildContext context) {
    return DropdownButtonFormField<GoalDifficulty>(
      value: _selectedDifficulty,
      decoration: InputDecoration(
        filled: true,
        fillColor: MinimalColors.backgroundPrimary(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
          ),
        ),
      ),
      dropdownColor: MinimalColors.backgroundCard(context),
      style: TextStyle(color: MinimalColors.textPrimary(context)),
      items: GoalDifficulty.values.map((difficulty) {
        return DropdownMenuItem(
          value: difficulty,
          child: Text(_getDifficultyDisplayName(difficulty)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null && value != _selectedDifficulty) {
          setState(() {
            _selectedDifficulty = value;
            _hasChanges = true;
          });
        }
      },
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    return DropdownButtonFormField<GoalPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        filled: true,
        fillColor: MinimalColors.backgroundPrimary(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
          ),
        ),
      ),
      dropdownColor: MinimalColors.backgroundCard(context),
      style: TextStyle(color: MinimalColors.textPrimary(context)),
      items: GoalPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(_getPriorityDisplayName(priority)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null && value != _selectedPriority) {
          setState(() {
            _selectedPriority = value;
            _hasChanges = true;
          });
        }
      },
    );
  }

  Widget _buildFrequencyGrid(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: GoalFrequency.values.map((frequency) {
        final isSelected = _selectedFrequency == frequency;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedFrequency = frequency;
            _hasChanges = true;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                  : null,
              color: !isSelected 
                  ? MinimalColors.backgroundPrimary(context)
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _getFrequencyDisplayName(frequency),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white 
                    : MinimalColors.textSecondary(context),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVisibilityDropdown(BuildContext context) {
    return DropdownButtonFormField<GoalVisibility>(
      value: _selectedVisibility,
      decoration: InputDecoration(
        filled: true,
        fillColor: MinimalColors.backgroundPrimary(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
          ),
        ),
      ),
      dropdownColor: MinimalColors.backgroundCard(context),
      style: TextStyle(color: MinimalColors.textPrimary(context)),
      items: GoalVisibility.values.map((visibility) {
        return DropdownMenuItem(
          value: visibility,
          child: Row(
            children: [
              Icon(
                _getVisibilityIcon(visibility),
                size: 18,
                color: MinimalColors.textSecondary(context),
              ),
              const SizedBox(width: 8),
              Text(_getVisibilityDisplayName(visibility)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null && value != _selectedVisibility) {
          setState(() {
            _selectedVisibility = value;
            _hasChanges = true;
          });
        }
      },
    );
  }

  Widget _buildUnitSelector(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonUnits.map((unit) {
            final isSelected = _selectedCustomUnit == unit;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedCustomUnit = unit;
                _hasChanges = true;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.accentGradient(context))
                      : null,
                  color: !isSelected 
                      ? MinimalColors.backgroundPrimary(context)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Colors.white 
                        : MinimalColors.textSecondary(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _customUnitController,
          label: 'Unidad Personalizada',
          hint: 'Ej: libros, kilómetros...',
        ),
      ],
    );
  }

  Widget _buildIconSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonIcons.map((iconCode) {
        final isSelected = _selectedIconCode == iconCode;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedIconCode = iconCode;
            _hasChanges = true;
          }),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                  : null,
              color: !isSelected 
                  ? MinimalColors.backgroundPrimary(context)
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              _getIconData(iconCode),
              size: 24,
              color: isSelected 
                  ? Colors.white 
                  : MinimalColors.textSecondary(context),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonColors.map((colorHex) {
            final isSelected = _selectedColorHex == colorHex;
            final color = Color(int.parse('FF$colorHex', radix: 16));
            return GestureDetector(
              onTap: () => setState(() {
                _selectedColorHex = colorHex;
                _hasChanges = true;
              }),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? MinimalColors.textPrimary(context)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _colorHexController,
          label: 'Color Personalizado (Hex)',
          hint: 'Ej: FF5722',
        ),
      ],
    );
  }

  Widget _buildDatePickers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            context,
            'Fecha de Inicio',
            _startDate,
            (date) => setState(() {
              _startDate = date;
              _hasChanges = true;
            }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDatePicker(
            context,
            'Fecha de Fin',
            _endDate,
            (date) => setState(() {
              _endDate = date;
              _hasChanges = true;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
  ) {
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
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            onDateSelected(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundPrimary(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: MinimalColors.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      color: selectedDate != null
                          ? MinimalColors.textPrimary(context)
                          : MinimalColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() {
                        _tags.remove(tag);
                        _hasChanges = true;
                      }),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                style: TextStyle(color: MinimalColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'Agregar etiqueta...',
                  hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
                  filled: true,
                  fillColor: MinimalColors.backgroundPrimary(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_tags.contains(value)) {
                    setState(() {
                      _tags.add(value);
                      _hasChanges = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMotivationalQuotesInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_motivationalQuotes.isNotEmpty) ...[
          Column(
            children: _motivationalQuotes.map((quote) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundPrimary(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '"$quote"',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _motivationalQuotes.remove(quote);
                        _hasChanges = true;
                      }),
                      child: Icon(
                        Icons.delete,
                        size: 18,
                        color: MinimalColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _motivationalQuoteController,
                style: TextStyle(color: MinimalColors.textPrimary(context)),
                decoration: InputDecoration(
                  hintText: 'Agregar frase motivacional...',
                  hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
                  filled: true,
                  fillColor: MinimalColors.backgroundPrimary(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_motivationalQuotes.contains(value)) {
                    setState(() {
                      _motivationalQuotes.add(value);
                      _motivationalQuoteController.clear();
                      _hasChanges = true;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                final value = _motivationalQuoteController.text;
                if (value.isNotEmpty && !_motivationalQuotes.contains(value)) {
                  setState(() {
                    _motivationalQuotes.add(value);
                    _motivationalQuoteController.clear();
                    _hasChanges = true;
                  });
                }
              },
              icon: Icon(
                Icons.add,
                color: MinimalColors.primaryGradient(context)[0],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundPrimary(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurar recordatorios diarios',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los recordatorios te ayudarán a mantener el enfoque en tu objetivo.',
            style: TextStyle(
              fontSize: 12,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _reminderSettings.containsKey('enabled') ? _reminderSettings['enabled'] as bool : false,
                onChanged: (value) {
                  setState(() {
                    _reminderSettings['enabled'] = value;
                    if (value) {
                      _reminderSettings['time'] = '09:00';
                      _reminderSettings['message'] = '¡Es hora de trabajar en tu objetivo!';
                    }
                    _hasChanges = true;
                  });
                },
                activeColor: MinimalColors.primaryGradient(context)[0],
              ),
              const SizedBox(width: 8),
              Text(
                'Activar recordatorios',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleBackPressed,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: MinimalColors.textSecondary(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _hasChanges ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          color: _hasChanges ? Colors.white : Colors.white.withValues(alpha: 0.5),
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

  void _handleBackPressed() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: MinimalColors.backgroundCard(context),
          title: Text(
            'Cambios sin guardar',
            style: TextStyle(color: MinimalColors.textPrimary(context)),
          ),
          content: Text(
            '¿Estás seguro de que quieres salir sin guardar los cambios?',
            style: TextStyle(color: MinimalColors.textSecondary(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: MinimalColors.textSecondary(context)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Salir sin guardar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      // Create updated goal model
      final updatedGoal = widget.goal.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        targetValue: int.parse(_targetValueController.text),
        currentValue: int.parse(_currentValueController.text),
        estimatedDays: int.parse(_estimatedDaysController.text),
        progressNotes: _progressNotesController.text.isNotEmpty ? _progressNotesController.text : null,
        category: _selectedCategory,
        type: _selectedType,
        difficulty: _selectedDifficulty,
        priority: _selectedPriority,
        frequency: _selectedFrequency,
        visibility: _selectedVisibility,
        status: _selectedStatus,
        customUnit: _selectedCustomUnit ?? (_customUnitController.text.isNotEmpty ? _customUnitController.text : null),
        iconCode: _selectedIconCode,
        colorHex: _selectedColorHex ?? (_colorHexController.text.isNotEmpty ? _colorHexController.text : null),
        tags: _tags,
        customSettings: _customSettings,
        startDate: _startDate,
        endDate: _endDate,
        motivationalQuotes: _motivationalQuotes,
        reminderSettings: _reminderSettings,
        lastUpdated: DateTime.now(),
      );

      // Update through provider
      final goalsProvider = context.read<EnhancedGoalsProvider>();
      await goalsProvider.updateGoal(updatedGoal);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Objetivo actualizado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error actualizando objetivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper methods (same as creation screen)
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

  String _getDifficultyDisplayName(GoalDifficulty difficulty) {
    switch (difficulty) {
      case GoalDifficulty.easy: return 'Fácil';
      case GoalDifficulty.medium: return 'Medio';
      case GoalDifficulty.hard: return 'Difícil';
      case GoalDifficulty.expert: return 'Experto';
    }
  }

  String _getPriorityDisplayName(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.low: return 'Baja';
      case GoalPriority.medium: return 'Media';
      case GoalPriority.high: return 'Alta';
      case GoalPriority.urgent: return 'Urgente';
    }
  }

  String _getFrequencyDisplayName(GoalFrequency frequency) {
    switch (frequency) {
      case GoalFrequency.daily: return 'Diario';
      case GoalFrequency.weekly: return 'Semanal';
      case GoalFrequency.monthly: return 'Mensual';
      case GoalFrequency.custom: return 'Personalizado';
    }
  }

  String _getVisibilityDisplayName(GoalVisibility visibility) {
    switch (visibility) {
      case GoalVisibility.private: return 'Privado';
      case GoalVisibility.shared: return 'Compartido';
      case GoalVisibility.public: return 'Público';
    }
  }

  IconData _getVisibilityIcon(GoalVisibility visibility) {
    switch (visibility) {
      case GoalVisibility.private: return Icons.lock;
      case GoalVisibility.shared: return Icons.people;
      case GoalVisibility.public: return Icons.public;
    }
  }

  String _getStatusDisplayName(GoalStatus status) {
    switch (status) {
      case GoalStatus.active: return 'Activo';
      case GoalStatus.completed: return 'Completado';
      case GoalStatus.archived: return 'Archivado';
    }
  }

  IconData _getStatusIcon(GoalStatus status) {
    switch (status) {
      case GoalStatus.active: return Icons.play_circle;
      case GoalStatus.completed: return Icons.check_circle;
      case GoalStatus.archived: return Icons.archive;
    }
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active: return Colors.blue;
      case GoalStatus.completed: return Colors.green;
      case GoalStatus.archived: return Colors.grey;
    }
  }

  IconData _getIconData(String iconCode) {
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