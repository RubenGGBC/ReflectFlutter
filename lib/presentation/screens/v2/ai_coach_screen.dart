// lib/presentation/screens/v2/ai_coach_screen.dart
// VERSIÓN MODIFICADA PARA DESCARGA REAL Y RESPUESTAS DE IA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ai/models/ai_response_model.dart';
import '../../../data/models/optimized_models.dart';
import '../../../data/services/optimized_database_service.dart';
import '../../providers/optimized_providers.dart';
import '../../../ai/provider/ai_provider.dart'; // Importar AIProvider
import '../components/modern_design_system.dart';

// ... imports iguales ...

class AICoachScreenV2 extends StatefulWidget {
  const AICoachScreenV2({super.key});

  @override
  State<AICoachScreenV2> createState() => _AICoachScreenV2State();
}

class _AICoachScreenV2State extends State<AICoachScreenV2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        title: const Text('🧠 Tu Coach de Bienestar IA'),
        backgroundColor: ModernColors.darkPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer2<OptimizedAuthProvider, AIProvider>(
        builder: (context, authProvider, aiProvider, _) {
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            return const Center(
              child: Text(
                'Inicia sesión para usar el coach.',
                style: ModernTypography.bodyMedium,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!aiProvider.isInitialized && !aiProvider.isInitializing)
                  _buildInitializeCard(aiProvider),

                if (aiProvider.isInitializing)
                  _buildInitializingCard(aiProvider),

                if (aiProvider.errorMessage != null)
                  _buildErrorCard(aiProvider),

                if (aiProvider.isInitialized)
                  _buildGenerateSummaryCard(authProvider, aiProvider),

                if (aiProvider.lastSummary != null)
                  _buildSummaryDisplay(aiProvider.lastSummary!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitializeCard(AIProvider ai) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const Icon(Icons.auto_mode_outlined, size: 64, color: ModernColors.accentPurple),
          const SizedBox(height: 20),
          const Text('Activa tu Coach de IA', style: ModernTypography.heading2),
          const SizedBox(height: 12),
          const Text(
            'Se descargará un modelo (2.1 GB) para usar el coach sin conexión. Esto solo ocurre una vez.',
            textAlign: TextAlign.center,
            style: ModernTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          ModernButton(
            icon: Icons.download,
            text: 'Descargar y Activar',
            onPressed: () => _confirmAndStartDownload(ai),
          ),
        ],
      ),
    );
  }

  Widget _buildInitializingCard(AIProvider ai) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const CircularProgressIndicator(strokeWidth: 4, color: ModernColors.accentPurple),
          const SizedBox(height: 20),
          Text(ai.status, style: ModernTypography.heading3),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: ai.initProgress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation(ModernColors.accentPurple),
          ),
          const SizedBox(height: 10),
          Text('${(ai.initProgress * 100).toStringAsFixed(1)}%', style: ModernTypography.bodySmall),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildErrorCard(AIProvider ai) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 20),
      backgroundColor: ModernColors.error.withOpacity(0.15),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 40, color: ModernColors.error),
          const SizedBox(height: 12),
          Text('Error de Inicialización',
              style: ModernTypography.heading3.copyWith(color: ModernColors.error)),
          const SizedBox(height: 10),
          Text(ai.errorMessage!, style: ModernTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ModernButton(
            text: 'Reintentar',
            onPressed: () => ai.initializeAI(),
            isPrimary: false,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateSummaryCard(OptimizedAuthProvider auth, AIProvider ai) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const Text('Genera tu Análisis Semanal', style: ModernTypography.heading3),
          const SizedBox(height: 10),
          Text(ai.status, style: ModernTypography.bodySmall),
          const SizedBox(height: 18),
          ModernButton(
            text: 'Analizar mi Semana',
            icon: Icons.analytics_outlined,
            isLoading: ai.isInitializing,
            onPressed: ai.isInitializing ? null : () => _generateSummary(auth, ai),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDisplay(AIResponseModel summary) {
    return ModernCard(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝 Análisis del Coach', style: ModernTypography.heading2),
          const Divider(height: 28),
          _buildSection('Resumen', summary.summary, ModernColors.accentBlue),
          _buildListSection('Insights Clave', summary.insights, Icons.insights, ModernColors.accentGreen),
          _buildListSection('Sugerencias', summary.suggestions, Icons.recommend, ModernColors.accentOrange),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ModernTypography.heading3.copyWith(color: color)),
        const SizedBox(height: 8),
        Text(content, style: ModernTypography.bodyMedium),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ModernTypography.heading3.copyWith(color: color)),
        const SizedBox(height: 8),
        ...items.map((item) => ListTile(
          dense: true,
          leading: Icon(icon, color: color),
          title: Text(item, style: ModernTypography.bodyMedium),
          contentPadding: EdgeInsets.zero,
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  void _confirmAndStartDownload(AIProvider ai) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descargar modelo de IA?'),
        content: const Text(
          'Se descargará un modelo de IA de 2.1 GB. Se recomienda Wi-Fi. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ai.initializeAI();
            },
            child: const Text('Descargar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSummary(OptimizedAuthProvider auth, AIProvider ai) async {
    final dbService = OptimizedDatabaseService();
    final weeklyData = await dbService.getWeeklyDataForAI(auth.currentUser!.id);

    await ai.generateWeeklySummary(
      weeklyEntries: weeklyData['entries'],
      weeklyMoments: weeklyData['moments'],
      userName: auth.currentUser!.name,
    );
  }
}
