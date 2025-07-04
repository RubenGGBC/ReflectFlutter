// ============================================================================
// presentation/screens/v2/interactive_moments_screen_v2.dart - CÓDIGO MEJORADO Y DIDÁCTICO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:dotted_border/dotted_border.dart'; // Asegúrate de añadir esta dependencia

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
  late AnimationController _listController;

  // Estado para la pestaña de "Ver Momentos"
  String _selectedFilterCategory = 'all';

  // Estado para la pestaña de "Añadir Momento"
  final _textController = TextEditingController();
  final _emojiController = TextEditingController(text: '✨');
  String _momentType = 'positive';
  int _selectedIntensity = 5;
  String? _selectedCategoryForAdd; // <-- UX CORREGIDA: Categoría para el nuevo momento

  // Definición centralizada de categorías
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

  void _setupAnimations() {
    _tabController = TabController(length: 2, vsync: this);
    _headerController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)..forward();
    _listController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this)..forward();
  }

  Future<void> _loadMoments() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authProvider = context.read<OptimizedAuthProvider>();
      final user = authProvider.currentUser;
      if (user != null) {
        await context.read<OptimizedMomentsProvider>().loadMoments(user.id);
        if(mounted) _listController.forward(from: 0.0);
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

  // --- WIDGETS DE LA PESTAÑA "VER MOMENTOS" ---

  Widget _buildViewMomentsTab() {
    return Column(
      children: [
        _buildCategoriesFilter(),
        Expanded(child: _buildMomentsList()),
      ],
    );
  }

  Widget _buildCategoriesFilter() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack)),
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: _categories.entries.map((entry) {
            final categoryId = entry.key;
            final categoryData = entry.value;
            final isSelected = _selectedFilterCategory == categoryId;
            return _buildCategoryChip(categoryId, categoryData, isSelected, (id) {
              setState(() => _selectedFilterCategory = id);
              _listController.forward(from: 0.0);
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String id, Map<String, dynamic> data, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: data['gradient']) : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data['icon'], style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              data['name'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMomentsList() {
    return Consumer<OptimizedMomentsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.moments.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final filteredMoments = _selectedFilterCategory == 'all'
            ? provider.moments
            : provider.getMomentsByCategory(_selectedFilterCategory);

        if (filteredMoments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_categories[_selectedFilterCategory]?['icon'] ?? '✨', style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('No hay momentos en esta categoría', style: TextStyle(color: Colors.white60, fontSize: 16)),
              ],
            ),
          );
        }

        return FadeTransition(
          opacity: _listController,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredMoments.length,
            itemBuilder: (context, index) {
              final moment = filteredMoments[index];
              return _buildMomentCard(moment, index);
            },
          ),
        );
      },
    );
  }

  // --- WIDGETS DE LA PESTAÑA "AÑADIR MOMENTO" (ENFOQUE DIDÁCTICO) ---

  Widget _buildAddMomentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGuidingCard(
            icon: Icons.sentiment_very_satisfied_outlined,
            title: '1. ¿Qué sentiste?',
            child: _buildTypeSelector(),
          ),
          _buildGuidingCard(
            icon: Icons.edit_note,
            title: '2. Descríbelo',
            child: _buildDescriptionCard(),
          ),
          _buildGuidingCard(
            icon: Icons.category_outlined,
            title: '3. Elige una categoría',
            child: _buildCategorySelectorForAdd(),
          ),
          _buildGuidingCard(
            icon: Icons.add_chart,
            title: '4. Añade detalles',
            child: _buildDetailsCard(),
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildGuidingCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(child: _buildTypeButton('positive', 'Positivo', '😊', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildTypeButton('negative', 'Desafío', '😔', Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildTypeButton('neutral', 'Neutral', '😐', Colors.grey)),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hint: Text('Describe tu momento...')),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Elige un emoji:', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _emojiController,
                maxLength: 2,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(hint: Text('✨')).copyWith(counterText: ""),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCategorySelectorForAdd() {
    // Excluimos 'all' de las opciones a elegir
    final selectableCategories = _categories.entries.where((e) => e.key != 'all').toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: selectableCategories.map((entry) {
        final categoryId = entry.key;
        final categoryData = entry.value;
        final isSelected = _selectedCategoryForAdd == categoryId;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryForAdd = categoryId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: categoryData['gradient']) : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              '${categoryData['icon']} ${categoryData['name']}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Intensidad (1-10)', style: TextStyle(color: Colors.white70)),
        Row(
          children: [
            Text('1', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            Expanded(
              child: Slider(
                value: _selectedIntensity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _selectedIntensity.toString(),
                activeColor: ModernColors.primaryGradient.first,
                inactiveColor: Colors.white.withOpacity(0.3),
                onChanged: (value) => setState(() => _selectedIntensity = value.round()),
              ),
            ),
            Text('10', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        // --- FUTURA OPCIÓN PARA AÑADIR FOTO ---
        DottedBorder(
          color: Colors.white38,
          strokeWidth: 1,
          dashPattern: const [6, 4],
          radius: const Radius.circular(12),
          borderType: BorderType.RRect,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.white38),
                  SizedBox(width: 12),
                  Text('Añadir Foto (Próximamente)', style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }


  Future<void> _addMoment() async {
    // Validaciones
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('Por favor describe tu momento.', isError: true);
      return;
    }
    if (_selectedCategoryForAdd == null) {
      _showSnackBar('Por favor, selecciona una categoría para tu momento.', isError: true);
      return;
    }

    final authProvider = context.read<OptimizedAuthProvider>();
    final momentsProvider = context.read<OptimizedMomentsProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      _showSnackBar('Error: Usuario no autenticado.', isError: true);
      return;
    }

    final success = await momentsProvider.addMoment(
      userId: user.id,
      emoji: _emojiController.text.isNotEmpty ? _emojiController.text : '✨',
      text: _textController.text.trim(),
      type: _momentType,
      intensity: _selectedIntensity,
      category: _selectedCategoryForAdd!, // Usamos la nueva variable de estado
    );

    if (mounted) {
      if (success) {
        _showSnackBar('¡Momento registrado con éxito!');
        // Resetear formulario
        _textController.clear();
        _emojiController.text = '✨';
        setState(() {
          _momentType = 'positive';
          _selectedIntensity = 5;
          _selectedCategoryForAdd = null; // Reseteamos la categoría
        });
        _tabController.animateTo(0);
        _loadMoments(); // Recargar la lista de momentos
      } else {
        _showSnackBar(momentsProvider.errorMessage ?? 'Error al registrar el momento.', isError: true);
      }
    }
  }


  // --- WIDGETS COMUNES Y LÓGICA ---

  Widget _buildModernHeader() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: ModernColors.primaryGradient,),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: 8),
                const Expanded(child: Text('✨ Momentos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                Consumer<OptimizedMomentsProvider>(
                  builder: (context, momentsProvider, child) => IconButton(
                    icon: momentsProvider.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)) : const Icon(Icons.refresh, color: Colors.white),
                    onPressed: momentsProvider.isLoading ? null : _loadMoments,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<OptimizedMomentsProvider>(
              builder: (context, momentsProvider, child) {
                final stats = momentsProvider.getMomentsStats();
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Total', '${stats['total'] ?? 0}', Icons.auto_awesome)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Hoy', '${stats['today'] ?? 0}', Icons.today)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Positivos', '${((stats['positive_ratio'] as double? ?? 0) * 100).toInt()}%', Icons.sentiment_very_satisfied)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
            gradient: LinearGradient(colors: ModernColors.primaryGradient),
            borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        tabs: const [
          Tab(icon: Icon(Icons.list_alt_rounded), text: 'Mis Momentos'),
          Tab(icon: Icon(Icons.add_circle_outline_rounded), text: 'Añadir Nuevo')
        ],
      ),
    );
  }

  Widget _buildMomentCard(OptimizedInteractiveMomentModel moment, int index) {
    // Reutilizado de la versión anterior, ya es bastante bueno
    return Container(
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
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse(moment.colorHex.substring(1), radix: 16) + 0xFF000000).withOpacity(0.2),
                ),
                child: Center(child: Text(moment.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: _categories[moment.category]?['color']?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(_categories[moment.category]?['name'] ?? moment.category,
                              style: TextStyle( color: _categories[moment.category]?['color'], fontSize: 10, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(moment.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(moment.timeStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) => Icon(i < (moment.intensity / 2).round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 12)),
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
    );
  }

  // El resto de los widgets (stat card, details, etc.) y la lógica (_showSnackBar, dispose) se mantienen igual
  // ya que son robustos y no necesitan cambios para cumplir los nuevos requisitos.

  @override
  void dispose() {
    _tabController.dispose();
    _headerController.dispose();
    _listController.dispose();
    _textController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, String emoji, Color color) {
    final isSelected = _momentType == type;
    return GestureDetector(
      onTap: () => setState(() => _momentType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? color : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
            boxShadow: [BoxShadow(color: ModernColors.primaryGradient.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: momentsProvider.isLoading ? null : _addMoment,
              child: Center(
                child: momentsProvider.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Registrar Momento', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        );
      },
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
              const Icon(Icons.battery_charging_full, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text('Energía: ${moment.energyBefore} → ${moment.energyAfter}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          if (moment.hasMoodData) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.sentiment_satisfied, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text('Ánimo: ${moment.moodBefore} → ${moment.moodAfter}', style: const TextStyle(color: Colors.white70, fontSize: 12))
            ])
          ],
          if (moment.contextLocation != null || moment.contextWeather != null || moment.contextSocial != null) ...[
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      [moment.contextLocation, moment.contextWeather, moment.contextSocial].where((c) => c != null).join(' • '),
                      style: const TextStyle(color: Colors.white70, fontSize: 12))),
            ]),
          ],
        ],
      ),
    );
  }

}