// ============================================================================
// presentation/screens/v2/interactive_moments_screen_v2.dart - CÓDIGO COMPLETO Y CORREGIDO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers optimizados
import '../../providers/optimized_providers.dart';

// Componentes modernos
import '../components/modern_design_system.dart';

// Modelos optimizados
import '../../../data/models/optimized_models.dart';

class InteractiveMomentsScreenV2 extends StatefulWidget {
  const InteractiveMomentsScreenV2({super.key});

  @override
  State<InteractiveMomentsScreenV2> createState() =>
      _InteractiveMomentsScreenV2State();
}

class _InteractiveMomentsScreenV2State extends State<InteractiveMomentsScreenV2>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerController;
  late AnimationController _categoriesController;
  late AnimationController _momentsController;

  String _selectedCategory = 'all';
  int _selectedIntensity = 5;
  final PageController _categoriesPageController = PageController();

  final _textController = TextEditingController();
  final _emojiController = TextEditingController(text: '✨');
  String _momentType = 'positive';

  final Map<String, Map<String, dynamic>> _categories = {
    'all': {'icon': '🌟', 'name': 'Todos', 'color': ModernColors.primaryGradient.first, 'gradient': ModernColors.primaryGradient,},
    'emocional': {'icon': '😊', 'name': 'Emocional', 'color': ModernColors.accentBlue, 'gradient': [ModernColors.accentBlue, const Color(0xFF764ba2)],},
    'fisico': {'icon': '🏃‍♀️', 'name': 'Físico', 'color': ModernColors.accentGreen, 'gradient': [ModernColors.accentGreen, const Color(0xFF38ef7d)],},
    'social': {'icon': '👥', 'name': 'Social', 'color': ModernColors.accentOrange, 'gradient': [ModernColors.accentOrange, const Color(0xFF667eea)],},
    'logros': {'icon': '🏆', 'name': 'Logros', 'color': Colors.amber, 'gradient': [Colors.amber, const Color(0xFFf093fb)],},
    'aprendizaje': {'icon': '📚', 'name': 'Aprender', 'color': Colors.lightBlue, 'gradient': [Colors.lightBlue, const Color(0xFF4facfe)],},
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMoments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _categoriesController.dispose();
    _momentsController.dispose();
    _textController.dispose();
    _emojiController.dispose();
    _categoriesPageController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _tabController = TabController(length: 2, vsync: this);
    _headerController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)..forward();
    _categoriesController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this)..forward();
    _momentsController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..forward();
  }

  Future<void> _loadMoments() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authProvider = context.read<OptimizedAuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        await context.read<OptimizedMomentsProvider>().loadMoments(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildViewMomentsTab(), _buildAddMomentTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ModernColors.primaryGradient,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('✨ Momentos Interactivos',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                Consumer<OptimizedMomentsProvider>(
                  builder: (context, momentsProvider, child) {
                    return IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed:
                      momentsProvider.isLoading ? null : _loadMoments,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<OptimizedMomentsProvider>(
              builder: (context, momentsProvider, child) {
                final stats = momentsProvider.getMomentsStats();
                return Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            'Total', '${stats['total'] ?? 0}', Icons.auto_awesome)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Hoy', '${stats['today'] ?? 0}', Icons.today)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Positivos',
                            '${((stats['positive_ratio'] as double? ?? 0) * 100).toInt()}%',
                            Icons.sentiment_very_satisfied)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
            gradient: LinearGradient(colors: ModernColors.primaryGradient),
            borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(icon: Icon(Icons.list), text: 'Ver Momentos'),
          Tab(
              icon: Icon(Icons.add_circle_outline),
              text: 'Añadir Momento')
        ],
      ),
    );
  }

  Widget _buildViewMomentsTab() {
    return Column(
      children: [
        _buildCategoriesSelector(),
        Expanded(child: _buildMomentsList()),
      ],
    );
  }

  Widget _buildCategoriesSelector() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(
          parent: _categoriesController, curve: Curves.easeOutBack)),
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: PageView.builder(
          controller: _categoriesPageController,
          itemCount: (_categories.length / 3).ceil(),
          itemBuilder: (context, pageIndex) {
            final startIndex = pageIndex * 3;
            final endIndex = math.min(startIndex + 3, _categories.length);
            final pageCategories =
            _categories.entries.toList().sublist(startIndex, endIndex);
            return Row(
              children: pageCategories.map((entry) {
                final categoryId = entry.key;
                final category = entry.value;
                final isSelected = _selectedCategory == categoryId;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = categoryId),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: category['gradient'])
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.2),
                            width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(category['icon'],
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(category['name'],
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMomentsList() {
    return Consumer<OptimizedMomentsProvider>(
      builder: (context, momentsProvider, child) {
        if (momentsProvider.isLoading && momentsProvider.moments.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (momentsProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(momentsProvider.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadMoments, child: const Text('Reintentar')),
              ],
            ),
          );
        }

        final filteredMoments = _selectedCategory == 'all'
            ? momentsProvider.moments
            : momentsProvider.getMomentsByCategory(_selectedCategory);

        if (filteredMoments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_categories[_selectedCategory]?['icon'] ?? '✨', style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('No hay momentos en esta categoría', style: TextStyle(color: Colors.white60, fontSize: 16)),
              ],
            ),
          );
        }

        return FadeTransition(
          opacity: _momentsController,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredMoments.length,
            itemBuilder: (context, index) {
              final moment = filteredMoments[index];
              return KeyedSubtree(
                key: ValueKey(moment.id),
                child: _buildMomentCard(moment, index),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMomentCard(OptimizedInteractiveMomentModel moment, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _momentsController,
        curve: Interval((index * 0.1).clamp(0.0, 1.0),
            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutBack),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(int.parse(moment.colorHex.substring(1),
                        radix: 16) +
                        0xFF000000)
                        .withOpacity(0.2),
                  ),
                  child: Center(
                      child: Text(moment.emoji,
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(moment.type.toUpperCase(),
                              style: TextStyle(
                                  color: Color(int.parse(
                                      moment.colorHex.substring(1),
                                      radix: 16) +
                                      0xFF000000),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: _categories[moment.category]?['color']?.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                _categories[moment.category]?['name'] ??
                                    moment.category,
                                style: TextStyle(
                                    color: _categories[moment.category]?['color'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(moment.text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(moment.timeStr,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          5,
                              (i) => Icon(
                              i < (moment.intensity / 2).round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 12)),
                    ),
                  ],
                ),
              ],
            ),
            if (moment.hasContext || moment.hasEnergyData || moment.hasMoodData) ...[
              const SizedBox(height: 12),
              _buildMomentDetails(moment),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMomentDetails(OptimizedInteractiveMomentModel moment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (moment.hasEnergyData)
            Row(children: [
              const Icon(Icons.battery_charging_full,
                  color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                  'Energía: ${moment.energyBefore} → ${moment.energyAfter}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          if (moment.hasMoodData) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.sentiment_satisfied, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text('Ánimo: ${moment.moodBefore} → ${moment.moodAfter}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12))
            ])
          ],
          if (moment.contextLocation != null ||
              moment.contextWeather != null ||
              moment.contextSocial != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      [
                        moment.contextLocation,
                        moment.contextWeather,
                        moment.contextSocial
                      ].where((c) => c != null).join(' • '),
                      style: const TextStyle(color: Colors.white70, fontSize: 12))),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAddMomentTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddMomentForm(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMomentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tipo de Momento',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildTypeButton('positive', 'Positivo', '😊', Colors.green)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTypeButton('negative', 'Desafío', '😔', Colors.red)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildTypeButton('neutral', 'Neutral', '😐', Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Emoji',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
              controller: _emojiController,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: '✨',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          const Text('¿Qué ha pasado?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  hintText: 'Describe tu momento...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          const Text('Intensidad (1-10)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('1', style: TextStyle(color: Colors.white70)),
              Expanded(
                  child: Slider(
                      value: _selectedIntensity.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _selectedIntensity.toString(),
                      activeColor: ModernColors.primaryGradient.first,
                      onChanged: (value) =>
                          setState(() => _selectedIntensity = value.round()))),
              const Text('10', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, String emoji, Color color) {
    final isSelected = _momentType == type;
    return GestureDetector(
      onTap: () => setState(() => _momentType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.2),
              width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: isSelected ? color : Colors.white70,
                    fontSize: 12,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<OptimizedMomentsProvider>(
      builder: (context, momentsProvider, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: ModernColors.primaryGradient),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: ModernColors.primaryGradient.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: momentsProvider.isLoading ? null : _addMoment,
              child: Center(
                child: momentsProvider.isLoading
                    ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Registrar Momento',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addMoment() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('Por favor describe tu momento', isError: true);
      return;
    }
    final authProvider = context.read<OptimizedAuthProvider>();
    final momentsProvider = context.read<OptimizedMomentsProvider>();
    final user = authProvider.currentUser;
    if (user == null) {
      _showSnackBar('Error: Usuario no autenticado', isError: true);
      return;
    }
    try {
      final success = await momentsProvider.addMoment(
        userId: user.id,
        emoji: _emojiController.text.isNotEmpty ? _emojiController.text : '✨',
        text: _textController.text.trim(),
        type: _momentType,
        intensity: _selectedIntensity,
        category: _selectedCategory,
      );
      if (mounted) {
        if (success) {
          _showSnackBar('¡Momento registrado exitosamente!');
          _textController.clear();
          _emojiController.text = '✨';
          setState(() {
            _momentType = 'positive';
            _selectedIntensity = 5;
          });
          _tabController.animateTo(0);
        } else {
          _showSnackBar(
              momentsProvider.errorMessage ?? 'Error al registrar momento',
              isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Error inesperado: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}