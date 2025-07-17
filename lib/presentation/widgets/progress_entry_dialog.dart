// lib/presentation/widgets/progress_entry_dialog.dart
// ============================================================================
// PROGRESS ENTRY DIALOG - MULTI-METRIC INPUT
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/models/goal_model.dart';
import '../../data/services/image_picker_service.dart';
import '../../injection_container_clean.dart' as clean_di;
import '../screens/v2/components/minimal_colors.dart';

class ProgressEntryDialog extends StatefulWidget {
  final GoalModel goal;
  final Function(ProgressEntry) onEntryCreated;

  const ProgressEntryDialog({
    super.key,
    required this.goal,
    required this.onEntryCreated,
  });

  @override
  State<ProgressEntryDialog> createState() => _ProgressEntryDialogState();
}

class _ProgressEntryDialogState extends State<ProgressEntryDialog>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  // Form controllers
  final _primaryValueController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Metrics
  int _qualityRating = 3;
  int _moodBefore = 3;
  int _moodAfter = 3;
  int _energyLevel = 3;
  int _stressLevel = 3;
  int _difficultyRating = 3;
  
  // Photos and tags
  final List<String> _photoUrls = [];
  final List<String> _tags = [];
  final List<String> _availableTags = [
    'motivado', 'cansado', 'feliz', 'estresado', 'energético',
    'tranquilo', 'productivo', 'relajado', 'ansioso', 'confiado'
  ];
  
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _primaryValueController.text = widget.goal.currentValue.toString();
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
    _primaryValueController.dispose();
    _notesController.dispose();
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
          constraints: const BoxConstraints(maxHeight: 600),
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
                      'Actualizar Progreso',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.goal.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
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
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.3),
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
        return _buildMetricsStep();
      case 2:
        return _buildExtrasStep();
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
        
        // Primary value input
        Text(
          'Nuevo Valor (${widget.goal.suggestedUnit})',
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
            controller: _primaryValueController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: MinimalColors.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Ingresa el nuevo valor',
              hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
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
        
        const SizedBox(height: 24),
        
        // Notes input
        Text(
          'Notas (Opcional)',
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
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(color: MinimalColors.textPrimary(context)),
            decoration: InputDecoration(
              hintText: '¿Cómo te sentiste? ¿Qué aprendiste?',
              hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
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

  Widget _buildMetricsStep() {
    return Column(
      key: const ValueKey('metrics'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas de Calidad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 24),
        
        _buildRatingSlider(
          'Calidad de la Sesión',
          _qualityRating,
          (value) => setState(() => _qualityRating = value),
          ['Malo', 'Regular', 'Bueno', 'Muy Bueno', 'Excelente'],
        ),
        
        _buildRatingSlider(
          'Humor Antes',
          _moodBefore,
          (value) => setState(() => _moodBefore = value),
          ['😢', '😕', '😐', '🙂', '😊'],
        ),
        
        _buildRatingSlider(
          'Humor Después',
          _moodAfter,
          (value) => setState(() => _moodAfter = value),
          ['😢', '😕', '😐', '🙂', '😊'],
        ),
        
        _buildRatingSlider(
          'Nivel de Energía',
          _energyLevel,
          (value) => setState(() => _energyLevel = value),
          ['Muy Bajo', 'Bajo', 'Normal', 'Alto', 'Muy Alto'],
        ),
        
        _buildRatingSlider(
          'Nivel de Estrés',
          _stressLevel,
          (value) => setState(() => _stressLevel = value),
          ['Muy Bajo', 'Bajo', 'Normal', 'Alto', 'Muy Alto'],
        ),
      ],
    );
  }

  Widget _buildExtrasStep() {
    return Column(
      key: const ValueKey('extras'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extras',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 24),
        
        // Photo section
        _buildPhotoSection(context),
        
        const SizedBox(height: 24),
        
        // Tags section
        _buildTagsSection(context),
      ],
    );
  }

  Widget _buildRatingSlider(
    String label,
    int value,
    Function(int) onChanged,
    List<String> labels,
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: MinimalColors.primaryGradient(context)[0],
                inactiveColor: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                onChanged: (newValue) => onChanged(newValue.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels.map((label) => Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: MinimalColors.textSecondary(context),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Fotos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('Agregar'),
              style: TextButton.styleFrom(
                foregroundColor: MinimalColors.primaryGradient(context)[0],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photoUrls.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_photoUrls[index]),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No hay fotos agregadas',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas de Estado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
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
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentStep == 2 ? 'Guardar' : 'Siguiente',
                        style: const TextStyle(
                          color: Colors.white,
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

  Future<void> _addPhoto() async {
    try {
      final imageService = clean_di.sl<ImagePickerService>();
      final imagePath = await imageService.pickFromGallery();
      if (imagePath != null) {
        setState(() {
          _photoUrls.add(imagePath);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error agregando foto: $e')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  void _handleNextOrSubmit() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitEntry();
    }
  }

  void _submitEntry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final primaryValue = int.tryParse(_primaryValueController.text) ?? widget.goal.currentValue;
      
      final entry = ProgressEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: widget.goal.id.toString(),
        timestamp: DateTime.now(),
        primaryValue: primaryValue,
        metrics: {
          'quality': _qualityRating,
          'mood_before': _moodBefore,
          'mood_after': _moodAfter,
          'energy_level': _energyLevel,
          'stress_level': _stressLevel,
          'difficulty': _difficultyRating,
        },
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        photoUrls: _photoUrls,
        tags: _tags,
      );

      widget.onEntryCreated(entry);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando entrada: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}