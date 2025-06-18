// ============================================================================
// MODERN INTERACTIVE MOMENTS SCREEN - Rediseñada con componentes modernos
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../widgets/modern_ui_components.dart';

class ModernInteractiveMomentsScreen extends StatefulWidget {
  const ModernInteractiveMomentsScreen({super.key});

  @override
  State<ModernInteractiveMomentsScreen> createState() =>
      _ModernInteractiveMomentsScreenState();
}

class _ModernInteractiveMomentsScreenState
    extends State<ModernInteractiveMomentsScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _categoriesController;
  late AnimationController _momentsController;

  // State
  String _selectedCategory = 'all';
  final List<Map<String, dynamic>> _todayMoments = [];
  final PageController _categoriesPageController = PageController();

  // Categories with modern design
  final Map<String, Map<String, dynamic>> _categories = {
    'all': {
      'icon': '🌟',
      'name': 'Todos',
      'color': const Color(0xFF667eea),
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    },
    'positive': {
      'icon': '😊',
      'name': 'Positivos',
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
    },
    'creative': {
      'icon': '🎨',
      'name': 'Creativos',
      'color': const Color(0xFFF59E0B),
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    },
    'work': {
      'icon': '💼',
      'name': 'Trabajo',
      'color': const Color(0xFF3B82F6),
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
    },
    'health': {
      'icon': '🏃‍♀️',
      'name': 'Salud',
      'color': const Color(0xFFEF4444),
      'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
    },
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTodayMoments();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _categoriesController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _momentsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Staggered animations
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
    _headerController.dispose();
    _categoriesController.dispose();
    _momentsController.dispose();
    _categoriesPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernHeader(),
              _buildCategoriesSection(),
              Expanded(child: _buildMomentsContent()),
              _buildFloatingAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return FadeTransition(
      opacity: _headerController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _headerController,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCurrentDate(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Stats circle
                  _buildStatsCircle(),
                ],
              ),

              const SizedBox(height: 16),

              // Subtitle with moments count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      '${_todayMoments.length} momentos hoy',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCircle() {
    final progress = math.min(_todayMoments.length / 10.0, 1.0);

    return Container(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF667eea),
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_todayMoments.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Text(
                'hoy',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return FadeTransition(
      opacity: _categoriesController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _categoriesController,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final categoryKey = _categories.keys.elementAt(index);
              final category = _categories[categoryKey]!;
              final isSelected = _selectedCategory == categoryKey;

              return _buildCategoryChip(
                categoryKey: categoryKey,
                category: category,
                isSelected: isSelected,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String categoryKey,
    required Map<String, dynamic> category,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectCategory(categoryKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: category['gradient'])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (category['color'] as Color).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category['icon'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomentsContent() {
    return FadeTransition(
      opacity: _momentsController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _momentsController,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Today's timeline
              if (_todayMoments.isNotEmpty) ...[
                _buildTodayTimeline(),
                const SizedBox(height: 24),
              ],

              // Quick add suggestions
              Expanded(child: _buildQuickAddGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Timeline de Hoy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _todayMoments.length,
              itemBuilder: (context, index) {
                final moment = _todayMoments[index];
                return _buildTimelineMoment(moment, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineMoment(Map<String, dynamic> moment, int index) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Emoji bubble
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCategoryColor(moment['category']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _getCategoryColor(moment['category']).withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                moment['emoji'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Time
          Text(
            moment['time'] ?? '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          // Text preview
          Text(
            moment['text']?.substring(0, math.min(moment['text'].length, 10)) ?? '',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddGrid() {
    final suggestions = _getFilteredSuggestions();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ ${_categories[_selectedCategory]!['name']} Rápidos',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildSuggestionChip(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(Map<String, dynamic> suggestion) {
    final isPositive = suggestion['type'] == 'positive';

    return GestureDetector(
      onTap: () => _addMoment(suggestion),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444)).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              suggestion['emoji'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion['text'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FloatingActionButton.extended(
        onPressed: _showCustomMomentDialog,
        backgroundColor: const Color(0xFF667eea),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Momento Personalizado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Color _getCategoryColor(String? category) {
    return _categories[category]?['color'] ?? const Color(0xFF667eea);
  }

  void _selectCategory(String categoryKey) {
    setState(() {
      _selectedCategory = categoryKey;
    });
  }

  List<Map<String, dynamic>> _getFilteredSuggestions() {
    // Return category-specific suggestions
    return [
      {'emoji': '😊', 'text': 'Momento feliz', 'type': 'positive', 'category': _selectedCategory},
      {'emoji': '🎉', 'text': 'Logro conseguido', 'type': 'positive', 'category': _selectedCategory},
      {'emoji': '💪', 'text': 'Me siento fuerte', 'type': 'positive', 'category': _selectedCategory},
      {'emoji': '🌟', 'text': 'Inspiración súbita', 'type': 'positive', 'category': _selectedCategory},
      {'emoji': '😔', 'text': 'Un poco triste', 'type': 'negative', 'category': _selectedCategory},
      {'emoji': '😰', 'text': 'Momento estresante', 'type': 'negative', 'category': _selectedCategory},
    ];
  }

  void _addMoment(Map<String, dynamic> suggestion) {
    setState(() {
      _todayMoments.add({
        ...suggestion,
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'timestamp': DateTime.now(),
      });
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${suggestion['emoji']} ${suggestion['text']} añadido'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCustomMomentDialog() {
    // Show custom moment creation dialog
    // This would open a FloatingPanel with custom form
  }

  void _loadTodayMoments() {
    // Load today's moments from provider/database
    // For demo purposes, adding some sample data
    setState(() {
      _todayMoments.addAll([
        {
          'emoji': '☕',
          'text': 'Café matutino perfecto',
          'type': 'positive',
          'category': 'positive',
          'time': '08:30',
        },
        {
          'emoji': '💼',
          'text': 'Reunión productiva',
          'type': 'positive',
          'category': 'work',
          'time': '10:15',
        },
      ]);
    });
  }
}