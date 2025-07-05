// lib/presentation/screens/v2/predictive_analysis_screen.dart
// ============================================================================
// PANTALLA DE ANÁLISIS PREDICTIVO - UI PARA MOSTRAR PREDICCIONES Y BURNOUT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ai/provider/predective_analysis_provider.dart';
import '../../../ai/provider/ai_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../../injection_container_clean.dart' as clean_di;
import '../../../data/services/optimized_database_service.dart';
import '../components/modern_design_system.dart';

class PredictiveAnalysisScreen extends StatefulWidget {
  const PredictiveAnalysisScreen({super.key});

  @override
  State<PredictiveAnalysisScreen> createState() => _PredictiveAnalysisScreenState();
}

class _PredictiveAnalysisScreenState extends State<PredictiveAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ✅ NUEVO: Estados de inicialización
  bool _isInitializing = true;
  String _initializationStatus = 'Preparando análisis...';
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  /// 🚀 Iniciar proceso de inicialización
  void _startInitialization() {
    // Delay pequeño para permitir que el widget se construya completamente
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _initializeAndRunAnalysis();
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _loadAnalysisData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeAndRunAnalysis();
    });
  }

  /// 🔧 Inicializar servicios y ejecutar análisis completo
  Future<void> _initializeAndRunAnalysis() async {
    final auth = context.read<OptimizedAuthProvider>();
    final predictive = context.read<PredictiveAnalysisProvider>();

    // Verificar que el usuario esté autenticado
    if (auth.currentUser?.id == null) {
      _showError('Usuario no autenticado');
      return;
    }

    try {
      // 1. Verificar e inicializar servicio de IA
      await _ensureAIServiceReady();

      // 2. Verificar datos suficientes
      await _checkDataAvailability(auth.currentUser!.id);

      // 3. Marcar inicialización como completada
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initializationStatus = 'Análisis iniciado';
        });
      }

      // 4. Ejecutar análisis si todo está listo
      await predictive.runCompleteAnalysis(
        userId: auth.currentUser!.id,
        daysAhead: 7,
      );

    } catch (e) {
      _showError('Error durante inicialización: $e');
    }
  }

  /// 🤖 Verificar e inicializar servicio de IA
  Future<void> _ensureAIServiceReady() async {
    final ai = context.read<AIProvider>();

    if (!ai.isInitialized && !ai.isInitializing) {
      setState(() {
        _initializationStatus = 'Inicializando servicio de IA...';
      });

      // Intentar inicializar la IA
      final success = await ai.initializeAI();


    }

    if (ai.isInitializing) {
      setState(() {
        _initializationStatus = 'Esperando inicialización de IA...';
      });

      // Esperar hasta que termine de inicializar (con timeout)
      int attempts = 0;
      while (ai.isInitializing && attempts < 30) { // 30 segundos max
        await Future.delayed(const Duration(seconds: 1));
        attempts++;
      }

      if (ai.isInitializing) {
        throw Exception('Timeout esperando inicialización de IA');
      }
    }

    if (!ai.isInitialized) {
      throw Exception('Servicio de IA no disponible');
    }
  }

  /// 📊 Verificar que hay datos suficientes para análisis
  Future<void> _checkDataAvailability(int userId) async {
    setState(() {
      _initializationStatus = 'Verificando datos disponibles...';
    });

    try {
      // Obtener acceso al servicio de base de datos directamente
      final databaseService = clean_di.sl<OptimizedDatabaseService>();

      // Verificar entradas recientes para burnout (mínimo 5 días)
      final recentEntries = await databaseService.getDailyEntries(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
        endDate: DateTime.now(),
        limit: 14,
      );

      if (recentEntries.length < 5) {
        throw Exception('Datos insuficientes para análisis de burnout.\n\nSe requieren al menos 5 días de reflexiones recientes.\nActualmente tienes: ${recentEntries.length} días.');
      }

      // Verificar historial para predicción (mínimo 7 días)
      final historicalEntries = await databaseService.getDailyEntries(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        limit: 30,
      );

      if (historicalEntries.length < 7) {
        throw Exception('Datos insuficientes para predicción de tendencias.\n\nSe requieren al menos 7 días de historial.\nActualmente tienes: ${historicalEntries.length} días.');
      }

      setState(() {
        _initializationStatus = 'Datos verificados. Iniciando análisis IA...';
      });

    } catch (e) {
      throw Exception('Error verificando datos: ${e.toString()}');
    }
  }

  /// ❌ Mostrar error en UI
  void _showError(String message) {
    if (mounted) {
      setState(() {
        _initializationError = message;
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildAnalysisContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: ModernColors.darkPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '🔮 Análisis Predictivo',
          style: ModernTypography.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ModernColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 60), // Espacio para el título
              Text(
                'Predicciones IA sobre tu bienestar',
                style: ModernTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<PredictiveAnalysisProvider>(
          builder: (context, predictive, _) {
            final isLoading = _isInitializing || predictive.isLoading;
            return IconButton(
              icon: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : const Icon(Icons.refresh, color: Colors.white),
              onPressed: isLoading ? null : () {
                setState(() {
                  _isInitializing = true;
                  _initializationError = null;
                  _initializationStatus = 'Reiniciando análisis...';
                });
                _initializeAndRunAnalysis();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisContent() {
    return SliverPadding(
      padding: const EdgeInsets.all(ModernSpacing.md),
      sliver: Consumer<PredictiveAnalysisProvider>(
        builder: (context, predictive, _) {
          // 1. Estado de inicialización
          if (_isInitializing) {
            return _buildInitializationState();
          }

          // 2. Error de inicialización
          if (_initializationError != null) {
            return _buildInitializationErrorState();
          }

          // 3. Estado de carga del análisis
          if (predictive.isLoading) {
            return _buildLoadingState();
          }

          // 4. Errores del análisis
          if (predictive.hasAnyErrors) {
            return _buildErrorState(predictive);
          }

          // 5. Contenido principal - análisis completado
          return SliverList(
            delegate: SliverChildListDelegate([
              // Alertas críticas (si las hay)
              if (predictive.hasCriticalAlerts()) ...[
                _buildCriticalAlertCard(predictive),
                const SizedBox(height: ModernSpacing.md),
              ],

              // Evaluación de Burnout
              _buildBurnoutRiskCard(predictive),
              const SizedBox(height: ModernSpacing.md),

              // Predicción de Tendencias
              _buildMoodTrendCard(predictive),
              const SizedBox(height: ModernSpacing.md),

              // Recomendaciones Prioritarias
              _buildRecommendationsCard(predictive),
              const SizedBox(height: ModernSpacing.lg),
            ]),
          );
        },
      ),
    );
  }

  /// 🔄 Estado de inicialización
  Widget _buildInitializationState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ModernColors.accentBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(ModernColors.accentBlue),
                    strokeWidth: 3,
                  ),
                  const Icon(
                    Icons.psychology,
                    color: ModernColors.accentBlue,
                    size: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ModernSpacing.lg),
            Text(
              '🤖 Inicializando Análisis IA',
              style: ModernTypography.heading3.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ModernSpacing.sm),
            Text(
              _initializationStatus,
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ModernSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ModernSpacing.md,
                vertical: ModernSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Preparando tu análisis personalizado...',
                style: ModernTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ❌ Estado de error de inicialización
  Widget _buildInitializationErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: ModernCard(
          gradient: const [Color(0xFFe74c3c), Color(0xFFc0392b)],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: ModernSpacing.md),
              Text(
                '❌ Error de Inicialización',
                style: ModernTypography.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.sm),
              Text(
                _initializationError!,
                style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.lg),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isInitializing = true;
                        _initializationError = null;
                        _initializationStatus = 'Reintentando inicialización...';
                      });
                      _initializeAndRunAnalysis();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(ModernColors.accentBlue),
            ),
            const SizedBox(height: ModernSpacing.md),
            Text(
              '🤖 La IA está analizando tus datos...',
              style: ModernTypography.bodyLarge.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ModernSpacing.sm),
            Text(
              'Esto puede tomar unos momentos',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(PredictiveAnalysisProvider predictive) {
    return SliverFillRemaining(
      child: Center(
        child: ModernCard(
          gradient: const [Color(0xFFe74c3c), Color(0xFFc0392b)],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: ModernSpacing.md),
              Text(
                '❌ Error en el Análisis IA',
                style: ModernTypography.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.sm),
              if (predictive.moodPredictionError != null) ...[
                Text(
                  'Predicción: ${predictive.moodPredictionError}',
                  style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ModernSpacing.xs),
              ],
              if (predictive.burnoutAssessmentError != null) ...[
                Text(
                  'Burnout: ${predictive.burnoutAssessmentError}',
                  style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: ModernSpacing.md),
              ModernButton(
                text: 'Reintentar',
                onPressed: _loadAnalysisData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAlertCard(PredictiveAnalysisProvider predictive) {
    return ModernCard(
      gradient: const [Color(0xFFe74c3c), Color(0xFFc0392b)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 28),
              const SizedBox(width: ModernSpacing.sm),
              Expanded(
                child: Text(
                  '🚨 ALERTA CRÍTICA',
                  style: ModernTypography.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            'La IA ha detectado patrones que requieren atención inmediata.',
            style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: ModernSpacing.md),
          ...predictive.getPriorityRecommendations().map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Text(
                    rec,
                    style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBurnoutRiskCard(PredictiveAnalysisProvider predictive) {
    final uiData = predictive.getUIDisplayData();
    final burnoutData = uiData['burnout_risk'] as Map<String, dynamic>;

    if (!burnoutData['has_data']) {
      return _buildDataNotAvailableCard('🚨 Evaluación de Burnout', 'burnout');
    }

    final riskScore = burnoutData['risk_score'] as int;
    final riskLevel = burnoutData['risk_level'] as String;
    final riskColor = _getRiskColorFromString(burnoutData['risk_color'] as String);

    return ModernCard(
      gradient: [riskColor.withOpacity(0.8), riskColor],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🚨 Riesgo de Burnout',
                style: ModernTypography.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$riskScore/100',
                  style: ModernTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            'Nivel: $riskLevel',
            style: ModernTypography.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernSpacing.md),

          // Factores de riesgo
          if ((burnoutData['top_factors'] as List).isNotEmpty) ...[
            Text(
              'Factores Identificados:',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ModernSpacing.xs),
            ...(burnoutData['top_factors'] as List<String>).map((factor) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
                  child: Text(
                    '• $factor',
                    style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
            ),
          ],

          // Acciones inmediatas
          if ((burnoutData['immediate_actions'] as List).isNotEmpty) ...[
            const SizedBox(height: ModernSpacing.sm),
            Text(
              'Acciones Inmediatas:',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ModernSpacing.xs),
            ...(burnoutData['immediate_actions'] as List<String>).take(2).map((action) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
                  child: Text(
                    '→ $action',
                    style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodTrendCard(PredictiveAnalysisProvider predictive) {
    final uiData = predictive.getUIDisplayData();
    final moodData = uiData['mood_trend'] as Map<String, dynamic>;

    if (!moodData['has_data']) {
      return _buildDataNotAvailableCard('🔮 Predicción de Tendencias', 'mood');
    }

    final confidence = moodData['confidence_percentage'] as int;
    final riskDays = moodData['risk_days_summary'] as List<String>;

    return ModernCard(
      gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔮 Predicción 7 Días',
                style: ModernTypography.heading3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Confianza: $confidence%',
                  style: ModernTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),

          // Días de riesgo
          if (riskDays.isNotEmpty) ...[
            Text(
              '⚠️ Días de Riesgo Detectados:',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ModernSpacing.xs),
            ...riskDays.map((day) => Padding(
              padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
              child: Text(
                '• $day',
                style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            )),
          ] else ...[
            Text(
              '✅ No se detectaron días de riesgo en la próxima semana',
              style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ],

          // Sugerencias preventivas
          if ((moodData['top_suggestions'] as List).isNotEmpty) ...[
            const SizedBox(height: ModernSpacing.sm),
            Text(
              'Sugerencias Preventivas:',
              style: ModernTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: ModernSpacing.xs),
            ...(moodData['top_suggestions'] as List<String>).map((suggestion) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: ModernSpacing.xs),
                  child: Text(
                    '→ $suggestion',
                    style: ModernTypography.bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(PredictiveAnalysisProvider predictive) {
    final recommendations = predictive.getPriorityRecommendations();

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return ModernCard(
      gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Recomendaciones Prioritarias',
            style: ModernTypography.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            'Basadas en tu análisis predictivo personalizado',
            style: ModernTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: ModernSpacing.md),
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final recommendation = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
              padding: const EdgeInsets.all(ModernSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: ModernTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDataNotAvailableCard(String title, String type) {
    return ModernCard(
      gradient: [Colors.grey.withOpacity(0.8), Colors.grey],
      child: Column(
        children: [
          Icon(
            type == 'burnout' ? Icons.psychology : Icons.trending_up,
            size: 48,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            title,
            style: ModernTypography.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            'La IA necesita más datos para generar este análisis',
            style: ModernTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRiskColorFromString(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.amber;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}