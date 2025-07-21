// lib/presentation/screens/v2/advanced_goal_editing_screen.dart
// ============================================================================
// SIMPLIFIED & INTUITIVE GOAL EDITING SCREEN - 3 SECTION APPROACH
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
  late TextEditingController _durationController;
  late TextEditingController _customUnitController;

  // Form state
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  int _currentSection = 0;

  // Simplified goal configuration
  late GoalCategory _selectedCategory;
  late FrequencyType _selectedFrequency;
  late GoalStatus _selectedStatus;
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
    _initializeFromGoal();
    _setupAnimations();
    _setupChangeListeners();
  }

  void _initializeFromGoal() {
    final goal = widget.goal;
    
    // Initialize controllers
    _titleController = TextEditingController(text: goal.title);
    _descriptionController = TextEditingController(text: goal.description);
    _targetValueController = TextEditingController(text: goal.targetValue.toString());
    _currentValueController = TextEditingController(text: goal.currentValue.toString());
    _durationController = TextEditingController(text: goal.durationDays.toString());
    _customUnitController = TextEditingController(text: goal.customUnit ?? '');

    // Initialize simplified configuration
    _selectedCategory = goal.category;
    _selectedFrequency = goal.frequency;
    _selectedStatus = goal.status;
    _selectedCustomUnit = goal.customUnit;
    _selectedIconCode = goal.iconCode;
    _selectedColorHex = goal.colorHex;
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

  void _setupChangeListeners() {
    _titleController.addListener(_markAsChanged);
    _descriptionController.addListener(_markAsChanged);
    _targetValueController.addListener(_markAsChanged);
    _currentValueController.addListener(_markAsChanged);
    _durationController.addListener(_markAsChanged);
    _customUnitController.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
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
                _buildSectionTabs(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: MinimalColors.accentGradient(context)[0],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Modificado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.accentGradient(context)[0],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTabs(BuildContext context) {
    final sections = [
      {'title': 'Tu Objetivo', 'icon': Icons.flag},
      {'title': 'Seguimiento', 'icon': Icons.timeline},
      {'title': 'Personalización', 'icon': Icons.palette},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          final isSelected = _currentSection == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentSection = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  right: index < sections.length - 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: !isSelected ? MinimalColors.backgroundCard(context) : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.textMuted(context).withValues(alpha: 0.2),
                  ),
                  boxShadow: isSelected
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
                      section['icon'] as IconData,
                      color: isSelected 
                          ? MinimalColors.textPrimary(context) 
                          : MinimalColors.textSecondary(context),
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? MinimalColors.textPrimary(context) 
                            : MinimalColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
          child: _getCurrentSectionContent(),
        ),
      ),
    );
  }

  Widget _getCurrentSectionContent() {
    switch (_currentSection) {
      case 0:
        return _buildYourObjectiveSection();
      case 1:
        return _buildTrackingSection();
      case 2:
        return _buildPersonalizationSection();
      default:
        return _buildYourObjectiveSection();
    }
  }

  Widget _buildYourObjectiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
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

  Widget _buildTrackingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Seguimiento',
          'Configura cómo hacer seguimiento de tu progreso',
          Icons.timeline,
        ),
        const SizedBox(height: 24),
        
        // Current Progress
        _buildInputField(
          'Progreso Actual',
          _currentValueController,
          '0',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El progreso actual es obligatorio';
            }
            if (int.tryParse(value) == null || int.parse(value) < 0) {
              return 'Debe ser un número mayor o igual a 0';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        
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
        const SizedBox(height: 20),
        
        // Status Selection
        _buildStatusSelection(),
      ],
    );
  }

  Widget _buildPersonalizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
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
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
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
                  _markAsChanged();
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
              value: _selectedCustomUnit ?? widget.goal.suggestedUnit,
              isExpanded: true,
              style: TextStyle(color: MinimalColors.textPrimary(context)),
              dropdownColor: MinimalColors.backgroundCard(context),
              items: () {
                final currentValue = _selectedCustomUnit ?? widget.goal.suggestedUnit;
                final allUnits = <String>{..._commonUnits};
                if (currentValue != null && currentValue.isNotEmpty) {
                  allUnits.add(currentValue);
                }
                return allUnits.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList();
              }(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomUnit = value;
                  _customUnitController.text = value ?? '';
                  _markAsChanged();
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
                  _markAsChanged();
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

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
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
          children: GoalStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                  _markAsChanged();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _getStatusColor(status).withValues(alpha: 0.2)
                      : MinimalColors.backgroundCard(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _getStatusColor(status)
                        : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 16,
                      color: isSelected 
                          ? _getStatusColor(status)
                          : MinimalColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusDisplayName(status),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? _getStatusColor(status)
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
                  _markAsChanged();
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
                  _markAsChanged();
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
                    ? Icon(Icons.check, color: MinimalColors.textPrimary(context), size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
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
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGoal,
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
                    :  Text(
                        'Guardar Cambios',
                        style: TextStyle(
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

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final goalsProvider = context.read<EnhancedGoalsProvider>();

      final updatedGoal = widget.goal.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        targetValue: int.parse(_targetValueController.text),
        currentValue: int.parse(_currentValueController.text),
        durationDays: int.parse(_durationController.text),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        status: _selectedStatus,
        customUnit: _customUnitController.text.trim().isEmpty 
            ? null 
            : _customUnitController.text.trim(),
        iconCode: _selectedIconCode,
        colorHex: _selectedColorHex,
        lastUpdated: DateTime.now(),
      );

      await goalsProvider.updateGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objetivo actualizado exitosamente'),
            backgroundColor: MinimalColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar objetivo: $e'),
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

  String _getFrequencyDisplayName(FrequencyType frequency) {
    switch (frequency) {
      case FrequencyType.daily: return 'Diario';
      case FrequencyType.weekly: return 'Semanal';
      case FrequencyType.monthly: return 'Mensual';
      case FrequencyType.custom: return 'Personalizado';
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
      case GoalStatus.active: return Icons.play_arrow;
      case GoalStatus.completed: return Icons.check_circle;
      case GoalStatus.archived: return Icons.archive;
    }
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active: return const Color(0xFF3B82F6);
      case GoalStatus.completed: return const Color(0xFF10B981);
      case GoalStatus.archived: return const Color(0xFF6B7280);
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