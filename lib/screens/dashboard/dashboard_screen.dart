import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/influencer_provider.dart';
import '../followups/followups_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final stats = analytics.dashboardStats;
    final formattedDate = DateFormat('MMM dd, yyyy').format(DateTime(2023, 10, 24)).toUpperCase();

    return RefreshIndicator(
      onRefresh: () => analytics.fetchDashboardData(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Date and Greeting (exact match to Screen 1)
            Text(
              formattedDate,
              style: AppTextStyles.dateLabel,
            ),
            const SizedBox(height: 6),
            const Text(
              'Good morning.',
              style: AppTextStyles.screenHeading,
            ),
            const SizedBox(height: 24),

            // 2x2 Grid of Stat Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Active Deals',
                    value: stats != null ? '${stats.activeDeals}' : '142',
                    icon: Icons.trending_up,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viewing 142 Active Deals in Pipeline')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Pending Replies',
                    value: stats != null ? '${stats.pendingReplies}' : '38',
                    icon: Icons.mail_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('38 creators have replied to outreach')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'New Prospects',
                    value: stats != null ? '${stats.newProspects}' : '12',
                    icon: Icons.person_add_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('12 new qualified creators discovered')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'AI Priority',
                    value: stats != null ? '${stats.aiPriorityCount}' : '5',
                    icon: Icons.auto_awesome,
                    isPurpleHighlight: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FollowupsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section Header: "Prioritized Actions"
            const Text(
              'Prioritized Actions',
              style: AppTextStyles.sectionHeading,
            ),
            const SizedBox(height: 16),

            // Action 1: Draft follow-up for TechNova
            ActionCard(
              leadingIcon: Icons.auto_awesome,
              leadingIconColor: AppColors.primaryPurpleText,
              title: 'Draft follow-up for TechNova',
              description: 'High engagement detected on latest proposal. AI suggests immediate outreach.',
              buttonText: 'Draft with AI',
              buttonIcon: Icons.edit_outlined,
              buttonVariant: ActionButtonVariant.purple,
              onButtonPressed: () {
                final infProv = context.read<InfluencerProvider>();
                infProv.selectInfluencer('inf_1');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FollowupsScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // Action 2: Review GlobalCorp contract
            ActionCard(
              leadingIcon: Icons.access_time,
              leadingIconColor: AppColors.textPrimary,
              title: 'Review GlobalCorp contract',
              description: 'Pending legal review since yesterday.',
              buttonText: 'Review',
              buttonIcon: Icons.arrow_forward,
              buttonVariant: ActionButtonVariant.dark,
              onButtonPressed: () {
                _showContractReviewModal(context);
              },
            ),
            const SizedBox(height: 14),

            // Action 3: Analyze drop-off in Q3 Campaign
            ActionCard(
              leadingIcon: Icons.auto_awesome,
              leadingIconColor: AppColors.primaryPurpleText,
              title: 'Analyze drop-off in Q3 Campaign',
              description: 'Anomaly detected in response rates for UK segment.',
              buttonText: 'View Insights',
              buttonIcon: Icons.insights,
              buttonVariant: ActionButtonVariant.purple,
              onButtonPressed: () {
                _showInsightsModal(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showContractReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GlobalCorp Sponsorship Contract',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Terms: \$4,500 for 2 dedicated YouTube integrations + 3 TikTok features. 15% revenue share on user conversions using promo code GLOBAL20.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Request Revision'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('GlobalCorp contract approved & signed!')),
                      );
                    },
                    child: const Text('Approve & Sign'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showInsightsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome, color: AppColors.primaryPurpleText, size: 20),
                SizedBox(width: 8),
                Text(
                  'AI Campaign Diagnosis',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'UK tech creator outreach had a 6.2% lower reply rate due to US-centric exam references in pitch emails. Recommendation: Switch template to GCSE / A-Levels active recall hooks for UK creators.',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Applied UK localized outreach template!')),
                );
              },
              child: const Text('Apply AI Template Fix'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
