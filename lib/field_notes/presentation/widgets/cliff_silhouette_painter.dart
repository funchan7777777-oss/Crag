import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';

class CliffSilhouettePainter extends CustomPainter {
  const CliffSilhouettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final backWall = Paint()
      ..color = LedgePalette.pineShadow.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final frontWall = Paint()
      ..color = LedgePalette.mossTrace.withValues(alpha: 0.74)
      ..style = PaintingStyle.fill;
    final seamLine = Paint()
      ..color = LedgePalette.lichenGold.withValues(alpha: 0.44)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rearPath = Path()
      ..moveTo(size.width * 0.02, size.height)
      ..lineTo(size.width * 0.12, size.height * 0.68)
      ..lineTo(size.width * 0.23, size.height * 0.73)
      ..lineTo(size.width * 0.32, size.height * 0.46)
      ..lineTo(size.width * 0.48, size.height * 0.62)
      ..lineTo(size.width * 0.62, size.height * 0.35)
      ..lineTo(size.width * 0.82, size.height * 0.58)
      ..lineTo(size.width * 0.98, size.height * 0.28)
      ..lineTo(size.width, size.height)
      ..close();

    final frontPath = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..lineTo(size.width * 0.29, size.height * 0.72)
      ..lineTo(size.width * 0.38, size.height * 0.78)
      ..lineTo(size.width * 0.48, size.height * 0.52)
      ..lineTo(size.width * 0.61, size.height * 0.66)
      ..lineTo(size.width * 0.72, size.height * 0.43)
      ..lineTo(size.width * 0.92, size.height * 0.69)
      ..lineTo(size.width, size.height)
      ..close();

    final seamPath = Path()
      ..moveTo(size.width * 0.34, size.height * 0.58)
      ..cubicTo(
        size.width * 0.42,
        size.height * 0.6,
        size.width * 0.5,
        size.height * 0.42,
        size.width * 0.58,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.58,
        size.width * 0.69,
        size.height * 0.46,
        size.width * 0.78,
        size.height * 0.52,
      );

    canvas.drawPath(rearPath, backWall);
    canvas.drawPath(frontPath, frontWall);
    canvas.drawPath(seamPath, seamLine);
  }

  @override
  bool shouldRepaint(covariant CliffSilhouettePainter oldDelegate) => false;
}
