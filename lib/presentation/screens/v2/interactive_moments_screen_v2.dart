// ============================================================================
// screens/v2/interactive_moments_screen_v2.dart - REDISEÑO AVANZADO Y DINÁMICO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';
import '../components/add_moment_panel.dart';
import '../../../data/models/interactive_moment_model.dart';

class InteractiveMomentsScreenV2 extends StatefulWidget {
  const InteractiveMomentsScreenV2({super.key});

  @override
  State<InteractiveMomentsScreenV2> createState() =>
      _InteractiveMomentsScreenV2State();
}

class _InteractiveMomentsScreenV2State extends State<InteractiveMomentsScreenV2>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Data for different modes
  final Map<String, List<Map<String, dynamic>>> _quickEmojis = {
    'Felicidad': [
      {'emoji': '😊', 'text': 'Contento/a', 'type': 'positive'},
      {'emoji': '😄', 'text': 'Feliz', 'type': 'positive'},
      {'emoji': '🤩', 'text': 'Asombrado/a', 'type': 'positive'},
    ],
    'Logros': [
      {'emoji': '🎉', 'text': 'Celebrando', 'type': 'positive'},
      {'emoji': '💪', 'text': 'Reto superado', 'type': 'positive'},
      {'emoji': '🎯', 'text': 'Objetivo cumplido', 'type': 'positive'},
    ],
    'Estrés': [
      {'emoji': '😰', 'text': 'Ansioso/a', 'type': 'negative'},
      {'emoji': '😓', 'text': 'Presionado/a', 'type': 'negative'},
      {'emoji': '🤯', 'text': 'Abrumado/a', 'type': 'negative'},
    ],
    'Tristeza': [
      {'emoji': '😔', 'text': 'Un poco triste', 'type': 'negative'},
      {'emoji': '😞', 'text': 'Decepcionado/a', 'type': 'negative'},
      {'emoji': '😢', 'text': 'Necesito un respiro', 'type': 'negative'},
    ],
  };

  // NEW: Smart suggestions based on time of day
  final Map<String, List<Map<String, dynamic>>> _timeBasedSuggestions = {
    'Mañana': [
      {'emoji': '☕', 'text': 'Disfrutando el café de la mañana', 'type': 'positive'},
      {'emoji': '🏃', 'text': 'Paseo o ejercicio matutino', 'type': 'positive'},
      {'emoji': '📅', 'text': 'Planificando un día productivo', 'type': 'positive'},
    ],
    'Tarde': [
      {'emoji': '🥗', 'text': 'Almuerzo saludable y rico', 'type': 'positive'},
      {'emoji': '💡', 'text': 'Tuve una idea brillante en el trabajo', 'type': 'positive'},
      {'emoji': '😮‍💨', 'text': 'Sintiendo el cansancio de la tarde', 'type': 'negative'},
    ],
    'Noche': [
      {'emoji': '🧘', 'text': 'Momento de meditación o calma', 'type': 'positive'},
      {'emoji': '📚', 'text': 'Relajándome con un buen libro', 'type': 'positive'},
      {'emoji': '回顾', 'text': 'Reflexionando sobre el día', 'type': 'negative'},
    ],
  };

  final List<String> _zenQuotes = [
    "El secreto de la salud para la mente y el cuerpo no es lamentarse por el pasado, sino vivir en el momento presente.",
    "La paz viene de dentro. No la busques fuera.",
    "No hay camino a la felicidad, la felicidad es el camino.",
    "Con cada paso, el viento sopla.",
    "La verdadera meditación es sobre ser plenamente presente con todo."
  ];
  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentQuote = _zenQuotes[math.Random().nextInt(_zenQuotes.length)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<InteractiveMomentsProvider>().loadTodayMoments(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildTimeline()),
              SliverPersistentHeader(
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelStyle: ModernTypography.button.copyWith(fontSize: 14),
                    unselectedLabelStyle: ModernTypography.bodyLarge.copyWith(fontSize: 14),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                      color: ModernColors.primaryGradient.first.withOpacity(0.8),
                    ),
                    tabs: const [
                      Tab(text: '⚡ Rápido'),
                      Tab(text: '💡 Sugerencias'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildQuickModeTab(),
              _buildSuggestionsTab(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMomentPanel,
        backgroundColor: ModernColors.primaryGradient.first,
        child: const Icon(Icons.edit_note, color: Colors.white),
        tooltip: 'Añadir momento personalizado',
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ModernSpacing.lg, ModernSpacing.lg, ModernSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Captura tu Momento', style: ModernTypography.heading1),
          const SizedBox(height: ModernSpacing.xs),
          // NEW: Zen Quote of the Day
          Text('“$_currentQuote”', style: ModernTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // NEW: Visual timeline of today's moments
  Widget _buildTimeline() {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.moments.isEmpty) {
          return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()));
        }
        if (provider.moments.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(ModernSpacing.lg, ModernSpacing.lg, ModernSpacing.lg, ModernSpacing.sm),
              child: Text("Línea de tiempo de hoy", style: ModernTypography.heading3),
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
                itemCount: provider.moments.length,
                itemBuilder: (context, index) {
                  final moment = provider.moments[index];
                  return _buildTimelineCard(moment);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimelineCard(InteractiveMomentModel moment) {
    bool isPositive = moment.type == 'positive';
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: ModernSpacing.sm),
      padding: const EdgeInsets.all(ModernSpacing.sm),
      decoration: BoxDecoration(
          color: ModernColors.glassSurface,
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
          border: Border.all(color: isPositive ? ModernColors.success.withOpacity(0.3) : ModernColors.warning.withOpacity(0.3))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(moment.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: ModernSpacing.sm),
              Text(moment.timeStr, style: ModernTypography.caption),
            ],
          ),
          const Spacer(),
          Text(
            moment.text,
            style: ModernTypography.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickModeTab() {
    return ListView(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      children: _quickEmojis.entries.map((entry) {
        return _buildEmojiCategorySection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildEmojiCategorySection(String title, List<Map<String, dynamic>> items) {
    bool isPositive = items.first['type'] == 'positive';
    return ModernCard(
      margin: const EdgeInsets.only(bottom: ModernSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ModernTypography.heading3.copyWith(color: isPositive ? ModernColors.success : ModernColors.warning)),
          const SizedBox(height: ModernSpacing.md),
          Wrap(
            spacing: ModernSpacing.sm,
            runSpacing: ModernSpacing.sm,
            children: items.map((item) {
              return GestureDetector(
                onTap: () => _addMoment(
                  emoji: item['emoji']!,
                  text: item['text']!,
                  type: item['type']!,
                  category: 'quick',
                ),
                child: Chip(
                  avatar: Text(item['emoji']!, style: const TextStyle(fontSize: 16)),
                  label: Text(item['text']!, style: ModernTypography.bodyMedium),
                  backgroundColor: ModernColors.glassSecondary,
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // NEW: Replaced Templates with time-based suggestions
  Widget _buildSuggestionsTab() {
    final String timeOfDay = _getTimeOfDay();
    final suggestions = _timeBasedSuggestions[timeOfDay]!;

    return ListView(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        children: [
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sugerencias de $timeOfDay', style: ModernTypography.heading3),
                const SizedBox(height: ModernSpacing.sm),
                ...suggestions.map((item) {
                  bool isPositive = item['type'] == 'positive';
                  return ListTile(
                    leading: Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
                    title: Text(item['text']!, style: ModernTypography.bodyLarge),
                    trailing: Icon(isPositive ? Icons.add_circle_outline : Icons.add_circle, color: isPositive ? ModernColors.success : ModernColors.warning),
                    onTap: () => _addMoment(
                      emoji: item['emoji']!,
                      text: item['text']!,
                      type: item['type']!,
                      category: 'suggestion',
                    ),
                  );
                })
              ],
            ),
          )
        ]
    );
  }

  void _showAddMomentPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ChangeNotifierProvider.value(
          value: context.read<InteractiveMomentsProvider>(),
          child: const AddMomentPanel(),
        ),
      ),
    );
  }

  Future<void> _addMoment({
    required String emoji,
    required String text,
    required String type,
    String category = 'general',
  }) async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Usuario no encontrado')));
      return;
    }

    final success = await momentsProvider.addMoment(
      userId: userId,
      emoji: emoji,
      text: text,
      type: type,
      category: category,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Momento "$text" añadido'),
          backgroundColor: ModernColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Mañana';
    if (hour < 18) return 'Tarde';
    return 'Noche';
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ModernColors.darkPrimary,
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
