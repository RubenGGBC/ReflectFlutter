// lib/presentation/screens/v2/moment_capture_hub_screen.dart
// Pantalla de captura de momentos completamente arreglada

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/optimized_models.dart';
import '../../providers/optimized_providers.dart'; // ✅ IMPORT ARREGLADO
import '../components/modern_design_system.dart';

class MomentsHubScreen extends StatefulWidget {
  const MomentsHubScreen({super.key});

  @override
  State<MomentsHubScreen> createState() => _MomentsHubScreenState();
}

class _MomentsHubScreenState extends State<MomentsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _momentController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedType = 'positive';
  int _selectedIntensity = 5;

  final List<String> _categories = [
    'general', 'trabajo', 'familia', 'salud', 'amor', 'amistad', 'estudio'
  ];

  final Map<String, String> _categoryEmojis = {
    'general': '✨',
    'trabajo': '💼',
    'familia': '👨‍👩‍👧‍👦',
    'salud': '🏥',
    'amor': '❤️',
    'amistad': '👫',
    'estudio': '📚',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMoments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _momentController.dispose();
    super.dispose();
  }

  void _loadMoments() {
    final authProvider = context.read<OptimizedAuthProvider>(); // ✅ PROVIDER ARREGLADO
    final user = authProvider.currentUser;

    if (user != null) {
      context.read<OptimizedMomentsProvider>().loadMoments(user.id); // ✅ PROVIDER ARREGLADO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        backgroundColor: ModernColors.darkPrimary,
        elevation: 0,
        title: const Text(
          'Momentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ModernColors.accentBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '✨ Capturar'),
            Tab(text: '📚 Historial'),
          ],
        ),
      ),
      body: Consumer2<OptimizedAuthProvider, OptimizedMomentsProvider>( // ✅ PROVIDERS ARREGLADOS
        builder: (context, auth, moments, child) {
          if (auth.currentUser == null) {
            return const Center(
              child: Text(
                'Usuario no autenticado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCaptureTab(auth.currentUser!, moments),
              _buildHistoryTab(moments),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaptureTab(OptimizedUserModel user, OptimizedMomentsProvider moments) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header motivacional
          _buildMotivationalHeader(),
          const SizedBox(height: 24),

          // Formulario de captura
          _buildCaptureForm(user, moments),
          const SizedBox(height: 24),

          // Momentos de hoy
          _buildTodayMoments(moments),
        ],
      ),
    );
  }

  Widget _buildMotivationalHeader() {
    final hour = DateTime.now().hour;
    String message;
    String emoji;

    if (hour < 12) {
      message = '¡Buenos días! ¿Qué te está inspirando esta mañana?';
      emoji = '🌅';
    } else if (hour < 18) {
      message = '¿Cómo va tu tarde? Captura este momento';
      emoji = '☀️';
    } else {
      message = 'Reflexiona sobre tu día. ¿Qué destacarías?';
      emoji = '🌙';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureForm(OptimizedUserModel user, OptimizedMomentsProvider moments) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Captura tu momento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de texto
          TextField(
            controller: _momentController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe lo que estás sintiendo o pensando...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tipo de momento
          const Text(
            'Tipo de momento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton('positive', '😊 Positivo', _selectedType == 'positive'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeButton('negative', '😔 Desafiante', _selectedType == 'negative'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categoría
          const Text(
            'Categoría',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) => _buildCategoryChip(category)).toList(),
          ),
          const SizedBox(height: 16),

          // Intensidad
          const Text(
            'Intensidad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('1', style: TextStyle(color: Colors.white54)),
              Expanded(
                child: Slider(
                  value: _selectedIntensity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: ModernColors.accentBlue,
                  onChanged: (value) {
                    setState(() {
                      _selectedIntensity = value.round();
                    });
                  },
                ),
              ),
              const Text('10', style: TextStyle(color: Colors.white54)),
            ],
          ),
          Text(
            'Intensidad: $_selectedIntensity/10',
            style: TextStyle(
              color: ModernColors.accentBlue,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),

          // Botón guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: moments.isLoading ? null : () => _saveMoment(user, moments),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: moments.isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Guardar Momento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ModernColors.accentBlue : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ModernColors.accentBlue : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    final emoji = _categoryEmojis[category] ?? '✨';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ModernColors.accentBlue : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ModernColors.accentBlue : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              category.substring(0, 1).toUpperCase() + category.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMoments(OptimizedMomentsProvider moments) {
    final todayMoments = moments.todayMoments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Momentos de Hoy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${todayMoments.length} momentos',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (todayMoments.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ModernColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Aún no has capturado momentos hoy\n¡Empieza ahora!',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...todayMoments.map((moment) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ModernColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  _categoryEmojis[moment.category] ?? '✨',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moment.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${moment.category} • ${moment.timestamp.hour.toString().padLeft(2, '0')}:${moment.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: moment.type == 'positive' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${moment.intensity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildHistoryTab(OptimizedMomentsProvider moments) {
    final allMoments = moments.moments;

    if (moments.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allMoments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes momentos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comienza a capturar tus momentos especiales',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.accentBlue,
              ),
              child: const Text('Capturar Primer Momento'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allMoments.length,
      itemBuilder: (context, index) {
        final moment = allMoments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _categoryEmojis[moment.category] ?? '✨',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moment.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${moment.entryDate.day}/${moment.entryDate.month}/${moment.entryDate.year} • ${moment.timestamp.hour.toString().padLeft(2, '0')}:${moment.timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: moment.type == 'positive' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          moment.type == 'positive' ? 'Positivo' : 'Desafiante',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${moment.intensity}/10',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveMoment(OptimizedUserModel user, OptimizedMomentsProvider moments) async {
    if (_momentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, describe tu momento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await moments.addMoment(
      userId: user.id,
      emoji: _categoryEmojis[_selectedCategory] ?? '✨',
      text: _momentController.text.trim(),
      type: _selectedType,
      category: _selectedCategory,
      intensity: _selectedIntensity,
    );

    if (success) {
      _momentController.clear();
      setState(() {
        _selectedIntensity = 5;
        _selectedType = 'positive';
        _selectedCategory = 'general';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Momento guardado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(moments.errorMessage ?? 'Error al guardar el momento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}