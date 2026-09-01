import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/outreach.dart';
import '../../widgets/creator_avatar.dart';
import '../../providers/outreach_provider.dart';
import '../settings/settings_screen.dart';

class OutreachDetailScreen extends StatelessWidget {
  final OutreachMessage message;

  const OutreachDetailScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Thread Details'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender info
            Row(
              children: [
                CreatorAvatar(
                  name: message.influencerName,
                  colorValue: message.avatarColorValue,
                  size: 52,
                  borderRadius: 10,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.influencerName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        message.recipientEmail,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    message.status.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPurpleText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subject container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subject',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.subject,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  const Text(
                    'Message Content',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.body,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gmail sync info
            if (message.gmailThreadId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Synced with Gmail (Thread: ${message.gmailThreadId})',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            if (message.replySnippet != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.reply, size: 16, color: AppColors.primaryPurpleText),
                        SizedBox(width: 6),
                        Text(
                          'Latest Reply',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurpleText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.replySnippet!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            if (message.status == OutreachStatus.draft)
              Consumer<OutreachProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (provider.sendError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.sendError!,
                                  style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final sent = await provider.sendDraft(message);
                                if (!context.mounted) return;
                                if (sent) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Draft sent via Gmail!'),
                                      backgroundColor: AppColors.darkButton,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(provider.sendError ?? 'Failed to send via Gmail'),
                                      backgroundColor: Colors.red.shade800,
                                      action: SnackBarAction(
                                        label: 'Settings',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const SettingsScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Send via Gmail Now',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

