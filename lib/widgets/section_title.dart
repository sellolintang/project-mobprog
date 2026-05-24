import 'package:flutter/material.dart';

import '../app/colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry margin;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}