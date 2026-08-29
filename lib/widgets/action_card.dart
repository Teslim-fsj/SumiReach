import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ActionButtonVariant {
  purple,
  dark,
}

class ActionCard extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingIconColor;
  final String title;
  final String description;
  final String buttonText;
  final IconData buttonIcon;
  final ActionButtonVariant buttonVariant;
  final VoidCallback onButtonPressed;

  const ActionCard({
    super.key,
    required this.leadingIcon,
    this.leadingIconColor = AppColors.primaryPurpleText,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonIcon,
    this.buttonVariant = ActionButtonVariant.purple,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkButton = buttonVariant == ActionButtonVariant.dark;
    final btnBg = isDarkButton ? AppColors.darkButton : const Color(0xFF8B5CF6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                leadingIcon,
                size: 18,
                color: leadingIconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.cardTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBg,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  buttonIcon,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
