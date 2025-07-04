// ============================================================================
// quick_moments_screen.dart - CAPTURA RÁPIDA DE MOMENTOS CON FLUJO GUIADO
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/image_moments_provider.dart'; // <-- AÑADIDO: Provider de imágenes

// Modelos
import '../../../data/models/optimized_models.dart';

class QuickMomentsScreen extends StatefulWidget {
  final bool startWithCamera;

  const QuickMomentsScreen({
    super.key,
    this.startWithCamera = false,
  });

  @override
  State<QuickMomentsScreen> createState() => _QuickMomentsScreenState();
}

class _QuickMomentsScreenState extends State<QuickMomentsScreen>
    with TickerProviderStateMixin {

  // ============================================================================
  // ESTADO Y CONTROLADORES
  // ============================================================================

  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _slideController;

  int _currentStep = 0;
  final int _totalSteps = 3;

  // Datos del momento
  File? _selectedImage;
  String _selectedEmoji = '✨';
  String _momentType = 'positive';
  String _description = '';
  int _intensity = 5;
  String _category = 'personal';
  String _location = '';

  // Controladores de texto
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Picker de imágenes
  final ImagePicker _imagePicker = ImagePicker();

  // Configuración de pasos
  final List<String> _stepTitles = [
    'Captura el momento',
    'Describe tu experiencia',
    'Añade contexto'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController.forward();
    _updateProgress();

    // Si se debe empezar con la cámara
    if (widget.startWithCamera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _takePhoto();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ============================================================================
  // LÓGICA DE NAVEGACIÓN
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
        return _selectedEmoji.isNotEmpty;
      case 1:
        return _description.trim().isNotEmpty;
      case 2:
        return _category.isNotEmpty;
      default:
        return false;
    }
  }

  // ============================================================================
  // LÓGICA DE CÁMARA Y GALERÍA
  // ============================================================================

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Error al tomar la foto');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar la imagen');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    HapticFeedback.lightImpact();
  }

  // ============================================================================
  // LÓGICA DE GUARDADO
  // ============================================================================

  Future<void> _saveMoment() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final momentsProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);
    final imageProvider = Provider.of<ImageMomentsProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      _showErrorSnackBar('Error: usuario no autenticado');
      return;
    }

    try {
      // Mostrar loading
      _showLoadingDialog();

      // NOTA: Se asume que `addMoment` ahora devuelve el momento creado (OptimizedInteractiveMomentModel?)
      // en lugar de un booleano, para poder obtener el ID del nuevo momento.
      final newMoment = await momentsProvider.addMoment(
        userId: authProvider.currentUser!.id,
        emoji: _selectedEmoji,
        text: _description.trim(),
        type: _momentType,
        intensity: _intensity,
        category: _category,
        contextLocation: _location.trim().isEmpty ? null : _location.trim(),
      );

      // Si el momento se creó correctamente
      if (newMoment != null && newMoment.id != null) {
        // Y si hay una imagen seleccionada, la guardamos
        if (_selectedImage != null) {
          await imageProvider.saveImageForMoment(
            imageFile: _selectedImage!,
            momentId: newMoment.id!,
          );
        }

        Navigator.pop(context); // Cerrar loading

        // FIX: El método correcto es heavyImpact() o mediumImpact().
        HapticFeedback.heavyImpact();
        Navigator.pop(context, true); // Volver con éxito
        _showSuccessSnackBar('¡Momento guardado exitosamente!');

      } else {
        Navigator.pop(context); // Cerrar loading
        _showErrorSnackBar('Error al guardar el momento');
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      _showErrorSnackBar('Error inesperado al guardar: $e');
    }
  }

  // ============================================================================
  // UI HELPERS
  // ============================================================================

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic)),
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // Desactivar swipe
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                    _updateProgress();
                  },
                  children: [
                    _buildStep1(), // Captura del momento
                    _buildStep2(), // Descripción
                    _buildStep3(), // Contexto
                  ],
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER Y PROGRESO
  // ============================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  _stepTitles[_currentStep],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Spacer para centrar
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${_currentStep + 1} de $_totalSteps',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 4,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressController.value,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            borderRadius: BorderRadius.circular(2),
          );
        },
      ),
    );
  }

  // ============================================================================
  // PASO 1: CAPTURA DEL MOMENTO
  // ============================================================================

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Área de foto
          _buildPhotoSection(),

          const SizedBox(height: 30),

          // Selector de emoji
          _buildEmojiSelector(),

          const SizedBox(height: 30),

          // Selector de tipo
          _buildTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: _selectedImage != null
          ? _buildSelectedImage()
          : _buildPhotoPlaceholder(),
    );
  }

  Widget _buildSelectedImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.camera_alt_outlined,
          color: Colors.white54,
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Añade una foto (opcional)',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPhotoButton(
              icon: Icons.camera_alt,
              label: 'Cámara',
              onTap: _takePhoto,
            ),
            const SizedBox(width: 16),
            _buildPhotoButton(
              icon: Icons.photo_library,
              label: 'Galería',
              onTap: _pickFromGallery,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiSelector() {
    final emojis = ['😊', '😢', '😡', '😴', '🤔', '😍', '😰', '🎉', '✨', '💪'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elige un emoji representativo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emojis.map((emoji) {
            final isSelected = _selectedEmoji == emoji;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEmoji = emoji;
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cómo te sientes?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeOption('positive', '😊 Positivo', Colors.green),
            const SizedBox(width: 12),
            _buildTypeOption('neutral', '😐 Neutral', Colors.orange),
            const SizedBox(width: 12),
            _buildTypeOption('negative', '😔 Negativo', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(String type, String label, Color color) {
    final isSelected = _momentType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _momentType = type;
          });
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.3)
                : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // PASO 2: DESCRIPCIÓN
  // ============================================================================

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          const Text(
            'Describe tu momento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Cuéntanos qué pasó y cómo te hizo sentir',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          // Campo de descripción
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _descriptionController,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
              maxLines: 4,
              maxLength: 200,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ej: "Terminé mi proyecto más rápido de lo esperado y me siento muy orgulloso del resultado..."',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                counterText: '',
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Selector de intensidad
          _buildIntensitySelector(),
        ],
      ),
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Intensidad de la experiencia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            const Text(
              'Leve',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Expanded(
              child: Slider(
                value: _intensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.blue,
                inactiveColor: Colors.white24,
                onChanged: (value) {
                  setState(() {
                    _intensity = value.round();
                  });
                },
                onChangeEnd: (_) {
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            const Text(
              'Intensa',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_intensity/10',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // PASO 3: CONTEXTO
  // ============================================================================

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Selector de categoría
          _buildCategorySelector(),

          const SizedBox(height: 30),

          // Campo de ubicación
          _buildLocationField(),

          const SizedBox(height: 30),

          // Resumen del momento
          _buildMomentSummary(),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = {
      'personal': {'icon': '👤', 'name': 'Personal'},
      'trabajo': {'icon': '💼', 'name': 'Trabajo'},
      'familia': {'icon': '👨‍👩‍👧‍👦', 'name': 'Familia'},
      'amigos': {'icon': '👥', 'name': 'Amigos'},
      'salud': {'icon': '💪', 'name': 'Salud'},
      'hobby': {'icon': '🎨', 'name': 'Hobby'},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría del momento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.entries.map((entry) {
            final isSelected = _category == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _category = entry.key;
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.value['icon']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.value['name']!,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación (opcional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _locationController,
            onChanged: (value) {
              setState(() {
                _location = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ej: En casa, en la oficina, en el parque...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(Icons.location_on, color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMomentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de tu momento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _selectedEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _description.isEmpty ? 'Sin descripción' : _description,
                  style: TextStyle(
                    color: _description.isEmpty ? Colors.white54 : Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tipo: $_momentType • Intensidad: $_intensity/10 • Categoría: $_category',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ACCIONES INFERIORES
  // ============================================================================

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Anterior'),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 12),

          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _canContinue()
                  ? (_currentStep == _totalSteps - 1 ? _saveMoment : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.blue.withOpacity(0.5),
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Guardar momento' : 'Continuar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
