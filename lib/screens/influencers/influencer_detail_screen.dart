import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/creator_avatar.dart';
import '../../widgets/ai_fit_card.dart';
import '../../widgets/outreach_draft_card.dart';
import '../../providers/influencer_provider.dart';
import '../../providers/outreach_provider.dart';

class InfluencerDetailScreen extends StatefulWidget {
  final String influencerId;

  const InfluencerDetailScreen({
    super.key,
    required this.influencerId,
  });

  @override
  State<InfluencerDetailScreen> createState() => _InfluencerDetailScreenState();
}

class _InfluencerDetailScreenState extends State<InfluencerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InfluencerProvider>().selectInfluencer(widget.influencerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InfluencerProvider>();
    final influencer = provider.selectedInfluencer;
    final draft = provider.currentDraft;

    if (influencer == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final analysis = provider.aiAnalysisResult ?? {
      'fitScore': influencer.fitScore,
      'audienceOverlap': influencer.audienceOverlapPercent,
      'strongEngagement': influencer.strongEngagementText,
      'brandAlignment': influencer.brandAlignmentText,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Profile'),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Profile Header (exact match to Screen 3)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CreatorAvatar(
                      name: influencer.name,
                      colorValue: influencer.avatarColorValue,
                      size: 64,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            influencer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            influencer.handle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            influencer.bio,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // AI Fit Analysis Card
                AiFitCard(
                  fitScore: analysis['fitScore'] as int? ?? influencer.fitScore,
                  audienceOverlapText:
                      '${analysis['audienceOverlap'] ?? influencer.audienceOverlapPercent}% of followers match our target demographic (US, 18-34, tech-focused).',
                  strongEngagementText:
                      analysis['strongEngagement'] as String? ?? influencer.strongEngagementText,
                  brandAlignmentText:
                      analysis['brandAlignment'] as String? ?? influencer.brandAlignmentText,
                  isAnalyzing: provider.isAnalyzingAi,
                  onReanalyze: () => provider.triggerAiAnalysis(),
                ),
                const SizedBox(height: 24),

                // Draft Outreach Card
                if (draft != null)
                  OutreachDraftCard(
                    draft: draft,
                    isGenerating: provider.isGeneratingPitch,
                    onRegenerate: () => provider.regeneratePitch(),
                    onEdit: () => _showEditDraftModal(context, draft.subject, draft.body),
                  ),

                const SizedBox(height: 100), // padding for bottom bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _handleSendPitch(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkButton,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.send_outlined, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Generate & Send Pitch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDraftModal(BuildContext context, String currentSubject, String currentBody) {
    final subCtrl = TextEditingController(text: currentSubject);
    final bodyCtrl = TextEditingController(text: currentBody);

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit Outreach Pitch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Subject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: subCtrl,
                decoration: const InputDecoration(isDense: true),
              ),
              const SizedBox(height: 12),
              const Text('Message Body', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: bodyCtrl,
                maxLines: 8,
                decoration: const InputDecoration(isDense: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final prov = context.read<InfluencerProvider>();
                  prov.updateDraftSubject(subCtrl.text);
                  prov.updateDraftBody(bodyCtrl.text);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendPitch(BuildContext context) async {
    final infProv = context.read<InfluencerProvider>();
    final outreachProv = context.read<OutreachProvider>();
    final draft = infProv.currentDraft;

    if (draft == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Sending pitch via Gmail...'),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await outreachProv.sendDraft(draft);

    if (!mounted) return;
    nav.pop(); // dismiss loading dialog

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Pitch sent to ${draft.recipientEmail} via Gmail!'),
          backgroundColor: AppColors.darkButton,
          action: SnackBarAction(
            label: 'View Pipeline',
            textColor: AppColors.primaryLight,
            onPressed: () {
              nav.pop();
            },
          ),
        ),
      );
      nav.pop();
    }
  }
}
