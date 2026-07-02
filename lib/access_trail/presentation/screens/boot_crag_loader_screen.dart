import 'package:flutter/material.dart';

import '../../../field_notes/presentation/screens/crag_home_tabs_screen.dart';
import '../../data/local_crag_access_cache.dart';
import 'route_cards_onboarding_screen.dart';
import 'trailhead_access_screen.dart';

class BootCragLoaderScreen extends StatefulWidget {
  const BootCragLoaderScreen({super.key});

  @override
  State<BootCragLoaderScreen> createState() => _BootCragLoaderScreenState();
}

class _BootCragLoaderScreenState extends State<BootCragLoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathingHold;

  @override
  void initState() {
    super.initState();
    _breathingHold = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);
    _chooseFirstRoute();
  }

  Future<void> _chooseFirstRoute() async {
    final cache = await LocalCragAccessCache.open();
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) {
      return;
    }

    final activeCard = cache.readActiveCard();
    final nextScreen = activeCard != null
        ? const CragHomeTabsScreen()
        : cache.hasSeenRouteCards
        ? TrailheadAccessScreen(cache: cache)
        : RouteCardsOnboardingScreen(cache: cache);

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => nextScreen));
  }

  @override
  void dispose() {
    _breathingHold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: ScaleTransition(
              scale: _breathingHold,
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6FF00).withValues(alpha: 0.22),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset('assets/images/Grip.png'),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 86,
            child: _ChalkDotLoader(),
          ),
        ],
      ),
    );
  }
}

class _ChalkDotLoader extends StatefulWidget {
  const _ChalkDotLoader();

  @override
  State<_ChalkDotLoader> createState() => _ChalkDotLoaderState();
}

class _ChalkDotLoaderState extends State<_ChalkDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final shifted = (_controller.value + index * 0.22) % 1;
            final alpha = shifted < 0.5 ? 0.35 + shifted : 1.35 - shifted;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: alpha.clamp(0.2, 0.9)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
