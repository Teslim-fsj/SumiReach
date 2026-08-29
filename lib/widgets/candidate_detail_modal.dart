import 'package:flutter/material.dart';
import '../models/discovered_candidate.dart';
import '../theme/app_colors.dart';
import '../widgets/creator_avatar.dart';
import '../widgets/score_badge.dart';

class CandidateDetailModal extends StatelessWidget {
  final DiscoveredCandidate candidate;
  final VoidCallback onSave;

  const CandidateDetailModal({
    super.key,
    required this.candidate,
    required this.onSave,
  });

  static void show(BuildContext context, DiscoveredCandidate candidate, VoidCallback onSave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CandidateDetailModal(
        candidate: candidate,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Modal Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discovered Creator Details',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Overview
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CreatorAvatar(
                        name: candidate.name,
                        colorValue: candidate.avatarColorValue,
                        size: 56,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${candidate.handle} • ${candidate.platform}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              candidate.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ScoreBadge(score: candidate.fitScore),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bio Section
                  if (candidate.bio.isNotEmpty) ...[
                    const Text('Biography / Profile Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      candidate.bio,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // AI Fit Analysis Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.scoreHighBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryPurpleText),
                            const SizedBox(width: 8),
                            Text(
                              'SumQuiz Fit Score: ${candidate.fitScore} / 100',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          candidate.fitReason,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Target Student Overlap: ~${candidate.audienceOverlapPercent}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Relevant Content Topics
                  if (candidate.relevantContent.isNotEmpty) ...[
                    const Text('Relevant Content Focus', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              candidate.relevantContent,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Contact Information
                  const Text('Contact Information', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          candidate.hasPublicEmail ? Icons.email_outlined : Icons.mail_lock_outlined,
                          size: 18,
                          color: candidate.hasPublicEmail ? const Color(0xFF15803D) : AppColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            candidate.email ?? 'No public email listed (Direct Message / Link in Bio required)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: candidate.hasPublicEmail ? FontWeight.w600 : FontWeight.normal,
                              color: candidate.hasPublicEmail ? AppColors.textPrimary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Source Evidence Transparency
                  const Text('Public Web Sources & Evidence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  if (candidate.sources.isEmpty)
                    const Text('Indexed web search results.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                  else
                    Column(
                      children: candidate.sources.map((src) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      src.title,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      src.url,
                                      style: const TextStyle(fontSize: 11, color: AppColors.primaryPurpleText),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.open_in_new, size: 14, color: AppColors.textMuted),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: candidate.isSaved
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check, size: 18, color: Color(0xFF15803D)),
                        label: const Text('Already in SumiReach Roster', style: TextStyle(color: Color(0xFF15803D))),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          onSave();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkButton,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text('Save Candidate to SumiReach', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}