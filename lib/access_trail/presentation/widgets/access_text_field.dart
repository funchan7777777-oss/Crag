import 'package:flutter/material.dart';

class AccessTextField extends StatelessWidget {
  const AccessTextField({
    required this.label,
    required this.controller,
    this.hint = 'Please enter',
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.trailing,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          minLines: maxLines > 1 ? 4 : 1,
          cursorColor: const Color(0xFFD6FF00),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.34),
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            suffixIcon: trailing,
            filled: true,
            fillColor: const Color(0xFF151F20).withValues(alpha: 0.92),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFD6FF00),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
