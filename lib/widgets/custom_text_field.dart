import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}