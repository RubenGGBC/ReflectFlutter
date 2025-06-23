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

class AICoachScreenV2 extends StatefulWidget {
  const AICoachScreenV2({super.key});

  @override
  State<AICoachScreenV2> createState() => _AICoachScreenV2State();
}

class _AICoachScreenV2State extends State<AICoachScreenV2> {

  // Simplemente genera la UI, el estado lo maneja el AIProvider
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        title: const Text('Tu Coach de Bienestar IA'),
        backgroundColor: ModernColors.darkPrimary,
      ),
      body: Consumer2<OptimizedAuthProvider, AIProvider>(
        builder: (context, authProvider, aiProvider, child) {
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            return const Center(child: Text('Inicia sesión para usar el coach.'));
          }

          // La UI cambia según el estado del AIProvider
          return _buildMainView(authProvider, aiProvider);
        },
      ),
    );
  }

  Widget _buildMainView(OptimizedAuthProvider auth, AIProvider ai) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Si la IA no está inicializada, muestra el botón para empezar.
          if (!ai.isInitialized && !ai.isInitializing)
            _buildInitializeCard(ai),

          // Si se está inicializando, muestra el progreso.
          if (ai.isInitializing)
            _buildInitializingCard(ai),

          // Si hay un error, lo muestra.
          if (ai.errorMessage != null)
            _buildErrorCard(ai),

          // Si la IA está lista, muestra el generador de resúmenes.
          if (ai.isInitialized)
            _buildGenerateSummaryCard(auth, ai),

          // Muestra el último resumen generado.
          if (ai.lastSummary != null)
            _buildSummaryDisplay(ai.lastSummary!),
        ],
      ),
    );
  }

  // Widget para iniciar el proceso
  Widget _buildInitializeCard(AIProvider ai) {
    return ModernCard(
      child: Column(
        children: [
          const Icon(Icons.psychology, size: 48, color: ModernColors.accentPurple),
          const SizedBox(height: 16),
          const Text('Activa tu Coach de IA', style: ModernTypography.heading2),
          const SizedBox(height: 8),
          const Text(
            'El coach necesita descargar un modelo de lenguaje (2.1 GB) para funcionar sin conexión. Este proceso solo se realizará una vez.',
            textAlign: TextAlign.center,
            style: ModernTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          ModernButton(
            text: 'Descargar y Activar IA',
            onPressed: () => _confirmAndStartDownload(ai),
          )
        ],
      ),
    );
  }

  // Widget para mostrar el progreso de la descarga/inicialización
  Widget _buildInitializingCard(AIProvider ai) {
    return ModernCard(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(ai.status, style: ModernTypography.heading3),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ai.initProgress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text('${(ai.initProgress * 100).toStringAsFixed(1)}%', style: ModernTypography.bodySmall)
        ],
      ),
    );
  }

  // Widget para mostrar errores
  Widget _buildErrorCard(AIProvider ai) {
    return ModernCard(
      backgroundColor: ModernColors.error.withOpacity(0.2),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: ModernColors.error, size: 32),
          const SizedBox(height: 12),
          Text("Error de Inicialización", style: ModernTypography.heading3.copyWith(color: ModernColors.error)),
          const SizedBox(height: 8),
          Text(ai.errorMessage!, style: ModernTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ModernButton(text: "Reintentar", onPressed: () => ai.initializeAI(), isPrimary: false)
        ],
      ),
    );
  }

  // Widget para generar el resumen cuando la IA está lista
  Widget _buildGenerateSummaryCard(OptimizedAuthProvider auth, AIProvider ai) {
    return ModernCard(
      child: Column(
        children: [
          const Text('Genera tu Análisis Semanal', style: ModernTypography.heading3),
          const SizedBox(height: 12),
          Text(ai.status, style: ModernTypography.bodySmall),
          const SizedBox(height: 16),
          ModernButton(
            text: 'Analizar mi Semana',
            onPressed: () => _generateSummary(auth, ai),
            isLoading: ai.isInitializing,
          )
        ],
      ),
    );
  }

  // Widget para mostrar el resumen de la IA
  Widget _buildSummaryDisplay(AIResponseModel summary) {
    return ModernCard(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Análisis del Coach', style: ModernTypography.heading2),
          const Divider(height: 24),

          Text('Resumen', style: ModernTypography.heading3.copyWith(color: ModernColors.accentBlue)),
          const SizedBox(height: 8),
          Text(summary.summary, style: ModernTypography.bodyMedium),
          const SizedBox(height: 20),

          Text('Insights Clave', style: ModernTypography.heading3.copyWith(color: ModernColors.accentGreen)),
          const SizedBox(height: 8),
          ...summary.insights.map((insight) => ListTile(
            leading: const Icon(Icons.lightbulb_outline, color: ModernColors.accentGreen),
            title: Text(insight, style: ModernTypography.bodyMedium),
          )),
          const SizedBox(height: 20),

          Text('Sugerencias', style: ModernTypography.heading3.copyWith(color: ModernColors.accentOrange)),
          const SizedBox(height: 8),
          ...summary.suggestions.map((suggestion) => ListTile(
            leading: const Icon(Icons.thumb_up_alt_outlined, color: ModernColors.accentOrange),
            title: Text(suggestion, style: ModernTypography.bodyMedium),
          )),
        ],
      ),
    );
  }

  // Lógica para confirmar y empezar la descarga
  void _confirmAndStartDownload(AIProvider ai) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Descarga'),
        content: const Text(
            'Se descargará el modelo de IA (aprox. 2.1 GB). Se recomienda usar Wi-Fi. ¿Deseas continuar?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Descargar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ai.initializeAI();
            },
          ),
        ],
      ),
    );
  }

  // Lógica para generar el resumen
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