// lib/presentation/screens/v2/ai_coach_screen_v2.dart
// ✅ ESTRUCTURA CORREGIDA PARA TU PROYECTO

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/optimized_models.dart';
import '../../../data/services/optimized_database_service.dart';
import '../../providers/optimized_providers.dart';
import '../components/modern_design_system.dart';

class AICoachScreenV2 extends StatefulWidget {
  const AICoachScreenV2({super.key});

  @override
  State<AICoachScreenV2> createState() => _AICoachScreenV2State();
}

class _AICoachScreenV2State extends State<AICoachScreenV2>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isGenerating = false;
  Map<String, dynamic>? _lastSummary;
  String _status = 'IA Coach lista para usar';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadLastSummary();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  void _loadLastSummary() {
    // Por ahora, simular que no hay resumen previo
    setState(() {
      _lastSummary = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: const Text(
          'Tu Coach de Bienestar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Consumer<OptimizedAuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
            return _buildNotLoggedInView();
          }

          return _buildMainView(authProvider);
        },
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.purple.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'Acceso Restringido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Necesitas iniciar sesión para acceder a tu Coach de IA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(OptimizedAuthProvider authProvider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(authProvider.currentUser!),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildGenerateSummaryCard(),
            if (_lastSummary != null) ...[
              const SizedBox(height: 16),
              _buildSummaryCard(_lastSummary!),
            ],
            const SizedBox(height: 16),
            _buildFeaturesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(OptimizedUserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withOpacity(0.8),
            Colors.blue.shade400.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade400.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user.avatarEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${user.name}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Tu coach personal está listo para ayudarte',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.accentBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coach de IA Activo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.accentPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernColors.accentPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: ModernColors.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Resumen Semanal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Genera un análisis personalizado de tu semana con insights y sugerencias para mejorar tu bienestar.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateWeeklySummary,
              icon: _isGenerating
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.psychology),
              label: Text(
                _isGenerating ? 'Analizando...' : 'Generar Resumen de Esta Semana',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tu Resumen Semanal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary['summary'] ?? 'Resumen no disponible',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          if (summary['insights'] != null && summary['insights'].isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Insights Clave:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...List<String>.from(summary['insights']).map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(color: ModernColors.accentBlue),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (summary['suggestions'] != null && summary['suggestions'].isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Sugerencias:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...List<String>.from(summary['suggestions']).map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '→ ',
                    style: TextStyle(color: Colors.green.shade400),
                  ),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 12),
          Text(
            'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.new_releases,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Próximamente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Estamos trabajando en nuevas funciones para tu Coach:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem('🧠', 'IA avanzada local'),
          _buildFeatureItem('🔍', 'Búsqueda semántica'),
          _buildFeatureItem('💡', 'Sugerencias proactivas'),
          _buildFeatureItem('📊', 'Correlaciones automáticas'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateWeeklySummary() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() {
      _isGenerating = true;
      _status = 'Analizando tu semana...';
    });

    try {
      // Obtener datos de la semana
      final dbService = OptimizedDatabaseService();
      final weeklyData = await dbService.getWeeklyDataForAI(authProvider.currentUser!.id);

      // Simular análisis IA (por ahora)
      await Future.delayed(const Duration(seconds: 3));

      // Generar resumen basado en datos reales
      final summary = _generateSmartSummary(
        weeklyData,
        authProvider.currentUser!.name,
      );

      setState(() {
        _lastSummary = summary;
        _status = 'Resumen generado correctamente';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Resumen semanal generado exitosamente!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {
      setState(() {
        _status = 'Error generando resumen';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _generateSmartSummary(Map<String, dynamic> weeklyData, String userName) {
    final entries = List<Map<String, dynamic>>.from(weeklyData['entries'] ?? []);
    final moments = List<Map<String, dynamic>>.from(weeklyData['moments'] ?? []);

    // Análisis inteligente de datos
    final moodScores = entries
        .where((e) => e['mood_score'] != null)
        .map((e) => e['mood_score'] as int)
        .toList();

    final energyLevels = entries
        .where((e) => e['energy_level'] != null)
        .map((e) => e['energy_level'] as int)
        .toList();

    final positiveMoments = moments.where((m) => m['type'] == 'positive').length;
    final negativeMoments = moments.where((m) => m['type'] == 'negative').length;

    final avgMood = moodScores.isNotEmpty ? moodScores.reduce((a, b) => a + b) / moodScores.length : 5.0;
    final avgEnergy = energyLevels.isNotEmpty ? energyLevels.reduce((a, b) => a + b) / energyLevels.length : 5.0;

    // Generar resumen personalizado
    String summary;
    List<String> insights = [];
    List<String> suggestions = [];

    if (avgMood >= 7) {
      summary = 'Hola $userName, has tenido una semana fantástica! Tu estado de ánimo promedio fue de ${avgMood.toStringAsFixed(1)}/10, lo cual refleja una actitud muy positiva. ';
    } else if (avgMood >= 5) {
      summary = 'Hola $userName, has tenido una semana equilibrada. Tu estado de ánimo promedio fue de ${avgMood.toStringAsFixed(1)}/10, manteniéndote en un rango estable. ';
    } else {
      summary = 'Hola $userName, parece que has pasado por algunos desafíos esta semana. Tu estado de ánimo promedio fue de ${avgMood.toStringAsFixed(1)}/10, pero recuerda que los altibajos son normales. ';
    }

    if (positiveMoments > negativeMoments) {
      summary += 'Es genial ver que registraste $positiveMoments momentos positivos frente a $negativeMoments negativos. ¡Sigues enfocándote en lo bueno!';
      insights.add('Tienes una tendencia natural a notar y valorar los momentos positivos');
    } else if (negativeMoments > positiveMoments) {
      summary += 'Noté que registraste $negativeMoments momentos desafiantes y $positiveMoments positivos. Es importante reconocer ambos tipos de experiencias.';
      insights.add('Estás siendo honesto contigo mismo al reconocer los momentos difíciles');
      suggestions.add('Intenta también capturar momentos pequeños pero positivos del día');
    }

    // Insights sobre energía
    if (avgEnergy >= 7) {
      insights.add('Tu nivel de energía promedio fue alto (${avgEnergy.toStringAsFixed(1)}/10)');
    } else if (avgEnergy < 5) {
      insights.add('Tu energía estuvo baja esta semana (${avgEnergy.toStringAsFixed(1)}/10)');
      suggestions.add('Considera revisar tu rutina de sueño y actividad física');
    }

    // Sugerencias generales
    if (entries.length < 5) {
      suggestions.add('Intenta reflexionar más días de la semana para obtener mejores insights');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Continúa con tu práctica de auto-reflexión, vas muy bien');
    }

    return {
      'summary': summary,
      'insights': insights,
      'suggestions': suggestions,
      'data': {
        'avgMood': avgMood,
        'avgEnergy': avgEnergy,
        'totalEntries': entries.length,
        'totalMoments': moments.length,
        'positiveMoments': positiveMoments,
        'negativeMoments': negativeMoments,
      }
    };
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernColors.darkSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Tu Coach de Bienestar',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Este coach analiza tus reflexiones y momentos de la semana para generar insights personalizados que te ayuden en tu crecimiento personal.',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(color: ModernColors.accentBlue),
            ),
          ),
        ],
      ),
    );
  }
}