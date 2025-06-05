// ============================================================================
// presentation/widgets/notification_settings_widget.dart - VERSIÓN MEJORADA
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notifications_provider.dart';
import '../providers/theme_provider.dart';
import 'themed_container.dart';
import 'themed_button.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool showHeader;
  final bool isCard;
  final bool showDebugInfo;

  const NotificationSettingsWidget({
    super.key,
    this.showHeader = true,
    this.isCard = true,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: themeProvider.currentColors.accentPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '🔔 Recordatorios Zen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        Consumer<NotificationsProvider>(
          builder: (context, notificationsProvider, child) {
            return Column(
              children: [
                _buildNotificationStatus(notificationsProvider, themeProvider),

                // ✅ NUEVO: Mostrar mensajes de feedback
                if (notificationsProvider.lastOperationResult != null ||
                    notificationsProvider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildFeedbackMessage(notificationsProvider, themeProvider),
                ],

                // ✅ NUEVO: Información de debugging opcional
                if (showDebugInfo) ...[
                  const SizedBox(height: 16),
                  _buildDebugInfo(notificationsProvider, themeProvider),
                ],
              ],
            );
          },
        ),
      ],
    );

    if (isCard) {
      return ThemedContainer(child: content);
    } else {
      return content;
    }
  }

  /// ✅ NUEVO: Widget para mostrar mensajes de feedback
  Widget _buildFeedbackMessage(NotificationsProvider provider, ThemeProvider themeProvider) {
    final hasError = provider.errorMessage != null;
    final message = hasError ? provider.errorMessage! : provider.lastOperationResult!;
    final color = hasError
        ? themeProvider.currentColors.negativeMain
        : themeProvider.currentColors.positiveMain;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            hasError ? Icons.error : Icons.check_circle,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.currentColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ NUEVO: Información de debugging detallada
  Widget _buildDebugInfo(NotificationsProvider provider, ThemeProvider themeProvider) {
    final diagnostic = provider.getDiagnosticInfo();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.currentColors.borderColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔧 Información de Debug',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.currentColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          ...diagnostic['provider_state'].entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${entry.key}:',
                      style: TextStyle(
                        fontSize: 10,
                        color: themeProvider.currentColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: 10,
                        color: themeProvider.currentColors.textPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Text(
            'Notificaciones pendientes: ${diagnostic['stats']['pending_details']?.length ?? 0}',
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.currentColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStatus(NotificationsProvider provider, ThemeProvider themeProvider) {
    if (provider.isLoading) {
      return _buildLoadingState(themeProvider);
    }

    final config = provider.getConfigInfo();
    final status = config['status'] as String;

    switch (status) {
      case 'not_initialized':
        return _buildNotInitializedState(config, themeProvider);
      case 'disabled':
        return _buildDisabledState(config, provider, themeProvider);
      case 'partially_configured':
        return _buildPartiallyConfiguredState(config, provider, themeProvider);
      case 'active':
        return _buildActiveState(config, provider, themeProvider);
      default:
        return _buildErrorState(provider, themeProvider);
    }
  }

  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  themeProvider.currentColors.accentPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Configurando sistema de notificaciones...',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.currentColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotInitializedState(Map<String, dynamic> config, ThemeProvider themeProvider) {
    return Column(
      children: [
        _buildStatusHeader('⚙️', config, themeProvider),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.settings, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El sistema de notificaciones se está inicializando...',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledState(Map<String, dynamic> config, NotificationsProvider provider, ThemeProvider themeProvider) {
    return Column(
      children: [
        _buildStatusHeader('🔕', config, themeProvider),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.currentColors.negativeMain.withOpacity(0.1),
                themeProvider.currentColors.negativeMain.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.currentColors.negativeMain.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_off,
                    color: themeProvider.currentColors.negativeMain,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sin recordatorios',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.currentColors.negativeMain,
                          ),
                        ),
                        Text(
                          'No recibirás recordatorios para registrar tus momentos zen',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.currentColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ThemedButton(
                onPressed: () => provider.requestPermissions(),
                type: ThemedButtonType.positive,
                width: double.infinity,
                height: 45,
                isLoading: provider.isLoading,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Activar recordatorios zen', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartiallyConfiguredState(Map<String, dynamic> config, NotificationsProvider provider, ThemeProvider themeProvider) {
    return Column(
      children: [
        _buildStatusHeader('⚠️', config, themeProvider),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.orange.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configuración incompleta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Algunas notificaciones no se programaron correctamente',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.currentColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ThemedButton(
                      onPressed: () => provider.reconfigureNotifications(),
                      type: ThemedButtonType.outlined,
                      height: 40,
                      isLoading: provider.isLoading,
                      child: const Text('Reconfigurar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThemedButton(
                      onPressed: () => provider.sendTestNotification(),
                      height: 40,
                      isLoading: provider.isLoading,
                      child: const Text('Probar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState(Map<String, dynamic> config, NotificationsProvider provider, ThemeProvider themeProvider) {
    final stats = provider.stats;
    final randomCheckins = stats['random_checkins_scheduled'] ?? 0;
    final dailyReview = stats['daily_review_scheduled'] ?? false;

    return Column(
      children: [
        _buildStatusHeader('✅', config, themeProvider),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.currentColors.positiveMain.withOpacity(0.1),
                themeProvider.currentColors.positiveMain.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.currentColors.positiveMain.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Estado activo
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: themeProvider.currentColors.positiveMain,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistema zen activo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.currentColors.positiveMain,
                          ),
                        ),
                        Text(
                          'Recibirás recordatorios zen durante el día',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.currentColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Estadísticas detalladas
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '🎲',
                      randomCheckins.toString(),
                      'Aleatorios',
                      themeProvider.currentColors.accentPrimary,
                      themeProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      '🌙',
                      dailyReview ? '1' : '0',
                      'Nocturna',
                      themeProvider.currentColors.accentSecondary,
                      themeProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      '⏰',
                      '22:30',
                      'Hora fija',
                      themeProvider.currentColors.positiveMain,
                      themeProvider,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ThemedButton(
                      onPressed: () => provider.sendTestNotification(),
                      type: ThemedButtonType.outlined,
                      height: 40,
                      isLoading: provider.isLoading,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 16),
                          SizedBox(width: 4),
                          Text('Probar'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThemedButton(
                      onPressed: () => provider.updateStats(),
                      type: ThemedButtonType.text,
                      height: 40,
                      isLoading: provider.isLoading,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, size: 16),
                          SizedBox(width: 4),
                          Text('Actualizar'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(NotificationsProvider provider, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.currentColors.negativeMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.currentColors.negativeMain.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error,
                color: themeProvider.currentColors.negativeMain,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.errorMessage ?? 'Error en el sistema de notificaciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.currentColors.negativeMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ThemedButton(
                  onPressed: () => provider.initialize(),
                  type: ThemedButtonType.outlined,
                  height: 40,
                  isLoading: provider.isLoading,
                  child: const Text('Reintentar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ThemedButton(
                  onPressed: () => provider.checkNotificationStatus(),
                  type: ThemedButtonType.text,
                  height: 40,
                  isLoading: provider.isLoading,
                  child: const Text('Diagnosticar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String emoji, Map<String, dynamic> config, ThemeProvider themeProvider) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config['title'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.currentColors.textPrimary,
                ),
              ),
              Text(
                config['description'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.currentColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
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
          ),
        ],
      ),
    );
  }
}