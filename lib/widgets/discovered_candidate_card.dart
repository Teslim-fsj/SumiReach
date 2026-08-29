import 'package:flutter/material.dart';
import '../models/discovered_candidate.dart';
import '../theme/app_colors.dart';
import '../widgets/creator_avatar.dart';
import '../widgets/score_badge.dart';

class DiscoveredCandidateCard extends StatelessWidget {
  final DiscoveredCandidate candidate;
  final bool isSelected;
  final ValueChanged<bool?> onSelectChanged;
  final VoidCallback onView;
  final VoidCallback onSave;
  final VoidCallback? onViewInRoster;

  const DiscoveredCandidateCard({
    super.key,
    required this.candidate,
    required this.isSelected,
    required this.onSelectChanged,
    required this.onView,
    required this.onSave,
    this.onViewInRoster,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Selection Checkbox, Avatar, Name/Handle, Score Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!candidate.isSaved) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: onSelectChanged,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                CreatorAvatar(
                  name: candidate.name,
                  colorValue: candidate.avatarColorValue,
                  size: 44,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              candidate.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              candidate.platform,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryPurpleText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        candidate.handle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ScoreBadge(score: candidate.fitScore),
              ],
            ),
            const SizedBox(height: 12),

            // Metadata Chips: Followers, Location, Contact
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (candidate.followersDisplay != 'Unknown')
                  _buildMetaTag(
                    icon: Icons.people_outline,
                    text: '${candidate.followersDisplay} followers',
                  ),
                if (candidate.location != 'Unknown')
                  _buildMetaTag(
                    icon: Icons.location_on_outlined,
                    text: candidate.location,
                  ),
                _buildContactTag(candidate.hasPublicEmail),
              ],
            ),
            const SizedBox(height: 10),

            // Bio / Description
            if (candidate.bio.isNotEmpty)
              Text(
                candidate.bio,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),

            // AI Fit Reason snippet with subtle purple stripe
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(6),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.primaryPurpleText,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      candidate.fitReason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons Row
            Row(
              children: [
                // View Details Button
                OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View Evidence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),

                // Source indicator
                if (candidate.sources.isNotEmpty)
                  Expanded(
                    child: Text(
                      'Source: ${candidate.sources.first.title}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const Spacer(),

                // Save or Already In SumiReach
                if (candidate.isSaved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Color(0xFF15803D), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'In SumiReach',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkButton,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Save', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaTag({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTag(bool hasEmail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hasEmail ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasEmail ? Icons.email_outlined : Icons.mail_lock_outlined,
            size: 12,
            color: hasEmail ? const Color(0xFF15803D) : AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            hasEmail ? 'Email found' : 'No public email',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: hasEmail ? const Color(0xFF15803D) : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}