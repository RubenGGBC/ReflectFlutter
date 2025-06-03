// ============================================================================
// presentation/screens/interactive_moments_screen.dart - PANTALLA REAL
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
import '../widgets/emoji_picker.dart';
import '../widgets/tag_chip.dart';
import '../../data/models/interative_moment_model.dart';

class InteractiveMomentsScreen extends StatefulWidget {
  const InteractiveMomentsScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveMomentsScreen> createState() => _InteractiveMomentsScreenState();
}

class _InteractiveMomentsScreenState extends State<InteractiveMomentsScreen> {
  final Logger _logger = Logger();
  final _textController = TextEditingController();

  String _activeMode = "quick"; // quick, mood, timeline, templates
  double _currentIntensity = 5.0;
  int _selectedHour = DateTime.now().hour;

  @override
  void initState() {
    super.initState();
    _loadUserMoments();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadUserMoments() async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser != null) {
      await momentsProvider.loadTodayMoments(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final momentsProvider = context.watch<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: Column(
        children: [
          _buildHeader(themeProvider, authProvider.currentUser!.name),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildDescription(themeProvider, momentsProvider),
                  const SizedBox(height: 12),
                  _buildModeSelector(themeProvider),
                  const SizedBox(height: 16),
                  _buildActiveMode(themeProvider, momentsProvider),
                  const SizedBox(height: 16),
                  _buildMomentsSummary(themeProvider, momentsProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, String userName) {
    return GradientHeader(
      title: '🎮 Momentos',
      leftButton: TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/calendar'),
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
      rightButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/theme_selector'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🎨', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacementNamed('/calendar'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('📅', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
    String statsText = "";
    if (momentsProvider.totalCount > 0) {
      statsText = " • ${momentsProvider.positiveCount}+ ${momentsProvider.negativeCount}-";
    }

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
  }

  Widget _buildModeSelector(ThemeProvider themeProvider) {
    final modes = [
      {"id": "quick", "emoji": "⚡", "name": "Quick"},
      {"id": "mood", "emoji": "🎭", "name": "Mood"},
      {"id": "timeline", "emoji": "⏰", "name": "Timeline"},
      {"id": "templates", "emoji": "🎯", "name": "Templates"}
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton(modes[0], themeProvider),
            const SizedBox(width: 8),
            _buildModeButton(modes[1], themeProvider),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeButton(modes[2], themeProvider),
            const SizedBox(width: 8),
            _buildModeButton(modes[3], themeProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(Map<String, String> mode, ThemeProvider themeProvider) {
    final isActive = _activeMode == mode["id"];

    return GestureDetector(
      onTap: () => setState(() => _activeMode = mode["id"]!),
      child: Container(
        width: 140,
        height: 70,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? themeProvider.currentColors.accentPrimary.withValues(alpha: 0.3)
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
            Text(mode["emoji"]!, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              mode["name"]!,
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

  Widget _buildActiveMode(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
    switch (_activeMode) {
      case "quick":
        return _buildQuickMode(themeProvider, momentsProvider);
      case "mood":
        return _buildMoodMode(themeProvider, momentsProvider);
      case "timeline":
        return _buildTimelineMode(themeProvider, momentsProvider);
      case "templates":
        return _buildTemplatesMode(themeProvider, momentsProvider);
      default:
        return _buildQuickMode(themeProvider, momentsProvider);
    }
  }

  Widget _buildQuickMode(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
    return Column(
      children: [
        // Campo de texto
        ThemedContainer(
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: '¿Qué pasó?',
              border: InputBorder.none,
            ),
            style: TextStyle(color: themeProvider.currentColors.textPrimary),
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  "Me sentí increíble",
                  "Fue genial",
                  "Muy estresante",
                  "Me frustré"
                ].map((phrase) {
                  return GestureDetector(
                    onTap: () => _textController.text = phrase,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeProvider.currentColors.surface,
                        border: Border.all(color: themeProvider.currentColors.borderColor),
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
          type: "positive",
          onEmojiSelected: (emoji) => _addQuickMoment(emoji, "positive", momentsProvider),
        ),

        const SizedBox(height: 8),

        // Emojis negativos
        EmojiPicker(
          type: "negative",
          onEmojiSelected: (emoji) => _addQuickMoment(emoji, "negative", momentsProvider),
        ),
      ],
    );
  }

  Widget _buildMoodMode(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
    return ThemedContainer(
      child: Column(
        children: [
          Text(
            '🎚️ Intensidad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('😐', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Slider(
                  min: 1,
                  max: 10,
                  value: _currentIntensity,
                  divisions: 9,
                  onChanged: (value) => setState(() => _currentIntensity = value),
                ),
              ),
              const Text('🤯', style: TextStyle(fontSize: 20)),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '${_currentIntensity.round()}/10',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.getMoodColor(_currentIntensity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineMode(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
    return ThemedContainer(
      child: Column(
        children: [
          Text(
            '⏰ Selecciona hora',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Text('Modo Timeline - En desarrollo'),
        ],
      ),
    );
  }

  Widget _buildTemplatesMode(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
    return ThemedContainer(
      child: Column(
        children: [
          Text(
            '🎯 Templates',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Text('Modo Templates - En desarrollo'),
        ],
      ),
    );
  }

  Widget _buildMomentsSummary(ThemeProvider themeProvider, InteractiveMomentsProvider momentsProvider) {
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${momentsProvider.positiveCount}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.currentColors.positiveMain,
                    ),
                  ),
                  Text(
                    'Positivos',
                    style: TextStyle(
                      fontSize: 10,
                      color: themeProvider.currentColors.textHint,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${momentsProvider.negativeCount}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.currentColors.negativeMain,
                    ),
                  ),
                  Text(
                    'Difíciles',
                    style: TextStyle(
                      fontSize: 10,
                      color: themeProvider.currentColors.textHint,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${momentsProvider.totalCount}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.currentColors.accentPrimary,
                    ),
                  ),
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10,
                      color: themeProvider.currentColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ThemedButton(
                  onPressed: () => _clearMoments(momentsProvider),
                  type: ThemedButtonType.negative,
                  height: 35,
                  child: const Text('🗑️ Limpiar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ThemedButton(
                  onPressed: () => _saveMoments(momentsProvider),
                  type: ThemedButtonType.positive,
                  height: 35,
                  child: const Text('💾 Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addQuickMoment(String emoji, String type, InteractiveMomentsProvider momentsProvider) async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Escribe qué pasó antes de seleccionar emoji')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await momentsProvider.addMoment(
      userId: authProvider.currentUser!.id!,
      emoji: emoji,
      text: _textController.text.trim(),
      type: type,
      category: 'quick',
    );

    if (success) {
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $emoji ${_textController.text} añadido')),
      );
    }
  }

  Future<void> _clearMoments(InteractiveMomentsProvider momentsProvider) async {
    final authProvider = context.read<AuthProvider>();
    await momentsProvider.clearAllMoments(authProvider.currentUser!.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🗑️ Momentos eliminados')),
    );
  }

  Future<void> _saveMoments(InteractiveMomentsProvider momentsProvider) async {
    final authProvider = context.read<AuthProvider>();
    final entryId = await momentsProvider.saveMomentsAsEntry(
      authProvider.currentUser!.id!,
      reflection: 'Entrada creada desde Momentos Interactivos',
      worthIt: momentsProvider.positiveCount > momentsProvider.negativeCount,
    );

    if (entryId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${momentsProvider.totalCount} momentos guardados')),
      );
      Navigator.of(context).pushReplacementNamed('/calendar');
    }
  }
}