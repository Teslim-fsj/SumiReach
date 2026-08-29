import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/gmail_service.dart';
import '../../providers/integrations_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final integrations = context.watch<IntegrationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Integrations & Settings'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Google Sheets Card
              _buildIntegrationCard(
                context: context,
                icon: Icons.table_chart_outlined,
                iconColor: const Color(0xFF0F9D58),
                title: 'Google Sheets',
                subtitle: integrations.sheetName,
                status: integrations.sheetsStatus,
                onToggle: () => integrations.toggleSheets(),
                onSync: () => integrations.syncSheetsNow(),
              ),
              const SizedBox(height: 16),

              // Gmail Integration Card
              _buildIntegrationCard(
                context: context,
                icon: Icons.mail_outline,
                iconColor: const Color(0xFFEA4335),
                title: 'Gmail API',
                subtitle: integrations.gmailAccount,
                status: integrations.gmailStatus,
                onToggle: () => integrations.toggleGmail(),
              ),
              const SizedBox(height: 16),

              // AI Model Configuration
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: AppColors.primaryPurpleText, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'AI Copilot Engine',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Model: Gemini 1.5 Pro / Flash Copilot. Configured for influencer fit scoring, outreach draft generation, and follow-up cadence.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.scoreHighBorder),
                      ),
                      child: const Text(
                        'Status: Active • Rate Limit Healthy (100 req/min)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryPurpleText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntegrationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required IntegrationStatus status,
    required VoidCallback onToggle,
    VoidCallback? onSync,
  }) {
    final isConnected = status == IntegrationStatus.connected;
    final isSyncing = status == IntegrationStatus.syncing;
    final isConnecting = status == IntegrationStatus.connecting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSyncing
                      ? 'SYNCING...'
                      : isConnecting
                          ? 'CONNECTING...'
                          : isConnected
                              ? 'CONNECTED'
                              : 'DISCONNECTED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isConnected ? const Color(0xFF15803D) : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton(
                onPressed: onToggle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: Text(isConnected ? 'Disconnect' : 'Connect'),
              ),
              if (onSync != null && isConnected) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSyncing ? null : onSync,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: isSyncing
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sync Now'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
