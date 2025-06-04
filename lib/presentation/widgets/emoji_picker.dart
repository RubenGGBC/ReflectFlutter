// ============================================================================
// presentation/widgets/emoji_picker.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class EmojiPicker extends StatelessWidget {
  final String type; // "positive" or "negative"
  final Function(String) onEmojiSelected;

  const EmojiPicker({
    super.key,
    required this.type,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final emojis = type == "positive" ? _positiveEmojis : _negativeEmojis;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: type == "positive"
            ? themeProvider.currentColors.positiveMain.withOpacity(0.1)
            : themeProvider.currentColors.negativeMain.withOpacity(0.1),
        border: Border.all(
          color: type == "positive"
              ? themeProvider.currentColors.positiveMain.withOpacity(0.3)
              : themeProvider.currentColors.negativeMain.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == "positive" ? Icons.sunny : Icons.cloud,
                color: type == "positive"
                    ? themeProvider.currentColors.positiveMain
                    : themeProvider.currentColors.negativeMain,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                type == "positive" ? 'Momentos Positivos' : 'Momentos Difíciles',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: type == "positive"
                      ? themeProvider.currentColors.positiveMain
                      : themeProvider.currentColors.negativeMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emojis.map((emoji) {
              return GestureDetector(
                onTap: () => onEmojiSelected(emoji),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeProvider.currentColors.surface,
                    border: Border.all(color: themeProvider.currentColors.borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static const List<String> _positiveEmojis = [
    '😊', '🎉', '💪', '☕', '🎵', '🤗', '🌟', '✨', '🎯', '🏆',
    '❤️', '🌈', '🌞', '🎸', '📚', '🍕', '🏃‍♂️', '🧘‍♀️', '🎨', '🌸'
  ];

  static const List<String> _negativeEmojis = [
    '😰', '😔', '😤', '💼', '😫', '🤯', '😪', '🌧️', '⚡', '💔',
    '😷', '🤒', '😵', '🥱', '😮‍💨', '🤐', '😞', '😿', '⛈️', '🔥'
  ];
}