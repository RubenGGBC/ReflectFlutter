// ============================================================================
// presentation/widgets/tag_chip.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../../data/models/tag_model.dart';

class TagChip extends StatelessWidget {
  final TagModel tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final String type; // "positive" or "negative"

  const TagChip({
    super.key,
    required this.tag,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final isPositive = type == "positive";
    final backgroundColor = isPositive
        ? themeProvider.currentColors.positiveMain.withOpacity(isSelected ? 0.3 : 0.15)
        : themeProvider.currentColors.negativeMain.withOpacity(isSelected ? 0.3 : 0.15);

    final borderColor = isPositive
        ? themeProvider.currentColors.positiveMain.withOpacity(isSelected ? 1.0 : 0.5)
        : themeProvider.currentColors.negativeMain.withOpacity(isSelected ? 1.0 : 0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                tag.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.currentColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: themeProvider.currentColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}