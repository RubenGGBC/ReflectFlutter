// ============================================================================
// presentation/components/quick_action_dialogs.dart - DIÁLOGOS Y COMPONENTES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/models/optimized_models.dart';

// ============================================================================
// DIÁLOGO PARA MOMENTO RÁPIDO
// ============================================================================

class QuickMomentDialog extends StatefulWidget {
  const QuickMomentDialog({super.key});

  @override
  State<QuickMomentDialog> createState() => _QuickMomentDialogState();
}

class _QuickMomentDialogState extends State<QuickMomentDialog> {
  final _textController = TextEditingController();
  String _selectedEmoji = '✨';
  String _selectedType = 'positive';
  int _intensity = 5;

  final List<String> _positiveEmojis = ['😊', '🎉', '❤️', '🌟', '🙌', '💪', '🚀', '🌈'];
  final List<String> _negativeEmojis = ['😔', '😰', '😤', '😓', '🥺', '😞', '😩', '😫'];
  final List<String> _neutralEmojis = ['😐', '🤔', '😌', '😶', '🙂', '😯', '😑', '😏'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_reaction,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Registrar momento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tipo de momento
            Text(
              'Tipo de momento',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('positive', 'Positivo', Colors.green),
                const SizedBox(width: 8),
                _buildTypeChip('neutral', 'Neutral', Colors.blue),
                const SizedBox(width: 8),
                _buildTypeChip('negative', 'Desafiante', Colors.orange),
              ],
            ),

            const SizedBox(height: 16),

            // Selector de emoji
            Text(
              'Emoji',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildEmojiSelector(),

            const SizedBox(height: 16),

            // Campo de texto
            Text(
              'Describe tu momento',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '¿Qué ha pasado? ¿Cómo te sientes?',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Intensidad
            Text(
              'Intensidad: $_intensity/10',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _intensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: const Color(0xFF8B5CF6),
              inactiveColor: Colors.white.withOpacity(0.2),
              onChanged: (value) {
                setState(() {
                  _intensity = value.round();
                });
              },
            ),

            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMoment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, Color color) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            // Cambiar emoji por defecto según el tipo
            if (type == 'positive') {
              _selectedEmoji = _positiveEmojis.first;
            } else if (type == 'negative') {
              _selectedEmoji = _negativeEmojis.first;
            } else {
              _selectedEmoji = _neutralEmojis.first;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiSelector() {
    List<String> emojis;
    switch (_selectedType) {
      case 'positive':
        emojis = _positiveEmojis;
        break;
      case 'negative':
        emojis = _negativeEmojis;
        break;
      default:
        emojis = _neutralEmojis;
    }

    return Container(
      height: 60,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          final emoji = emojis[index];
          final isSelected = _selectedEmoji == emoji;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedEmoji = emoji;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveMoment() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor describe tu momento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final momentsProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final success = await momentsProvider.addMoment(
      userId: authProvider.currentUser!.id,
      emoji: _selectedEmoji,
      text: _textController.text.trim(),
      type: _selectedType,
      intensity: _intensity,
      category: 'quick_action',
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Momento registrado exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el momento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ============================================================================
// DIÁLOGO DE GRATITUD
// ============================================================================

class GratitudeDialog extends StatefulWidget {
  const GratitudeDialog({super.key});

  @override
  State<GratitudeDialog> createState() => _GratitudeDialogState();
}

class _GratitudeDialogState extends State<GratitudeDialog> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Momento de gratitud',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Escribe 3 cosas por las que estás agradecido hoy:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            // Campos de gratitud
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllers[index],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '${index + 1}. Algo por lo que estoy agradecido...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pink),
                  ),
                ),
              ),
            )),

            const SizedBox(height: 20),

            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveGratitude,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveGratitude() async {
    final gratitudeItems = _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (gratitudeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe al menos una cosa por la que estés agradecido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final momentsProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final gratitudeText = gratitudeItems.map((item) => '• $item').join('\n');

    final success = await momentsProvider.addMoment(
      userId: authProvider.currentUser!.id,
      emoji: '🙏',
      text: 'Gratitud del día:\n$gratitudeText',
      type: 'positive',
      intensity: 8,
      category: 'gratitude',
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Gratitud registrada! Esto fortalece tu bienestar'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============================================================================
// DIÁLOGO DE MEDITACIÓN
// ============================================================================

class MeditationDialog extends StatefulWidget {
  const MeditationDialog({super.key});

  @override
  State<MeditationDialog> createState() => _MeditationDialogState();
}

class _MeditationDialogState extends State<MeditationDialog> {
  int _selectedMinutes = 5;
  String _selectedType = 'breathing';

  final Map<String, Map<String, dynamic>> _meditationTypes = {
    'breathing': {
      'name': 'Respiración',
      'description': 'Enfócate en tu respiración',
      'icon': '🧘‍♀️',
      'color': Colors.blue,
    },
    'body_scan': {
      'name': 'Escaneo Corporal',
      'description': 'Relaja todo tu cuerpo',
      'icon': '🌊',
      'color': Colors.teal,
    },
    'mindfulness': {
      'name': 'Mindfulness',
      'description': 'Atención plena al momento',
      'icon': '🌱',
      'color': Colors.green,
    },
    'gratitude': {
      'name': 'Gratitud',
      'description': 'Aprecia lo que tienes',
      'icon': '🙏',
      'color': Colors.orange,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sesión de meditación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Duración
            Text(
              'Duración: $_selectedMinutes minutos',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [3, 5, 10, 15, 20].map((minutes) =>
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMinutes = minutes),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedMinutes == minutes
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedMinutes == minutes
                                ? Colors.blue
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          '${minutes}m',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedMinutes == minutes
                                ? Colors.blue
                                : Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ).toList(),
            ),

            const SizedBox(height: 20),

            // Tipo de meditación
            Text(
              'Tipo de meditación',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            ..._meditationTypes.entries.map((entry) {
              final type = entry.key;
              final data = entry.value;
              final isSelected = _selectedType == type;

              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? data['color'].withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? data['color']
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        data['icon'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: TextStyle(
                                color: isSelected ? data['color'] : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              data['description'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: data['color'],
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startMeditation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startMeditation() {
    Navigator.of(context).pop();

    // Aquí podrías navegar a una pantalla de meditación completa
    // Por ahora, registramos la intención como un momento positivo

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sesión de meditación de $_selectedMinutes minutos iniciada'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Registrar',
          textColor: Colors.white,
          onPressed: () => _logMeditationMoment(),
        ),
      ),
    );
  }

  void _logMeditationMoment() async {
    final momentsProvider = Provider.of<OptimizedMomentsProvider>(context, listen: false);
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final meditationType = _meditationTypes[_selectedType]!;

    await momentsProvider.addMoment(
      userId: authProvider.currentUser!.id,
      emoji: meditationType['icon'],
      text: 'Meditación de ${meditationType['name']} por $_selectedMinutes minutos',
      type: 'positive',
      intensity: 7,
      category: 'meditation',
    );
  }
}

// ============================================================================
// FUNCIONES AUXILIARES PARA MOSTRAR DIÁLOGOS
// ============================================================================

void showQuickMomentDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const QuickMomentDialog(),
  );
}

void showGratitudeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const GratitudeDialog(),
  );
}

void showMeditationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const MeditationDialog(),
  );
}

// ============================================================================
// FUNCIONES PARA ACCIONES RÁPIDAS (implementar en el HomeScreen)
// ============================================================================

void startMeditationSession(BuildContext context) {
  showMeditationDialog(context);
}

void logExercise(BuildContext context) {
  // Implementar diálogo de ejercicio o navegar a pantalla de ejercicio
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Función de ejercicio próximamente'),
      backgroundColor: Colors.green,
    ),
  );
}

void showGratitudePractice(BuildContext context) {
  showGratitudeDialog(context);
}