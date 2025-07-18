// ============================================================================
// quick_moments_screen.dart - VERSIÓN MEJORADA CON ESTILO VISUAL UNIFICADO
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/image_moments_provider.dart';
import '../../providers/challenges_provider.dart';
import '../../providers/streak_provider.dart';


// Sistema de colores
import 'components/minimal_colors.dart';

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
  late AnimationController _glowController;
  late AnimationController _fadeController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;
  final int _totalSteps = 3;

  // Datos del momento
  File? _selectedImage;
  String _selectedEmoji = '';
  String _momentType = '';
  String _description = '';
  String _category = '';
  int _intensity = 5;
  String? _location;

  // Controladores
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.startWithCamera) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _takePicture());
    }
  }

  void _initializeControllers() {
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _pageController.dispose();
    _progressController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ============================================================================
  // NAVEGACIÓN ENTRE PASOS
  // ============================================================================

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _currentStep++;
      _updateProgress();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _updateProgress();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _updateProgress() {
    setState(() {});
    _progressController.animateTo((_currentStep + 1) / _totalSteps);
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedEmoji.isNotEmpty && _momentType.isNotEmpty;
      case 1:
        return _description.isNotEmpty;
      case 2:
        return true; // El paso de revisión siempre permite continuar
      default:
        return false;
    }
  }

  // ============================================================================
  // FUNCIONES DE IMAGEN
  // ============================================================================

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Error al tomar la foto: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar la imagen: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    HapticFeedback.lightImpact();
  }

  // ============================================================================
  // GUARDAR MOMENTO CON NAVEGACIÓN ARREGLADA
  // ============================================================================

  Future<void> _saveMoment() async {
    try {
      _showLoadingDialog();

      // Obtener todos los providers necesarios
      final momentsProvider = context.read<OptimizedMomentsProvider>();
      final imageProvider = context.read<ImageMomentsProvider>();
      final userId = context.read<OptimizedAuthProvider>().currentUser?.id;

      if (userId == null) {
        Navigator.pop(context); // Cerrar loading
        _showErrorSnackBar('Error: Usuario no identificado.');
        return;
      }

      // Guardar el momento
      final newMoment = await momentsProvider.addMoment(
        userId: userId,
        emoji: _selectedEmoji,
        text: _description.trim(),
        type: _momentType,
        intensity: _intensity,
        category: _category.isEmpty ? 'personal' : _category,
      );

      if (newMoment != null && newMoment.id != null) {
        // Guardar imagen si existe
        if (_selectedImage != null) {
          await imageProvider.saveImageForMoment(
            imageFile: _selectedImage!,
            momentId: newMoment.id!,
          );
        }

        // ✅ RECARGAR TODOS LOS DATOS DE LA HOME SCREEN
        if (mounted) {
          await _reloadData(context, userId);
          
          if (mounted) {
            Navigator.pop(context); // Cerrar loading
            HapticFeedback.heavyImpact();
            _showSuccessSnackBar('¡Momento guardado exitosamente!');

            // ✅ NAVEGACIÓN CORREGIDA - Regresar a la pantalla principal
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }

      } else {
        if (mounted) {
          Navigator.pop(context); // Cerrar loading
          _showErrorSnackBar('Error al guardar el momento');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        _showErrorSnackBar('Error inesperado: $e');
      }
    }
  }

  // ✅ NUEVO MÉTODO PARA RECARGAR DATOS
  Future<void> _reloadData(BuildContext context, int userId) async {
    // Usamos read para evitar escuchar cambios aquí, solo ejecutar la acción
    final momentsProvider = context.read<OptimizedMomentsProvider>();
    final dailyEntriesProvider = context.read<OptimizedDailyEntriesProvider>();
    final analyticsProvider = context.read<OptimizedAnalyticsProvider>();
    final goalsProvider = context.read<GoalsProvider>();
    final challengesProvider = context.read<ChallengesProvider>();
    final streakProvider = context.read<StreakProvider>();

    // Ejecutar todas las cargas en paralelo para mayor eficiencia
    await Future.wait([
      momentsProvider.loadTodayMoments(userId),
      dailyEntriesProvider.loadEntries(userId),
      analyticsProvider.loadCompleteAnalytics(userId),
      goalsProvider.loadUserGoals(userId),
      challengesProvider.loadChallenges(userId),
      streakProvider.loadStreakData(userId),
    ]);
  }

  // ============================================================================
  // UI PRINCIPAL CON DISEÑO MEJORADO
  // ============================================================================

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
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }

  // ============================================================================
  // APP BAR MODERNO
  // ============================================================================


  // ============================================================================
  // HEADER CON PASO ACTUAL
  // ============================================================================

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: MinimalColors.primaryGradient(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nuevo Momento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ============================================================================
  // INDICADOR DE PROGRESO MEJORADO
  // ============================================================================


  // ============================================================================
  // PASO 1: CAPTURA DEL MOMENTO MEJORADO
  // ============================================================================

  Widget _buildStep1() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildEnhancedPhotoSection(),
            const SizedBox(height: 20),
            _buildEnhancedEmojiSelector(),
            const SizedBox(height: 20),
            _buildEnhancedTypeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPhotoSection() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _selectedImage != null ? _buildSelectedImage() : _buildImagePicker(),
    );
  }

  Widget _buildSelectedImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _selectedImage!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Overlay con gradiente
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        // Botón de eliminar
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        // Botones de acción en la parte inferior
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.camera_alt,
                  label: 'Cambiar',
                  onTap: _takePicture,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.photo_library,
                  label: 'Galería',
                  onTap: _pickFromGallery,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.lightGradient(context).map((color) =>
                      color.withValues(alpha: 0.1 + (_glowController.value * 0.1))).toList(),
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.add_a_photo,
                size: 48,
                color: MinimalColors.textSecondary(context),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Agrega una foto (opcional)',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Captura el momento con una imagen',
          style: TextStyle(
            color: MinimalColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.camera_alt,
                label: 'Tomar foto',
                onTap: _takePicture,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.photo_library,
                label: 'Galería',
                onTap: _pickFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(colors: MinimalColors.accentGradient(context))
              : null,
          color: isPrimary ? null : MinimalColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : MinimalColors.textSecondary(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: MinimalColors.textPrimary(context),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SELECTOR DE EMOJI MEJORADO
  // ============================================================================

  Widget _buildEnhancedEmojiSelector() {
    const emojis = ['😊', '😔', '😮', '😡', '😌', '🤔', '😍', '😴', '🎉', '💪', '😰', '🙏'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo te sientes?',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundSecondary(context),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              final emoji = emojis[index];
              final isSelected = _selectedEmoji == emoji;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: MinimalColors.lightGradient(context))
                        : null,
                    color: isSelected ? null : MinimalColors.backgroundSecondary(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? MinimalColors.accentGradient(context)[0]
                          : MinimalColors.textSecondary(context).withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // SELECTOR DE TIPO MEJORADO
  // ============================================================================

  Widget _buildEnhancedTypeSelector() {
    final types = [
      {'label': 'Positivo', 'value': 'positive', 'color': const Color(0xFF10b981)},
      {'label': 'Neutral', 'value': 'neutral', 'color': const Color(0xFFf59e0b)},
      {'label': 'Negativo', 'value': 'negative', 'color': const Color(0xFFef4444)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de momento',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: types.map((type) {
            final isSelected = _momentType == type['value'];
            final color = type['color'] as Color;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _momentType = type['value'] as String;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : MinimalColors.textSecondary(context).withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    type['label'] as String,
                    style: TextStyle(
                      color: isSelected ? color : MinimalColors.textSecondary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================================
  // PASO 2: DESCRIPCIÓN MEJORADA
  // ============================================================================

  Widget _buildStep2() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildIntensitySlider(),
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildLocationField(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe tu momento',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cuéntanos qué pasó y cómo te hizo sentir',
          style: TextStyle(
            color: MinimalColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundSecondary(context),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
              width: 1,
            ),
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
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Ej: "Terminé mi proyecto y me siento orgulloso del resultado..."',
              hintStyle: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterStyle: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Intensidad',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_intensity/10',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundSecondary(context),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MinimalColors.accentGradient(context)[1],
              inactiveTrackColor: MinimalColors.backgroundSecondary(context),
              thumbColor: MinimalColors.accentGradient(context)[1],
              overlayColor: MinimalColors.accentGradient(context)[1].withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: _intensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _intensity = value.round();
                });
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      'Personal', 'Trabajo', 'Familia', 'Amigos', 'Salud', 'Creatividad'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _category == cat.toLowerCase();
            return GestureDetector(
              onTap: () {
                setState(() {
                  _category = cat.toLowerCase();
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.accentGradient(context))
                      : null,
                  color: isSelected ? null : MinimalColors.backgroundCard(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.textSecondary(context).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected
                        ? MinimalColors.textPrimary(context)
                        : MinimalColors.textSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
        Text(
          'Ubicación (opcional)',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundSecondary(context),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _locationController,
            onChanged: (value) {
              setState(() {
                _location = value;
              });
            },
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Ej: Casa, Oficina, Parque...',
              hintStyle: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: MinimalColors.textMuted(context),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // PASO 3: RESUMEN MEJORADO
  // ============================================================================

  Widget _buildStep3() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Resumen de tu momento',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen si existe
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Emoji y tipo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.lightGradient(context)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Momento $_momentType',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Intensidad: $_intensity/10',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Descripción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              _description.isEmpty ? 'Sin descripción' : _description,
              style: TextStyle(
                color: _description.isEmpty
                    ? MinimalColors.textMuted(context)
                    : MinimalColors.textPrimary(context),
                fontSize: 14,
                fontStyle: _description.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),

          // Metadatos adicionales
          if (_category.isNotEmpty || _location != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_category.isNotEmpty)
                  _buildMetadataChip(
                    icon: Icons.category_outlined,
                    label: _category,
                  ),
                if (_location != null && _location!.isNotEmpty)
                  _buildMetadataChip(
                    icon: Icons.location_on_outlined,
                    label: _location!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: MinimalColors.textMuted(context),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BOTONES DE ACCIÓN MEJORADOS
  // ============================================================================

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            MinimalColors.backgroundPrimary(context).withValues(alpha: 0.8),
            MinimalColors.backgroundPrimary(context),
          ],
        ),
      ),
      child: Row(
        children: [
          // Botón anterior
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: MinimalColors.textPrimary(context),
                  side: BorderSide(
                    color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Anterior',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Botón continuar/guardar
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: _canContinue()
                    ? LinearGradient(colors: MinimalColors.accentGradient(context))
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _canContinue()
                    ? [
                  BoxShadow(
                    color: MinimalColors.accentGradient(context)[1].withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: _canContinue()
                    ? (_currentStep == _totalSteps - 1 ? _saveMoment : _nextStep)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: MinimalColors.backgroundSecondary(context),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: MinimalColors.textMuted(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == _totalSteps - 1 ? 'Guardar momento' : 'Continuar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentStep == _totalSteps - 1
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: MinimalColors.primaryGradient(context),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Guardando momento...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFef4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10b981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}