import 'package:flutter/material.dart';
import '../models/outreach.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'creator_avatar.dart';

class PipelineMessageTile extends StatelessWidget {
  final OutreachMessage message;
  final VoidCallback onTap;

  const PipelineMessageTile({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreatorAvatar(
                name: message.influencerName,
                colorValue: message.avatarColorValue,
                size: 46,
                borderRadius: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          message.influencerName,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                        ),
                        if (message.timeAgoDisplay != null)
                          Text(
                            message.timeAgoDisplay!,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Subject: ${message.subject}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.replySnippet ?? message.body.replaceAll('\n', ' '),
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}
