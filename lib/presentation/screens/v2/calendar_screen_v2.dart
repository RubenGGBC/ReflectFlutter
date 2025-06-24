// lib/presentation/screens/v2/calendar_screen_v2.dart
// Pantalla de calendario completamente arreglada

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
import '../components/modern_design_system.dart';

class CalendarScreenV2 extends StatefulWidget {
  const CalendarScreenV2({super.key});

  @override
  State<CalendarScreenV2> createState() => _CalendarScreenV2State();
}

class _CalendarScreenV2State extends State<CalendarScreenV2> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = context.read<OptimizedAuthProvider>(); // ✅ PROVIDER ARREGLADO
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedAnalyticsProvider>().loadCompleteAnalytics(user.id, days: 90); // ✅ PROVIDER ARREGLADO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: const Text(
          'Calendario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<OptimizedAnalyticsProvider>( // ✅ PROVIDER ARREGLADO
        builder: (context, analytics, child) {
          if (analytics.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthHeader(),
                const SizedBox(height: 24),
                _buildCalendarGrid(analytics),
                const SizedBox(height: 24),
                _buildSelectedDayDetails(analytics),
                const SizedBox(height: 24),
                _buildMonthStats(analytics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
              });
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
              });
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(OptimizedAnalyticsProvider analytics) {
    final moodData = analytics.getMoodChartData();
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                .map((day) => Text(
              day,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Grid de días
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 semanas
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayWeekday + 2;

              if (dayNumber <= 0 || dayNumber > daysInMonth) {
                return const SizedBox(); // Días vacíos
              }

              final dayDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final hasData = _hasDataForDate(dayDate, moodData);
              final moodScore = _getMoodForDate(dayDate, moodData);
              final isSelected = dayDate.day == _selectedDate.day &&
                  dayDate.month == _selectedDate.month &&
                  dayDate.year == _selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = dayDate;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ModernColors.accentBlue
                        : hasData
                        ? _getMoodColor(moodScore).withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: hasData
                        ? Border.all(color: _getMoodColor(moodScore), width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildSelectedDayDetails(OptimizedAnalyticsProvider analytics) {
    final moodData = analytics.getMoodChartData();
    final dayData = _getDataForDate(_selectedDate, moodData);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (dayData != null) ...[
            _buildDetailRow('Estado de ánimo', '${(dayData['mood'] as double? ?? 0.0).toStringAsFixed(1)}/10', _getMoodColor(dayData['mood'] as double? ?? 0.0)),
            _buildDetailRow('Nivel de energía', '${(dayData['energy'] as double? ?? 0.0).toStringAsFixed(1)}/10', Colors.yellow),
            _buildDetailRow('Nivel de estrés', '${(dayData['stress'] as double? ?? 0.0).toStringAsFixed(1)}/10', Colors.red),
          ] else ...[
            const Text(
              'No hay registro para este día',
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showCreateEntryDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentBlue,
              ),
              child: const Text('Crear Registro'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStats(OptimizedAnalyticsProvider analytics) {
    final summary = analytics.getDashboardSummary();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas del Mes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('📊', 'Entradas', '${summary['total_entries'] ?? 0}'),
              _buildStatItem('🔥', 'Racha', '${summary['current_streak'] ?? 0} días'),
              _buildStatItem('😊', 'Mood Avg', '${(summary['avg_mood'] as double? ?? 0.0).toStringAsFixed(1)}/10'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  bool _hasDataForDate(DateTime date, List<Map<String, dynamic>> moodData) {
    return moodData.any((data) {
      final entryDate = DateTime.parse(data['date'] as String);
      return entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day;
    });
  }

  double _getMoodForDate(DateTime date, List<Map<String, dynamic>> moodData) {
    try {
      final data = moodData.firstWhere((data) {
        final entryDate = DateTime.parse(data['date'] as String);
        return entryDate.year == date.year &&
            entryDate.month == date.month &&
            entryDate.day == date.day;
      });
      return data['mood'] as double? ?? 0.0;
    } catch (e) {
      return 0.0;
    }
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

  Color _getMoodColor(double mood) {
    if (mood >= 7) return Colors.green;
    if (mood >= 5) return Colors.blue;
    if (mood >= 3) return Colors.orange;
    return Colors.red;
  }

  void _showCreateEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernColors.surfaceDark,
        title: const Text(
          'Crear Registro',
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

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }
}