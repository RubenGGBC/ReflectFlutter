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
import '../../providers/image_moments_provider.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// Pantalla de Destino
import 'home_screen_v2.dart';

// ============================================================================
// 🎨 PALETA DE COLORES (BASADA EN GOALSCOLORS)
// ============================================================================
class QuickMomentsColors {
  static const Color backgroundPrimary = Color(0xFF000000);
  static const Color backgroundCard = Color(0xFF0F0F0F);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  static const List<Color> primaryGradient = [
    Color(0xFF1e3a8a), // Azul oscuro
    Color(0xFF581c87), // Morado oscuro
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6), // Azul
    Color(0xFF8b5cf6), // Morado
  ];

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF666666);

  static const Color positive = Color(0xFF10b981);
  static const Color neutral = Color(0xFFf59e0b);
  static const Color negative = Color(0xFFef4444);
}


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
      _showLoadingDialog();

      final newMoment = await momentsProvider.addMoment(
        userId: authProvider.currentUser!.id,
        emoji: _selectedEmoji,
        text: _description.trim(),
        type: _momentType,
        intensity: _intensity,
        category: _category,
        contextLocation: _location.trim().isEmpty ? null : _location.trim(),
      );

      if (newMoment != null && newMoment.id != null) {
        if (_selectedImage != null) {
          await imageProvider.saveImageForMoment(
            imageFile: _selectedImage!,
            momentId: newMoment.id!,
          );
        }

        Navigator.pop(context); // Cerrar loading

        HapticFeedback.heavyImpact();
        _showSuccessSnackBar('¡Momento guardado exitosamente!');

        // NAVEGACIÓN A HOME SCREEN V2
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreenV2()),
              (Route<dynamic> route) => false,
        );

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
      builder: (context) => Dialog(
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
        backgroundColor: QuickMomentsColors.negative,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: QuickMomentsColors.positive,
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
      backgroundColor: QuickMomentsColors.backgroundPrimary,
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
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                    _updateProgress();
                  },
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
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
                icon: const Icon(Icons.close, color: QuickMomentsColors.textPrimary),
              ),
              Expanded(
                child: Text(
                  _stepTitles[_currentStep],
                  style: const TextStyle(
                    color: QuickMomentsColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Paso ${_currentStep + 1} de $_totalSteps',
            style: const TextStyle(
              color: QuickMomentsColors.textSecondary,
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: QuickMomentsColors.backgroundSecondary,
            ),
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
          _buildPhotoSection(),
          const SizedBox(height: 30),
          _buildEmojiSelector(),
          const SizedBox(height: 30),
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
        color: QuickMomentsColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QuickMomentsColors.textTertiary.withOpacity(0.2)),
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
          color: QuickMomentsColors.textSecondary,
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Añade una foto (opcional)',
          style: TextStyle(
            color: QuickMomentsColors.textSecondary,
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
          color: QuickMomentsColors.accentGradient[0].withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: QuickMomentsColors.accentGradient[0].withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: QuickMomentsColors.accentGradient[0], size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: QuickMomentsColors.accentGradient[0],
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
            color: QuickMomentsColors.textPrimary,
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
                      ? QuickMomentsColors.accentGradient[0].withOpacity(0.3)
                      : QuickMomentsColors.backgroundCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? QuickMomentsColors.accentGradient[0] : Colors.transparent,
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
            color: QuickMomentsColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeOption('positive', '😊 Positivo', QuickMomentsColors.positive),
            const SizedBox(width: 12),
            _buildTypeOption('neutral', '😐 Neutral', QuickMomentsColors.neutral),
            const SizedBox(width: 12),
            _buildTypeOption('negative', '😔 Negativo', QuickMomentsColors.negative),
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
                : QuickMomentsColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : QuickMomentsColors.textSecondary,
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
              color: QuickMomentsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuéntanos qué pasó y cómo te hizo sentir',
            style: TextStyle(
              color: QuickMomentsColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            onChanged: (value) {
              setState(() {
                _description = value;
              });
            },
            maxLines: 4,
            maxLength: 200,
            style: const TextStyle(color: QuickMomentsColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ej: "Terminé mi proyecto más rápido de lo esperado y me siento muy orgulloso del resultado..."',
              hintStyle: const TextStyle(color: QuickMomentsColors.textTertiary),
              filled: true,
              fillColor: QuickMomentsColors.backgroundCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: QuickMomentsColors.accentGradient[1]),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 30),
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
            color: QuickMomentsColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Leve',
              style: TextStyle(color: QuickMomentsColors.textSecondary, fontSize: 12),
            ),
            Expanded(
              child: Slider(
                value: _intensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: QuickMomentsColors.accentGradient[0],
                inactiveColor: QuickMomentsColors.backgroundSecondary,
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
              style: TextStyle(color: QuickMomentsColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: QuickMomentsColors.accentGradient[0].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_intensity/10',
              style: TextStyle(
                color: QuickMomentsColors.accentGradient[0],
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
          _buildCategorySelector(),
          const SizedBox(height: 30),
          _buildLocationField(),
          const SizedBox(height: 30),
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
            color: QuickMomentsColors.textPrimary,
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
                      ? QuickMomentsColors.accentGradient[0].withOpacity(0.3)
                      : QuickMomentsColors.backgroundCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? QuickMomentsColors.accentGradient[0] : QuickMomentsColors.textTertiary.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
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
                        color: isSelected ? QuickMomentsColors.accentGradient[0] : QuickMomentsColors.textSecondary,
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
            color: QuickMomentsColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          onChanged: (value) {
            setState(() {
              _location = value;
            });
          },
          style: const TextStyle(color: QuickMomentsColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej: En casa, en la oficina, en el parque...',
            hintStyle: const TextStyle(color: QuickMomentsColors.textTertiary),
            prefixIcon: const Icon(Icons.location_on_outlined, color: QuickMomentsColors.textTertiary),
            filled: true,
            fillColor: QuickMomentsColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: QuickMomentsColors.accentGradient[1]),
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
        color: QuickMomentsColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: QuickMomentsColors.accentGradient[0].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de tu momento',
            style: TextStyle(
              color: QuickMomentsColors.textPrimary,
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
                    color: _description.isEmpty ? QuickMomentsColors.textSecondary : QuickMomentsColors.textPrimary,
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
              color: QuickMomentsColors.textSecondary,
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
                  foregroundColor: QuickMomentsColors.textPrimary,
                  side: const BorderSide(color: QuickMomentsColors.textTertiary),
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
                backgroundColor: QuickMomentsColors.accentGradient[1],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: QuickMomentsColors.accentGradient[1].withOpacity(0.5),
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
