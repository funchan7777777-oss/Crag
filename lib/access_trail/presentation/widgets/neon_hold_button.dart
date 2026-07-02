import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';

class NeonHoldButton extends StatelessWidget {
  const NeonHoldButton({
    required this.label,
    required this.onPressed,
    this.leading,
    this.busy = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: LedgePalette.lichenGold.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD6FF00),
            foregroundColor: Colors.black,
            disabledBackgroundColor: const Color(0xFFB7CA5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: busy ? null : onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: busy
                ? const SizedBox(
                    key: ValueKey('hold-busy'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.black,
                    ),
                  )
                : Row(
                    key: const ValueKey('hold-label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
