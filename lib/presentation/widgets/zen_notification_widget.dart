// ============================================================================
// presentation/widgets/zen_notification_widget.dart - WIDGET SIMPLIFICADO
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Asegúrate que esta ruta es correcta y que ZenNotificationProvider está definido
import '../providers/zen_notification_provider.dart';

class ZenNotificationWidget extends StatelessWidget {
  final bool compact;

  const ZenNotificationWidget({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ZenNotificationProvider>(
      builder: (context, provider, child) {
        if (compact) {
          return _buildCompactView(context, provider);
        }
        return _buildFullView(context, provider);
      },
    );
  }

  Widget _buildCompactView(BuildContext context, ZenNotificationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildStatusIcon(provider),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔔 Recordatorios Zen',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  provider.getStatusSummary(), // Método del provider
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (provider.needsUserAction()) // Método del provider
            ElevatedButton(
              onPressed: () => provider.requestAndSetup(), // Método del provider
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(60, 32),
              ),
              child: provider.isLoading // Propiedad del provider
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Activar', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildFullView(BuildContext context, ZenNotificationProvider provider) {
    // AQUÍ ESTÁ LA CORRECCIÓN: La variable se declara ANTES del return del widget.
    final recommendation = provider.getActionRecommendation(); // Método del provider

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
          // Header
          Row(
            children: [
              _buildStatusIcon(provider),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔔 Sistema de Recordatorios Zen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      provider.getStatusSummary(), // Método del provider
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ), // Fin de Row (Header)

          const SizedBox(height: 16),

          // Configuración actual
          if (provider.isEnabled) ...[
            _buildConfigDisplay(provider),
            const SizedBox(height: 16),
          ],

          // Acciones
          _buildActions(context, provider),

          // Recomendaciones
          // Ahora la variable 'recommendation' se usa aquí, pero fue declarada arriba.
          if (recommendation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation, // Uso de la variable
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ), // Fin de Container (Recomendación)
          ],
        ], // FIN de la lista principal de Column
      ),
    );
  }

  Widget _buildStatusIcon(ZenNotificationProvider provider) {
    IconData icon;
    Color color;

    if (provider.isLoading) { // Propiedad del provider
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      );
    }

    if (!provider.isInitialized) { // Propiedad del provider
      icon = Icons.sync;
      color = Colors.orange;
    } else if (!provider.isEnabled) { // Propiedad del provider
      icon = Icons.notifications_off;
      color = const Color(0xFFEF4444);
    } else {
      icon = Icons.notifications_active;
      color = const Color(0xFF10B981);
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildConfigDisplay(ZenNotificationProvider provider) {
    // Asumiendo que provider.config no es nulo si provider.isEnabled es true
    // De lo contrario, necesitarías un null check para config también.
    // Necesitas asegurarte de que `provider.config` no sea nulo aquí.
    // Si puede ser nulo, incluso cuando isEnabled es true, debes manejarlo.
    // Por ejemplo, mostrando un widget alternativo o usando valores predeterminados seguros.
    // Por ahora, asumo que tu lógica de provider garantiza que config no es nulo
    // cuando isEnabled es true. Si ese no es el caso, esta parte podría dar error.
    final config = provider.config; // Si config puede ser null aquí, esto fallará.

    // Comprobación para evitar error si config es null
    if (config == null) {
      // Puedes retornar un SizedBox.shrink() o un mensaje de error/placeholder.
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildConfigItem('📱', '${config.dailyCheckInsCount}', 'Check-ins diarios'),
              _buildConfigItem('🌙', '${config.nightlyHour}:${config.nightlyMinute.toString().padLeft(2, '0')}', 'Nocturna'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildConfigItem('⏰', '${provider.stats['total_pending'] ?? 0}', 'Programadas'), // Propiedad del provider
              _buildConfigItem('✨', config.enabledTypes.length.toString(), 'Tipos activos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String emoji, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ZenNotificationProvider provider) {
    if (!provider.isInitialized) { // Propiedad del provider
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Botón principal
        if (!provider.isEnabled) ...[
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () => provider.requestAndSetup(), // Propiedades y métodos del provider
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: provider.isLoading // Propiedad del provider
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Activar Recordatorios Zen', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ]
        else ...[
          // Botones cuando está habilitado
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : () => provider.sendTest(), // Propiedades y métodos del provider
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Probar', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: provider.isLoading ? null : () => provider.disable(), // Propiedades y métodos del provider
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off, color: Color(0xFFEF4444), size: 16),
                      SizedBox(width: 4),
                      Text('Desactivar', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}