// lib/presentation/screens/v2/ai_coach_screen.dart
// ✅ VERSIÓN CON ANÁLISIS CERCANO Y ESQUEMATIZADO

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
              _buildSchematizedSummaryCard(_lastSummary!),
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
      child: Row(
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
                _isGenerating ? 'Analizando tu semana...' : 'Generar Resumen de Esta Semana',
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

  // ✅ NUEVA UI ESQUEMATIZADA Y AMIGABLE
  Widget _buildSchematizedSummaryCard(Map<String, dynamic> summary) {
    final data = summary['data'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        // Resumen principal con tono cercano
        _buildMainSummarySection(summary),
        const SizedBox(height: 16),

        // Datos de la semana de forma visual
        _buildWeekDataSection(data),
        const SizedBox(height: 16),

        // Lo que me llamó la atención (insights)
        if (summary['insights'] != null && (summary['insights'] as List).isNotEmpty)
          _buildInsightsSection(summary['insights'] as List<String>),
        const SizedBox(height: 16),

        // Cosas que celebramos juntos
        if (summary['momentos_destacados'] != null && (summary['momentos_destacados'] as List).isNotEmpty)
          _buildCelebrationSection(summary['momentos_destacados'] as List<String>),
        const SizedBox(height: 16),

        // Te sugiero que pruebes...
        if (summary['suggestions'] != null && (summary['suggestions'] as List).isNotEmpty)
          _buildSuggestionsSection(summary['suggestions'] as List<String>),
      ],
    );
  }

  Widget _buildMainSummarySection(Map<String, dynamic> summary) {
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
                  Icons.psychology,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mi Análisis de Tu Semana',
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
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Analizado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDataSection(Map<String, dynamic> data) {
    final avgMood = (data['avgMood'] as double? ?? 5.0);
    final avgEnergy = (data['avgEnergy'] as double? ?? 5.0);
    final avgStress = (data['avgStress'] as double? ?? 5.0);
    final totalEntries = data['totalEntries'] as int? ?? 0;
    final totalMoments = data['totalMoments'] as int? ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
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
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Los Números de Tu Semana',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Métricas principales con emojis y colores
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '😊',
                  'Estado de Ánimo',
                  '${avgMood.toStringAsFixed(1)}/10',
                  _getMoodColor(avgMood),
                  _getMoodComment(avgMood),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  '⚡',
                  'Energía',
                  '${avgEnergy.toStringAsFixed(1)}/10',
                  _getEnergyColor(avgEnergy),
                  _getEnergyComment(avgEnergy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '😰',
                  'Estrés',
                  '${avgStress.toStringAsFixed(1)}/10',
                  _getStressColor(avgStress),
                  _getStressComment(avgStress),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityCard(totalEntries, totalMoments),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String label, String value, Color color, String comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            comment,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(int entries, int moments) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('📝', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            'Actividad',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            '$entries días\n$moments momentos',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            _getActivityComment(entries),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(List<String> insights) {
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
                  Icons.lightbulb,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lo que me llamó la atención',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade300,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCelebrationSection(List<String> highlights) {
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
                  Icons.celebration,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cosas que celebramos juntos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...highlights.map((highlight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Text(
                highlight,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(List<String> suggestions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.darkSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
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
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Te sugiero que pruebes...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
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
          color: Colors.cyan.withOpacity(0.3),
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
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.new_releases,
                  color: Colors.cyan,
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

  // ✅ MÉTODOS AUXILIARES PARA COLORES Y COMENTARIOS
  Color _getMoodColor(double mood) {
    if (mood >= 8) return Colors.green;
    if (mood >= 6) return Colors.blue;
    if (mood >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getMoodComment(double mood) {
    if (mood >= 8) return '¡Increíble!';
    if (mood >= 6) return 'Bien encaminado';
    if (mood >= 4) return 'Regular';
    return 'Días difíciles';
  }

  Color _getEnergyColor(double energy) {
    if (energy >= 7) return Colors.green;
    if (energy >= 5) return Colors.blue;
    if (energy >= 3) return Colors.orange;
    return Colors.red;
  }

  String _getEnergyComment(double energy) {
    if (energy >= 7) return 'A tope';
    if (energy >= 5) return 'Estable';
    if (energy >= 3) return 'Bajita';
    return 'Agotado';
  }

  Color _getStressColor(double stress) {
    if (stress >= 7) return Colors.red;
    if (stress >= 5) return Colors.orange;
    if (stress >= 3) return Colors.blue;
    return Colors.green;
  }

  String _getStressComment(double stress) {
    if (stress >= 7) return 'Muy alto';
    if (stress >= 5) return 'Moderado';
    if (stress >= 3) return 'Controlado';
    return 'Muy relajado';
  }

  String _getActivityComment(int entries) {
    if (entries >= 6) return '¡Súper constante!';
    if (entries >= 4) return 'Buen ritmo';
    if (entries >= 2) return 'Empezando';
    return 'A mejorar';
  }

  Future<void> _generateWeeklySummary() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() {
      _isGenerating = true;
      _status = 'Analizando tu semana...';
    });

    try {
      final dbService = OptimizedDatabaseService();
      final weeklyData = await dbService.getWeeklyDataForAI(authProvider.currentUser!.id);

      await Future.delayed(const Duration(seconds: 3));

      final summary = _generateFriendlySmartSummary(
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
          const SnackBar(
            content: Text('¡Resumen semanal generado exitosamente!'),
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

  // ✅ ANÁLISIS AMIGABLE Y CERCANO
  Map<String, dynamic> _generateFriendlySmartSummary(Map<String, dynamic> weeklyData, String userName) {
    final entries = List<Map<String, dynamic>>.from(weeklyData['entries'] ?? <Map<String, dynamic>>[]);
    final moments = List<Map<String, dynamic>>.from(weeklyData['moments'] ?? <Map<String, dynamic>>[]);

    if (entries.isEmpty && moments.isEmpty) {
      return _generateEmptyWeekSummary(userName);
    }

    // Cálculos básicos
    final avgMood = _calculateAverage(entries, 'mood_score');
    final avgEnergy = _calculateAverage(entries, 'energy_level');
    final avgStress = _calculateAverage(entries, 'stress_level');

    final positiveMoments = moments.where((m) => m['type'] == 'positive').toList();
    final negativeMoments = moments.where((m) => m['type'] == 'negative').toList();

    // Crear análisis conversacional y cercano
    final summary = _createFriendlyNarrative(userName, entries, moments, avgMood, avgEnergy, avgStress);
    final insights = _generateFriendlyInsights(entries, moments, avgMood, avgEnergy, avgStress);
    final suggestions = _generateFriendlySuggestions(entries, moments, avgMood, avgEnergy, avgStress);
    final highlights = _getFriendlyHighlights(entries, moments);

    return {
      'summary': summary,
      'insights': insights,
      'suggestions': suggestions,
      'momentos_destacados': highlights,
      'patrones_observados': <String>[],
      'data': {
        'totalEntries': entries.length,
        'totalMoments': moments.length,
        'avgMood': avgMood,
        'avgEnergy': avgEnergy,
        'avgStress': avgStress,
      }
    };
  }

  String _createFriendlyNarrative(String userName, List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments, double avgMood, double avgEnergy, double avgStress) {

    String narrative = 'Hola $userName 😊, ';

    // Analizar el mood general de la semana
    if (avgMood >= 7) {
      narrative += 'veo que has tenido una semana realmente buena! Con un estado de ánimo promedio de ${avgMood.toStringAsFixed(1)}/10, se nota que las cosas han ido bien. ';
    } else if (avgMood >= 5) {
      narrative += 'has tenido una semana bastante equilibrada. Tu ánimo promedio de ${avgMood.toStringAsFixed(1)}/10 muestra que has sabido mantener las cosas en balance. ';
    } else {
      narrative += 'parece que ha sido una semana un poco más difícil de lo usual. Con un ánimo de ${avgMood.toStringAsFixed(1)}/10, me imagino que han pasado algunas cosas que te han afectado. ';
    }

    // Citar reflexiones específicas si están disponibles
    if (entries.isNotEmpty) {
      final sortedEntries = [...entries]..sort((a, b) =>
          (a['entry_date'] ?? '').toString().compareTo((b['entry_date'] ?? '').toString()));

      final lastEntry = sortedEntries.last;
      final lastReflection = lastEntry['free_reflection'] as String? ?? '';

      if (lastReflection.isNotEmpty && lastReflection.length > 15) {
        final shortQuote = lastReflection.length > 60
            ? '${lastReflection.substring(0, 57)}...'
            : lastReflection;
        narrative += 'Me quedé pensando en lo que escribiste el ${_formatDate(lastEntry['entry_date'])}: "$shortQuote". ';
      }
    }

    // Comentar sobre los momentos registrados
    if (moments.isNotEmpty) {
      final positiveCount = moments.where((m) => m['type'] == 'positive').length;
      final negativeCount = moments.where((m) => m['type'] == 'negative').length;

      if (positiveCount > negativeCount) {
        narrative += 'Me encanta que hayas registrado $positiveCount momentos positivos vs $negativeCount más complicados. ';

        // Citar un momento positivo específico
        final positiveMoments = moments.where((m) => m['type'] == 'positive').toList();
        if (positiveMoments.isNotEmpty) {
          final moment = positiveMoments[0];
          final emoji = moment['emoji'] as String? ?? '';
          final text = moment['text'] as String? ?? '';
          if (text.isNotEmpty) {
            narrative += 'Especialmente me gustó cuando dijiste $emoji "$text". ';
          }
        }
      } else if (negativeCount > positiveCount) {
        narrative += 'Registraste $negativeCount momentos difíciles y $positiveCount más positivos. ';
        narrative += 'Es completamente normal tener días así, y me parece genial que seas honesto/a contigo mismo/a. ';
      }
    }

    // Comentar sobre la energía
    if (avgEnergy < 4) {
      narrative += 'Noto que tu energía ha estado bastante baja (${avgEnergy.toStringAsFixed(1)}/10). ¿Has estado durmiendo bien?';
    } else if (avgEnergy > 7) {
      narrative += 'Tu energía ha estado genial esta semana (${avgEnergy.toStringAsFixed(1)}/10) - ¡eso me da mucha alegría!';
    }

    return narrative;
  }

  List<String> _generateFriendlyInsights(List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments, double avgMood, double avgEnergy, double avgStress) {

    List<String> insights = <String>[];

    // Insight sobre la correlación energía-ánimo
    if (entries.length >= 3) {
      final moodEnergyCorrelation = _analyzeEnergyMoodCorrelation(entries);
      if (moodEnergyCorrelation.isNotEmpty) {
        insights.add('He notado que cuando tu energía sube, tu ánimo también mejora. Esto es súper importante para entender cómo funciona tu bienestar.');
      }
    }

    // Insight sobre consistencia
    if (entries.length >= 5) {
      insights.add('Me parece increíble que hayas reflexionado ${entries.length} días esta semana. Esa constancia habla muy bien de tu compromiso contigo mismo/a.');
    } else if (entries.length >= 3) {
      insights.add('Has reflexionado ${entries.length} días esta semana, lo cual está muy bien. La reflexión regular es como hacer ejercicio para la mente.');
    }

    // Insight sobre manejo del estrés
    if (avgStress > 6 && avgMood > 5) {
      insights.add('Aunque tu estrés ha estado en ${avgStress.toStringAsFixed(1)}/10, has logrado mantener un buen ánimo. Eso dice mucho de tu resistencia emocional.');
    }

    // Insight sobre balance emocional
    final positiveMoments = moments.where((m) => m['type'] == 'positive').length;
    final negativeMoments = moments.where((m) => m['type'] == 'negative').length;

    if (positiveMoments > 0 && negativeMoments > 0) {
      insights.add('Valoro mucho que registres tanto momentos buenos como difíciles. Esa honestidad emocional es el primer paso hacia el crecimiento personal.');
    }

    // Asegurar al menos 2 insights
    if (insights.length < 2) {
      insights.addAll([
        'Tu forma de escribir las reflexiones muestra una persona muy consciente de sus emociones.',
        'Cada vez que registras algo aquí, estás invirtiendo en tu bienestar mental. Eso es algo que admiro.',
      ]);
    }

    return insights.take(4).toList();
  }

  List<String> _generateFriendlySuggestions(List<Map<String, dynamic>> entries,
      List<Map<String, dynamic>> moments, double avgMood, double avgEnergy, double avgStress) {

    List<String> suggestions = <String>[];

    // Sugerencias específicas basadas en los datos
    if (avgEnergy < 5) {
      suggestions.add('Como tu energía ha estado bajita, te sugiero que explores qué actividades específicas te recargan. ¿Podríamos identificar 2-3 cosas que realmente te den energía?');
    }

    if (avgStress > 6) {
      suggestions.add('Tu nivel de estrés ha estado alto (${avgStress.toStringAsFixed(1)}/10). ¿Qué te parece si intentamos identificar exactamente qué te está estresando más para poder atacarlo de raíz?');
    }

    if (entries.length < 4) {
      suggestions.add('Me encantaría que pudiéramos reflexionar juntos más días de la semana. Aunque sean 2-3 líneas, cada entrada me ayuda a entenderte mejor.');
    }

    final positiveMoments = moments.where((m) => m['type'] == 'positive').length;
    if (positiveMoments < 2) {
      suggestions.add('Intentemos capturar más momentos positivos, aunque sean pequeños. A veces nos enfocamos tanto en lo malo que se nos olvida celebrar lo bueno.');
    }

    // Sugerencias generales si no hay específicas
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Sigues así con tu práctica de reflexión. Cada día que escribes aquí estás construyendo una mejor relación contigo mismo/a.',
        'Me gustaría que intentaras ser más específico/a en tus reflexiones. Cuéntame qué exactamente te hizo sentir de cierta manera.',
      ]);
    }

    return suggestions.take(3).toList();
  }

  List<String> _getFriendlyHighlights(List<Map<String, dynamic>> entries, List<Map<String, dynamic>> moments) {
    List<String> highlights = <String>[];

    // Buscar días con mood alto
    for (final entry in entries) {
      final mood = (entry['mood_score'] as num?)?.toInt() ?? 0;
      if (mood >= 8) {
        final date = _formatDate(entry['entry_date']);
        highlights.add('🌟 $date fue un día especial - tu ánimo llegó a ${mood}/10');
      }
    }

    // Destacar momentos positivos
    final positiveMoments = moments.where((m) => m['type'] == 'positive').take(2);
    for (final moment in positiveMoments) {
      final emoji = moment['emoji'] as String? ?? '✨';
      final text = moment['text'] as String? ?? '';
      if (text.isNotEmpty) {
        highlights.add('$emoji "$text" - me encantó leer esto');
      }
    }

    // Highlight por constancia
    if (entries.length >= 5) {
      highlights.add('📝 ${entries.length} días de reflexión esta semana - ¡eres increíble!');
    }

    return highlights.take(3).toList();
  }

  // ✅ MÉTODOS AUXILIARES REUTILIZADOS
  String _analyzeEnergyMoodCorrelation(List<Map<String, dynamic>> entries) {
    if (entries.length < 3) return '';

    int correlationCount = 0;
    for (final entry in entries) {
      final mood = (entry['mood_score'] as num?)?.toInt() ?? 0;
      final energy = (entry['energy_level'] as num?)?.toInt() ?? 0;
      if ((mood >= 7 && energy >= 7) || (mood <= 4 && energy <= 4)) {
        correlationCount++;
      }
    }

    if (correlationCount >= entries.length * 0.7) {
      return 'correlación fuerte';
    }
    return '';
  }

  double _calculateAverage(List<Map<String, dynamic>> entries, String field) {
    final values = entries
        .where((e) => e[field] != null)
        .map((e) => (e[field] as num).toDouble())
        .toList();

    return values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 5.0;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'un día';
    final dateStr = date.toString();
    final parts = dateStr.split('-');
    if (parts.length >= 3) {
      final day = parts[2].split(' ')[0];
      final month = parts[1];
      return '$day/$month';
    }
    return dateStr;
  }

  Map<String, dynamic> _generateEmptyWeekSummary(String userName) {
    return {
      'summary': 'Hola $userName 😊, veo que esta semana aún no has registrado reflexiones o momentos. No pasa nada, todos necesitamos nuestro tiempo. Cuando estés listo/a, estaré aquí para acompañarte en tu proceso de autoconocimiento.',
      'insights': <String>[
        'El simple hecho de estar aquí ya muestra tu interés en cuidar tu bienestar mental',
        'No hay prisa - cada persona tiene su propio ritmo para la introspección',
      ],
      'suggestions': <String>[
        'Cuando te sientas cómodo/a, empieza con algo simple: ¿cómo te sientes ahora mismo?',
        'No necesitas escribir párrafos - a veces una sola palabra describe perfectamente tu día',
      ],
      'momentos_destacados': <String>[],
      'patrones_observados': <String>[],
      'data': {
        'totalEntries': 0,
        'totalMoments': 0,
        'avgMood': 5.0,
        'avgEnergy': 5.0,
        'avgStress': 5.0,
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