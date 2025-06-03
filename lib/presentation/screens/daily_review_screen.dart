// ============================================================================
// presentation/screens/daily_review_screen.dart
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
import '../widgets/mood_slider.dart';
import '../widgets/custom_text_field.dart';
import '../../data/services/database_service.dart';
import '../../data/models/daily_entry_model.dart';
import '../../data/models/tag_model.dart';

class DailyReviewScreen extends StatefulWidget {
  const DailyReviewScreen({Key? key}) : super(key: key);

  @override
  State<DailyReviewScreen> createState() => _DailyReviewScreenState();
}

class _DailyReviewScreenState extends State<DailyReviewScreen> {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  // Controladores
  final TextEditingController _reflectionController = TextEditingController();

  // Estado
  bool _isLoading = false;
  double _moodScore = 5.0;
  bool? _worthIt;
  List<TagModel> _positiveTags = [];
  List<TagModel> _negativeTags = [];

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
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
          _buildHeader(context, themeProvider),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(themeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    final today = DateTime.now();
    final todayStr = '${today.day} ${_getMonthName(today.month)}';

    return GradientHeader(
      title: '📝 Revisa tu día - $todayStr',
      leftButton: TextButton(
        onPressed: () => Navigator.of(context).pop(),
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
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Introducción
          _buildIntroSection(themeProvider),
          const SizedBox(height: 16),

          // Resumen de momentos
          _buildMomentsSection(themeProvider),
          const SizedBox(height: 16),

          // Reflexión libre
          _buildReflectionSection(themeProvider),
          const SizedBox(height: 16),

          // Evaluación del día
          _buildWorthItSection(themeProvider),
          const SizedBox(height: 16),

          // Mood score
          _buildMoodSection(themeProvider),
          const SizedBox(height: 20),

          // Botones de acción
          _buildActionButtons(themeProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIntroSection(ThemeProvider themeProvider) {
    final totalMoments = _positiveTags.length + _negativeTags.length;

    String introText;
    String introEmoji;

    if (totalMoments > 0) {
      introText = 'Has registrado $totalMoments momentos hoy. Es hora de reflexionar sobre tu día completo.';
      introEmoji = '🌟';
    } else {
      introText = 'Aún no has registrado momentos específicos, pero puedes reflexionar sobre tu día.';
      introEmoji = '💭';
    }

    return ThemedContainer(
      child: Row(
        children: [
          Text(introEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hora de reflexionar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  introText,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsSection(ThemeProvider themeProvider) {
    if (_positiveTags.isEmpty && _negativeTags.isEmpty) {
      return ThemedContainer(
        child: Column(
          children: [
            Text(
              '📋 Momentos del día',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.currentColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay momentos específicos registrados. Puedes usar la reflexión libre abajo.',
              style: TextStyle(
                fontSize: 13,
                color: themeProvider.currentColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Estadísticas
    final stats = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              '${_positiveTags.length}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.currentColors.positiveMain,
              ),
            ),
            Text(
              'Positivos',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.currentColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          width: 2,
          height: 40,
          color: themeProvider.currentColors.borderColor,
        ),
        Column(
          children: [
            Text(
              '${_negativeTags.length}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.currentColors.negativeMain,
              ),
            ),
            Text(
              'Difíciles',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.currentColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );

    // Lista de momentos recientes
    final allMoments = [..._positiveTags, ..._negativeTags];
    final recentMoments = allMoments.take(3).map((tag) {
      final isPositive = _positiveTags.contains(tag);
      final color = isPositive
          ? themeProvider.currentColors.positiveMain
          : themeProvider.currentColors.negativeMain;

      return Row(
        children: [
          Text(tag.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tag.name,
              style: TextStyle(
                fontSize: 13,
                color: themeProvider.currentColors.textSecondary,
              ),
            ),
          ),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
    }).toList();

    return ThemedContainer(
      child: Column(
        children: [
          Text(
            '📋 Momentos del día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          stats,
          if (recentMoments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Últimos momentos:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: themeProvider.currentColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: recentMoments
                  .map((moment) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: moment,
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReflectionSection(ThemeProvider themeProvider) {
    // Prompts de ayuda
    const prompts = [
      '¿Qué aprendiste hoy?',
      '¿Qué te hizo sonreír?',
      '¿Qué cambiarías?',
      '¿Cómo te sientes ahora?',
    ];

    final promptButtons = <Widget>[];
    for (int i = 0; i < prompts.length; i += 2) {
      final row = <Widget>[];
      for (int j = 0; j < 2 && i + j < prompts.length; j++) {
        final prompt = prompts[i + j];
        row.add(
          Expanded(
            child: GestureDetector(
              onTap: () => _addPromptToReflection(prompt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: themeProvider.currentColors.surface,
                  border: Border.all(color: themeProvider.currentColors.borderColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 11,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
        if (j == 0 && i + j + 1 < prompts.length) {
          row.add(const SizedBox(width: 8));
        }
      }
      promptButtons.add(
        Row(children: row),
      );
      if (i + 2 < prompts.length) {
        promptButtons.add(const SizedBox(height: 6));
      }
    }

    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💭 Reflexión libre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _reflectionController,
            label: '¿Cómo fue tu día? Reflexiona libremente...',
            hint: 'Escribe aquí tus pensamientos...',
            maxLines: 6,
            minLines: 4,
          ),
          const SizedBox(height: 12),
          Text(
            '💡 Ideas para reflexionar:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: themeProvider.currentColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Column(children: promptButtons),
        ],
      ),
    );
  }

  Widget _buildWorthItSection(ThemeProvider themeProvider) {
    final options = [
      {
        'value': true,
        'emoji': '😊',
        'text': 'SÍ, mereció la pena',
        'color': themeProvider.currentColors.positiveMain,
      },
      {
        'value': false,
        'emoji': '😔',
        'text': 'NO, no mereció la pena',
        'color': themeProvider.currentColors.negativeMain,
      },
      {
        'value': null,
        'emoji': '🤷',
        'text': 'No estoy seguro/a',
        'color': themeProvider.currentColors.textHint,
      },
    ];

    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚖️ ¿Mereció la pena el día?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...options.map((option) {
            final isSelected = _worthIt == option['value'];
            final color = option['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _worthIt = option['value'] as bool?),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : themeProvider.currentColors.surface,
                    border: Border.all(
                      color: isSelected ? color : themeProvider.currentColors.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(option['emoji'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option['text'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.currentColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          border: Border.all(color: color, width: 2),
                          borderRadius: BorderRadius.circular(10),
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

  Widget _buildMoodSection(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: MoodSlider(
        value: _moodScore,
        onChanged: (value) => setState(() => _moodScore = value),
        label: '🎭 ¿Cómo calificas tu día?',
      ),
    );
  }

  Widget _buildActionButtons(ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: ThemedButton(
            onPressed: _saveDailyReview,
            type: ThemedButtonType.positive,
            height: 50,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('💾', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'Guardar día',
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
        const SizedBox(width: 12),
        Expanded(
          child: ThemedButton(
            onPressed: _goToCalendar,
            type: ThemedButtonType.outlined,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Ver calendario',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.currentColors.accentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MÉTODOS DE NEGOCIO
  // ============================================================================

  Future<void> _loadTodayData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final userId = authProvider.currentUser!.id!;

      // Cargar momentos interactivos de hoy
      final momentsProvider = context.read<InteractiveMomentsProvider>();
      await momentsProvider.loadTodayMoments(userId);

      // Convertir momentos a tags
      final moments = momentsProvider.moments;
      _positiveTags = moments
          .where((m) => m.type == 'positive')
          .map((m) => m.toTag())
          .toList();

      _negativeTags = moments
          .where((m) => m.type == 'negative')
          .map((m) => m.toTag())
          .toList();

      // Cargar entrada existente si existe
      final existingEntry = await _databaseService.getDayEntry(userId, DateTime.now());
      if (existingEntry != null) {
        _reflectionController.text = existingEntry.freeReflection;
        _worthIt = existingEntry.worthIt;
        _moodScore = existingEntry.moodScore?.toDouble() ?? 5.0;
      }

      _logger.d('📊 Datos cargados: ${_positiveTags.length} positivos, ${_negativeTags.length} negativos');

    } catch (e) {
      _logger.e('❌ Error cargando datos del día: $e');
      _showMessage('Error cargando datos del día', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addPromptToReflection(String prompt) {
    final current = _reflectionController.text;
    final newText = current.isEmpty
        ? '$prompt '
        : current.endsWith('\n')
        ? '$current$prompt '
        : '$current\n\n$prompt ';

    _reflectionController.text = newText;
    _reflectionController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  Future<void> _saveDailyReview() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      _showMessage('Error: No hay datos de usuario', isError: true);
      return;
    }

    if (_reflectionController.text.trim().isEmpty) {
      _showMessage('Añade una reflexión antes de guardar', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = authProvider.currentUser!.id!;

      final entry = DailyEntryModel.create(
        userId: userId,
        freeReflection: _reflectionController.text.trim(),
        positiveTags: _positiveTags,
        negativeTags: _negativeTags,
        worthIt: _worthIt,
      );

      // Sobrescribir mood score
      final entryWithMood = entry.copyWith(moodScore: _moodScore.round());

      final entryId = await _databaseService.saveDailyEntry(entryWithMood);

      if (entryId != null) {
        _showMessage('✅ Día guardado correctamente');

        // Navegar al calendario después de un momento
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/calendar');
          }
        });
      } else {
        _showMessage('Error guardando el día', isError: true);
      }

    } catch (e) {
      _logger.e('❌ Error guardando revisión diaria: $e');
      _showMessage('Error guardando el día', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToCalendar() {
    Navigator.of(context).pushReplacementNamed('/calendar');
  }

  void _showMessage(String message, {bool isError = false}) {
    final themeProvider = context.read<ThemeProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: isError
            ? themeProvider.currentColors.negativeMain
            : themeProvider.currentColors.positiveMain,
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month];
  }
}