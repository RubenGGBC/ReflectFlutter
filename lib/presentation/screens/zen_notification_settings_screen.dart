// ============================================================================
// presentation/screens/zen_notification_settings_screen.dart - CONFIGURACIÓN SIMPLIFICADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/zen_notification_provider.dart';

class ZenNotificationSettingsScreen extends StatefulWidget {
  const ZenNotificationSettingsScreen({super.key});

  @override
  State<ZenNotificationSettingsScreen> createState() => _ZenNotificationSettingsScreenState();
}

class _ZenNotificationSettingsScreenState extends State<ZenNotificationSettingsScreen> {
  late bool _enabled;
  late int _checkInsCount;
  late int _nightlyHour;
  late int _nightlyMinute;
  late Map<String, bool> _timeSlots;
  late List<String> _enabledTypes;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    final provider = context.read<ZenNotificationProvider>();
    final config = provider.config;

    _enabled = config.enabled;
    _checkInsCount = config.dailyCheckInsCount;
    _nightlyHour = config.nightlyHour;
    _nightlyMinute = config.nightlyMinute;
    _timeSlots = Map.from(config.timeSlots);
    _enabledTypes = List.from(config.enabledTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMainToggle(),
            if (_enabled) ...[
              const SizedBox(height: 16),
              _buildCheckInsSection(),
              const SizedBox(height: 16),
              _buildTimeSlotsSection(),
              const SizedBox(height: 16),
              _buildNightlySection(),
              const SizedBox(height: 16),
              _buildTypesSection(),
              const SizedBox(height: 16),
              _buildPreviewSection(),
            ],
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E3A8A),
      elevation: 0,
      title: const Text(
        '🔔 Configuración de Notificaciones',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (_enabled ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _enabled ? Icons.notifications_active : Icons.notifications_off,
              color: _enabled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recordatorios Zen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _enabled
                      ? 'Recibirás recordatorios durante el día'
                      : 'Las notificaciones están desactivadas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
            activeColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInsSection() {
    return _buildSection(
      title: '📱 Check-ins Diarios',
      subtitle: 'Cuántos recordatorios quieres al día',
      child: Column(
        children: [
          Row(
            children: [
              const Text('Cantidad:', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Text(
                '$_checkInsCount recordatorios',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: const Color(0xFF1E3A8A),
              thumbColor: const Color(0xFF3B82F6),
            ),
            child: Slider(
              value: _checkInsCount.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              onChanged: (value) => setState(() => _checkInsCount = value.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    return _buildSection(
      title: '⏰ Horarios Activos',
      subtitle: 'Cuándo quieres recibir recordatorios',
      child: Column(
        children: [
          _buildTimeSlot('🌅 Mañana (9-11)', 'morning'),
          _buildTimeSlot('☀️ Mediodía (12-14)', 'midday'),
          _buildTimeSlot('🌤️ Tarde (15-17)', 'afternoon'),
          _buildTimeSlot('🌆 Noche (18-20)', 'evening'),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Switch(
            value: _timeSlots[key] ?? true,
            onChanged: (value) => setState(() => _timeSlots[key] = value),
            activeColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNightlySection() {
    return _buildSection(
      title: '🌙 Notificación Nocturna',
      subtitle: 'Recordatorio antes del nuevo día',
      child: Column(
        children: [
          Row(
            children: [
              const Text('Activar nocturna:', style: TextStyle(color: Colors.white70)),
              const Spacer(),
              Switch(
                value: _enabledTypes.contains('nightly'),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      if (!_enabledTypes.contains('nightly')) {
                        _enabledTypes.add('nightly');
                      }
                    } else {
                      _enabledTypes.remove('nightly');
                    }
                  });
                },
                activeColor: const Color(0xFF10B981),
              ),
            ],
          ),
          if (_enabledTypes.contains('nightly')) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Hora:', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                GestureDetector(
                  onTap: _selectNightlyTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                    ),
                    child: Text(
                      '${_nightlyHour.toString().padLeft(2, '0')}:${_nightlyMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypesSection() {
    return _buildSection(
      title: '✨ Tipos de Notificaciones',
      subtitle: 'Qué tipos de recordatorios quieres',
      child: Column(
        children: [
          _buildTypeToggle(
            '📱 Check-ins regulares',
            'checkin',
            'Recordatorios para registrar momentos',
          ),
          _buildTypeToggle(
            '🌅 Motivación matutina',
            'motivation',
            'Mensaje inspirador para empezar el día',
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(String title, String type, String description) {
    final isEnabled = _enabledTypes.contains(type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                if (value) {
                  if (!_enabledTypes.contains(type)) {
                    _enabledTypes.add(type);
                  }
                } else {
                  _enabledTypes.remove(type);
                }
              });
            },
            activeColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    final activeSlots = _timeSlots.entries.where((e) => e.value).length;
    final totalNotifications = _checkInsCount +
        (_enabledTypes.contains('nightly') ? 1 : 0) +
        (_enabledTypes.contains('motivation') ? 1 : 0);

    return _buildSection(
      title: '👀 Vista Previa',
      subtitle: 'Cómo quedará tu configuración',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            _buildPreviewItem(
              '📱',
              'Check-ins diarios',
              '$_checkInsCount recordatorios en $activeSlots períodos',
            ),
            if (_enabledTypes.contains('motivation'))
              _buildPreviewItem(
                '🌅',
                'Motivación matutina',
                'Mensaje inspirador entre 8:00-9:00',
              ),
            if (_enabledTypes.contains('nightly'))
              _buildPreviewItem(
                '🌙',
                'Recordatorio nocturno',
                '${_nightlyHour.toString().padLeft(2, '0')}:${_nightlyMinute.toString().padLeft(2, '0')} cada día',
              ),
            const Divider(color: Colors.white24),
            Row(
              children: [
                const Icon(Icons.schedule, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Total: $totalNotifications notificaciones diarias',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<ZenNotificationProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _saveConfiguration,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: provider.isLoading
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Guardar Configuración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _selectNightlyTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _nightlyHour, minute: _nightlyMinute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              surface: Color(0xFF141B2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _nightlyHour = picked.hour;
        _nightlyMinute = picked.minute;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    final provider = context.read<ZenNotificationProvider>();

    await provider.updateConfig(
      enabled: _enabled,
      dailyCheckInsCount: _checkInsCount,
      nightlyHour: _nightlyHour,
      nightlyMinute: _nightlyMinute,
      enabledTypes: _enabledTypes,
      timeSlots: _timeSlots,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _enabled
                    ? '✅ Configuración guardada y notificaciones activadas'
                    : '🔕 Notificaciones desactivadas',
              ),
            ],
          ),
          backgroundColor: _enabled ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Volver a la pantalla anterior después de un momento
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }
}