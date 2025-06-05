// ============================================================================
// presentation/screens/interactive_moments_screen.dart - VERSIÓN CORREGIDA COMPLETA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/interactive_moments_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/mood_slider.dart';
import '../../data/services/database_service.dart';

enum InteractiveMode {
  quick,
  mood,
  timeline,
  templates,
  voice,
  smart,
}

class InteractiveMomentsScreen extends StatefulWidget {
  const InteractiveMomentsScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveMomentsScreen> createState() => _InteractiveMomentsScreenState();
}

class _InteractiveMomentsScreenState extends State<InteractiveMomentsScreen>
    with TickerProviderStateMixin {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  InteractiveMode _activeMode = InteractiveMode.quick;
  final PageController _pageController = PageController();

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  // Controllers para diferentes modos
  final _quickTextController = TextEditingController();
  final _timelineTextController = TextEditingController();
  final _voiceTextController = TextEditingController();

  // Estado del mood mode
  double _currentIntensity = 5.0;

  // Estado del timeline mode
  int _selectedHour = DateTime.now().hour;

  // Estado del voice mode
  bool _isListening = false;
  bool _isProcessingVoice = false;

  // Estado del smart mode
  String _selectedCategory = 'work';
  List<String> _favoriteEmojis = ['😊', '💪', '🎯', '☕'];

  // Estadísticas del usuario
  Map<String, dynamic> _userStats = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserMoments();
    _loadUserStats();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotationController,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    _quickTextController.dispose();
    _timelineTextController.dispose();
    _voiceTextController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadUserMoments() {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser != null) {
      momentsProvider.loadTodayMoments(authProvider.currentUser!.id!);
    }
  }

  // ✅ CORREGIDO: Cargar estadísticas reales
  Future<void> _loadUserStats() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    try {
      _userStats = await _databaseService.getUserComprehensiveStatistics(
          authProvider.currentUser!.id!
      );

      if (mounted) {
        setState(() {}); // Actualizar UI
      }

      _logger.d('📊 Estadísticas cargadas: ${_userStats['streak_days']} días de racha');
    } catch (e) {
      _logger.e('Error cargando estadísticas: $e');
      _userStats = {
        'streak_days': 0,
        'best_mood_score': 5,
        'total_entries': 0,
        'positive_count': 0,
        'negative_count': 0,
      };
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: Column(
        children: [
          _buildEnhancedHeader(context, themeProvider, authProvider),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _activeMode = InteractiveMode.values[index];
                });
              },
              children: [
                _buildQuickModePage(themeProvider),
                _buildMoodModePage(themeProvider),
                _buildTimelineModePage(themeProvider),
                _buildTemplatesModePage(themeProvider),
                _buildVoiceModePage(themeProvider),
                _buildSmartModePage(themeProvider),
              ],
            ),
          ),
          _buildEnhancedBottomBar(themeProvider),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ThemeProvider themeProvider, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.currentColors.accentPrimary,
            themeProvider.currentColors.accentSecondary,
            themeProvider.currentColors.positiveMain.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.accentPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Botón volver con efecto glassmorphism
                  _buildGlassButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pushReplacementNamed('/calendar'),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        // Título con animación shimmer
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.centerLeft + Alignment(_shimmerAnimation.value, 0),
                                  end: Alignment.centerRight + Alignment(_shimmerAnimation.value, 0),
                                  colors: const [
                                    Colors.white70,
                                    Colors.white,
                                    Colors.white70,
                                  ],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                '✨ Momentos Zen ✨',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),

                        // Nombre del usuario con glow effect
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            '👋 ${authProvider.currentUser!.name}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botones de acción
                  Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.palette,
                        label: 'Temas',
                        onTap: () => Navigator.of(context).pushNamed('/theme_selector'),
                      ),
                      const SizedBox(width: 8),
                      _buildGlassButton(
                        icon: Icons.calendar_today,
                        label: 'Cal',
                        onTap: () => Navigator.of(context).pushReplacementNamed('/calendar'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Estadísticas en tiempo real con animaciones
              _buildRealTimeStats(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (label != null) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeStats(ThemeProvider themeProvider) {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, momentsProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBubble(
                '😊',
                momentsProvider.positiveCount.toString(),
                'Positivos',
                themeProvider.currentColors.positiveMain,
              ),
              _buildStatBubble(
                '😓',
                momentsProvider.negativeCount.toString(),
                'Difíciles',
                themeProvider.currentColors.negativeMain,
              ),
              _buildStatBubble(
                '🎯',
                momentsProvider.totalCount.toString(),
                'Total',
                Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBubble(String emoji, String value, String label, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: value != '0' ? _pulseAnimation.value : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickModePage(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Input con efecto glass
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '⚡ Modo Rápido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _quickTextController,
                  label: '¿Qué está pasando?',
                  hint: 'Describe tu momento...',
                ),
                const SizedBox(height: 16),
                _buildQuickPhrases(themeProvider),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Emojis mejorados con categorías
          _buildEnhancedEmojiSection('positive', themeProvider),
          const SizedBox(height: 12),
          _buildEnhancedEmojiSection('negative', themeProvider),

          const SizedBox(height: 16),

          // Favoritos
          _buildFavoritesSection(themeProvider),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    final themeProvider = context.read<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.currentColors.surface.withOpacity(0.7),
            themeProvider.currentColors.surfaceVariant.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeProvider.currentColors.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.shadowColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuickPhrases(ThemeProvider themeProvider) {
    final phrases = [
      '🎉 Me siento increíble hoy',
      '💪 Superé mis límites',
      '☕ Momento perfecto de café',
      '😰 Día muy estresante',
      '😤 Situación frustrante',
      '😴 Agotado mentalmente',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💭 Frases rápidas:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: themeProvider.currentColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: phrases.map((phrase) {
            return GestureDetector(
              onTap: () => _quickTextController.text = phrase,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.currentColors.accentPrimary.withOpacity(0.2),
                      themeProvider.currentColors.accentSecondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: themeProvider.currentColors.borderColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  phrase,
                  style: TextStyle(
                    fontSize: 11,
                    color: themeProvider.currentColors.textPrimary,
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

  Widget _buildEnhancedEmojiSection(String type, ThemeProvider themeProvider) {
    // Emojis expandidos por categoría
    final positiveEmojis = {
      'Felicidad': ['😊', '😄', '🤗', '😁', '🥳', '🤩', '😍', '🥰'],
      'Logros': ['🎉', '🏆', '🎯', '💪', '✨', '🌟', '🔥', '⭐'],
      'Tranquilidad': ['😌', '🧘‍♀️', '🕯️', '🌸', '🌿', '☕', '🍵', '🌅'],
      'Amor': ['❤️', '💕', '💖', '💝', '🥰', '😘', '💞', '💓'],
      'Diversión': ['🎵', '🎸', '🎨', '🎭', '🎪', '🎮', '🎲', '🎊'],
    };

    final negativeEmojis = {
      'Estrés': ['😰', '😓', '🤯', '😵', '😮‍💨', '😤', '⚡', '🌧️'],
      'Tristeza': ['😔', '😞', '😿', '💔', '😢', '😭', '😪', '🌧️'],
      'Enojo': ['😤', '😠', '🤬', '👿', '💢', '🔥', '⚡', '💥'],
      'Ansiedad': ['😰', '😨', '😱', '🤐', '😬', '🫨', '😵‍💫', '⛈️'],
      'Cansancio': ['😴', '😪', '🥱', '😵', '🤒', '😷', '🤧', '💤'],
    };

    final emojis = type == 'positive' ? positiveEmojis : negativeEmojis;
    final color = type == 'positive'
        ? themeProvider.currentColors.positiveMain
        : themeProvider.currentColors.negativeMain;

    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == 'positive' ? Icons.sunny : Icons.cloud,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                type == 'positive' ? '✨ Momentos Positivos' : '🌧️ Momentos Difíciles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...emojis.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.value.map((emoji) {
                    return GestureDetector(
                      onTap: () => _addQuickMoment(emoji, type, 'quick'), // ✅ CORREGIDO
                      child: _buildAnimatedEmojiButton(emoji, color),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ CORREGIDO: Añadir funcionalidad de tap
  Widget _buildAnimatedEmojiButton(String emoji, Color color) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesSection(ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: themeProvider.currentColors.positiveMain,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '💫 Favoritos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _favoriteEmojis.map((emoji) {
              return GestureDetector(
                onTap: () => _addFavoriteMoment(emoji), // ✅ CORREGIDO
                child: _buildAnimatedEmojiButton(
                  emoji,
                  themeProvider.currentColors.accentPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodModePage(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '🎭 Modo Intensidad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEnhancedMoodSlider(themeProvider),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildMoodRing(themeProvider),

          const SizedBox(height: 16),

          _buildAdvancedMoodBubbles(themeProvider),
        ],
      ),
    );
  }

  Widget _buildEnhancedMoodSlider(ThemeProvider themeProvider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                themeProvider.getMoodColor(_currentIntensity).withOpacity(0.3),
                themeProvider.getMoodColor(_currentIntensity).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                '🎚️ Intensidad del momento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Slider personalizado con gradiente
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                  activeTrackColor: themeProvider.getMoodColor(_currentIntensity),
                  inactiveTrackColor: themeProvider.currentColors.borderColor,
                  thumbColor: themeProvider.getMoodColor(_currentIntensity),
                  overlayColor: themeProvider.getMoodColor(_currentIntensity).withOpacity(0.2),
                ),
                child: Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _currentIntensity,
                  onChanged: (value) => setState(() => _currentIntensity = value),
                ),
              ),

              const SizedBox(height: 16),

              // Display del valor con animación
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: themeProvider.getMoodColor(_currentIntensity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeProvider.getMoodColor(_currentIntensity),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${_currentIntensity.round()}/10 - ${themeProvider.getMoodLabel(_currentIntensity)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.getMoodColor(_currentIntensity),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodRing(ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        children: [
          Text(
            '🔮 Anillo del Estado de Ánimo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        themeProvider.currentColors.negativeMain,
                        Colors.orange,
                        themeProvider.currentColors.positiveMain,
                        themeProvider.currentColors.accentPrimary,
                        themeProvider.currentColors.negativeMain,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.getMoodColor(_currentIntensity).withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeProvider.currentColors.surface,
                    ),
                    child: Center(
                      child: Text(
                        _getMoodEmoji(_currentIntensity),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedMoodBubbles(ThemeProvider themeProvider) {
    final moodCategories = {
      'Energía Alta': [
        {'emoji': '🚀', 'text': 'Súper energético', 'type': 'positive', 'intensity': 9},
        {'emoji': '⚡', 'text': 'Lleno de energía', 'type': 'positive', 'intensity': 8},
        {'emoji': '🔥', 'text': 'En llamas', 'type': 'positive', 'intensity': 7},
      ],
      'Tranquilidad': [
        {'emoji': '😌', 'text': 'Muy relajado', 'type': 'positive', 'intensity': 6},
        {'emoji': '🧘‍♀️', 'text': 'Zen total', 'type': 'positive', 'intensity': 5},
        {'emoji': '🌸', 'text': 'En paz', 'type': 'positive', 'intensity': 5},
      ],
      'Desafíos': [
        {'emoji': '😰', 'text': 'Algo estresado', 'type': 'negative', 'intensity': 4},
        {'emoji': '😞', 'text': 'Bajón emocional', 'type': 'negative', 'intensity': 3},
        {'emoji': '😵', 'text': 'Abrumado', 'type': 'negative', 'intensity': 2},
      ],
    };

    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🫧 Estados de Ánimo Detallados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          ...moodCategories.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.value.map((mood) {
                    return _buildMoodBubble(mood, themeProvider);
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMoodBubble(Map<String, dynamic> mood, ThemeProvider themeProvider) {
    final isPositive = mood['type'] == 'positive';
    final color = isPositive
        ? themeProvider.currentColors.positiveMain
        : themeProvider.currentColors.negativeMain;

    return GestureDetector(
      onTap: () => _createMoodMoment(mood),
      child: Container(
        width: 100,
        height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood['emoji'], style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              mood['text'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: themeProvider.currentColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineModePage(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '⏰ Línea Temporal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEnhancedTimeSelector(themeProvider),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildTimelineVisualization(themeProvider),

          const SizedBox(height: 16),

          _buildTimelineForm(themeProvider),
        ],
      ),
    );
  }

  Widget _buildEnhancedTimeSelector(ThemeProvider themeProvider) {
    final currentHour = DateTime.now().hour;
    final hours = List.generate(24, (index) => index);

    return Column(
      children: [
        Text(
          'Selecciona la hora del momento',
          style: TextStyle(
            fontSize: 14,
            color: themeProvider.currentColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            itemBuilder: (context, index) {
              final hour = hours[index];
              final isSelected = hour == _selectedHour;
              final isCurrent = hour == currentHour;

              return GestureDetector(
                onTap: () => setState(() => _selectedHour = hour),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isSelected
                          ? [
                        themeProvider.currentColors.accentPrimary,
                        themeProvider.currentColors.accentSecondary,
                      ]
                          : isCurrent
                          ? [
                        themeProvider.currentColors.positiveMain.withOpacity(0.3),
                        themeProvider.currentColors.positiveMain.withOpacity(0.1),
                      ]
                          : [
                        themeProvider.currentColors.surface,
                        themeProvider.currentColors.surfaceVariant,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? themeProvider.currentColors.accentPrimary
                          : isCurrent
                          ? themeProvider.currentColors.positiveMain
                          : themeProvider.currentColors.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : themeProvider.currentColors.textPrimary,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: themeProvider.currentColors.positiveMain,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineVisualization(ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        children: [
          Text(
            '📊 Vista del Día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Timeline visual simplificado
          Container(
            height: 60,
            child: Row(
              children: List.generate(24, (index) {
                final hasEvent = index % 4 == 0; // Simulación de eventos
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: hasEvent
                          ? themeProvider.currentColors.accentPrimary.withOpacity(0.5)
                          : themeProvider.currentColors.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: hasEvent
                        ? const Center(child: Text('•', style: TextStyle(color: Colors.white)))
                        : null,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: TextStyle(fontSize: 10, color: themeProvider.currentColors.textHint)),
              Text('12:00', style: TextStyle(fontSize: 10, color: themeProvider.currentColors.textHint)),
              Text('23:59', style: TextStyle(fontSize: 10, color: themeProvider.currentColors.textHint)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineForm(ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        children: [
          CustomTextField(
            controller: _timelineTextController,
            label: '¿Qué pasó a las ${_selectedHour.toString().padLeft(2, '0')}:00?',
            hint: 'Describe el momento específico...',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ThemedButton(
                  onPressed: () => _addTimelineMoment('positive'),
                  type: ThemedButtonType.positive,
                  height: 50,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✨', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('Positivo', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ThemedButton(
                  onPressed: () => _addTimelineMoment('negative'),
                  type: ThemedButtonType.negative,
                  height: 50,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌧️', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('Difícil', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesModePage(ThemeProvider themeProvider) {
    final templateCategories = {
      'Trabajo': [
        {'emoji': '🎯', 'text': 'Tarea completada con éxito', 'type': 'positive'},
        {'emoji': '💡', 'text': 'Idea brillante en reunión', 'type': 'positive'},
        {'emoji': '📊', 'text': 'Presentación exitosa', 'type': 'positive'},
        {'emoji': '😰', 'text': 'Estrés por deadline', 'type': 'negative'},
        {'emoji': '🤯', 'text': 'Sobrecarga de trabajo', 'type': 'negative'},
        {'emoji': '😤', 'text': 'Conflicto con compañero', 'type': 'negative'},
      ],
      'Personal': [
        {'emoji': '💪', 'text': 'Sesión de ejercicio increíble', 'type': 'positive'},
        {'emoji': '📚', 'text': 'Aprendí algo nuevo', 'type': 'positive'},
        {'emoji': '🎵', 'text': 'Música que me inspiró', 'type': 'positive'},
        {'emoji': '😴', 'text': 'Noche de mal sueño', 'type': 'negative'},
        {'emoji': '💔', 'text': 'Problema en relación', 'type': 'negative'},
        {'emoji': '🤒', 'text': 'No me siento bien', 'type': 'negative'},
      ],
      'Social': [
        {'emoji': '🤗', 'text': 'Abrazo reconfortante', 'type': 'positive'},
        {'emoji': '☕', 'text': 'Café con buen amigo', 'type': 'positive'},
        {'emoji': '🎉', 'text': 'Celebración familiar', 'type': 'positive'},
        {'emoji': '🤐', 'text': 'Discusión incómoda', 'type': 'negative'},
        {'emoji': '😞', 'text': 'Sentimiento de soledad', 'type': 'negative'},
        {'emoji': '😬', 'text': 'Situación social awkward', 'type': 'negative'},
      ],
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '🎯 Plantillas Inteligentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Situaciones comunes organizadas por categoría',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ...templateCategories.entries.map((category) {
            return Column(
              children: [
                _buildTemplateCategory(category.key, category.value, themeProvider),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTemplateCategory(String categoryName, List<Map<String, dynamic>> templates, ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.currentColors.accentPrimary,
                      themeProvider.currentColors.accentSecondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...templates.map((template) {
            final isPositive = template['type'] == 'positive';
            final color = isPositive
                ? themeProvider.currentColors.positiveMain
                : themeProvider.currentColors.negativeMain;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _addTemplateItem(template),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(template['emoji'], style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          template['text'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.currentColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: color,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ CORREGIDO: Voice Mode funcional
  Widget _buildVoiceModePage(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '🎤 Modo Voz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isListening
                      ? 'Escuchando... (simulado)'
                      : _isProcessingVoice
                      ? 'Procesando...'
                      : 'Habla naturalmente sobre tu momento',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Botón de voz central
                GestureDetector(
                  onTap: _toggleVoiceRecording,
                  child: AnimatedBuilder(
                    animation: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: _isListening
                                  ? [
                                themeProvider.currentColors.positiveMain,
                                themeProvider.currentColors.positiveMain.withOpacity(0.3),
                              ]
                                  : _isProcessingVoice
                                  ? [
                                themeProvider.currentColors.accentSecondary,
                                themeProvider.currentColors.accentSecondary.withOpacity(0.3),
                              ]
                                  : [
                                themeProvider.currentColors.accentPrimary,
                                themeProvider.currentColors.accentSecondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _isListening
                                    ? themeProvider.currentColors.positiveMain.withOpacity(0.5)
                                    : themeProvider.currentColors.accentPrimary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop : _isProcessingVoice ? Icons.hourglass_empty : Icons.mic,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  _isListening
                      ? 'Grabando... Toca para parar'
                      : _isProcessingVoice
                      ? 'Procesando audio...'
                      : 'Toca para hablar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Campo de texto transcrito
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '📝 Transcripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _voiceTextController,
                  label: 'Lo que dijiste aparecerá aquí',
                  hint: 'O escribe directamente...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ThemedButton(
                        onPressed: _voiceTextController.text.trim().isNotEmpty
                            ? () => _processVoiceInput('positive')
                            : null,
                        type: ThemedButtonType.positive,
                        height: 45,
                        child: const Text('✨ Momento Positivo', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ThemedButton(
                        onPressed: _voiceTextController.text.trim().isNotEmpty
                            ? () => _processVoiceInput('negative')
                            : null,
                        type: ThemedButtonType.negative,
                        height: 45,
                        child: const Text('🌧️ Momento Difícil', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ CORREGIDO: Smart Mode con categorías funcionales
  Widget _buildSmartModePage(ThemeProvider themeProvider) {
    final smartSuggestions = _getSmartSuggestions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGlassContainer(
            child: Column(
              children: [
                Text(
                  '🤖 Modo Inteligente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sugerencias basadas en la categoría seleccionada',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selector de categoría
          _buildCategorySelector(themeProvider),

          const SizedBox(height: 16),

          // Sugerencias inteligentes
          _buildSmartSuggestions(smartSuggestions, themeProvider),

          const SizedBox(height: 16),

          // Patrones de actividad
          _buildActivityPatterns(themeProvider),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(ThemeProvider themeProvider) {
    final categories = ['work', 'personal', 'social', 'health', 'creative'];
    final categoryEmojis = {
      'work': '💼',
      'personal': '🏠',
      'social': '👥',
      'health': '💪',
      'creative': '🎨',
    };

    return _buildGlassContainer(
      child: Column(
        children: [
          Text(
            'Selecciona categoría',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: categories.map((category) {
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = category; // ✅ CORREGIDO: Actualizar estado
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      colors: [
                        themeProvider.currentColors.accentPrimary,
                        themeProvider.currentColors.accentSecondary,
                      ],
                    ) : null,
                    color: isSelected ? null : themeProvider.currentColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? themeProvider.currentColors.accentPrimary
                          : themeProvider.currentColors.borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(categoryEmojis[category]!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : themeProvider.currentColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestions(List<Map<String, dynamic>> suggestions, ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: themeProvider.currentColors.positiveMain,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Sugerencias para ti ahora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...suggestions.map((suggestion) {
            final isPositive = suggestion['type'] == 'positive';
            final color = isPositive
                ? themeProvider.currentColors.positiveMain
                : themeProvider.currentColors.negativeMain;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _addSmartSuggestion(suggestion),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(suggestion['emoji'], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion['text'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: themeProvider.currentColors.textPrimary,
                              ),
                            ),
                            Text(
                              suggestion['reason'],
                              style: TextStyle(
                                fontSize: 10,
                                color: themeProvider.currentColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline,
                        color: color,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ CORREGIDO: Patrones de actividad con datos reales
  Widget _buildActivityPatterns(ThemeProvider themeProvider) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 Patrones de Actividad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.currentColors.positiveMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.currentColors.positiveMain.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('🌅', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        'Mejor hora',
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.currentColors.textSecondary,
                        ),
                      ),
                      Text(
                        '09:00', // TODO: Usar datos reales cuando estén disponibles
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.currentColors.positiveMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.currentColors.accentPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.currentColors.accentPrimary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('🔥', style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        'Racha',
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.currentColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_userStats['streak_days'] ?? 0} días', // ✅ CORREGIDO
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.currentColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBottomBar(ThemeProvider themeProvider) {
    final modes = [
      {'mode': InteractiveMode.quick, 'icon': Icons.flash_on, 'label': 'Quick'},
      {'mode': InteractiveMode.mood, 'icon': Icons.psychology, 'label': 'Mood'},
      {'mode': InteractiveMode.timeline, 'icon': Icons.schedule, 'label': 'Time'},
      {'mode': InteractiveMode.templates, 'icon': Icons.apps, 'label': 'Templates'},
      {'mode': InteractiveMode.voice, 'icon': Icons.mic, 'label': 'Voice'},
      {'mode': InteractiveMode.smart, 'icon': Icons.auto_awesome, 'label': 'Smart'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeProvider.currentColors.surface.withOpacity(0.9),
            themeProvider.currentColors.primaryBg,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: themeProvider.currentColors.borderColor.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navegación de modos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: modes.map((mode) {
              final isActive = _activeMode == mode['mode'];
              final index = modes.indexOf(mode);

              return GestureDetector(
                onTap: () {
                  setState(() => _activeMode = mode['mode'] as InteractiveMode);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? themeProvider.currentColors.accentPrimary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        mode['icon'] as IconData,
                        color: isActive
                            ? themeProvider.currentColors.accentPrimary
                            : themeProvider.currentColors.textHint,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mode['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? themeProvider.currentColors.accentPrimary
                              : themeProvider.currentColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Botones de acción principales
          _buildActionButtons(themeProvider),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeProvider themeProvider) {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, momentsProvider, child) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: ThemedButton(
                onPressed: momentsProvider.isLoading ? null : _clearMoments,
                type: ThemedButtonType.negative,
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Limpiar (${momentsProvider.totalCount})',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: ThemedButton(
                onPressed: momentsProvider.isLoading || momentsProvider.totalCount == 0 ? null : _saveMoments,
                type: ThemedButtonType.positive,
                height: 45,
                isLoading: momentsProvider.isLoading,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      momentsProvider.totalCount > 0
                          ? 'Guardar ${momentsProvider.totalCount} momentos'
                          : 'Sin momentos',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================================
  // MÉTODOS DE NEGOCIO CORREGIDOS
  // ============================================================================

  void _addQuickMoment(String emoji, String type, String category) {
    if (_quickTextController.text.trim().isEmpty) {
      _showEnhancedMessage('⚠️ Escribe qué pasó antes de seleccionar emoji', isError: true);
      return;
    }

    _addMoment(
      emoji: emoji,
      text: _quickTextController.text.trim(),
      type: type,
      category: category,
    );

    _quickTextController.clear();
  }

  // ✅ AÑADIDO: Método para favoritos
  void _addFavoriteMoment(String emoji) {
    if (_quickTextController.text.trim().isEmpty) {
      _showEnhancedMessage('⚠️ Escribe qué pasó antes de usar favoritos', isError: true);
      return;
    }

    // Detectar tipo basado en el emoji o contexto
    final type = _detectMomentType(_quickTextController.text, emoji);

    _addMoment(
      emoji: emoji,
      text: _quickTextController.text.trim(),
      type: type,
      category: 'favorite',
    );

    _quickTextController.clear();
  }

  String _detectMomentType(String text, String emoji) {
    // Emojis positivos comunes
    const positiveEmojis = ['😊', '💪', '🎯', '☕', '🎉', '✨', '🌟', '❤️'];
    if (positiveEmojis.contains(emoji)) return 'positive';

    // Palabras clave en el texto
    final lowerText = text.toLowerCase();
    final positiveWords = ['bien', 'genial', 'perfecto', 'increíble', 'feliz', 'contento'];
    final negativeWords = ['mal', 'horrible', 'estrés', 'triste', 'cansado', 'problema'];

    if (positiveWords.any((word) => lowerText.contains(word))) return 'positive';
    if (negativeWords.any((word) => lowerText.contains(word))) return 'negative';

    return 'positive'; // Por defecto
  }

  void _createMoodMoment(Map<String, dynamic> bubble) {
    _addMoment(
      emoji: bubble['emoji'] as String,
      text: bubble['text'] as String,
      type: bubble['type'] as String,
      intensity: bubble['intensity'] as int? ?? _currentIntensity.round(),
      category: 'mood',
    );
  }

  void _addTimelineMoment(String type) {
    if (_timelineTextController.text.trim().isEmpty) {
      _showEnhancedMessage('⚠️ Describe qué pasó', isError: true);
      return;
    }

    _addMoment(
      emoji: type == 'positive' ? '⭐' : '🌧️',
      text: _timelineTextController.text.trim(),
      type: type,
      category: 'timeline',
      timeStr: '${_selectedHour.toString().padLeft(2, '0')}:00',
    );

    _timelineTextController.clear();
  }

  void _addTemplateItem(Map<String, dynamic> template) {
    _addMoment(
      emoji: template['emoji'] as String,
      text: template['text'] as String,
      type: template['type'] as String,
      category: 'template',
    );
  }

  // ✅ CORREGIDO: Voice recording funcional
  void _toggleVoiceRecording() {
    setState(() {
      _isListening = !_isListening;
      if (!_isListening) {
        _isProcessingVoice = false;
      }
    });

    if (_isListening) {
      _showEnhancedMessage('🎤 Grabando... (simulado)');

      // Simular proceso de grabación y transcripción
      Future.delayed(const Duration(seconds: 2), () {
        if (_isListening && mounted) {
          setState(() {
            _isListening = false;
            _isProcessingVoice = true;
          });

          // Simular procesamiento
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _voiceTextController.text = _generateVoiceTranscription();
                _isProcessingVoice = false;
              });
              _showEnhancedMessage('✅ Transcripción completada');
            }
          });
        }
      });
    }
  }

  // ✅ AÑADIDO: Generar transcripciones variadas
  String _generateVoiceTranscription() {
    final hour = DateTime.now().hour;
    final transcriptions = [
      'Hoy tuve una reunión muy productiva con el equipo',
      'Me siento muy estresado por la cantidad de trabajo',
      'Almorcé algo delicioso y me relajó mucho',
      'El tráfico estuvo horrible en el camino a casa',
      'Completé todas mis tareas del día sin problemas',
      'Tuve una conversación muy interesante con un amigo',
      'El ejercicio de esta mañana me dio mucha energía',
      'Estoy preocupado por un problema familiar',
      'Leí un libro que me inspiró mucho',
      'Me sentí abrumado por todas las responsabilidades',
    ];

    return transcriptions[hour % transcriptions.length];
  }

  void _processVoiceInput(String type) {
    if (_voiceTextController.text.trim().isEmpty) {
      _showEnhancedMessage('⚠️ Primero graba o escribe algo', isError: true);
      return;
    }

    _addMoment(
      emoji: type == 'positive' ? '🎤' : '📢',
      text: _voiceTextController.text.trim(),
      type: type,
      category: 'voice',
    );

    _voiceTextController.clear();
  }

  void _addSmartSuggestion(Map<String, dynamic> suggestion) {
    _addMoment(
      emoji: suggestion['emoji'] as String,
      text: suggestion['text'] as String,
      type: suggestion['type'] as String,
      category: 'smart',
    );
  }

  // ✅ CORREGIDO: Sugerencias que cambian según categoría
  List<Map<String, dynamic>> _getSmartSuggestions() {
    final hour = DateTime.now().hour;

    final suggestions = <String, List<Map<String, dynamic>>>{
      'work': [
        {'emoji': '💼', 'text': 'Reunión productiva', 'type': 'positive', 'reason': 'Hora laboral perfecta'},
        {'emoji': '📊', 'text': 'Presentación exitosa', 'type': 'positive', 'reason': 'Pico de productividad'},
        {'emoji': '💡', 'text': 'Idea brillante en equipo', 'type': 'positive', 'reason': 'Momento creativo'},
        {'emoji': '😰', 'text': 'Estrés por deadline', 'type': 'negative', 'reason': 'Presión laboral común'},
        {'emoji': '🤯', 'text': 'Sobrecarga de tareas', 'type': 'negative', 'reason': 'Hora de alta demanda'},
      ],
      'personal': [
        {'emoji': '🏃‍♂️', 'text': 'Ejercicio energizante', 'type': 'positive', 'reason': 'Hora ideal para actividad'},
        {'emoji': '📚', 'text': 'Lectura inspiradora', 'type': 'positive', 'reason': 'Momento de crecimiento'},
        {'emoji': '🍳', 'text': 'Cocinando algo delicioso', 'type': 'positive', 'reason': 'Actividad relajante'},
        {'emoji': '😴', 'text': 'Cansancio personal', 'type': 'negative', 'reason': 'Fatiga natural'},
        {'emoji': '😞', 'text': 'Bajón emocional', 'type': 'negative', 'reason': 'Momento reflexivo'},
      ],
      'social': [
        {'emoji': '👥', 'text': 'Tiempo con amigos', 'type': 'positive', 'reason': 'Hora social perfecta'},
        {'emoji': '☕', 'text': 'Café con alguien especial', 'type': 'positive', 'reason': 'Momento de conexión'},
        {'emoji': '🎉', 'text': 'Celebración familiar', 'type': 'positive', 'reason': 'Tiempo de calidad'},
        {'emoji': '😞', 'text': 'Conflicto interpersonal', 'type': 'negative', 'reason': 'Tensión social'},
        {'emoji': '😔', 'text': 'Sentimiento de soledad', 'type': 'negative', 'reason': 'Necesidad de conexión'},
      ],
      'health': [
        {'emoji': '💪', 'text': 'Entrenamiento completado', 'type': 'positive', 'reason': 'Logro fitness'},
        {'emoji': '🥗', 'text': 'Comida saludable', 'type': 'positive', 'reason': 'Bienestar nutricional'},
        {'emoji': '🧘‍♀️', 'text': 'Meditación relajante', 'type': 'positive', 'reason': 'Momento zen'},
        {'emoji': '🤒', 'text': 'No me siento bien', 'type': 'negative', 'reason': 'Malestar físico'},
        {'emoji': '😪', 'text': 'Agotamiento físico', 'type': 'negative', 'reason': 'Necesidad de descanso'},
      ],
      'creative': [
        {'emoji': '🎨', 'text': 'Proyecto creativo avanzado', 'type': 'positive', 'reason': 'Inspiración activa'},
        {'emoji': '💡', 'text': 'Idea brillante', 'type': 'positive', 'reason': 'Momento eureka'},
        {'emoji': '🎵', 'text': 'Música que me inspira', 'type': 'positive', 'reason': 'Estímulo artístico'},
        {'emoji': '😑', 'text': 'Bloqueo creativo', 'type': 'negative', 'reason': 'Estancamiento común'},
        {'emoji': '😤', 'text': 'Frustración artística', 'type': 'negative', 'reason': 'Proceso creativo'},
      ],
    };

    return suggestions[_selectedCategory] ?? suggestions['work']!; // ✅ CORREGIDO
  }

  Future<void> _addMoment({
    required String emoji,
    required String text,
    required String type,
    int intensity = 5,
    String category = 'general',
    String? timeStr,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) return;

    final success = await momentsProvider.addMoment(
      userId: authProvider.currentUser!.id!,
      emoji: emoji,
      text: text,
      type: type,
      intensity: intensity,
      category: category,
      timeStr: timeStr,
    );

    if (success) {
      _showEnhancedMessage('✅ $emoji $text añadido');

      // Añadir a favoritos si se usa mucho
      if (!_favoriteEmojis.contains(emoji) && _favoriteEmojis.length < 8) {
        setState(() {
          _favoriteEmojis.add(emoji);
        });
      }
    } else {
      _showEnhancedMessage('❌ Error añadiendo momento', isError: true);
    }
  }

  Future<void> _clearMoments() async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) return;

    final success = await momentsProvider.clearAllMoments(authProvider.currentUser!.id!);

    if (success) {
      _showEnhancedMessage('🗑️ Momentos eliminados');
    } else {
      _showEnhancedMessage('❌ Error eliminando momentos', isError: true);
    }
  }

  Future<void> _saveMoments() async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) {
      _showEnhancedMessage('Error: No hay usuario logueado', isError: true);
      return;
    }

    if (momentsProvider.moments.isEmpty) {
      _showEnhancedMessage('No hay momentos para guardar', isError: true);
      return;
    }

    try {
      final userId = authProvider.currentUser!.id!;

      final entryId = await _databaseService.saveInteractiveMomentsAsEntry(
        userId,
        reflection: 'Entrada creada desde Momentos Interactivos',
        worthIt: momentsProvider.positiveCount > momentsProvider.negativeCount,
      );

      if (entryId != null) {
        _showEnhancedMessage('✅ ${momentsProvider.totalCount} momentos guardados como entrada diaria');

        momentsProvider.clear();

        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/daily_review');
          }
        });
      } else {
        _showEnhancedMessage('Error guardando momentos', isError: true);
      }
    } catch (e) {
      _logger.e('❌ Error guardando momentos: $e');
      _showEnhancedMessage('Error guardando momentos', isError: true);
    }
  }

  void _showEnhancedMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    final themeProvider = context.read<ThemeProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isError ? '❌' : '✅',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isError
            ? themeProvider.currentColors.negativeMain
            : themeProvider.currentColors.positiveMain,
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getMoodEmoji(double mood) {
    final moodEmojis = ["😢", "😔", "😐", "🙂", "😊", "😄", "🤗", "😁", "🥳", "🤩"];
    final index = (mood - 1).clamp(0, 9).toInt();
    return moodEmojis[index];
  }
}