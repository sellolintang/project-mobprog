import 'package:flutter/material.dart';

import '../app/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );

    final ButtonStyle buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
    )
        : ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
    );

    final Widget button = isOutlined
        ? OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonChild,
    )
        : ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonChild,
    );

    if (!isFullWidth) return button;

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}