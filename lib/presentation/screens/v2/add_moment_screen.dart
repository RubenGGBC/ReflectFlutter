// ============================================================================
// screens/v2/add_moment_screen.dart - REDISEÑO AVANZADO Y DETALLADO - FIXED
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/modern_design_system.dart';
// FIX: Cambiar a providers optimizados
import '../../providers/optimized_providers.dart';
import 'dart:ui';

class AddMomentScreen extends StatefulWidget {
  const AddMomentScreen({super.key});

  @override
  State<AddMomentScreen> createState() => _AddMomentScreenState();
}

class _AddMomentScreenState extends State<AddMomentScreen> {
  final _textController = TextEditingController();
  final _tagsController = TextEditingController();

  // State for the form
  String _momentType = 'positive';
  double _intensity = 5.0;
  DateTime _selectedDate = DateTime.now();
  final Set<String> _tags = {};

  // Suggested tags based on text input
  final List<String> _allPossibleTags = ['trabajo', 'personal', 'salud', 'social', 'creativo', 'familia', 'amigos', 'proyecto'];
  List<String> _suggestedTags = [];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateSuggestedTags);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateSuggestedTags);
    _textController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateSuggestedTags() {
    final text = _textController.text.toLowerCase();
    if (text.isEmpty) {
      setState(() => _suggestedTags = []);
      return;
    }
    setState(() {
      _suggestedTags = _allPossibleTags.where((tag) => text.contains(tag) && !_tags.contains(tag)).toList();
    });
  }

  void _addMoment() async {
    if (_textController.text.trim().isEmpty) return;

    // FIX: Obtener todos los providers necesarios para refrescar la data
    final momentsProvider = context.read<OptimizedMomentsProvider>();
    final dailyEntriesProvider = context.read<OptimizedDailyEntriesProvider>();
    final analyticsProvider = context.read<OptimizedAnalyticsProvider>();
    final userId = context.read<OptimizedAuthProvider>().currentUser?.id;

    if (userId == null) return;

    final success = await momentsProvider.addMoment(
      userId: userId,
      text: _textController.text.trim(),
      emoji: _getEmojiForType(_momentType),
      type: _momentType,
      intensity: _intensity.toInt(),
      category: _tags.isNotEmpty ? _tags.join(', ') : 'general',
      // FIX: Para mantener compatibilidad con OptimizedMomentsProvider
      // el parámetro timeStr no se necesita aquí ya que se genera automáticamente
    );

    if (mounted && success) {
      // ✅ REFRESCAR DATOS DE LA HOME SCREEN ANTES DE VOLVER
      await momentsProvider.loadTodayMoments(userId);
      await dailyEntriesProvider.loadEntries(userId);
      await analyticsProvider.loadCompleteAnalytics(userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Momento guardado con éxito'), backgroundColor: ModernColors.success),
      );
      Navigator.pop(context);
    }
  }

  String _getEmojiForType(String type) {
    switch (type) {
      case 'grateful': return '🙏';
      case 'happy': return '😄';
      case 'productive': return '🚀';
      case 'calm': return '😌';
      case 'sad': return '😔';
      case 'stressed': return '😰';
      case 'tired': return '😴';
      default: return '🤔';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernColors.darkPrimary,
      appBar: AppBar(
        title: const Text('Añadir Nuevo Momento'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _addMoment, icon: const Icon(Icons.check_circle_outline))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(ModernSpacing.md),
        children: [
          _buildDescriptionCard(),
          const SizedBox(height: ModernSpacing.md),
          _buildEmotionCard(),
          const SizedBox(height: ModernSpacing.md),
          _buildDetailsCard(),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('El Momento', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.md),
          ModernTextField(
            controller: _textController,
            hintText: '¿Qué ha pasado o en qué estás pensando?',
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCard() {
    final List<Map<String, dynamic>> emotionTypes = [
      {'label': 'Agradecido', 'type': 'grateful', 'icon': '🙏'},
      {'label': 'Feliz', 'type': 'happy', 'icon': '😄'},
      {'label': 'Productivo', 'type': 'productive', 'icon': '🚀'},
      {'label': 'En calma', 'type': 'calm', 'icon': '😌'},
      {'label': 'Triste', 'type': 'sad', 'icon': '😔'},
      {'label': 'Estresado', 'type': 'stressed', 'icon': '😰'},
      {'label': 'Cansado', 'type': 'tired', 'icon': '😴'},
    ];

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('La Emoción', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.md),
          Wrap(
            spacing: ModernSpacing.sm,
            runSpacing: ModernSpacing.sm,
            children: emotionTypes.map((emotion) {
              final isSelected = _momentType == emotion['type'];
              return ChoiceChip(
                label: Text(emotion['label']),
                avatar: Text(emotion['icon']),
                selected: isSelected,
                onSelected: (selected) {
                  if(selected) setState(() => _momentType = emotion['type']);
                },
                backgroundColor: ModernColors.glassSurface,
                selectedColor: ModernColors.primaryGradient.first,
              );
            }).toList(),
          ),
          const SizedBox(height: ModernSpacing.lg),
          Text('Intensidad: ${_intensity.toInt()}', style: ModernTypography.bodyLarge),
          Slider(
            value: _intensity,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: ModernColors.primaryGradient.first,
            inactiveColor: ModernColors.glassSurface,
            label: _intensity.toInt().toString(),
            onChanged: (value) => setState(() => _intensity = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalles Adicionales', style: ModernTypography.heading3),
          const SizedBox(height: ModernSpacing.md),
          _buildDateTimePicker(),
          const Divider(height: ModernSpacing.lg, color: ModernColors.glassSecondary),
          _buildTagInput(),
          if(_suggestedTags.isNotEmpty) ...[
            const SizedBox(height: ModernSpacing.sm),
            Wrap(
              spacing: ModernSpacing.sm,
              children: _suggestedTags.map((tag) => ActionChip(label: Text('Añadir "$tag"'), onPressed: (){
                setState(() {
                  _tags.add(tag);
                  _updateSuggestedTags();
                });
              })).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return ListTile(
      leading: const Icon(Icons.calendar_today_outlined, color: ModernColors.textSecondary),
      title: const Text('Fecha y Hora'),
      subtitle: Text('${MaterialLocalizations.of(context).formatFullDate(_selectedDate)}, ${TimeOfDay.fromDateTime(_selectedDate).format(context)}'),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date == null) return;

        if (!mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDate),
        );
        if (time == null) return;

        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      },
    );
  }

  Widget _buildTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernTextField(
          controller: _tagsController,
          hintText: 'Añadir etiqueta (ej: trabajo)',
          prefixIcon: Icons.label_outline,
          onFieldSubmitted: (tag) {
            if (tag.trim().isNotEmpty) {
              setState(() {
                _tags.add(tag.trim().toLowerCase());
                _tagsController.clear();
                _updateSuggestedTags();
              });
            }
          },
        ),
        const SizedBox(height: ModernSpacing.sm),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: ModernSpacing.sm,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                    _updateSuggestedTags();
                  });
                },
                backgroundColor: ModernColors.primaryGradient.last.withOpacity(0.8),
                deleteIconColor: Colors.white70,
              );
            }).toList(),
          ),
      ],
    );
  }
}