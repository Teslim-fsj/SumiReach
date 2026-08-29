import 'package:flutter/material.dart';
import '../models/outreach.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class OutreachDraftCard extends StatelessWidget {
  final OutreachMessage draft;
  final VoidCallback onEdit;
  final VoidCallback onRegenerate;
  final bool isGenerating;

  const OutreachDraftCard({
    super.key,
    required this.draft,
    required this.onEdit,
    required this.onRegenerate,
    this.isGenerating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Draft Outreach',
              style: AppTextStyles.sectionHeading,
            ),
            Row(
              children: [
                if (isGenerating)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
                    onPressed: onRegenerate,
                    tooltip: 'Regenerate pitch with AI',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  onPressed: onEdit,
                  tooltip: 'Edit draft',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To: ${draft.recipientEmail}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                draft.subject,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.border, height: 1),
              ),
              Text(
                draft.body,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
