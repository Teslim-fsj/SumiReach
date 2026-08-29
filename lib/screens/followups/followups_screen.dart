import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/followup_card.dart';
import '../../widgets/empty_state.dart';
import '../../providers/followup_provider.dart';

class FollowupsScreen extends StatelessWidget {
  const FollowupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FollowUpProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Follow-ups'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Due Today Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Today',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.pendingCount} pending actions',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const Icon(Icons.filter_list, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Follow-up Card List
              Expanded(
                child: provider.items.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.check_circle_outline,
                        title: 'All caught up!',
                        description: 'No pending follow-ups due today. Great job keeping in touch with creators.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = provider.items[index];
                          return FollowupCard(
                            item: item,
                            onSend: () async {
                              await provider.sendFollowUp(item);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Follow-up sent to ${item.influencerName}!'),
                                    backgroundColor: AppColors.darkButton,
                                  ),
                                );
                              }
                            },
                            onEdit: () => _showEditFollowUpModal(context, item.id, item.suggestedBody),
                            onSkip: () {
                              provider.skipFollowUp(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Skipped follow-up for ${item.influencerName}')),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditFollowUpModal(BuildContext context, String itemId, String currentBody) {
    final ctrl = TextEditingController(text: currentBody);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Follow-up Pitch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 5,
              decoration: const InputDecoration(isDense: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<FollowUpProvider>().updateFollowUpBody(itemId, ctrl.text);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
