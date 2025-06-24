// lib/presentation/screens/v2/daily_detail_screen_v2.dart
// Pantalla de detalle diario completamente arreglada

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
import '../components/modern_design_system.dart';

class DailyDetailScreenV2 extends StatefulWidget {
  final DateTime date;

  const DailyDetailScreenV2({
    super.key,
    required this.date,
  });

  @override
  State<DailyDetailScreenV2> createState() => _DailyDetailScreenV2State();
}

class _DailyDetailScreenV2State extends State<DailyDetailScreenV2> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>(); // ✅ PROVIDER ARREGLADO
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id, days: 30); // ✅ PROVIDER ARREGLADO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: Text(
          'Detalle ${widget.date.day}/${widget.date.month}/${widget.date.year}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
        builder: (context, analytics, child) {
          if (analytics.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final moodData = analytics.getMoodChartData();
          final dayData = _getDataForDate(widget.date, moodData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(),
                const SizedBox(height: 24),
                if (dayData != null) ...[
                  _buildMoodSection(dayData),
                  const SizedBox(height: 16),
                  _buildMetricsSection(dayData),
                  const SizedBox(height: 16),
                  _buildRecommendationsSection(analytics),
                ] else ...[
                  _buildNoDataSection(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${widget.date.day}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_getMonthName(widget.date.month)} ${widget.date.year}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Text(
            _getDayOfWeek(widget.date),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection(Map<String, dynamic> dayData) {
    final mood = (dayData['mood'] as double? ?? 5.0);
    final emoji = _getMoodEmoji(mood);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'Estado de Ánimo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${mood.toStringAsFixed(1)}/10',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: mood / 10,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getMoodColor(mood),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMoodDescription(mood),
            style: TextStyle(
              color: _getMoodColor(mood),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(Map<String, dynamic> dayData) {
    final energy = (dayData['energy'] as double? ?? 5.0);
    final stress = (dayData['stress'] as double? ?? 5.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas del Día',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('⚡', 'Energía', energy, Colors.yellow)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('😰', 'Estrés', stress, Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        // Indicadores adicionales
        _buildMetricIndicators(dayData),
      ],
    );
  }

  Widget _buildMetricCard(String emoji, String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 10,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricIndicators(Map<String, dynamic> dayData) {
    final mood = (dayData['mood'] as double? ?? 5.0);
    final energy = (dayData['energy'] as double? ?? 5.0);
    final stress = (dayData['stress'] as double? ?? 5.0);

    // Calcular score del día
    final dayScore = (mood + energy + (10 - stress)) / 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Puntuación del Día',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${dayScore.toStringAsFixed(1)}/10',
                style: TextStyle(
                  color: _getMoodColor(dayScore),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: dayScore / 10,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(_getMoodColor(dayScore)),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            _getDayScoreMessage(dayScore),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(OptimizedAnalyticsProvider analytics) {
    final recommendations = analytics.getPriorityRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recomendaciones',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendations.take(2).map((rec) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(rec['emoji'] ?? '💡', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rec['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildNoDataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sentiment_neutral,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay datos para este día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea una entrada para comenzar a registrar tu día',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateEntryDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear Entrada'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernColors.accentBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? _getDataForDate(DateTime date, List<Map<String, dynamic>> moodData) {
    try {
      return moodData.firstWhere((data) {
        final entryDate = DateTime.parse(data['date'] as String);
        return entryDate.year == date.year &&
            entryDate.month == date.month &&
            entryDate.day == date.day;
      });
    } catch (e) {
      return null;
    }
  }

  void _showCreateEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernColors.surfaceDark,
        title: const Text(
          'Crear Entrada',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta funcionalidad será implementada próximamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(double mood) {
    if (mood >= 9) return '🤩';
    if (mood >= 8) return '😍';
    if (mood >= 7) return '😊';
    if (mood >= 6) return '🙂';
    if (mood >= 5) return '😐';
    if (mood >= 4) return '🙁';
    if (mood >= 3) return '😔';
    if (mood >= 2) return '😢';
    return '😭';
  }

  Color _getMoodColor(double mood) {
    if (mood >= 7) return Colors.green;
    if (mood >= 5) return Colors.blue;
    if (mood >= 3) return Colors.orange;
    return Colors.red;
  }

  String _getMoodDescription(double mood) {
    if (mood >= 8) return 'Excelente';
    if (mood >= 6) return 'Muy bien';
    if (mood >= 5) return 'Bien';
    if (mood >= 4) return 'Regular';
    if (mood >= 3) return 'Bajo';
    return 'Muy bajo';
  }

  String _getDayScoreMessage(double score) {
    if (score >= 8) return '¡Día fantástico! Mantén este momentum';
    if (score >= 6) return 'Buen día en general, sigue así';
    if (score >= 4) return 'Día regular, pequeñas mejoras pueden ayudar';
    return 'Día desafiante, considera actividades de autocuidado';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    return days[date.weekday - 1];
  }
}