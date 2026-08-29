import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'score_badge.dart';

class AiFitCard extends StatelessWidget {
  final int fitScore;
  final String audienceOverlapText;
  final String strongEngagementText;
  final String brandAlignmentText;
  final VoidCallback? onReanalyze;
  final bool isAnalyzing;

  const AiFitCard({
    super.key,
    required this.fitScore,
    required this.audienceOverlapText,
    required this.strongEngagementText,
    required this.brandAlignmentText,
    this.onReanalyze,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top purple accent stripe
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Sparkle + "AI Fit Analysis" + Score Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.primaryPurpleText,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI Fit Analysis',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurpleText,
                          ),
                        ),
                        if (isAnalyzing) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    ScoreBadge(score: fitScore),
                  ],
                ),
                const SizedBox(height: 16),

                // Bullet 1: Audience Overlap
                _buildAnalysisBullet(
                  icon: Icons.check_circle_outline,
                  boldLabel: 'High Audience Overlap: ',
                  text: audienceOverlapText,
                ),
                const SizedBox(height: 14),

                // Bullet 2: Strong Engagement
                _buildAnalysisBullet(
                  icon: Icons.trending_up,
                  boldLabel: 'Strong Engagement: ',
                  text: strongEngagementText,
                ),
                const SizedBox(height: 14),

                // Bullet 3: Brand Alignment
                _buildAnalysisBullet(
                  icon: Icons.verified_user_outlined,
                  boldLabel: 'Brand Alignment: ',
                  text: brandAlignmentText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisBullet({
    required IconData icon,
    required String boldLabel,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: boldLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
