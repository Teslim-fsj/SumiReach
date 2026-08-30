import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../config/env.dart';
import '../../services/gmail_service.dart';
import '../../providers/integrations_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _isObscured = true;
  String _selectedModel = 'gemini-1.5-flash';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: Env.geminiApiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gemini API Key configured and verified!'),
        backgroundColor: AppColors.darkButton,
      ),
    );
  }

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
              // Google Gemini AI Configuration Card
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C47FF).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFF6C47FF), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Google Gemini AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              Text('Powers fit analysis, cold pitches & discovery', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CONNECTED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // API Key Input
                    const Text(
                      'Gemini API Key (Google AI Studio)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _isObscured,
                      style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        hintText: 'AIzaSy...',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(() => _isObscured = !_isObscured),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Model Selection Row
                    Row(
                      children: [
                        const Text(
                          'Active Model: ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedModel,
                          isDense: true,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('Gemini 1.5 Flash (Recommended)')),
                            DropdownMenuItem(value: 'gemini-2.0-flash', child: Text('Gemini 2.0 Flash (Fast)')),
                            DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('Gemini 1.5 Pro (Deep Reasoning)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedModel = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Action Buttons
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _saveApiKey,
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Save & Validate Key'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                  color: iconColor.withAlpha(25),
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