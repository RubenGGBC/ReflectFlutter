// ============================================================================
// moments_list_widget.dart - LISTA DE MOMENTOS CON SOPORTE PARA IMÁGENES
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Providers
import '../providers/optimized_providers.dart';
import '../providers/image_moments_provider.dart';

// Modelos
import '../../../data/models/optimized_models.dart';

// Pantalla de momentos rápidos
import '../screens/v2/quick_moments_screen.dart';

class MomentsListWidget extends StatefulWidget {
  final String? categoryFilter;
  final String? typeFilter;
  final bool showHeader;
  final int? limitItems;

  const MomentsListWidget({
    super.key,
    this.categoryFilter,
    this.typeFilter,
    this.showHeader = true,
    this.limitItems,
  });

  @override
  State<MomentsListWidget> createState() => _MomentsListWidgetState();
}

class _MomentsListWidgetState extends State<MomentsListWidget>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<OptimizedMomentsProvider>(
      builder: (context, momentsProvider, child) {
        if (momentsProvider.isLoading && momentsProvider.moments.isEmpty) {
          return _buildLoadingState();
        }

        if (momentsProvider.errorMessage != null) {
          return _buildErrorState(momentsProvider.errorMessage!);
        }

        // Filtrar momentos
        List<OptimizedInteractiveMomentModel> filteredMoments = momentsProvider.moments;

        if (widget.categoryFilter != null) {
          filteredMoments = filteredMoments
              .where((m) => m.category == widget.categoryFilter)
              .toList();
        }

        if (widget.typeFilter != null) {
          filteredMoments = filteredMoments
              .where((m) => m.type == widget.typeFilter)
              .toList();
        }

        if (widget.limitItems != null) {
          filteredMoments = filteredMoments.take(widget.limitItems!).toList();
        }

        if (filteredMoments.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader) _buildHeader(filteredMoments.length),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredMoments.length,
                itemBuilder: (context, index) {
                  final moment = filteredMoments[index];
                  return _buildMomentCard(moment, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================================
  // ESTADOS DE CARGA Y ERROR
  // ============================================================================

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando momentos...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar momentos',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _retryLoading,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '✨',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin momentos aún',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.categoryFilter != null
                ? 'No hay momentos en esta categoría'
                : 'Empieza capturando tu primer momento',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openQuickCapture,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Crear momento'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================

  Widget _buildHeader(int momentsCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tus momentos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$momentsCount momento${momentsCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          IconButton(
            onPressed: _openQuickCapture,
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.withOpacity(0.2),
              foregroundColor: Colors.blue,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TARJETA DE MOMENTO
  // ============================================================================

  Widget _buildMomentCard(OptimizedInteractiveMomentModel moment, int index) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMomentDetails(moment),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getTypeColor(moment.type).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Imagen del momento (si existe)
                _buildMomentImage(moment),

                // Contenido del momento
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMomentHeader(moment),
                      const SizedBox(height: 8),
                      _buildMomentText(moment),
                      const SizedBox(height: 12),
                      _buildMomentFooter(moment),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentImage(OptimizedInteractiveMomentModel moment) {
    // FIX: Check if moment.id is null before using it.
    if (moment.id == null) {
      return const SizedBox.shrink();
    }

    return Consumer<ImageMomentsProvider>(
      builder: (context, imageProvider, child) {
        return FutureBuilder<String?>(
          // FIX: Use the bang operator '!' because we've checked for null.
          future: imageProvider.getImageForMoment(moment.id!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildMomentHeader(OptimizedInteractiveMomentModel moment) {
    return Row(
      children: [
        // Emoji
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(moment.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              moment.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Info principal
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Categoría
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(moment.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getCategoryColor(moment.category).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getCategoryName(moment.category),
                      style: TextStyle(
                        color: _getCategoryColor(moment.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Intensidad
                  _buildIntensityIndicator(moment.intensity),
                ],
              ),

              const SizedBox(height: 4),

              // Timestamp
              Text(
                _formatTimestamp(moment.timestamp),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Indicador de tipo
        Container(
          width: 8,
          height: 48,
          decoration: BoxDecoration(
            color: _getTypeColor(moment.type),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildMomentText(OptimizedInteractiveMomentModel moment) {
    return Text(
      moment.text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMomentFooter(OptimizedInteractiveMomentModel moment) {
    return Row(
      children: [
        // Ubicación (si existe)
        if (moment.contextLocation != null) ...[
          Icon(
            Icons.location_on,
            size: 16,
            color: Colors.white54,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              moment.contextLocation!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),

        // Botones de acción
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.edit,
              onTap: () => _editMoment(moment),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.delete_outline,
              onTap: () => _deleteMoment(moment),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntensityIndicator(int intensity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < (intensity / 2).ceil();
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: isFilled ? Colors.blue : Colors.white24,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color ?? Colors.white70,
        ),
      ),
    );
  }

  // ============================================================================
  // HELPERS Y UTILIDADES
  // ============================================================================

  Color _getTypeColor(String type) {
    switch (type) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      case 'neutral':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'personal':
        return Colors.blue;
      case 'trabajo':
        return Colors.purple;
      case 'familia':
        return Colors.green;
      case 'amigos':
        return Colors.orange;
      case 'salud':
        return Colors.red;
      case 'hobby':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'personal':
        return 'Personal';
      case 'trabajo':
        return 'Trabajo';
      case 'familia':
        return 'Familia';
      case 'amigos':
        return 'Amigos';
      case 'salud':
        return 'Salud';
      case 'hobby':
        return 'Hobby';
      default:
        return category;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // ============================================================================
  // ACCIONES
  // ============================================================================

  void _retryLoading() {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final momentsProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      momentsProvider.loadMoments(authProvider.currentUser!.id);
    }
  }

  void _openQuickCapture() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const QuickMomentsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showMomentDetails(OptimizedInteractiveMomentModel moment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MomentDetailsSheet(moment: moment),
    );
  }

  void _editMoment(OptimizedInteractiveMomentModel moment) {
    // TODO: Implementar edición de momento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de edición próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _deleteMoment(OptimizedInteractiveMomentModel moment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Eliminar momento',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este momento? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteMoment(moment);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMoment(OptimizedInteractiveMomentModel moment) {
    // FIX: Check if the moment has a valid ID before proceeding.
    if (moment.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: El momento no tiene un ID válido para ser eliminado.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final imageProvider = Provider.of<ImageMomentsProvider>(context, listen: false);
    // final momentsProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);

    // Delete the image associated with the moment.
    // Use '!' because we have already checked for null.
    imageProvider.deleteImageForMoment(moment.id!);

    // TODO: Implementar eliminación real del momento en el provider de momentos.
    // momentsProvider.deleteMoment(moment.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Momento eliminado'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ============================================================================
// SHEET DE DETALLES DEL MOMENTO
// ============================================================================

class MomentDetailsSheet extends StatelessWidget {
  final OptimizedInteractiveMomentModel moment;

  const MomentDetailsSheet({
    super.key,
    required this.moment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con emoji y fecha
                  Row(
                    children: [
                      Text(
                        moment.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCategoryName(moment.category),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatFullTimestamp(moment.timestamp),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Imagen (si existe)
                  // FIX: Check if moment.id is null before using it.
                  if (moment.id != null)
                    Consumer<ImageMomentsProvider>(
                      builder: (context, imageProvider, child) {
                        return FutureBuilder<String?>(
                          // FIX: Use the bang operator '!' because we've checked for null.
                          future: imageProvider.getImageForMoment(moment.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(snapshot.data!),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),

                  // Texto del momento
                  Text(
                    moment.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detalles adicionales
                  _buildDetailRow('Intensidad', '${moment.intensity}/10'),
                  _buildDetailRow('Tipo', _getTypeName(moment.type)),
                  if (moment.contextLocation != null)
                    _buildDetailRow('Ubicación', moment.contextLocation!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'personal': return 'Personal';
      case 'trabajo': return 'Trabajo';
      case 'familia': return 'Familia';
      case 'amigos': return 'Amigos';
      case 'salud': return 'Salud';
      case 'hobby': return 'Hobby';
      default: return category;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'positive': return 'Positivo';
      case 'negative': return 'Negativo';
      case 'neutral': return 'Neutral';
      default: return type;
    }
  }

  String _formatFullTimestamp(DateTime timestamp) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${timestamp.day} de ${months[timestamp.month - 1]}, ${timestamp.year} a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
