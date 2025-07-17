import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/services/notification_service.dart';
import 'package:untitled3/presentation/screens/v2/components/minimal_colors.dart';
import 'package:untitled3/presentation/screens/components/modern_design_system.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> with TickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  
  // Notification settings
  bool _notificationsEnabled = true;
  bool _dailyReviewEnabled = true;
  bool _momentRemindersEnabled = true;
  bool _weeklyReflectionEnabled = true;
  
  // Times
  TimeOfDay _dailyReviewTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _morningMomentTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _afternoonMomentTime = const TimeOfDay(hour: 14, minute: 30);
  TimeOfDay _eveningMomentTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _weeklyReflectionTime = const TimeOfDay(hour: 19, minute: 0);
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadNotificationState();
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _dailyReviewEnabled = prefs.getBool('daily_review_enabled') ?? true;
      _momentRemindersEnabled = prefs.getBool('moment_reminders_enabled') ?? true;
      _weeklyReflectionEnabled = prefs.getBool('weekly_reflection_enabled') ?? true;
      
      // Load times
      _dailyReviewTime = TimeOfDay(
        hour: prefs.getInt('daily_review_hour') ?? 20,
        minute: prefs.getInt('daily_review_minute') ?? 0,
      );
      _morningMomentTime = TimeOfDay(
        hour: prefs.getInt('morning_moment_hour') ?? 9,
        minute: prefs.getInt('morning_moment_minute') ?? 0,
      );
      _afternoonMomentTime = TimeOfDay(
        hour: prefs.getInt('afternoon_moment_hour') ?? 14,
        minute: prefs.getInt('afternoon_moment_minute') ?? 30,
      );
      _eveningMomentTime = TimeOfDay(
        hour: prefs.getInt('evening_moment_hour') ?? 18,
        minute: prefs.getInt('evening_moment_minute') ?? 0,
      );
      _weeklyReflectionTime = TimeOfDay(
        hour: prefs.getInt('weekly_reflection_hour') ?? 19,
        minute: prefs.getInt('weekly_reflection_minute') ?? 0,
      );
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('daily_review_enabled', _dailyReviewEnabled);
    await prefs.setBool('moment_reminders_enabled', _momentRemindersEnabled);
    await prefs.setBool('weekly_reflection_enabled', _weeklyReflectionEnabled);
    
    // Save times
    await prefs.setInt('daily_review_hour', _dailyReviewTime.hour);
    await prefs.setInt('daily_review_minute', _dailyReviewTime.minute);
    await prefs.setInt('morning_moment_hour', _morningMomentTime.hour);
    await prefs.setInt('morning_moment_minute', _morningMomentTime.minute);
    await prefs.setInt('afternoon_moment_hour', _afternoonMomentTime.hour);
    await prefs.setInt('afternoon_moment_minute', _afternoonMomentTime.minute);
    await prefs.setInt('evening_moment_hour', _eveningMomentTime.hour);
    await prefs.setInt('evening_moment_minute', _eveningMomentTime.minute);
    await prefs.setInt('weekly_reflection_hour', _weeklyReflectionTime.hour);
    await prefs.setInt('weekly_reflection_minute', _weeklyReflectionTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ModernSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMinimalHeader(),
                  const SizedBox(height: ModernSpacing.xl),
                  _buildMasterToggle(),
                  const SizedBox(height: ModernSpacing.lg),
                  if (_notificationsEnabled) ...[
                    _buildNotificationCard(
                      title: '📝 Revisión Diaria',
                      subtitle: 'Recordatorio para reflexionar sobre tu día',
                      enabled: _dailyReviewEnabled,
                      time: _dailyReviewTime,
                      onToggle: (value) {
                        setState(() => _dailyReviewEnabled = value);
                        _updateNotifications();
                      },
                      onTimeChanged: (time) {
                        setState(() => _dailyReviewTime = time);
                        _updateNotifications();
                      },
                    ),
                    const SizedBox(height: ModernSpacing.lg),
                    _buildMomentRemindersCard(),
                    const SizedBox(height: ModernSpacing.lg),
                    _buildNotificationCard(
                      title: '🔄 Reflexión Semanal',
                      subtitle: 'Revisión semanal los domingos',
                      enabled: _weeklyReflectionEnabled,
                      time: _weeklyReflectionTime,
                      onToggle: (value) {
                        setState(() => _weeklyReflectionEnabled = value);
                        _updateNotifications();
                      },
                      onTimeChanged: (time) {
                        setState(() => _weeklyReflectionTime = time);
                        _updateNotifications();
                      },
                    ),
                    const SizedBox(height: ModernSpacing.xl),
                    _buildTestSection(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Título con gradiente
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: MinimalColors.accentGradient(context),
          ).createShader(bounds),
          child: const Text(
            'Notificaciones',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // Botón de volver
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: MinimalColors.lightGradient(context),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMasterToggle() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones Activas',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibir recordatorios y alertas',
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              if (value) {
                _updateNotifications();
              } else {
                _notificationService.cancelAllNotifications();
              }
              _saveNotificationSettings();
            },
            activeColor: MinimalColors.primaryGradient(context)[0],
            activeTrackColor: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required bool enabled,
    required TimeOfDay time,
    required Function(bool) onToggle,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: MinimalColors.accentGradient(context)[0],
                activeTrackColor: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectTime(time, onTimeChanged),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MinimalColors.textSecondary(context).withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: MinimalColors.textMuted(context),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Hora: ${time.format(context)}',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: MinimalColors.textMuted(context),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMomentRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📸 Recordatorios de Momentos',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recordatorios para capturar momentos especiales',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _momentRemindersEnabled,
                onChanged: (value) {
                  setState(() => _momentRemindersEnabled = value);
                  _updateNotifications();
                },
                activeColor: MinimalColors.accentGradient(context)[0],
                activeTrackColor: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
              ),
            ],
          ),
          if (_momentRemindersEnabled) ...[
            const SizedBox(height: 16),
            _buildMomentTimeItem('🌅 Mañana', _morningMomentTime, (time) {
              setState(() => _morningMomentTime = time);
              _updateNotifications();
            }),
            const SizedBox(height: 12),
            _buildMomentTimeItem('☀️ Mediodía', _afternoonMomentTime, (time) {
              setState(() => _afternoonMomentTime = time);
              _updateNotifications();
            }),
            const SizedBox(height: 12),
            _buildMomentTimeItem('🌙 Noche', _eveningMomentTime, (time) {
              setState(() => _eveningMomentTime = time);
              _updateNotifications();
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMomentTimeItem(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    return GestureDetector(
      onTap: () => _selectTime(time, onTimeChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              time.format(context),
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: MinimalColors.textMuted(context),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(TimeOfDay currentTime, Function(TimeOfDay) onTimeChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: MinimalColors.accentGradient(context)[0],
              onPrimary: Colors.white,
              surface: MinimalColors.backgroundCard(context),
              onSurface: MinimalColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentTime) {
      onTimeChanged(picked);
      _saveNotificationSettings();
    }
  }

  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.textSecondary(context).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📲 Prueba de Notificaciones',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba que las notificaciones funcionen correctamente',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTestButton(
                  'Revisión Diaria',
                  Icons.article_outlined,
                  () {
                    _notificationService.showDailyReminder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ Notificación de prueba enviada'),
                        backgroundColor: MinimalColors.accentGradient(context)[0],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTestButton(
                  'Momento',
                  Icons.camera_alt_outlined,
                  () {
                    _notificationService.showMomentReminder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ Notificación de prueba enviada'),
                        backgroundColor: MinimalColors.accentGradient(context)[0],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.lightGradient(context),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateNotifications() {
    if (!_notificationsEnabled) {
      _notificationService.cancelAllNotifications();
      return;
    }

    _notificationService.cancelAllNotifications();

    if (_dailyReviewEnabled) {
      _notificationService.scheduleDailyReviewReminder(
        hour: _dailyReviewTime.hour,
        minute: _dailyReviewTime.minute,
      );
    }

    if (_momentRemindersEnabled) {
      _notificationService.scheduleMomentReminders();
    }

    if (_weeklyReflectionEnabled) {
      _notificationService.scheduleWeeklyReflection();
    }

    _saveNotificationSettings();
  }

}