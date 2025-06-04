// ============================================================================
// presentation/screens/daily_review_screen.dart - VERSIÓN MEJORADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../widgets/mood_slider.dart';
import '../widgets/custom_text_field.dart';
import '../../data/services/database_service.dart';
import '../../data/models/daily_entry_model.dart';

class DailyReviewScreen extends StatefulWidget {
  const DailyReviewScreen({super.key});

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

  // Datos del día
  Map<String, dynamic>? _dayData;
  List<Map<String, dynamic>> _timeline = [];
  Map<String, dynamic> _hourlyStats = {};

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
          // Resumen del día con estadísticas
          _buildDaySummaryCard(themeProvider),
          const SizedBox(height: 16),

          // Timeline de momentos
          if (_timeline.isNotEmpty) ...[
            _buildTimelineCard(themeProvider),
            const SizedBox(height: 16),
          ],

          // Estadísticas por hora
          if (_hourlyStats.isNotEmpty) ...[
            _buildHourlyStatsCard(themeProvider),
            const SizedBox(height: 16),
          ],

          // Reflexión libre (con texto anterior preservado)
          _buildReflectionCard(themeProvider),
          const SizedBox(height: 16),

          // Evaluación del día
          _buildWorthItCard(themeProvider),
          const SizedBox(height: 16),

          // Mood score
          _buildMoodCard(themeProvider),
          const SizedBox(height: 20),

          // Botones de acción
          _buildActionButtons(themeProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDaySummaryCard(ThemeProvider themeProvider) {
    final totalMoments = _dayData?['total_moments'] ?? 0;
    final timelineMoments = _dayData?['timeline_moments'] ?? 0;
    final entry = _dayData?['entry'] as DailyEntryModel?;

    return ThemedContainer(
      child: Column(
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Día',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalMoments > 0
                          ? 'Has registrado $totalMoments momentos en total'
                          : 'Aún no hay momentos registrados',
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

          if (entry != null) ...[
            const SizedBox(height: 16),

            // Estadísticas detalladas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeProvider.currentColors.accentPrimary.withOpacity(0.1),
                    themeProvider.currentColors.accentSecondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.currentColors.borderColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    '😊',
                    entry.positiveTags.length.toString(),
                    'Positivos',
                    themeProvider.currentColors.positiveMain,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: themeProvider.currentColors.borderColor,
                  ),
                  _buildStatColumn(
                    '😔',
                    entry.negativeTags.length.toString(),
                    'Difíciles',
                    themeProvider.currentColors.negativeMain,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: themeProvider.currentColors.borderColor,
                  ),
                  _buildStatColumn(
                    '📝',
                    entry.wordCount.toString(),
                    'Palabras',
                    themeProvider.currentColors.accentPrimary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: themeProvider.currentColors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '⏰ Timeline del Día',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeProvider.currentColors.accentPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_timeline.length} momentos',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Timeline visual
          Column(
            children: _timeline.asMap().entries.map((entry) {
              final index = entry.key;
              final moment = entry.value;
              final isLast = index == _timeline.length - 1;

              return _buildTimelineItem(moment, isLast, themeProvider);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> moment, bool isLast, ThemeProvider themeProvider) {
    final isPositive = moment['type'] == 'positive';
    final color = isPositive
        ? themeProvider.currentColors.positiveMain
        : themeProvider.currentColors.negativeMain;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline visual
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  moment['emoji'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: themeProvider.currentColors.borderColor.withOpacity(0.3),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Contenido del momento
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      moment['time'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        moment['category'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  moment['text'],
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
                if (moment['intensity'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Intensidad: ',
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.currentColors.textHint,
                        ),
                      ),
                      ...List.generate(10, (i) {
                        return Icon(
                          i < moment['intensity'] ? Icons.circle : Icons.circle_outlined,
                          size: 8,
                          color: color.withOpacity(i < moment['intensity'] ? 1.0 : 0.3),
                        );
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyStatsCard(ThemeProvider themeProvider) {
    final hourlyStats = _hourlyStats['hourly_stats'] as Map<String, Map<String, dynamic>>? ?? {};
    final peakHour = _hourlyStats['peak_hour'] as String?;
    final totalHours = _hourlyStats['total_hours_active'] as int? ?? 0;

    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: themeProvider.currentColors.accentSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '📈 Actividad por Hora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Estadísticas resumidas
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.currentColors.positiveMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.currentColors.positiveMain.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        peakHour ?? '--:--',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.currentColors.positiveMain,
                        ),
                      ),
                      Text(
                        'Hora más activa',
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.currentColors.textSecondary,
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
                    border: Border.all(
                      color: themeProvider.currentColors.accentPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        totalHours.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.currentColors.accentPrimary,
                        ),
                      ),
                      Text(
                        'Horas con actividad',
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.currentColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (hourlyStats.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Gráfico simple de barras por hora
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (hour) {
                  final hourStr = '${hour.toString().padLeft(2, '0')}:00';
                  final stats = hourlyStats[hourStr];
                  final total = stats?['total'] as int? ?? 0;
                  final positive = stats?['positive'] as int? ?? 0;
                  final negative = stats?['negative'] as int? ?? 0;

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (total > 0) ...[
                            // Barra de negativos
                            if (negative > 0)
                              Container(
                                height: (negative * 20.0),
                                decoration: BoxDecoration(
                                  color: themeProvider.currentColors.negativeMain,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    topRight: Radius.circular(2),
                                  ),
                                ),
                              ),
                            // Barra de positivos
                            if (positive > 0)
                              Container(
                                height: (positive * 20.0),
                                decoration: BoxDecoration(
                                  color: themeProvider.currentColors.positiveMain,
                                  borderRadius: negative > 0
                                      ? null
                                      : const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    topRight: Radius.circular(2),
                                  ),
                                ),
                              ),
                          ] else ...[
                            Container(
                              height: 2,
                              color: themeProvider.currentColors.borderColor.withOpacity(0.3),
                            ),
                          ],
                          const SizedBox(height: 4),
                          if (hour % 6 == 0)
                            Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 8,
                                color: themeProvider.currentColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReflectionCard(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💭 Reflexión del Día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tus pensamientos sobre el día. Tu reflexión anterior se mantendrá.',
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.currentColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _reflectionController,
            label: 'Reflexiona sobre tu día...',
            hint: 'Escribe aquí tus pensamientos adicionales...',
            maxLines: 6,
            minLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItCard(ThemeProvider themeProvider) {
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
              fontWeight: FontWeight.bold,
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
          }),
        ],
      ),
    );
  }

  Widget _buildMoodCard(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: MoodSlider(
        value: _moodScore,
        onChanged: (value) => setState(() => _moodScore = value),
        label: '🎭 ¿Cómo calificas tu día en general?',
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
            isLoading: _isLoading,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('💾', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text(
                  'Guardar Reflexión Final',
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

  Widget _buildStatColumn(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: context.read<ThemeProvider>().currentColors.textSecondary,
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

      // Cargar datos del día con timeline
      _dayData = await _databaseService.getDayEntryWithTimeline(userId, DateTime.now());

      if (_dayData != null) {
        final entry = _dayData!['entry'] as DailyEntryModel;
        _timeline = List<Map<String, dynamic>>.from(_dayData!['timeline']);

        // Cargar datos en los controladores
        _reflectionController.text = entry.freeReflection;
        _worthIt = entry.worthIt;
        _moodScore = entry.moodScore?.toDouble() ?? 5.0;
      }

      // Cargar estadísticas por hora
      _hourlyStats = await _databaseService.getMomentsHourlyStats(userId, DateTime.now());

      _logger.d('📊 Datos cargados: ${_dayData?['total_moments']} momentos totales, ${_timeline.length} en timeline');

    } catch (e) {
      _logger.e('❌ Error cargando datos del día: $e');
      _showMessage('Error cargando datos del día', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDailyReview() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      _showMessage('Error: No hay datos de usuario', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = authProvider.currentUser!.id!;
      final existingEntry = _dayData?['entry'] as DailyEntryModel?;

      String finalReflection = _reflectionController.text.trim();

      // Si hay entrada existente, preservar reflexión anterior
      if (existingEntry != null && existingEntry.freeReflection.isNotEmpty) {
        if (finalReflection.isNotEmpty && finalReflection != existingEntry.freeReflection) {
          finalReflection = '${existingEntry.freeReflection}\n\n--- Reflexión adicional ---\n$finalReflection';
        } else if (finalReflection.isEmpty) {
          finalReflection = existingEntry.freeReflection;
        }
      }

      final entry = existingEntry?.copyWith(
        freeReflection: finalReflection.isNotEmpty
            ? finalReflection
            : 'Día revisado sin reflexión adicional',
        worthIt: _worthIt,
        moodScore: _moodScore.round(),
        updatedAt: DateTime.now(),
      ) ?? DailyEntryModel.create(
        userId: userId,
        freeReflection: finalReflection.isNotEmpty
            ? finalReflection
            : 'Día revisado sin momentos específicos',
        worthIt: _worthIt,
      ).copyWith(moodScore: _moodScore.round());

      final entryId = await _databaseService.saveDailyEntry(entry);

      if (entryId != null) {
        _showMessage('✅ Reflexión final guardada correctamente');

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/calendar');
          }
        });
      } else {
        _showMessage('Error guardando la reflexión', isError: true);
      }

    } catch (e) {
      _logger.e('❌ Error guardando revisión diaria: $e');
      _showMessage('Error guardando la reflexión', isError: true);
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