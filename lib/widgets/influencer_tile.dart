import 'package:flutter/material.dart';
import '../models/influencer.dart';
import '../theme/app_text_styles.dart';
import 'creator_avatar.dart';
import 'score_badge.dart';

class InfluencerTile extends StatelessWidget {
  final Influencer influencer;
  final VoidCallback onTap;

  const InfluencerTile({
    super.key,
    required this.influencer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CreatorAvatar(
                name: influencer.name,
                colorValue: influencer.avatarColorValue,
                size: 46,
                borderRadius: 8,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      influencer.name,
                      style: AppTextStyles.influencerName,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      influencer.handle,
                      style: AppTextStyles.influencerHandle,
                    ),
                  ],
                ),
              ),
              ScoreBadge(score: influencer.fitScore),
            ],
          ),
        ),
      ),
    );
  }
}
