// ============================================================================
// presentation/screens/daily_detail_screen.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../../data/services/database_service.dart';
import '../../data/models/daily_entry_model.dart';

class DailyDetailScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DailyDetailScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DailyDetailScreen> createState() => _DailyDetailScreenState();
}

class _DailyDetailScreenState extends State<DailyDetailScreen> {
  final Logger _logger = Logger();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = true;
  DailyEntryModel? _dayEntry;
  Map<String, dynamic>? _dayData;
  List<Map<String, dynamic>> _timeline = [];

  @override
  void initState() {
    super.initState();
    _loadDayData();
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
    final dayName = _getDayName(widget.selectedDate.weekday);
    final monthName = _getMonthName(widget.selectedDate.month);
    final dateStr = '$dayName ${widget.selectedDate.day} de $monthName ${widget.selectedDate.year}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: themeProvider.currentColors.gradientHeader,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
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
                  const Expanded(
                    child: Text(
                      '📅 Resumen del Día',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              if (_dayEntry != null) ...[
                const SizedBox(height: 12),
                _buildQuickStats(themeProvider),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('😊', _dayEntry!.positiveTags.length.toString(), 'Positivos'),
          _buildStatItem('😓', _dayEntry!.negativeTags.length.toString(), 'Difíciles'),
          _buildStatItem('🎭', '${_dayEntry!.moodScore ?? 5}', 'Mood'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          const SizedBox(height: 12),

          // ✅ MEJORAR: Mostrar reflexión organizada con momentos
          _buildOrganizedReflection(themeProvider),
        ],
      ),
    );
  }
  Widget _buildContent(ThemeProvider themeProvider) {
    if (_dayEntry == null) {
      return _buildEmptyState(themeProvider);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Resumen principal
          _buildSummaryCard(themeProvider),
          const SizedBox(height: 16),

          // Timeline si existe
          if (_timeline.isNotEmpty) ...[
            _buildTimelineCard(themeProvider),
            const SizedBox(height: 16),
          ],

          // Tags positivos
          if (_dayEntry!.positiveTags.isNotEmpty) ...[
            _buildTagsCard('✨ Momentos Positivos', _dayEntry!.positiveTags, true, themeProvider),
            const SizedBox(height: 16),
          ],

          // Tags negativos
          if (_dayEntry!.negativeTags.isNotEmpty) ...[
            _buildTagsCard('🌧️ Momentos Difíciles', _dayEntry!.negativeTags, false, themeProvider),
            const SizedBox(height: 16),
          ],

          // Reflexión
          _buildReflectionCard(themeProvider),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: themeProvider.currentColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: themeProvider.currentColors.borderColor),
            ),
            child: const Center(
              child: Text('📭', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin actividad registrada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este día no hay momentos guardados',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.currentColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ThemedButton(
            onPressed: () => Navigator.of(context).pop(),
            type: ThemedButtonType.outlined,
            child: const Text('Volver al calendario'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getMoodColor(_dayEntry!.moodScore?.toDouble() ?? 5.0, themeProvider).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getMoodColor(_dayEntry!.moodScore?.toDouble() ?? 5.0, themeProvider),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getMoodEmoji(_dayEntry!.moodScore?.toDouble() ?? 5.0),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayStatus(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getDayDescription(),
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.currentColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_dayEntry!.worthIt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_dayEntry!.worthIt!
                              ? themeProvider.currentColors.positiveMain
                              : themeProvider.currentColors.negativeMain).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _dayEntry!.worthIt! ? '✅ Mereció la pena' : '❌ No mereció la pena',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _dayEntry!.worthIt!
                                ? themeProvider.currentColors.positiveMain
                                : themeProvider.currentColors.negativeMain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeProvider.currentColors.accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.currentColors.borderColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _dayEntry!.wordCount.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentColors.accentPrimary,
                      ),
                    ),
                    Text(
                      'Palabras',
                      style: TextStyle(
                        fontSize: 10,
                        color: themeProvider.currentColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_dayEntry!.moodScore ?? 5}/10',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getMoodColor(_dayEntry!.moodScore?.toDouble() ?? 5.0, themeProvider),
                      ),
                    ),
                    Text(
                      'Mood Score',
                      style: TextStyle(
                        fontSize: 10,
                        color: themeProvider.currentColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${_dayEntry!.positiveTags.length + _dayEntry!.negativeTags.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentColors.positiveMain,
                      ),
                    ),
                    Text(
                      'Momentos',
                      style: TextStyle(
                        fontSize: 10,
                        color: themeProvider.currentColors.textSecondary,
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

  Widget _buildTimelineCard(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏰ Timeline del Día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...(_timeline.take(5).map((moment) => _buildTimelineItem(moment, themeProvider))),
          if (_timeline.length > 5)
            Text(
              '... y ${_timeline.length - 5} momentos más',
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.currentColors.textHint,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> moment, ThemeProvider themeProvider) {
    final isPositive = moment['type'] == 'positive';
    final color = isPositive
        ? themeProvider.currentColors.positiveMain
        : themeProvider.currentColors.negativeMain;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(moment['emoji'], style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            moment['time'],
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              moment['text'],
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.currentColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard(String title, List tags, bool isPositive, ThemeProvider themeProvider) {
    final color = isPositive
        ? themeProvider.currentColors.positiveMain
        : themeProvider.currentColors.negativeMain;

    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tag.emoji ?? (isPositive ? '✨' : '🌧️'), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      tag.name ?? tag.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.currentColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }




// ============================================================================
// MEJORAS PARA MOSTRAR MOMENTOS EN daily_detail_screen.dart
// ============================================================================



// 2. AÑADIR método para mostrar reflexión organizada:
  Widget _buildOrganizedReflection(ThemeProvider themeProvider) {
    if (_dayEntry == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeProvider.currentColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.currentColors.borderColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          'No hay reflexión para este día.',
          style: TextStyle(
            fontSize: 13,
            color: themeProvider.currentColors.textHint,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final reflection = _dayEntry!.freeReflection;

    // Detectar si es una reflexión con formato de momentos
    if (reflection.contains('=== MOMENTOS DEL DÍA ===')) {
      return _buildFormattedMomentsReflection(reflection, themeProvider);
    } else {
      return _buildSimpleReflection(reflection, themeProvider);
    }
  }

// 3. AÑADIR método para reflexión con momentos formateados:
  Widget _buildFormattedMomentsReflection(String reflection, ThemeProvider themeProvider) {
    final lines = reflection.split('\n');

    // Extraer secciones
    String? savedTime;
    List<String> momentsList = [];
    String? summary;
    List<String> additionalReflections = [];

    bool inMoments = false;
    bool inSummary = false;
    bool inAdditional = false;

    for (String line in lines) {
      if (line.startsWith('Momentos guardados a:')) {
        savedTime = line.replaceFirst('Momentos guardados a: ', '');
      } else if (line.contains('=== MOMENTOS DEL DÍA ===')) {
        inMoments = true;
        inSummary = false;
        inAdditional = false;
      } else if (line.contains('=== RESUMEN ===')) {
        inMoments = false;
        inSummary = true;
        inAdditional = false;
      } else if (line.contains('=== REFLEXIÓN ADICIONAL ===') || line.contains('--- Reflexión adicional')) {
        inMoments = false;
        inSummary = false;
        inAdditional = true;
      } else if (inMoments && line.trim().isNotEmpty) {
        momentsList.add(line.trim());
      } else if (inSummary && line.trim().isNotEmpty && line.startsWith('•')) {
        summary = '${summary ?? ''}$line\n';
      } else if (inAdditional && line.trim().isNotEmpty && !line.startsWith('Añadida a las')) {
        additionalReflections.add(line.trim());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con hora de guardado
        if (savedTime != null)
          Container(
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
                color: themeProvider.currentColors.accentPrimary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: themeProvider.currentColors.accentPrimary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Momentos guardados a las $savedTime',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.currentColors.accentPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getTimeOfDayEmoji(savedTime),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

        if (savedTime != null) const SizedBox(height: 16),

        // Lista de momentos en timeline
        if (momentsList.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.timeline,
                size: 18,
                color: themeProvider.currentColors.positiveMain,
              ),
              const SizedBox(width: 8),
              Text(
                '📝 Momentos del día (${momentsList.length}):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeProvider.currentColors.surface,
                  themeProvider.currentColors.surfaceVariant.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeProvider.currentColors.borderColor.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.currentColors.shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: momentsList.length,
              itemBuilder: (context, index) {
                return _buildEnhancedMomentItem(
                    momentsList[index],
                    index,
                    momentsList.length,
                    themeProvider
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],

        // Resumen estadístico
        if (summary != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.currentColors.positiveMain.withOpacity(0.1),
                  themeProvider.currentColors.positiveMain.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeProvider.currentColors.positiveMain.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      size: 18,
                      color: themeProvider.currentColors.positiveMain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Resumen del día:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentColors.positiveMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  summary.trim(),
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Reflexiones adicionales
        if (additionalReflections.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.currentColors.accentSecondary.withOpacity(0.1),
                  themeProvider.currentColors.accentSecondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeProvider.currentColors.accentSecondary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 18,
                      color: themeProvider.currentColors.accentSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reflexiones adicionales:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentColors.accentSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...additionalReflections.map((reflection) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      reflection,
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.currentColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
  Widget _buildSimpleReflection(String reflection, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.currentColors.accentPrimary.withOpacity(0.1),
            themeProvider.currentColors.accentPrimary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.currentColors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 16,
                color: themeProvider.currentColors.accentPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Reflexión del día:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.accentPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reflection.isNotEmpty ? reflection : 'Sin reflexión escrita para este día.',
            style: TextStyle(
              fontSize: 13,
              color: themeProvider.currentColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEnhancedMomentItem(String momentText, int index, int total, ThemeProvider themeProvider) {
    // Parsear: "HH:MM 😊 Texto del momento"
    final parts = momentText.split(' ');
    if (parts.length < 3) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Text(
          momentText,
          style: TextStyle(
            fontSize: 11,
            color: themeProvider.currentColors.textSecondary,
          ),
        ),
      );
    }

    final time = parts[0];
    final emoji = parts[1];
    final text = parts.skip(2).join(' ');
    final isPositive = _isPositiveEmoji(emoji);
    final color = isPositive
        ? themeProvider.currentColors.positiveMain
        : themeProvider.currentColors.negativeMain;
    final isLast = index == total - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline visual con línea conectora
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 14)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.5),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Contenido del momento
        Expanded(
          child: Container(
             margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getRelativeTimeDescription(time),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPositive ? 'POSITIVO' : 'DIFÍCIL',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textPrimary,
                    height: 1.3,
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

  Future<void> _loadDayData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    try {
      final userId = authProvider.currentUser!.id!;
      final dayData = await _databaseService.getDayEntryWithTimeline(userId, widget.selectedDate);

      if (dayData != null) {
        _dayEntry = dayData['entry'];
        _timeline = List<Map<String, dynamic>>.from(dayData['timeline']);
      }

      _logger.d('📊 Datos cargados para ${widget.selectedDate}: entrada=${_dayEntry != null}');

    } catch (e) {
      _logger.e('❌ Error cargando datos del día: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getDayStatus() {
    final moodScore = _dayEntry!.moodScore ?? 5;
    if (moodScore >= 8) return 'Día excelente 🌟';
    if (moodScore >= 6) return 'Buen día ✨';
    if (moodScore >= 4) return 'Día regular 😊';
    return 'Día difícil 🌧️';
  }

  String _getDayDescription() {
    final positive = _dayEntry!.positiveTags.length;
    final negative = _dayEntry!.negativeTags.length;
    final total = positive + negative;

    if (total == 0) return 'Sin momentos registrados';
    if (positive > negative) return '$positive momentos positivos predominaron';
    if (negative > positive) return '$negative momentos difíciles predominaron';
    return '$total momentos balanceados';
  }

  Color _getMoodColor(double mood, ThemeProvider themeProvider) {
    if (mood <= 3) return themeProvider.currentColors.negativeMain;
    if (mood <= 6) return Colors.orange;
    return themeProvider.currentColors.positiveMain;
  }

  String _getMoodEmoji(double mood) {
    const moodEmojis = ["😢", "😔", "😐", "🙂", "😊", "😄", "🤗", "😁", "🥳", "🤩"];
    final index = (mood - 1).clamp(0, 9).toInt();
    return moodEmojis[index];
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month];
  }
  bool _isPositiveEmoji(String emoji) {
    const positiveEmojis = [
      '😊', '😄', '🤗', '😁', '🥳', '🤩', '😍', '🥰',
      '🎉', '🏆', '🎯', '💪', '✨', '🌟', '🔥', '⭐',
      '😌', '🧘‍♀️', '☕', '🍵', '🌸', '🌿', '🌅',
      '❤️', '💕', '💖', '💝', '😘', '💞', '💓',
      '🎵', '🎸', '🎨', '🎭', '📚', '🎮'
    ];

    return positiveEmojis.contains(emoji);
  }

  String _getRelativeTimeDescription(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return timeStr;

      final hour = int.parse(parts[0]);

      if (hour >= 5 && hour < 12) {
        return '$timeStr (mañana)';
      } else if (hour >= 12 && hour < 17) {
        return '$timeStr (tarde)';
      } else if (hour >= 17 && hour < 21) {
        return '$timeStr (atardecer)';
      } else {
        return '$timeStr (noche)';
      }
    } catch (e) {
      return timeStr;
    }
  }

  String _getTimeOfDayEmoji(String? timeStr) {
    if (timeStr == null) return '🕐';

    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return '🕐';

      final hour = int.parse(parts[0]);

      if (hour >= 5 && hour < 12) {
        return '🌅';
      } else if (hour >= 12 && hour < 17) {
        return '☀️';
      } else if (hour >= 17 && hour < 21) {
        return '🌆';
      } else {
        return '🌙';
      }
    } catch (e) {
      return '🕐';
    }
  }
}