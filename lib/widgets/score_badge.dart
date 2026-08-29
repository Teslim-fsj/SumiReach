import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScoreBadge extends StatelessWidget {
  final int score;
  final bool showMax;
  final double fontSize;

  const ScoreBadge({
    super.key,
    required this.score,
    this.showMax = true,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final isHigh = score >= 90;

    final borderColor = isHigh ? AppColors.scoreHighBorder : AppColors.scoreMidBorder;
    final textColor = isHigh ? AppColors.scoreHighText : AppColors.scoreMidText;
    final bgColor = isHigh ? AppColors.scoreHighBg : AppColors.scoreMidBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Text(
        showMax ? '$score/100' : '$score',
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
