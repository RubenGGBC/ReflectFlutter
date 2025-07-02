// lib/presentation/screens/v2/notifications_settings_screen.dart
// ============================================================================
// PANTALLA DE CONFIGURACIÓN DE NOTIFICACIONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notifications_provider.dart';
import '../components/modern_design_system.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, child) {
        return Scaffold(
          backgroundColor: ModernColors.darkPrimary,
          appBar: _buildAppBar(context),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con descripción
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Estado de permisos
                    _buildPermissionsStatus(),
                    const SizedBox(height: 24),

                    // Configuración principal
                    _buildMainToggle(notificationsProvider),
                    const SizedBox(height: 24),

                    // Configuraciones específicas
                    if (notificationsProvider.notificationsEnabled) ...[
                      _buildDailyReflectionSettings(notificationsProvider),
                      const SizedBox(height: 20),
                      _buildEveningCheckInSettings(notificationsProvider),
                      const SizedBox(height: 20),
                      _buildWeeklyReviewSettings(notificationsProvider),
                      const SizedBox(height: 20),
                      _buildMotivationalSettings(notificationsProvider),
                      const SizedBox(height: 32),
                    ],

                    // Botones de acción
                    _buildActionButtons(notificationsProvider),
                    const SizedBox(height: 20),

                    // Información adicional
                    _buildInfoSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      title: const Text(
        'Notificaciones',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Configuración de Recordatorios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Personaliza cuándo y cómo quieres que te recordemos reflexionar sobre tu día.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsStatus() {
    return FutureBuilder<bool>(
      future: context.read<NotificationsProvider>().checkPermissions(),
      builder: (context, snapshot) {
        final hasPermissions = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasPermissions
                ? const Color(0xFF4ECDC4).withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasPermissions
                  ? const Color(0xFF4ECDC4).withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasPermissions ? Icons.check_circle : Icons.warning,
                color: hasPermissions ? const Color(0xFF4ECDC4) : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPermissions ? 'Permisos Concedidos' : 'Permisos Requeridos',
                      style: TextStyle(
                        color: hasPermissions ? const Color(0xFF4ECDC4) : Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hasPermissions
                          ? 'Las notificaciones están habilitadas'
                          : 'Necesitas habilitar los permisos de notificación',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainToggle(NotificationsProvider provider) {
    return _buildSettingsCard(
      title: 'Notificaciones Generales',
      subtitle: 'Habilitar o deshabilitar todas las notificaciones',
      icon: Icons.notifications,
      child: Switch(
        value: provider.notificationsEnabled,
        onChanged: provider.setNotificationsEnabled,
        activeColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildDailyReflectionSettings(NotificationsProvider provider) {
    return _buildSettingsCard(
      title: 'Reflexión Diaria',
      subtitle: 'Recordatorio para reflexionar sobre tu día',
      icon: Icons.edit_note,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Habilitado',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Switch(
                value: provider.dailyReflectionEnabled,
                onChanged: (value) => provider.setDailyReflection(enabled: value),
                activeColor: const Color(0xFF4ECDC4),
              ),
            ],
          ),
          if (provider.dailyReflectionEnabled) ...[
            const SizedBox(height: 12),
            _buildTimePicker(
              label: 'Hora',
              time: provider.dailyReflectionTime,
              onChanged: (time) => provider.setDailyReflection(time: time),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEveningCheckInSettings(NotificationsProvider provider) {
    return _buildSettingsCard(
      title: 'Check-in Vespertino',
      subtitle: 'Recordatorio adicional para el bienestar',
      icon: Icons.bedtime,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Habilitado',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Switch(
                value: provider.eveningCheckInEnabled,
                onChanged: (value) => provider.setEveningCheckIn(enabled: value),
                activeColor: const Color(0xFF4ECDC4),
              ),
            ],
          ),
          if (provider.eveningCheckInEnabled) ...[
            const SizedBox(height: 12),
            _buildTimePicker(
              label: 'Hora',
              time: provider.eveningCheckInTime,
              onChanged: (time) => provider.setEveningCheckIn(time: time),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyReviewSettings(NotificationsProvider provider) {
    return _buildSettingsCard(
      title: 'Revisión Semanal',
      subtitle: 'Recordatorio semanal para revisar progreso',
      icon: Icons.calendar_today,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Habilitado',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Switch(
                value: provider.weeklyReviewEnabled,
                onChanged: (value) => provider.setWeeklyReview(enabled: value),
                activeColor: const Color(0xFF4ECDC4),
              ),
            ],
          ),
          if (provider.weeklyReviewEnabled) ...[
            const SizedBox(height: 12),
            _buildWeekdayPicker(
              label: 'Día',
              weekday: provider.weeklyReviewDay,
              onChanged: (day) => provider.setWeeklyReview(weekday: day),
            ),
            const SizedBox(height: 12),
            _buildTimePicker(
              label: 'Hora',
              time: provider.weeklyReviewTime,
              onChanged: (time) => provider.setWeeklyReview(time: time),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMotivationalSettings(NotificationsProvider provider) {
    return _buildSettingsCard(
      title: 'Mensajes Motivacionales',
      subtitle: 'Mensajes ocasionales de ánimo y motivación',
      icon: Icons.favorite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Habilitado',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Switch(
            value: provider.motivationalEnabled,
            onChanged: provider.setMotivationalMessages,
            activeColor: const Color(0xFF4ECDC4),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF4ECDC4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          GestureDetector(
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: time,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF4ECDC4),
                        onPrimary: Colors.white,
                        surface: Color(0xFF2D3748),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedTime != null) {
                onChanged(pickedTime);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
              ),
              child: Text(
                context.read<NotificationsProvider>().formatTime(time),
                style: const TextStyle(
                  color: Color(0xFF4ECDC4),
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

  Widget _buildWeekdayPicker({
    required String label,
    required int weekday,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          DropdownButton<int>(
            value: weekday,
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            dropdownColor: const Color(0xFF2D3748),
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: [
              const DropdownMenuItem(value: 1, child: Text('Lunes')),
              const DropdownMenuItem(value: 2, child: Text('Martes')),
              const DropdownMenuItem(value: 3, child: Text('Miércoles')),
              const DropdownMenuItem(value: 4, child: Text('Jueves')),
              const DropdownMenuItem(value: 5, child: Text('Viernes')),
              const DropdownMenuItem(value: 6, child: Text('Sábado')),
              const DropdownMenuItem(value: 7, child: Text('Domingo')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(NotificationsProvider provider) {
    return Column(
      children: [
        // Botón de prueba
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.testNotification,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text(
              'Probar Notificación',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón de mensaje motivacional
        if (provider.motivationalEnabled)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.sendMotivationalNow,
              icon: const Icon(Icons.favorite, color: Color(0xFFFFD700)),
              label: const Text(
                'Enviar Mensaje Motivacional',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFD700)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Botón de restablecer
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showResetDialog(provider),
            icon: Icon(Icons.refresh, color: Colors.white.withOpacity(0.7)),
            label: Text(
              'Restablecer a Valores por Defecto',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Información',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Las notificaciones te ayudan a mantener una rutina de reflexión constante.\n'
                '• Puedes cambiar los horarios en cualquier momento.\n'
                '• Los mensajes se seleccionan aleatoriamente para mantener la variedad.\n'
                '• Si no ves las notificaciones, verifica los permisos en Configuración del sistema.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(NotificationsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Restablecer Configuración',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres restablecer todas las configuraciones de notificaciones a los valores por defecto?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetToDefaults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ECDC4),
            ),
            child: const Text(
              'Restablecer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}