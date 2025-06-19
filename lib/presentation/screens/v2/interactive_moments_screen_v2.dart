// ============================================================================
// interactive_moments_screen_v2.dart - VERSIÓN MEJORADA CON FUNCIONALIDADES DEL V1
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/interactive_moments_provider.dart';
import '../components/modern_design_system.dart';
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
  late AnimationController _headerController;
  late AnimationController _categoriesController;
  late AnimationController _momentsController;

  String _selectedCategory = 'all';
  int _selectedIntensity = 5;
  final PageController _categoriesPageController = PageController();

  // CATEGORÍAS ROBUSTAS DEL V1 CON DISEÑO MODERNO
  final Map<String, Map<String, dynamic>> _categories = {
    'all': {
      'icon': '🌟',
      'name': 'Todos',
      'color': ModernColors.primaryGradient.first,
      'gradient': ModernColors.primaryGradient,
      'description': 'Ver todos los momentos',
    },
    'emocional': {
      'icon': '😊',
      'name': 'Emocional',
      'color': ModernColors.categories['emocional']!,
      'gradient': [ModernColors.categories['emocional']!, const Color(0xFF764ba2)],
      'description': 'Momentos de alegría y bienestar',
    },
    'fisico': {
      'icon': '🏃‍♀️',
      'name': 'Físico',
      'color': ModernColors.categories['fisico']!,
      'gradient': [ModernColors.categories['fisico']!, const Color(0xFF38ef7d)],
      'description': 'Bienestar físico y salud',
    },
    'social': {
      'icon': '👥',
      'name': 'Social',
      'color': ModernColors.categories['social']!,
      'gradient': [ModernColors.categories['social']!, const Color(0xFFfeca57)],
      'description': 'Conexiones y relaciones',
    },
    'mental': {
      'icon': '🧠',
      'name': 'Mental',
      'color': ModernColors.categories['mental']!,
      'gradient': [ModernColors.categories['mental']!, const Color(0xFF4ecdc4)],
      'description': 'Claridad y concentración',
    },
    'espiritual': {
      'icon': '🕯️',
      'name': 'Espiritual',
      'color': ModernColors.categories['espiritual']!,
      'gradient': [ModernColors.categories['espiritual']!, const Color(0xFF764ba2)],
      'description': 'Paz interior y trascendencia',
    },
  };

  // PALETA DE EMOCIONES COMPLETA DEL V1
  final Map<String, List<Map<String, dynamic>>> _emotionPalette = {
    'Felicidad': [
      {'emoji': '😊', 'text': 'Contento/a', 'type': 'positive', 'intensity': 6},
      {'emoji': '😄', 'text': 'Feliz', 'type': 'positive', 'intensity': 7},
      {'emoji': '🤩', 'text': 'Eufórico/a', 'type': 'positive', 'intensity': 9},
      {'emoji': '😌', 'text': 'En paz', 'type': 'positive', 'intensity': 5},
      {'emoji': '🥰', 'text': 'Lleno/a de amor', 'type': 'positive', 'intensity': 8},
    ],
    'Logros': [
      {'emoji': '🎉', 'text': 'Celebrando', 'type': 'positive', 'intensity': 8},
      {'emoji': '💪', 'text': 'Reto superado', 'type': 'positive', 'intensity': 7},
      {'emoji': '🎯', 'text': 'Objetivo cumplido', 'type': 'positive', 'intensity': 7},
      {'emoji': '🏆', 'text': 'Victoria', 'type': 'positive', 'intensity': 9},
      {'emoji': '⚡', 'text': 'Energía pura', 'type': 'positive', 'intensity': 8},
    ],
    'Creatividad': [
      {'emoji': '🎨', 'text': 'Inspirado/a', 'type': 'positive', 'intensity': 7},
      {'emoji': '💡', 'text': 'Idea brillante', 'type': 'positive', 'intensity': 8},
      {'emoji': '🚀', 'text': 'Productivo/a', 'type': 'positive', 'intensity': 7},
      {'emoji': '✨', 'text': 'Momento mágico', 'type': 'positive', 'intensity': 8},
      {'emoji': '🌟', 'text': 'Flujo creativo', 'type': 'positive', 'intensity': 7},
    ],
    'Estrés': [
      {'emoji': '😰', 'text': 'Ansioso/a', 'type': 'negative', 'intensity': 6},
      {'emoji': '😓', 'text': 'Presionado/a', 'type': 'negative', 'intensity': 7},
      {'emoji': '🤯', 'text': 'Abrumado/a', 'type': 'negative', 'intensity': 8},
      {'emoji': '😵‍💫', 'text': 'Confundido/a', 'type': 'negative', 'intensity': 5},
      {'emoji': '😤', 'text': 'Frustrado/a', 'type': 'negative', 'intensity': 6},
    ],
    'Tristeza': [
      {'emoji': '😔', 'text': 'Un poco triste', 'type': 'negative', 'intensity': 4},
      {'emoji': '😞', 'text': 'Decepcionado/a', 'type': 'negative', 'intensity': 5},
      {'emoji': '😢', 'text': 'Necesito un respiro', 'type': 'negative', 'intensity': 6},
      {'emoji': '😴', 'text': 'Cansado/a', 'type': 'negative', 'intensity': 4},
      {'emoji': '🥺', 'text': 'Vulnerable', 'type': 'negative', 'intensity': 5},
    ],
    'Gratitud': [
      {'emoji': '🙏', 'text': 'Agradecido/a', 'type': 'positive', 'intensity': 6},
      {'emoji': '💝', 'text': 'Lleno/a de amor', 'type': 'positive', 'intensity': 7},
      {'emoji': '🌸', 'text': 'Apreciando el momento', 'type': 'positive', 'intensity': 6},
      {'emoji': '🕊️', 'text': 'En armonía', 'type': 'positive', 'intensity': 5},
      {'emoji': '🌅', 'text': 'Nuevo comienzo', 'type': 'positive', 'intensity': 6},
    ],
  };

  // SUGERENCIAS INTELIGENTES BASADAS EN HORA DEL DÍA
  final Map<String, List<Map<String, dynamic>>> _timeBasedSuggestions = {
    'Mañana': [
      {'emoji': '☕', 'text': 'Café perfecto', 'type': 'positive', 'intensity': 6},
      {'emoji': '🌅', 'text': 'Buen despertar', 'type': 'positive', 'intensity': 5},
      {'emoji': '🏃‍♂️', 'text': 'Ejercicio matutino', 'type': 'positive', 'intensity': 7},
      {'emoji': '📋', 'text': 'Lista de tareas clara', 'type': 'positive', 'intensity': 6},
      {'emoji': '😴', 'text': 'Cuesta levantarse', 'type': 'negative', 'intensity': 4},
    ],
    'Mediodía': [
      {'emoji': '🍽️', 'text': 'Almuerzo delicioso', 'type': 'positive', 'intensity': 6},
      {'emoji': '💼', 'text': 'Reunión productiva', 'type': 'positive', 'intensity': 7},
      {'emoji': '📱', 'text': 'Pausa social', 'type': 'positive', 'intensity': 5},
      {'emoji': '😓', 'text': 'Mucho trabajo', 'type': 'negative', 'intensity': 6},
      {'emoji': '🤯', 'text': 'Sobrecarga mental', 'type': 'negative', 'intensity': 7},
    ],
    'Tarde': [
      {'emoji': '🎯', 'text': 'Objetivo cumplido', 'type': 'positive', 'intensity': 8},
      {'emoji': '☀️', 'text': 'Energía renovada', 'type': 'positive', 'intensity': 7},
      {'emoji': '📚', 'text': 'Aprendizaje nuevo', 'type': 'positive', 'intensity': 6},
      {'emoji': '😵‍💫', 'text': 'Bajón de energía', 'type': 'negative', 'intensity': 5},
      {'emoji': '⏰', 'text': 'Presión de tiempo', 'type': 'negative', 'intensity': 6},
    ],
    'Noche': [
      {'emoji': '🛀', 'text': 'Relajándome', 'type': 'positive', 'intensity': 6},
      {'emoji': '📚', 'text': 'Lectura tranquila', 'type': 'positive', 'intensity': 5},
      {'emoji': '🍷', 'text': 'Momento para mí', 'type': 'positive', 'intensity': 6},
      {'emoji': '🙏', 'text': 'Reflexión del día', 'type': 'positive', 'intensity': 5},
      {'emoji': '😔', 'text': 'Día pesado', 'type': 'negative', 'intensity': 5},
    ],
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayMoments();
    });
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _categoriesController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _momentsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _categoriesController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _momentsController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _categoriesController.dispose();
    _momentsController.dispose();
    _categoriesPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      body: Column(
        children: [
          _buildModernHeader(),
          _buildCategoriesSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuickMomentsTab(),
                _buildPaletteTab(),
                _buildSuggestionsTab(),
                _buildTimelineTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOutBack,
      )),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          ModernSpacing.lg,
          ModernSpacing.xxl,
          ModernSpacing.lg,
          ModernSpacing.lg,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _categories[_selectedCategory]!['gradient'],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ModernSpacing.md,
                    vertical: ModernSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                  ),
                  child: Consumer<InteractiveMomentsProvider>(
                    builder: (context, provider, child) {
                      return Text(
                        'Hoy: ${provider.positiveCount}+ / ${provider.negativeCount}-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: ModernSpacing.lg),
            Row(
              children: [
                Text(
                  _categories[_selectedCategory]!['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: ModernSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Momentos ${_categories[_selectedCategory]!['name']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _categories[_selectedCategory]!['description'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ModernSpacing.lg),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.white,
        ),
        tabs: const [
          Tab(text: 'Rápido'),
          Tab(text: 'Paleta'),
          Tab(text: 'Ideas'),
          Tab(text: 'Timeline'),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _categoriesController,
        curve: Curves.easeOutCubic,
      )),
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: ModernSpacing.md),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.lg),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories.entries.elementAt(index);
            final isSelected = _selectedCategory == category.key;

            return GestureDetector(
              onTap: () => _selectCategory(category.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: ModernSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernSpacing.md,
                  vertical: ModernSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: category.value['gradient'])
                      : null,
                  color: isSelected ? null : ModernColors.glassSurface,
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : category.value['color'].withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.value['icon'],
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.value['name'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : ModernColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickMomentsTab() {
    return FadeTransition(
      opacity: _momentsController,
      child: ListView(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        children: [
          _buildIntensitySelector(),
          const SizedBox(height: ModernSpacing.lg),
          ..._emotionPalette.entries.take(3).map((entry) =>
              _buildEmotionGroup(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildIntensitySelector() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Intensidad del Momento', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.md),
          Row(
            children: [
              Text('Leve', style: ModernTypography.bodySmall),
              Expanded(
                child: Slider(
                  value: _selectedIntensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _categories[_selectedCategory]!['color'],
                  onChanged: (value) {
                    setState(() {
                      _selectedIntensity = value.round();
                    });
                  },
                ),
              ),
              Text('Intenso', style: ModernTypography.bodySmall),
            ],
          ),
          Text(
            'Nivel: $_selectedIntensity/10 - ${_getIntensityDescription(_selectedIntensity)}',
            style: TextStyle(
              color: _categories[_selectedCategory]!['color'],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionGroup(String groupName, List<Map<String, dynamic>> emotions) {
    return Column(
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(groupName, style: ModernTypography.heading3),
              const SizedBox(height: ModernSpacing.md),
              Wrap(
                spacing: ModernSpacing.sm,
                runSpacing: ModernSpacing.sm,
                children: emotions.map((emotion) {
                  return GestureDetector(
                    onTap: () => _addMoment(emotion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernSpacing.md,
                        vertical: ModernSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: emotion['type'] == 'positive'
                            ? ModernColors.success.withOpacity(0.1)
                            : ModernColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                        border: Border.all(
                          color: emotion['type'] == 'positive'
                              ? ModernColors.success.withOpacity(0.3)
                              : ModernColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emotion['emoji'], style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: ModernSpacing.sm),
                          Text(emotion['text'], style: ModernTypography.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: ModernSpacing.lg),
      ],
    );
  }

  Widget _buildPaletteTab() {
    return ListView(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      children: [
        _buildIntensitySelector(),
        const SizedBox(height: ModernSpacing.lg),
        ..._emotionPalette.entries.map((entry) =>
            _buildEmotionGroup(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildSuggestionsTab() {
    final timeOfDay = _getTimeOfDay();
    final suggestions = _timeBasedSuggestions[timeOfDay] ?? [];

    return ListView(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      children: [
        ModernCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_getTimeEmoji(), style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: ModernSpacing.sm),
                  Text('Sugerencias de $timeOfDay', style: ModernTypography.heading3),
                ],
              ),
              const SizedBox(height: ModernSpacing.md),
              Text(
                'Momentos típicos para esta hora del día',
                style: TextStyle(
                  color: ModernColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: ModernSpacing.lg),
              ...suggestions.map((suggestion) {
                return Container(
                  margin: const EdgeInsets.only(bottom: ModernSpacing.sm),
                  child: ListTile(
                    leading: Text(suggestion['emoji'], style: const TextStyle(fontSize: 24)),
                    title: Text(suggestion['text'], style: ModernTypography.bodyLarge),
                    subtitle: Text(
                      'Intensidad sugerida: ${suggestion['intensity']}/10',
                      style: ModernTypography.bodySmall,
                    ),
                    trailing: IconButton(
                      onPressed: () => _addMoment(suggestion),
                      icon: Icon(
                        Icons.add_circle,
                        color: suggestion['type'] == 'positive'
                            ? ModernColors.success
                            : ModernColors.warning,
                      ),
                    ),
                    onTap: () => _addMoment(suggestion),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab() {
    return Consumer<InteractiveMomentsProvider>(
      builder: (context, provider, child) {
        final moments = provider.moments;

        if (moments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📝', style: const TextStyle(fontSize: 64)),
                const SizedBox(height: ModernSpacing.lg),
                Text(
                  '¡Tu timeline está esperando!',
                  style: ModernTypography.heading3,
                ),
                const SizedBox(height: ModernSpacing.sm),
                Text(
                  'Agrega tu primer momento del día',
                  style: ModernTypography.bodyMedium.copyWith(
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(ModernSpacing.lg),
          itemCount: moments.length,
          itemBuilder: (context, index) {
            final moment = moments[index];
            return _buildTimelineItem(moment, index);
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(InteractiveMomentModel moment, int index) {
    final isPositive = moment.type == 'positive';

    return Container(
      margin: const EdgeInsets.only(bottom: ModernSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPositive ? ModernColors.success : ModernColors.warning,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    moment.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              if (index < Provider.of<InteractiveMomentsProvider>(context, listen: false).moments.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: ModernColors.glassSecondary,
                ),
            ],
          ),
          const SizedBox(width: ModernSpacing.md),

          // Content
          Expanded(
            child: ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          moment.text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        moment.timeStr,
                        style: TextStyle(
                          color: ModernColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ModernSpacing.sm),
                  Row(
                    children: [
                      _buildInfoChip(
                        'Intensidad ${moment.intensity}/10',
                        isPositive ? ModernColors.success : ModernColors.warning,
                      ),
                      const SizedBox(width: ModernSpacing.sm),
                      _buildInfoChip(
                        moment.category.toUpperCase(),
                        _getCategoryColor(moment.category),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showCustomMomentDialog,
      backgroundColor: _categories[_selectedCategory]!['color'],
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Momento Custom',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // HELPER METHODS
  void _selectCategory(String categoryKey) {
    setState(() {
      _selectedCategory = categoryKey;
    });
  }

  Future<void> _addMoment(Map<String, dynamic> emotion) async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser == null) return;

    final success = await momentsProvider.addMoment(
      userId: authProvider.currentUser!.id!,
      emoji: emotion['emoji'],
      text: emotion['text'],
      type: emotion['type'],
      intensity: emotion['intensity'] ?? _selectedIntensity,
      category: _selectedCategory,
    );

    if (success) {
      _showSuccessAnimation(emotion);
    }
  }

  void _showSuccessAnimation(Map<String, dynamic> emotion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emotion['emoji'], style: const TextStyle(fontSize: 20)),
            const SizedBox(width: ModernSpacing.sm),
            Expanded(
              child: Text(
                '${emotion['text']} añadido con intensidad $_selectedIntensity/10',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: emotion['type'] == 'positive'
            ? ModernColors.success
            : ModernColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        ),
      ),
    );
  }

  void _showCustomMomentDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Momento Personalizado', style: ModernTypography.heading3),
              const SizedBox(height: ModernSpacing.lg),
              Text(
                '¡Próximamente! Panel personalizado para crear momentos únicos.',
                style: TextStyle(
                  color: ModernColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSpacing.lg),
              ModernButton(
                text: 'Cerrar',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadTodayMoments() async {
    final authProvider = context.read<AuthProvider>();
    final momentsProvider = context.read<InteractiveMomentsProvider>();

    if (authProvider.currentUser != null) {
      await momentsProvider.loadTodayMoments(authProvider.currentUser!.id!);
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Mañana';
    if (hour >= 12 && hour < 17) return 'Mediodía';
    if (hour >= 17 && hour < 21) return 'Tarde';
    return 'Noche';
  }

  String _getTimeEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '🌅';
    if (hour >= 12 && hour < 17) return '☀️';
    if (hour >= 17 && hour < 21) return '🌆';
    return '🌙';
  }

  String _getIntensityDescription(int intensity) {
    if (intensity >= 9) return 'Muy intenso';
    if (intensity >= 7) return 'Intenso';
    if (intensity >= 5) return 'Moderado';
    if (intensity >= 3) return 'Leve';
    return 'Muy leve';
  }

  Color _getCategoryColor(String category) {
    return _categories[category]?['color'] ??
        ModernColors.categories[category] ??
        ModernColors.info;
  }
}