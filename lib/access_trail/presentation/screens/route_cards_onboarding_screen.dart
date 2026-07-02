import 'package:flutter/material.dart';

import '../../data/local_crag_access_cache.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/ledge_back_button.dart';
import 'trailhead_access_screen.dart';

class RouteCardsOnboardingScreen extends StatefulWidget {
  const RouteCardsOnboardingScreen({required this.cache, super.key});

  final LocalCragAccessCache cache;

  @override
  State<RouteCardsOnboardingScreen> createState() =>
      _RouteCardsOnboardingScreenState();
}

class _RouteCardsOnboardingScreenState
    extends State<RouteCardsOnboardingScreen> {
  final PageController _controller = PageController();
  int _activeIndex = 0;

  static const _cards = [
    _RouteCardFrame(
      imageAsset: 'assets/images/Bolt.png',
      buttonAsset: 'assets/images/Arete.png',
    ),
    _RouteCardFrame(
      imageAsset: 'assets/images/Ridge.png',
      buttonAsset: 'assets/images/Chalk.png',
    ),
    _RouteCardFrame(
      imageAsset: 'assets/images/Summit.png',
      buttonAsset: 'assets/images/Pinch.png',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (_activeIndex < _cards.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await widget.cache.markRouteCardsSeen();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TrailheadAccessScreen(cache: widget.cache),
      ),
    );
  }

  void _retreat() {
    if (_activeIndex == 0) {
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _cards.length,
            onPageChanged: (index) => setState(() => _activeIndex = index),
            itemBuilder: (context, index) {
              return CragImageBackdrop(assetPath: _cards[index].imageAsset);
            },
          ),
          if (_activeIndex > 0) LedgeBackButton(onPressed: _retreat),
          Positioned(
            left: 28,
            right: 28,
            bottom: 54,
            child: GestureDetector(
              onTap: _advance,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.34),
                      blurRadius: 18,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _cards[_activeIndex].buttonAsset,
                    height: 56,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCardFrame {
  const _RouteCardFrame({required this.imageAsset, required this.buttonAsset});

  final String imageAsset;
  final String buttonAsset;
}
