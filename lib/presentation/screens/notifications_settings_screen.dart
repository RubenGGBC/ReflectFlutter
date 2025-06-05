// ============================================================================
// presentation/screens/notification_settings_screen.dart - CONFIGURACIÓN COMPLETA DE NOTIFICACIONES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../providers/notifications_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/notification_settings_widget.dart';
import '../widgets/themed_container.dart';
import '../widgets/themed_button.dart';
import '../widgets/gradient_header.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.currentColors.primaryBg,
      body: Column(
        children: [
          _buildHeader(context, themeProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Widget principal de notificaciones
                  const NotificationSettingsWidget(),
                  const SizedBox(height: 16),

                  // Información detallada
                  _buildDetailedInfo(themeProvider),
                  const SizedBox(height: 16),

                  // Estadísticas avanzadas
                  _buildAdvancedStats(themeProvider),
                  const SizedBox(height: 16),

                  // Acciones avanzadas
                  _buildAdvancedActions(themeProvider),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return GradientHeader(
      title: '🔔 Configuración de Notificaciones',
      leftButton: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(foregroundColor: Colors.white),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white),
            SizedBox(width: 4),
            Text('Volver', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfo(ThemeProvider themeProvider) {
    return ThemedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 Sobre los recordatorios zen',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoItem(
            '🎲 Recordatorios aleatorios',
            'Recibirás entre 3-5 notificaciones aleatorias durante el día preguntándote cómo van las cosas. Estas aparecen en diferentes momentos para capturar la variedad de tu día.',
            themeProvider.currentColors.accentPrimary,
            themeProvider,
          ),

          const SizedBox(height: 12),

          _buildInfoItem(
            '🌙 Notificación nocturna',
            'A las 22:30 recibirás un recordatorio importante: tu resumen del día se guardará automáticamente a las 00:00. ¡Asegúrate de haber registrado todo!',
            themeProvider.currentColors.accentSecondary,
            themeProvider,
          ),

          const SizedBox(height: 12),

          _buildInfoItem(
            '⚡ Acciones rápidas',
            'Puedes responder directamente desde la notificación sin abrir la app. Añade momentos positivos o difíciles con un solo toque.',
            themeProvider.currentColors.positiveMain,
            themeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, Color color, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedStats(ThemeProvider themeProvider) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;

        return ThemedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: themeProvider.currentColors.accentPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '📊 Estadísticas del sistema',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.currentColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (provider.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          themeProvider.currentColors.accentPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (stats.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pendientes',
                        '${stats['total_pending'] ?? 0}',
                        Icons.schedule,
                        themeProvider.currentColors.accentPrimary,
                        themeProvider,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Aleatorios',
                        '${stats['random_checkins_scheduled'] ?? 0}',
                        Icons.shuffle,
                        themeProvider.currentColors.positiveMain,
                        themeProvider,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Estado',
                        stats['enabled'] == true ? 'ON' : 'OFF',
                        stats['enabled'] == true ? Icons.check_circle : Icons.cancel,
                        stats['enabled'] == true
                            ? themeProvider.currentColors.positiveMain
                            : themeProvider.currentColors.negativeMain,
                        themeProvider,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Estado detallado
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.currentColors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.currentColors.borderColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatusRow('Sistema inicializado', stats['initialized'] == true, themeProvider),
                      _buildStatusRow('Permisos otorgados', stats['enabled'] == true, themeProvider),
                      _buildStatusRow('Notificación nocturna', stats['daily_review_scheduled'] == true, themeProvider),
                      _buildStatusRow('Recordatorios configurados', (stats['random_checkins_scheduled'] ?? 0) > 0, themeProvider),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.currentColors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: themeProvider.currentColors.textHint,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cargando estadísticas...',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.currentColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              ThemedButton(
                onPressed: () => provider.updateStats(),
                type: ThemedButtonType.outlined,
                width: double.infinity,
                height: 40,
                isLoading: provider.isLoading,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 16),
                    SizedBox(width: 8),
                    Text('Actualizar estadísticas'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.currentColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive
                ? themeProvider.currentColors.positiveMain
                : themeProvider.currentColors.negativeMain,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.currentColors.textSecondary,
              ),
            ),
          ),
          Text(
            isActive ? 'SI' : 'NO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? themeProvider.currentColors.positiveMain
                  : themeProvider.currentColors.negativeMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedActions(ThemeProvider themeProvider) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, child) {
        return ThemedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚙️ Acciones avanzadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Botón de prueba
              ThemedButton(
                onPressed: () => provider.sendTestNotification(),
                type: ThemedButtonType.positive,
                width: double.infinity,
                height: 50,
                isLoading: provider.isLoading,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Enviar notificación de prueba', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Reconfigurar
              ThemedButton(
                onPressed: () => provider.reconfigureNotifications(),
                type: ThemedButtonType.outlined,
                width: double.infinity,
                height: 50,
                isLoading: provider.isLoading,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Reconfigurar todas las notificaciones'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Cancelar todas
              ThemedButton(
                onPressed: () => _showCancelAllDialog(provider, themeProvider),
                type: ThemedButtonType.negative,
                width: double.infinity,
                height: 50,
                isLoading: provider.isLoading,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Cancelar todas las notificaciones', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelAllDialog(NotificationsProvider provider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.currentColors.surface,
        title: Text(
          '⚠️ Cancelar notificaciones',
          style: TextStyle(color: themeProvider.currentColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro de que quieres cancelar todas las notificaciones zen? Tendrás que reconfigurarlas manualmente.',
          style: TextStyle(color: themeProvider.currentColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: themeProvider.currentColors.textSecondary),
            ),
          ),
          ThemedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await provider.cancelAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Todas las notificaciones han sido canceladas'),
                    backgroundColor: themeProvider.currentColors.negativeMain,
                  ),
                );
              }
            },
            type: ThemedButtonType.negative,
            child: const Text('Cancelar todas', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}