import 'package:flutter/material.dart';

import '../app/colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({
    super.key,
    required this.text,
    this.color = AppColors.primary,
  });

  factory StatusBadge.success(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.success,
    );
  }

  factory StatusBadge.warning(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.warning,
    );
  }

  factory StatusBadge.danger(String text) {
    return StatusBadge(
      text: text,
      color: AppColors.danger,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}