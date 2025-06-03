// ============================================================================
// presentation/screens/interactive_moments_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/interactive_moments_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/emoji_picker.dart';
import '../widgets/mood_slider.dart';

enum InteractiveMode {
  quick,
  mood,
  timeline,
  templates,
}

class InteractiveMomentsScreen extends StatefulWidget {
  const InteractiveMomentsScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveMomentsScreen> createState() => _InteractiveMomentsScreenState();
}

class _InteractiveMomentsScreenState extends State<InteractiveMomentsScreen> {
  final Logger _logger = Logger();

  InteractiveMode _activeMode = InteractiveMode.quick;

  // Controllers para diferentes modos
  final _quickTextController = TextEditingController();
  final _timelineTextController = TextEditingController();

  // Estado del mood mode
  double _currentIntensity = 5.0;

  // Estado del timeline mode
  int _selectedHour = DateTime
      .now()
      .hour;

  @override
  void initState() {
    super.initState();
    _loadUserMoments();
  }

  @override
  void dispose() {
    _quickTextController.dispose();
    _timelineTextController.dispose();
    super.dispose();
  }

  void _loadUserMoments() {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser != null) {
      momentsProvider.loadTodayMoments(authProvider.currentUser!.id!);
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
          _buildHeader(context, themeProvider, authProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildDescriptionSection(themeProvider),
                  const SizedBox(height: 12),
                  _buildModeSelector(themeProvider),
                  const SizedBox(height: 12),
                  _buildActiveMode(themeProvider),
                  const SizedBox(height: 12),
                  _buildMomentsSummary(themeProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider,
      AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: themeProvider.currentColors.gradientHeader,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Botón volver
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/calendar'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Volver', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

              // Título central
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      '🎮 Momentos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      authProvider.currentUser!.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción
              Row(
                children: [
                  _buildHeaderActionButton(
                    '🎨',
                    'Temas',
                        () =>
                        Navigator.of(context).pushNamed('/theme_selector'),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderActionButton(
                    '📅',
                    'Calendario',
                        () =>
                        Navigator.of(context).pushReplacementNamed('/calendar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActionButton(String emoji, String tooltip,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeProvider themeProvider) {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, momentsProvider, child) {
        final statsText = momentsProvider.totalCount > 0
            ? ' • ${momentsProvider.positiveCount}+ ${momentsProvider
            .negativeCount}-'
            : '';

        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          alignment: Alignment.center,
          child: Text(
            'Captura tus momentos$statsText',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.currentColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildModeSelector(ThemeProvider themeProvider) {
    final modes = [
      {'id': InteractiveMode.quick, 'emoji': '⚡', 'name': 'Quick'},
      {'id': InteractiveMode.mood, 'emoji': '🎭', 'name': 'Mood'},
      {'id': InteractiveMode.timeline, 'emoji': '⏰', 'name': 'Timeline'},
      {'id': InteractiveMode.templates, 'emoji': '🎯', 'name': 'Templates'},
    ];

    return Column(
      children: [
        // Primera fila
        Row(
          children: modes.take(2).map((mode) {
            final isActive = _activeMode == mode['id'];
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: _buildModeButton(mode, isActive, themeProvider),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Segunda fila
        Row(
          children: modes.skip(2).map((mode) {
            final isActive = _activeMode == mode['id'];
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: _buildModeButton(mode, isActive, themeProvider),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModeButton(Map<String, dynamic> mode, bool isActive,
      ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => setState(() => _activeMode = mode['id'] as InteractiveMode),
      child: Container(
        width: 140,
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? themeProvider.currentColors.accentPrimary.withOpacity(0.3)
              : themeProvider.currentColors.surface,
          border: Border.all(
            color: isActive
                ? themeProvider.currentColors.accentPrimary
                : themeProvider.currentColors.borderColor,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mode['emoji'] as String, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              mode['name'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: themeProvider.currentColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMode(ThemeProvider themeProvider) {
    switch (_activeMode) {
      case InteractiveMode.quick:
        return _buildQuickAddMode(themeProvider);
      case InteractiveMode.mood:
        return _buildMoodBubblesMode(themeProvider);
      case InteractiveMode.timeline:
        return _buildTimelineMode(themeProvider);
      case InteractiveMode.templates:
        return _buildTemplatesMode(themeProvider);
    }
  }

  Widget _buildQuickAddMode(ThemeProvider themeProvider) {
    return Column(
      children: [
        // Campo de texto
        ThemedContainer(
          child: CustomTextField(
            controller: _quickTextController,
            label: '¿Qué pasó?',
            hint: 'Describe tu momento...',
          ),
        ),

        const SizedBox(height: 8),

        // Frases rápidas
        ThemedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚡ Frases:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.currentColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  'Me sentí increíble',
                  'Fue genial',
                  'Muy estresante',
                  'Me frustré',
                ].map((phrase) {
                  return GestureDetector(
                    onTap: () => _quickTextController.text = phrase,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeProvider.currentColors.surface,
                        border: Border.all(
                            color: themeProvider.currentColors.borderColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        phrase,
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.currentColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Emojis positivos
        EmojiPicker(
          type: 'positive',
          onEmojiSelected: (emoji) =>
              _addQuickMoment(emoji, 'positive', 'quick'),
        ),

        const SizedBox(height: 8),

        // Emojis negativos
        EmojiPicker(
          type: 'negative',
          onEmojiSelected: (emoji) =>
              _addQuickMoment(emoji, 'negative', 'quick'),
        ),
      ],
    );
  }

  Widget _buildMoodBubblesMode(ThemeProvider themeProvider) {
    return Column(
      children: [
        // Slider de intensidad
        ThemedContainer(
          child: MoodSlider(
            value: _currentIntensity,
            onChanged: (value) => setState(() => _currentIntensity = value),
            label: '🎚️ Intensidad del momento',
          ),
        ),

        const SizedBox(height: 12),

        // Burbujas de emociones
        ThemedContainer(
          child: Column(
            children: [
              Text(
                '🫧 Toca una emoción',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.currentColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildMoodBubbles(themeProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodBubbles(ThemeProvider themeProvider) {
    final bubbleOptions = [
      {'emoji': '😊', 'text': 'Alegre', 'type': 'positive'},
      {'emoji': '🎉', 'text': 'Emocionado', 'type': 'positive'},
      {'emoji': '😌', 'text': 'Tranquilo', 'type': 'positive'},
      {'emoji': '💪', 'text': 'Motivado', 'type': 'positive'},
      {'emoji': '😰', 'text': 'Estresado', 'type': 'negative'},
      {'emoji': '😔', 'text': 'Triste', 'type': 'negative'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: bubbleOptions.map((bubble) {
        final isPositive = bubble['type'] == 'positive';
        final baseColor = isPositive
            ? themeProvider.currentColors.positiveMain
            : themeProvider.currentColors.negativeMain;

        return GestureDetector(
          onTap: () => _createMoodMoment(bubble),
          child: Container(
            width: 120,
            height: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.15),
              border: Border.all(color: baseColor.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(bubble['emoji'] as String,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  bubble['text'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineMode(ThemeProvider themeProvider) {
    final currentHour = DateTime
        .now()
        .hour;
    final hoursAround = [
      (currentHour - 2).clamp(0, 23),
      (currentHour - 1).clamp(0, 23),
      currentHour,
      (currentHour + 1).clamp(0, 23),
      (currentHour + 2).clamp(0, 23),
    ];

    return Column(
      children: [
        // Selector de hora
        ThemedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⏰ Selecciona hora',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: hoursAround.map((hour) {
                  final isSelected = hour == _selectedHour;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedHour = hour),
                    child: Container(
                      width: 60,
                      height: 35,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeProvider.currentColors.accentPrimary
                            .withOpacity(0.3)
                            : themeProvider.currentColors.surface,
                        border: Border.all(
                          color: isSelected
                              ? themeProvider.currentColors.accentPrimary
                              : themeProvider.currentColors.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.currentColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Formulario de timeline
        ThemedContainer(
          child: Column(
            children: [
              CustomTextField(
                controller: _timelineTextController,
                label: '¿Qué pasó en esta hora?',
                hint: 'Describe el momento...',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ThemedButton(
                      onPressed: () => _addTimelineMoment('positive'),
                      type: ThemedButtonType.positive,
                      height: 45,
                      child: const Text(
                          '✨ Positivo', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThemedButton(
                      onPressed: () => _addTimelineMoment('negative'),
                      type: ThemedButtonType.negative,
                      height: 45,
                      child: const Text(
                          '🌧️ Difícil', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesMode(ThemeProvider themeProvider) {
    final templates = [
      {'emoji': '💪', 'text': 'Ejercicio energizante', 'type': 'positive'},
      {'emoji': '☕', 'text': 'Café con amigo', 'type': 'positive'},
      {'emoji': '🎯', 'text': 'Tarea completada', 'type': 'positive'},
      {'emoji': '😰', 'text': 'Estrés laboral', 'type': 'negative'},
      {'emoji': '😴', 'text': 'Mala noche', 'type': 'negative'},
      {'emoji': '🤐', 'text': 'Conflicto personal', 'type': 'negative'},
    ];

    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Situaciones comunes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: templates.map((template) {
              final isPositive = template['type'] == 'positive';
              final color = isPositive
                  ? themeProvider.currentColors.positiveMain
                  : themeProvider.currentColors.negativeMain;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _addTemplateItem(template),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      border: Border.all(color: color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(template['emoji'] as String,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            template['text'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.currentColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(fontSize: 16, color: color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsSummary(ThemeProvider themeProvider) {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, momentsProvider, child) {
        if (momentsProvider.totalCount == 0) {
          return ThemedContainer(
            child: Text(
              'No hay momentos añadidos aún',
              style: TextStyle(
                color: themeProvider.currentColors.textHint,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ThemedContainer(
          child: Column(
            children: [
              Text(
                '📈 Resumen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Estadísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    momentsProvider.positiveCount.toString(),
                    'Positivos',
                    themeProvider.currentColors.positiveMain,
                  ),
                  Container(width: 2,
                      height: 40,
                      color: themeProvider.currentColors.borderColor),
                  _buildStatColumn(
                    momentsProvider.negativeCount.toString(),
                    'Difíciles',
                    themeProvider.currentColors.negativeMain,
                  ),
                  Container(width: 2,
                      height: 40,
                      color: themeProvider.currentColors.borderColor),
                  _buildStatColumn(
                    momentsProvider.totalCount.toString(),
                    'Total',
                    themeProvider.currentColors.accentPrimary,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ThemedButton(
                      onPressed: momentsProvider.isLoading
                          ? null
                          : _clearMoments,
                      type: ThemedButtonType.negative,
                      height: 35,
                      child: const Text('🗑️ Limpiar',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThemedButton(
                      onPressed: momentsProvider.isLoading
                          ? null
                          : _saveMoments,
                      type: ThemedButtonType.positive,
                      height: 35,
                      isLoading: momentsProvider.isLoading,
                      child: const Text('💾 Guardar',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: context
                .read<ThemeProvider>()
                .currentColors
                .textHint,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS DE NEGOCIO
  // ============================================================================

  void _addQuickMoment(String emoji, String type, String category) {
    if (_quickTextController.text
        .trim()
        .isEmpty) {
      _showMessage(
          '⚠️ Escribe qué pasó antes de seleccionar emoji', isError: true);
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

  void _createMoodMoment(Map<String, dynamic> bubble) {
    _addMoment(
      emoji: bubble['emoji'] as String,
      text: bubble['text'] as String,
      type: bubble['type'] as String,
      intensity: _currentIntensity.round(),
      category: 'mood',
    );
  }

  void _addTimelineMoment(String type) {
    if (_timelineTextController.text
        .trim()
        .isEmpty) {
      _showMessage('⚠️ Describe qué pasó', isError: true);
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
      _showMessage('✅ $emoji $text añadido');
    } else {
      _showMessage('❌ Error añadiendo momento', isError: true);
    }
  }

  Future<void> _clearMoments() async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) return;

    final success = await momentsProvider.clearAllMoments(
        authProvider.currentUser!.id!);

    if (success) {
      _showMessage('🗑️ Momentos eliminados');
    } else {
      _showMessage('❌ Error eliminando momentos', isError: true);
    }
  }

  Future<void> _saveMomentsAsEntry() async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) {
      _showMessage('Error: No hay usuario logueado', isError: true);
      return;
    }

    if (momentsProvider.moments.isEmpty) {
      _showMessage('No hay momentos para guardar', isError: true);
      return;
    }

    try {
      final userId = authProvider.currentUser!.id!;

      // Guardar momentos como entrada
      final entryId = await momentsProvider.saveMomentsAsEntry(
        userId,
        reflection: 'Entrada creada desde Momentos Interactivos',
        worthIt: momentsProvider.positiveCount > momentsProvider.negativeCount,
      );

      if (entryId != null) {
        _showMessage('✅ ${momentsProvider.totalCount} momentos guardados');

        // ✅ CAMBIO PRINCIPAL: Ir a daily review en lugar de calendario
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/daily_review');
          }
        });
      } else {
        _showMessage('Error guardando momentos', isError: true);
      }
    } catch (e) {
      _logger.e('❌ Error guardando momentos: $e');
      _showMessage('Error guardando momentos', isError: true);
    }
  }

  // ✅ TAMBIÉN ACTUALIZA ESTE MÉTODO SI EXISTE
  Widget _buildActionButtons(ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: ThemedButton(
            onPressed: _clearMoments,
            type: ThemedButtonType.outlined,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear,
                    color: themeProvider.currentColors.negativeMain),
                const SizedBox(width: 8),
                Text(
                  'Limpiar',
                  style: TextStyle(
                    color: themeProvider.currentColors.negativeMain,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ThemedButton(
            onPressed: _saveMomentsAsEntry,
            // ✅ Este método ya actualizado arriba
            type: ThemedButtonType.positive,
            height: 50,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📝', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'Continuar reflexión', // ✅ CAMBIO DE TEXTO
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}