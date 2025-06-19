// ============================================================================
// daily_review_screen_v2.dart - VERSIÓN CORREGIDA Y ROBUSTA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';

class DailyReviewScreenV2 extends StatefulWidget {
  const DailyReviewScreenV2({super.key});

  @override
  State<DailyReviewScreenV2> createState() => _DailyReviewScreenV2State();
}

class _DailyReviewScreenV2State extends State<DailyReviewScreenV2>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reflectionController = TextEditingController();
  final _goalsController = TextEditingController();
  final _gratitudeController = TextEditingController();

  int selectedMood = 5;
  bool worthIt = true;
  String selectedBackground = 'gradient1';

  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late AnimationController _chartController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _chartAnimation;

  final Map<String, List<Color>> backgrounds = {
    'gradient1': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    'gradient2': [const Color(0xFF11998e), const Color(0xFF38ef7d)],
    'gradient3': [const Color(0xFFff6b6b), const Color(0xFFfeca57)],
    'gradient4': [const Color(0xFF4ecdc4), const Color(0xFF44a08d)],
    'gradient5': [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Use addPostFrameCallback to ensure providers are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutBack),
    );
    _backgroundController.repeat(reverse: true);
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _chartController.forward();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final momentsProvider = Provider.of<InteractiveMomentsProvider>(context, listen: false);

    // FIX: Safely get the user ID and check for null before using it.
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      momentsProvider.loadTodayMoments(userId);
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _chartController.dispose();
    _reflectionController.dispose();
    _goalsController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildDynamicBackground(),
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final currentGradient = backgrounds[selectedBackground]!;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(currentGradient[0], currentGradient[0].withAlpha(204), _backgroundAnimation.value * 0.3)!,
                Color.lerp(currentGradient[1], currentGradient[1].withAlpha(230), _backgroundAnimation.value * 0.2)!,
                ModernColors.darkPrimary,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: ModernSpacing.xl),
            _buildMoodSelector(),
            const SizedBox(height: ModernSpacing.lg),
            _buildDaySummaryChart(),
            const SizedBox(height: ModernSpacing.lg),
            _buildReflectionForm(),
            const SizedBox(height: ModernSpacing.lg),
            _buildBackgroundSelector(),
            const SizedBox(height: ModernSpacing.xl),
            _buildSaveButton(),
            const SizedBox(height: ModernSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(_cardAnimation),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reflexión del Día', style: ModernTypography.heading2.copyWith(fontSize: 28)),
                Text('Cierra el día con gratitud y reflexión', style: ModernTypography.bodyMedium.copyWith(color: Colors.white.withAlpha(204))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.md, vertical: ModernSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(ModernSpacing.radiusRound),
              border: Border.all(color: Colors.white.withAlpha(77)),
            ),
            child: Text(DateTime.now().day.toString().padLeft(2, '0'), style: ModernTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return FadeTransition(
      opacity: _cardAnimation,
      child: ScaleTransition(
        scale: _cardAnimation,
        child: ModernMoodSelector(
          selectedMood: selectedMood,
          onMoodChanged: (mood) {
            setState(() {
              selectedMood = mood;
              selectedBackground = _getMoodBackground(mood);
            });
          },
          animated: true,
        ),
      ),
    );
  }

  Widget _buildDaySummaryChart() {
    return FadeTransition(
      opacity: _chartAnimation,
      child: ScaleTransition(
        scale: _chartAnimation,
        child: Consumer<InteractiveMomentsProvider>(
          builder: (context, provider, child) {
            final summary = provider.getDaySummary();
            final totalMoments = (summary['total_moments'] as int?) ?? 0;
            final balanceScore = (summary['balance_score'] as double?) ?? 0.0;
            return ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 Resumen del Día', style: ModernTypography.heading3),
                  const SizedBox(height: ModernSpacing.lg),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Momentos Totales', totalMoments.toString(), Icons.timeline, ModernColors.info)),
                      const SizedBox(width: ModernSpacing.md),
                      Expanded(child: _buildStatCard('Balance', _getBalanceText(balanceScore), Icons.balance, _getBalanceColor(balanceScore))),
                    ],
                  ),
                  const SizedBox(height: ModernSpacing.lg),
                  _buildMomentChart(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: ModernSpacing.sm),
          Text(value, style: ModernTypography.heading3.copyWith(color: color, fontSize: 20)),
          Text(title, style: ModernTypography.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMomentChart(InteractiveMomentsProvider provider) {
    final int positive = provider.positiveCount;
    final int negative = provider.negativeCount;
    final int total = provider.totalCount;
    if (total == 0) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        ),
        child: const Center(child: Text('Sin datos para mostrar aún', style: ModernTypography.bodyMedium)),
      );
    }
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        final positiveFlex = (positive * _chartAnimation.value).round();
        final negativeFlex = (negative * _chartAnimation.value).round();
        return Column(
          children: [
            Row(
              children: [
                if (positiveFlex > 0)
                  Expanded(
                    flex: positiveFlex,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: ModernColors.positiveGradient),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                      ),
                    ),
                  ),
                if (negativeFlex > 0)
                  Expanded(
                    flex: negativeFlex,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: ModernColors.negativeGradient),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ModernSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('😊 Positivos', positive.toString(), ModernColors.success),
                _buildLegendItem('💭 Reflexivos', negative.toString(), ModernColors.warning),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: ModernSpacing.sm),
        Text('$label: $value', style: ModernTypography.bodySmall),
      ],
    );
  }

  Widget _buildReflectionForm() {
    return FadeTransition(
      opacity: _cardAnimation,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✍️ ¿Cómo fue tu día?', style: ModernTypography.heading3),
                  const SizedBox(height: ModernSpacing.md),
                  ModernTextField(
                    controller: _reflectionController,
                    hintText: 'Describe los momentos más importantes del día...',
                    maxLines: 4,
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Comparte al menos una reflexión del día' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ModernSpacing.lg),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🙏 ¿Por qué estás agradecido/a?', style: ModernTypography.heading3),
                  const SizedBox(height: ModernSpacing.md),
                  ModernTextField(
                    controller: _gratitudeController,
                    hintText: 'Comparte tres cosas por las que te sientes agradecido/a...',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ModernSpacing.lg),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎯 ¿Qué esperas para mañana?', style: ModernTypography.heading3),
                  const SizedBox(height: ModernSpacing.md),
                  ModernTextField(
                    controller: _goalsController,
                    hintText: 'Establece una intención o meta para mañana...',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ModernSpacing.lg),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💎 ¿Valió la pena el día de hoy?', style: ModernTypography.heading3),
                  const SizedBox(height: ModernSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => worthIt = true),
                          child: AnimatedContainer(
                            duration: ModernAnimations.medium,
                            padding: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
                            decoration: BoxDecoration(
                              gradient: worthIt ? const LinearGradient(colors: ModernColors.positiveGradient) : null,
                              color: worthIt ? null : Colors.white.withAlpha(26),
                              borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                              border: Border.all(color: worthIt ? ModernColors.success : Colors.white.withAlpha(51)),
                            ),
                            child: Text('✨ Sí, valió la pena', style: ModernTypography.bodyLarge.copyWith(fontWeight: worthIt ? FontWeight.w600 : FontWeight.w400), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      const SizedBox(width: ModernSpacing.md),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => worthIt = false),
                          child: AnimatedContainer(
                            duration: ModernAnimations.medium,
                            padding: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
                            decoration: BoxDecoration(
                              gradient: !worthIt ? const LinearGradient(colors: ModernColors.negativeGradient) : null,
                              color: !worthIt ? null : Colors.white.withAlpha(26),
                              borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                              border: Border.all(color: !worthIt ? ModernColors.warning : Colors.white.withAlpha(51)),
                            ),
                            child: Text('🤔 Podría ser mejor', style: ModernTypography.bodyLarge.copyWith(fontWeight: !worthIt ? FontWeight.w600 : FontWeight.w400), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundSelector() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🎨 Personaliza tu fondo', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.md),
          Text('Elige un fondo que refleje tu estado de ánimo', style: ModernTypography.bodyMedium),
          const SizedBox(height: ModernSpacing.lg),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: backgrounds.length,
              itemBuilder: (context, index) {
                final key = backgrounds.keys.elementAt(index);
                final gradient = backgrounds[key]!;
                final isSelected = selectedBackground == key;
                return GestureDetector(
                  onTap: () => setState(() => selectedBackground = key),
                  child: AnimatedContainer(
                    duration: ModernAnimations.medium,
                    width: 60, height: 60,
                    margin: const EdgeInsets.only(right: ModernSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                      border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                      boxShadow: isSelected ? [BoxShadow(color: gradient.first.withAlpha(77), blurRadius: 12, spreadRadius: 2)] : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return FadeTransition(
      opacity: _cardAnimation,
      child: ModernButton(
        text: 'Guardar Reflexión del Día',
        onPressed: _saveDailyReview,
        icon: Icons.save_outlined,
        width: double.infinity,
        gradient: backgrounds[selectedBackground],
      ),
    );
  }

  String _getMoodBackground(int mood) {
    if (mood <= 2) return 'gradient3';
    if (mood <= 3) return 'gradient4';
    if (mood <= 4) return 'gradient1';
    return 'gradient2';
  }

  String _getBalanceText(double balance) {
    if (balance > 0.3) return 'Positivo';
    if (balance < -0.3) return 'Reflexivo';
    return 'Equilibrado';
  }

  Color _getBalanceColor(double balance) {
    if (balance > 0.3) return ModernColors.success;
    if (balance < -0.3) return ModernColors.warning;
    return ModernColors.info;
  }

  void _saveDailyReview() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final momentsProvider = Provider.of<InteractiveMomentsProvider>(context, listen: false);

    // FIX: Safely get the user ID and use a guard clause if it's null.
    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      _showErrorMessage('Error: No se ha encontrado el usuario.');
      return;
    }

    final reflection = _buildFullReflection();

    try {
      final entryId = await momentsProvider.saveMomentsAsEntry(
        userId, // Now it's guaranteed to be non-null.
        reflection: reflection,
        worthIt: worthIt,
      );
      if (mounted && entryId != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: ModernSpacing.sm), Expanded(child: Text('✨ Reflexión guardada exitosamente', style: ModernTypography.bodyMedium))]),
          backgroundColor: ModernColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge)),
          margin: const EdgeInsets.all(ModernSpacing.md),
        ));
        Navigator.pop(context);
      } else if (mounted) {
        _showErrorMessage('Error al guardar la reflexión. Inténtalo de nuevo.');
      }
    } catch (e) {
      if (mounted) _showErrorMessage('Error de conexión. Inténtalo de nuevo.');
    }
  }

  String _buildFullReflection() {
    final buffer = StringBuffer();
    buffer.writeln('🌟 REFLEXIÓN DEL DÍA\nMood: $selectedMood/5\n¿Valió la pena?: ${worthIt ? "Sí" : "No"}\n');
    if (_reflectionController.text.trim().isNotEmpty) buffer.writeln('📝 Reflexión:\n${_reflectionController.text.trim()}\n');
    if (_gratitudeController.text.trim().isNotEmpty) buffer.writeln('🙏 Gratitud:\n${_gratitudeController.text.trim()}\n');
    if (_goalsController.text.trim().isNotEmpty) buffer.writeln('🎯 Para mañana:\n${_goalsController.text.trim()}');
    return buffer.toString();
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: ModernSpacing.sm), Expanded(child: Text(message, style: ModernTypography.bodyMedium))]),
      backgroundColor: ModernColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge)),
      margin: const EdgeInsets.all(ModernSpacing.md),
    ));
  }
}
