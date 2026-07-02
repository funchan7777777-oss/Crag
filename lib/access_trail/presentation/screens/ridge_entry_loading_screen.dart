import 'package:flutter/material.dart';

import '../../../field_notes/presentation/screens/crag_overview_screen.dart';
import '../../data/local_crag_access_cache.dart';
import '../widgets/crag_image_backdrop.dart';

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
      MaterialPageRoute<void>(builder: (_) => const CragOverviewScreen()),
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
      backgroundColor: Colors.black,
      body: CragImageBackdrop(
        assetPath: 'assets/images/HarborWallBackdrop.png',
        scrimOpacity: 0.2,
        child: Center(
          child: AnimatedBuilder(
            animation: _ropeSweep,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 132,
                    height: 132,
                    child: CustomPaint(
                      painter: _RopeSweepPainter(progress: _ropeSweep.value),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Setting your route',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Saving your local access card',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
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
      ),
    );
  }
}

class _RopeSweepPainter extends CustomPainter {
  const _RopeSweepPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.42;
    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rope = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0x00D6FF00),
          Color(0xFFD6FF00),
          Color(0xFFFFFFFF),
          Color(0x00D6FF00),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * 6.28318530718);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.2,
      2.15,
      false,
      rope,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RopeSweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
