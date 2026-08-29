import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool isCircle;
  final BoxBorder? border;

  const AppLogo({
    super.key,
    this.size = 32,
    this.borderRadius = 8,
    this.isCircle = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isCircle ? BorderRadius.circular(size / 2) : BorderRadius.circular(borderRadius);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: border,
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/sumireach_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C47FF), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: radius,
            ),
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: size * 0.55,
            ),
          );
        },
      ),
    );
  }
}