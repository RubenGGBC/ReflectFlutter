// ============================================================================
// components/add_moment_panel.dart - PANEL PARA AÑADIR MOMENTOS - FIXED
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled3/data/models/optimized_models.dart';
import 'package:untitled3/presentation/providers/optimized_providers.dart';
// FIX: Corrected import path
import 'modern_design_system.dart';
// FIX: Corrected import path to go up two directories and then into data/models
import '../../../../data/models/moment_category.dart';

class AddMomentPanel extends StatefulWidget {
  const AddMomentPanel({super.key});

  @override
  State<AddMomentPanel> createState() => _AddMomentPanelState();
}

class _AddMomentPanelState extends State<AddMomentPanel> {
  final _textController = TextEditingController();
  final _emojiController = TextEditingController(text: '✨');
  MomentCategory _selectedCategory = MomentCategories.all.first;
  String _momentType = 'positive';

  @override
  void dispose() {
    _textController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  void _addMoment() async {
    if (_textController.text.trim().isEmpty) return;

    final authProvider = context.read<OptimizedAuthProvider>();
    // FIX: Cambiar a OptimizedMomentsProvider en lugar de OptimizedInteractiveMomentModel
    final momentsProvider = context.read<OptimizedMomentsProvider>();

    final userId = authProvider.currentUser?.id;
    if (userId == null) return;

    final success = await momentsProvider.addMoment(
      userId: userId,
      emoji: _emojiController.text,
      text: _textController.text.trim(),
      type: _momentType,
      category: _selectedCategory.id,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Momento añadido con éxito'),
          backgroundColor: ModernColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      decoration: const BoxDecoration(
        color: ModernColors.darkPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ModernSpacing.radiusXLarge),
          topRight: Radius.circular(ModernSpacing.radiusXLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: ModernSpacing.lg),
          Text('Añadir Nuevo Momento', style: ModernTypography.heading2),
          const SizedBox(height: ModernSpacing.xl),
          Row(
            children: [
              // Emoji Picker
              SizedBox(
                width: 80,
                child: ModernTextField(
                  controller: _emojiController,
                  labelText: 'Emoji',
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              // Text Field
              Expanded(
                child: ModernTextField(
                  controller: _textController,
                  hintText: 'Describe tu momento...',
                  labelText: 'Descripción',
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.lg),
          // Category Selector
          _buildCategorySelector(),
          const SizedBox(height: ModernSpacing.lg),
          // Type Selector
          _buildTypeSelector(),
          const SizedBox(height: ModernSpacing.xl),
          // Add Button
          ModernButton(
            text: 'Guardar Momento',
            onPressed: _addMoment,
            width: double.infinity,
            gradient: ModernColors.primaryGradient,
          )
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría', style: ModernTypography.bodyMedium),
        const SizedBox(height: ModernSpacing.sm),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: MomentCategories.all.length,
            itemBuilder: (context, index) {
              final category = MomentCategories.all[index];
              final isSelected = _selectedCategory.id == category.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: AnimatedContainer(
                  duration: ModernAnimations.fast,
                  margin: const EdgeInsets.only(right: ModernSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color.withOpacity(0.2) : ModernColors.glassSurface,
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                    border: Border.all(color: isSelected ? category.color : ModernColors.glassSecondary),
                  ),
                  child: Center(child: Text(category.name, style: ModernTypography.bodyLarge)),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _momentType = 'positive'),
            child: ModernCard(
              backgroundColor: _momentType == 'positive' ? ModernColors.success.withOpacity(0.3) : ModernColors.glassSurface,
              child: Center(child: Text('😊 Positivo', style: ModernTypography.bodyLarge)),
            ),
          ),
        ),
        const SizedBox(width: ModernSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _momentType = 'negative'),
            child: ModernCard(
              backgroundColor: _momentType == 'negative' ? ModernColors.warning.withOpacity(0.3) : ModernColors.glassSurface,
              child: Center(child: Text('🤔 Reflexivo', style: ModernTypography.bodyLarge)),
            ),
          ),
        ),
      ],
    );
  }
}