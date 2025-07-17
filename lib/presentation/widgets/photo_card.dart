
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/optimized_models.dart';
import '../providers/image_moments_provider.dart';
import '../screens/v2/components/minimal_colors.dart';

class PhotoCard extends StatefulWidget {
  final OptimizedInteractiveMomentModel moment;
  final int index;

  const PhotoCard({
    super.key,
    required this.moment,
    required this.index,
  });

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _pulseController;

  String? _imagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _pulseController.repeat(reverse: true);

    _loadImage();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final imageProvider =
        Provider.of<ImageMomentsProvider>(context, listen: false);
    final imagePath =
        await imageProvider.getImageForMoment(widget.moment.id ?? 0);
    if (mounted) {
      setState(() {
        _imagePath = imagePath;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * (50 * (widget.index + 1)),
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: _isLoading
                ? _buildPhotoPlaceholder(widget.moment.emoji ?? '📷')
                : _imagePath != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_imagePath!),
                              width: 100,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPhotoPlaceholder(
                                    widget.moment.emoji ?? '📷');
                              },
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            width: 100,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(178),
                                ],
                              ),
                            ),
                          ),
                          // Emoji and type indicator
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Column(
                              children: [
                                Text(
                                  widget.moment.emoji ?? '📷',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: double.infinity,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getMomentTypeGradient(
                                          widget.moment.type ?? 'neutral'),
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildPhotoPlaceholder(widget.moment.emoji ?? '📷'),
          ),
        );
      },
    );
  }

  Widget _buildPhotoPlaceholder(String emoji) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context)
                    .map((c) => c.withAlpha(76))
                    .toList(),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withAlpha(51),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.photo_camera,
                  color: MinimalColors.textSecondary(context),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getMomentTypeGradient(String type) {
    switch (type) {
      case 'positive':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'negative':
        return [const Color(0xFFb91c1c), const Color(0xFFef4444)];
      default:
        return [const Color(0xFFf59e0b), const Color(0xFFfbbf24)];
    }
  }
}
