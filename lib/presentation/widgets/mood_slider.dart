// ============================================================================
// presentation/widgets/mood_slider.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class MoodSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String? label;

  const MoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Slider visual
        Row(
          children: [
            const Text('😢', style: TextStyle(fontSize: 20)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: themeProvider.getMoodColor(value),
                  inactiveTrackColor: themeProvider.currentColors.borderColor,
                  thumbColor: themeProvider.getMoodColor(value),
                  overlayColor: themeProvider.getMoodColor(value).withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                ),
                child: Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: value,
                  onChanged: onChanged,
                ),
              ),
            ),
            const Text('🤩', style: TextStyle(fontSize: 20)),
          ],
        ),

        const SizedBox(height: 16),

        // Valor actual
        Row(
          children: [
            Text(_getMoodEmoji(value), style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${value.round()}/10',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.getMoodColor(value),
                  ),
                ),
                Text(
                  themeProvider.getMoodLabel(value),
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.currentColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _getMoodEmoji(double mood) {
    final moodEmojis = ["😢", "😔", "😐", "🙂", "😊", "😄", "🤗", "😁", "🥳", "🤩"];
    final index = (mood - 1).clamp(0, 9).toInt();
    return moodEmojis[index];
  }
}
