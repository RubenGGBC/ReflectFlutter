import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/modern_design_system.dart';
import '../../providers/optimized_providers.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<OptimizedAnalyticsProvider>(context);
    final wellbeingStatus = analyticsProvider.getWellbeingStatus();
    final weeklyComparison = analyticsProvider.getWeeklyComparison();
    final predictions = analyticsProvider.getWellbeingPrediction();
    final recommendations = analyticsProvider.getPersonalizedRecommendations();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Mi Progreso', style: ModernTypography.heading3),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN OVERVIEW ---
            const Text('Visión General', style: ModernTypography.heading2),
            const SizedBox(height: ModernSpacing.md),
            _buildOverviewCard(
              title: 'Ánimo',
              value: (wellbeingStatus['mood'] as double? ?? 7.2).toStringAsFixed(1),
              change: (weeklyComparison['mood_change'] as double? ?? 1.2),
              icon: Icons.sentiment_satisfied_alt,
              color: Colors.green,
            ),
            const SizedBox(height: ModernSpacing.sm),
            _buildOverviewCard(
              title: 'Estrés',
              value: (wellbeingStatus['stress'] as double? ?? 3.5).toStringAsFixed(1),
              change: (weeklyComparison['stress_change'] as double? ?? -0.5),
              icon: Icons.waves,
              color: Colors.orange,
              isStress: true,
            ),
            const SizedBox(height: ModernSpacing.sm),
            _buildOverviewCard(
              title: 'Sueño',
              value: (wellbeingStatus['sleep'] as double? ?? 8.1).toStringAsFixed(1),
              change: (weeklyComparison['sleep_change'] as double? ?? 0.8),
              icon: Icons.nights_stay,
              color: Colors.blue,
            ),
            const SizedBox(height: ModernSpacing.lg),

            // --- SECCIÓN PREDICCIONES ---
            const Text('Predicciones IA', style: ModernTypography.heading2),
            const SizedBox(height: ModernSpacing.md),
            _buildPredictionCard(
              context,
              title: 'Ánimo',
              predictionText:
              "Tu ánimo se predice que será de ${(predictions['mood_prediction'] as double? ?? 7.5).toStringAsFixed(1)} mañana.",
              imageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=500', // Reemplazar con assets
            ),
            const SizedBox(height: ModernSpacing.sm),
            _buildPredictionCard(
              context,
              title: 'Nivel de Estrés',
              predictionText:
              "Tu nivel de estrés se predice que será de ${(predictions['stress_prediction'] as double? ?? 3.2).toStringAsFixed(1)} mañana.",
              imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500', // Reemplazar con assets
            ),
            const SizedBox(height: ModernSpacing.lg),

            // --- SECCIÓN SOLUCIONES ---
            const Text('Soluciones Recomendadas', style: ModernTypography.heading2),
            const SizedBox(height: ModernSpacing.md),
            ...recommendations.map((rec) => _buildSolutionCard(
              context,
              title: rec['title'] ?? 'Recomendación',
              description: rec['description'] ?? 'Una acción para mejorar tu bienestar.',
              imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500', // Reemplazar
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required double change,
    required IconData icon,
    required Color color,
    bool isStress = false,
  }) {
    final bool isPositive = isStress ? change < 0 : change > 0;
    final String sign = change > 0 ? '+' : '';

    return ModernCard(
      backgroundColor: const Color(0xFF1E1E1E),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: ModernSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ModernTypography.bodyLarge),
              Text(value, style: ModernTypography.heading2.copyWith(color: color)),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: ModernSpacing.xs),
              Text(
                '$sign${change.toStringAsFixed(1)}%',
                style: ModernTypography.bodyMedium.copyWith(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, {required String title, required String predictionText, required String imageUrl}) {
    return ModernCard(
      backgroundColor: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(ModernSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: ModernSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PREDICCIÓN', style: ModernTypography.caption.copyWith(color: Colors.amber)),
                  Text(title, style: ModernTypography.heading4),
                  const SizedBox(height: ModernSpacing.xs),
                  Text(predictionText, style: ModernTypography.bodyMedium),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(BuildContext context, {required String title, required String description, required String imageUrl}) {
    return ModernCard(
      backgroundColor: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(ModernSpacing.sm),
      margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: ModernSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SOLUCIÓN', style: ModernTypography.caption.copyWith(color: Colors.cyanAccent)),
                  Text(title, style: ModernTypography.heading4),
                  const SizedBox(height: ModernSpacing.xs),
                  Text(description, style: ModernTypography.bodyMedium),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}