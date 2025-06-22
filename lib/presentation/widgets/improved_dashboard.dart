// lib/presentation/widgets/improved_dashboard.dart

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO

class ImprovedDashboard extends StatelessWidget {
  final int userId;

  const ImprovedDashboard({
    Key? key,
    required this.userId,
  }) : super(key: key);

  /// Parsea de forma segura un valor dinámico a un número (num).
  /// Maneja nulos, números existentes y representaciones de números en String.
  num _parseNum(dynamic value, {num fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  /// Parsea de forma segura un valor dinámico a un String.
  /// Maneja nulos devolviendo un valor por defecto.
  String _parseString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PROVIDER ARREGLADO
    final analytics = context.watch<OptimizedAnalyticsProvider>();

    // Estado de carga y error
    if (analytics.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (analytics.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error al cargar los datos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                analytics.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => analytics.loadCompleteAnalytics(userId),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Extracción de datos con métodos seguros
    final summary = analytics.getDashboardSummary();
    final stressAlerts = analytics.getStressAlerts();
    final recommendations = analytics.getTopRecommendations();

    // UI Principal del Dashboard
    return Column(
      children: [
        // Score principal
        _buildMainScoreCard(analytics),
        const SizedBox(height: 20),

        // Alertas si las hay
        if (stressAlerts['requires_attention'] == true)
          _buildStressAlert(stressAlerts),

        // Stats rápidas
        _buildQuickStats(context, analytics),
        const SizedBox(height: 20),

        // Recomendaciones
        if (recommendations.isNotEmpty)
          _buildRecommendationsSection(recommendations),
      ],
    );
  }

  Widget _buildMainScoreCard(OptimizedAnalyticsProvider analytics) {
    final wellbeingStatus = analytics.getWellbeingStatus();
    final score = _parseNum(wellbeingStatus['score'], fallback: 0).toInt();
    final level = _parseString(wellbeingStatus['level'], fallback: 'Sin datos');
    final emoji = _parseString(wellbeingStatus['emoji'], fallback: '📊');
    final message = _parseString(wellbeingStatus['message'], fallback: 'Registra algunos días para ver tu progreso');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor(score),
            _getScoreColor(score).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(score).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nivel $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '/10',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressAlert(Map<String, dynamic> stressAlerts) {
    final alertColor = stressAlerts['alert_color'] as Color? ?? Colors.orange;
    final alertIcon = _parseString(stressAlerts['alert_icon'], fallback: '⚠️');
    final alertTitle = _parseString(stressAlerts['alert_title'], fallback: 'Alerta');
    final recommendations = stressAlerts['recommendations'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(alertIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alertTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: alertColor,
                  ),
                ),
              ),
            ],
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recomendación: ${_parseString(recommendations.first)}',
              style: TextStyle(
                fontSize: 14,
                color: (Theme.of(context as BuildContext).textTheme.bodyMedium?.color ?? Colors.white).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, OptimizedAnalyticsProvider analytics) {
    final streakData = analytics.getStreakData();
    final moodInsights = analytics.getQuickStatsMoodInsights();
    final diversityInsights = analytics.getQuickStatsDiversityInsights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas Rápidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '🔥',
                'Racha Actual',
                '${_parseNum(streakData['current']).toInt()} días',
                'Mejor: ${_parseNum(streakData['longest']).toInt()}',
                Colors.orange.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                _parseString(moodInsights['trend_icon'], fallback: '😊'),
                'Mood Promedio',
                '${_parseNum(moodInsights['avg_mood']).toStringAsFixed(1)}/10',
                _parseString(moodInsights['trend_description'], fallback: 'Estable'),
                moodInsights['trend_color'] as Color? ?? Colors.blue.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '🌈',
                'Diversidad',
                '${_parseNum(diversityInsights['categories_used']).toInt()}/${_parseNum(diversityInsights['max_categories']).toInt()}',
                _parseString(diversityInsights['message'], fallback: 'Explora más'),
                Colors.purple.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '📊',
                'Bienestar',
                '${analytics.wellbeingScore}/10',
                analytics.wellbeingLevel,
                _getScoreColor(analytics.wellbeingScore),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String icon, String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<Map<String, dynamic>> recommendations) {
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
        const SizedBox(height: 12),
        ...recommendations.take(3).map((rec) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e).withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                _parseString(rec['emoji'], fallback: '💡'),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _parseString(rec['title'], fallback: 'Recomendación'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _parseString(rec['description'], fallback: ''),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(_parseString(rec['priority'], fallback: 'low')),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPriorityLabel(_parseString(rec['priority'], fallback: 'low')),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green.shade400;
    if (score >= 6) return Colors.blue.shade400;
    if (score >= 4) return Colors.orange.shade400;
    return Colors.red.shade400;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'low':
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MEDIA';
      case 'low':
        return 'BAJA';
      default:
        return 'INFO';
    }
  }
}