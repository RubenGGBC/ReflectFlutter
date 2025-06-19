// ============================================================================
// screens/v2/moment_capture_hub_screen.dart - HUB DE CAPTURA DE MOMENTOS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// FIX: Corrected import paths
import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';
import '../components/add_moment_panel.dart';
import '../../../data/models/interactive_moment_model.dart';

class MomentCaptureHubScreen extends StatefulWidget {
  const MomentCaptureHubScreen({super.key});

  @override
  State<MomentCaptureHubScreen> createState() => _MomentCaptureHubScreenState();
}

class _MomentCaptureHubScreenState extends State<MomentCaptureHubScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggeredController;
  final _textController = TextEditingController();

  final List<String> _zenQuotes = [
    "La paz viene de dentro. No la busques fuera.",
    "No hay camino a la felicidad, la felicidad es el camino.",
    "Con cada paso, el viento sopla.",
    "El momento presente es el único momento disponible para nosotros.",
  ];
  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _zenQuotes[math.Random().nextInt(_zenQuotes.length)];

    _staggeredController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggeredController.forward();
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<InteractiveMomentsProvider>().loadTodayMoments(userId);
      }
    });
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildTimeline(),
            _buildIdeaStream(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMomentPanel,
        backgroundColor: ModernColors.primaryGradient.first,
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: Text('Momento Detallado', style: ModernTypography.button.copyWith(fontSize: 14)),
        tooltip: 'Añadir un momento personalizado',
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(0.1 * index, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FadeTransition(
        opacity: _staggeredController,
        child: child,
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: _buildAnimatedSection(0, Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Captura tu Momento', style: ModernTypography.heading1),
            const SizedBox(height: ModernSpacing.xs),
            Text('“$_currentQuote”', style: ModernTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: ModernSpacing.lg),
            ModernTextField(
              controller: _textController,
              hintText: '¿Qué está pasando?',
              // FIX: Changed to use the correct onFieldSubmitted parameter
              onFieldSubmitted: (text) {
                if(text.isNotEmpty) {
                  _addMoment(text: text, emoji: '💬', type: 'positive', category: 'text');
                  _textController.clear();
                }
              },
            ),
          ],
        ),
      )),
    );
  }

  SliverToBoxAdapter _buildTimeline() {
    return SliverToBoxAdapter(
      child: Consumer<InteractiveMomentsProvider>(
        builder: (context, provider, child) {
          if (provider.moments.isEmpty) {
            return const SizedBox.shrink();
          }
          return _buildAnimatedSection(1, Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(ModernSpacing.lg, 0, ModernSpacing.lg, ModernSpacing.sm),
                child: Text("Tu día hasta ahora", style: ModernTypography.heading3),
              ),
              SizedBox(
                height: 70,
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
              const SizedBox(height: ModernSpacing.lg),
            ],
          ));
        },
      ),
    );
  }

  Widget _buildTimelineCard(InteractiveMomentModel moment) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: ModernSpacing.sm),
      decoration: BoxDecoration(
        color: ModernColors.glassSurface,
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(moment.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: ModernSpacing.xs),
          Text(moment.timeStr, style: ModernTypography.caption),
        ],
      ),
    );
  }

  SliverList _buildIdeaStream() {
    final ideaCards = [
      _buildSmartSuggestionsCard(),
      _buildEmojiPaletteCard(),
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _buildAnimatedSection(index + 2, ideaCards[index]);
        },
        childCount: ideaCards.length,
      ),
    );
  }

  Widget _buildSmartSuggestionsCard() {
    final String timeOfDay = _getTimeOfDay();
    final suggestions = _getSuggestionsForTime(timeOfDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.lg, vertical: ModernSpacing.sm),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sugerencias de $timeOfDay', style: ModernTypography.heading3),
            const SizedBox(height: ModernSpacing.md),
            ...suggestions.map((item) {
              return ListTile(
                leading: Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
                title: Text(item['text']!, style: ModernTypography.bodyLarge),
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
      ),
    );
  }

  Widget _buildEmojiPaletteCard() {
    final emojiMap = {
      'Felicidad': [
        {'emoji': '😊', 'type': 'positive'}, {'emoji': '😄', 'type': 'positive'}, {'emoji': '🤩', 'type': 'positive'}
      ],
      'Logros': [
        {'emoji': '🎉', 'type': 'positive'}, {'emoji': '💪', 'type': 'positive'}, {'emoji': '🎯', 'type': 'positive'}
      ],
      'Estrés': [
        {'emoji': '😰', 'type': 'negative'}, {'emoji': '😓', 'type': 'negative'}, {'emoji': '🤯', 'type': 'negative'}
      ],
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.lg, vertical: ModernSpacing.sm),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paleta de Emociones', style: ModernTypography.heading3),
            const SizedBox(height: ModernSpacing.md),
            ...emojiMap.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: ModernTypography.bodyMedium),
                  const SizedBox(height: ModernSpacing.sm),
                  Wrap(
                    spacing: ModernSpacing.md,
                    children: entry.value.map((item) {
                      return ActionChip(
                        avatar: Text(item['emoji']!, style: const TextStyle(fontSize: 18)),
                        label: Text(item['text'] ?? ''),
                        backgroundColor: ModernColors.glassSecondary,
                        onPressed: () => _addMoment(
                          emoji: item['emoji']!,
                          text: 'Me sentí: ${entry.key}',
                          type: item['type']!,
                          category: 'palette',
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: ModernSpacing.md),
                ],
              );
            })
          ],
        ),
      ),
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
    required String emoji, required String text, required String type, String category = 'general',
  }) async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Usuario no encontrado')));
      return;
    }

    final success = await momentsProvider.addMoment(
      userId: userId, emoji: emoji, text: text, type: type, category: category,
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

  List<Map<String, dynamic>> _getSuggestionsForTime(String timeOfDay) {
    final Map<String, List<Map<String, dynamic>>> allSuggestions = {
      'Mañana': [
        {'emoji': '☕', 'text': 'Disfrutando el café de la mañana', 'type': 'positive'},
        {'emoji': '🏃', 'text': 'Paseo o ejercicio matutino', 'type': 'positive'},
      ],
      'Tarde': [
        {'emoji': '🥗', 'text': 'Almuerzo saludable y rico', 'type': 'positive'},
        {'emoji': '💡', 'text': 'Tuve una idea brillante', 'type': 'positive'},
      ],
      'Noche': [
        {'emoji': '🧘', 'text': 'Momento de meditación o calma', 'type': 'positive'},
        {'emoji': '📚', 'text': 'Relajándome con un buen libro', 'type': 'positive'},
      ],
    };
    return allSuggestions[timeOfDay]!;
  }
}
