import 'package:flutter/material.dart';

class LedgeBackButton extends StatelessWidget {
  const LedgeBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 22,
      top: 52,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
