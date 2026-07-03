import 'package:flutter/material.dart';

import '../../../field_notes/presentation/screens/crag_home_tabs_screen.dart';
import '../../data/local_crag_access_cache.dart';

class RidgeEntryLoadingScreen extends StatefulWidget {
  const RidgeEntryLoadingScreen({required this.cache, super.key});

  final LocalCragAccessCache cache;

  @override
  State<RidgeEntryLoadingScreen> createState() =>
      _RidgeEntryLoadingScreenState();
}

class _RidgeEntryLoadingScreenState extends State<RidgeEntryLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ropeSweep;

  @override
  void initState() {
    super.initState();
    _ropeSweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _openHomeAfterHold();
  }

  Future<void> _openHomeAfterHold() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const CragHomeTabsScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _ropeSweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050706),
      body: Center(
        child: AnimatedBuilder(
          animation: _ropeSweep,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 148,
                  height: 178,
                  child: CustomPaint(
                    painter: _RouteTracePainter(progress: _ropeSweep.value),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Setting your route',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chalking the first wall',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RouteTracePainter extends CustomPainter {
  const _RouteTracePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final holds = [
      Offset(size.width * 0.28, size.height * 0.82),
      Offset(size.width * 0.68, size.height * 0.64),
      Offset(size.width * 0.36, size.height * 0.43),
      Offset(size.width * 0.72, size.height * 0.21),
    ];
    final routePath = Path()..moveTo(holds.first.dx, holds.first.dy);
    routePath.cubicTo(
      size.width * 0.5,
      size.height * 0.76,
      size.width * 0.48,
      size.height * 0.68,
      holds[1].dx,
      holds[1].dy,
    );
    routePath.cubicTo(
      size.width * 0.83,
      size.height * 0.5,
      size.width * 0.25,
      size.height * 0.58,
      holds[2].dx,
      holds[2].dy,
    );
    routePath.cubicTo(
      size.width * 0.2,
      size.height * 0.28,
      size.width * 0.7,
      size.height * 0.37,
      holds.last.dx,
      holds.last.dy,
    );

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFFD6FF00), Colors.white],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = const Color(0xFFD6FF00).withValues(alpha: 0.18)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(routePath, track);

    final routeMetric = routePath.computeMetrics().first;
    final reveal = Curves.easeInOutCubic.transform(progress);
    final activePath = routeMetric.extractPath(0, routeMetric.length * reveal);
    canvas.drawPath(activePath, glow);
    canvas.drawPath(activePath, active);

    for (var index = 0; index < holds.length; index += 1) {
      final holdProgress = (progress + index * 0.2) % 1;
      final pulse = holdProgress < 0.5
          ? Curves.easeOut.transform(holdProgress * 2)
          : Curves.easeIn.transform((1 - holdProgress) * 2);
      final reached = reveal >= index / (holds.length - 1);
      final holdColor = reached
          ? const Color(0xFFD6FF00)
          : Colors.white.withValues(alpha: 0.2);

      canvas.drawCircle(
        holds[index],
        reached ? 15 + pulse * 3 : 13,
        Paint()..color = holdColor.withValues(alpha: reached ? 0.18 : 0.12),
      );
      canvas.drawCircle(
        holds[index],
        reached ? 8 + pulse * 1.5 : 7,
        Paint()..color = holdColor,
      );
      if (reached) {
        canvas.drawCircle(
          holds[index] + const Offset(-2, -2),
          2.4,
          Paint()..color = Colors.white.withValues(alpha: 0.84),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RouteTracePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
