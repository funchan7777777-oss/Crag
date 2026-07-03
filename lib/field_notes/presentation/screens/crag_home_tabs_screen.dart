import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import '../../../social/data/climby_wallet_store.dart';
import '../../../social/presentation/screens/climby_me_screen.dart';
import '../../../social/presentation/screens/climby_messages_screen.dart';
import '../../../social/presentation/screens/climby_video_feed_screen.dart';
import 'crag_overview_screen.dart';

class CragHomeTabsScreen extends StatefulWidget {
  const CragHomeTabsScreen({super.key});

  @override
  State<CragHomeTabsScreen> createState() => _CragHomeTabsScreenState();
}

class _CragHomeTabsScreenState extends State<CragHomeTabsScreen> {
  final _wallet = ClimbyWalletStore.instance;
  int _activeIndex = 0;

  static const _tabs = [
    _CragTabSpec(
      label: 'Home',
      inactiveAsset: 'assets/images/Rope.png',
      activeAsset: 'assets/images/Circle.png',
    ),
    _CragTabSpec(
      label: 'League',
      inactiveAsset: 'assets/images/League.png',
      activeAsset: 'assets/images/Squad.png',
    ),
    _CragTabSpec(
      label: 'Signal',
      inactiveAsset: 'assets/images/Signal.png',
      activeAsset: 'assets/images/Profile.png',
    ),
    _CragTabSpec(
      label: 'Route',
      inactiveAsset: 'assets/images/Route.png',
      activeAsset: 'assets/images/Send.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomeCoins());
  }

  Future<void> _showWelcomeCoins() async {
    final granted = await _wallet.grantWelcomeCoinsIfNeeded();
    if (!mounted || granted == null) {
      return;
    }
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Welcome coins',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, _, _) {
        return _WelcomeCoinDialog(coins: granted);
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LedgePalette.chalkWhite,
      body: CragTabSwitcher(
        selectTab: (index) => setState(() => _activeIndex = index),
        child: IndexedStack(
          index: _activeIndex,
          children: [
            const CragOverviewScreen(),
            ClimbyVideoFeedScreen(active: _activeIndex == 1),
            const ClimbyMessagesScreen(),
            const ClimbyMeScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _CragBottomTabBar(
        activeIndex: _activeIndex,
        tabs: _tabs,
        onTabSelected: (index) => setState(() => _activeIndex = index),
      ),
    );
  }
}

class _WelcomeCoinDialog extends StatefulWidget {
  const _WelcomeCoinDialog({required this.coins});

  final int coins;

  @override
  State<_WelcomeCoinDialog> createState() => _WelcomeCoinDialogState();
}

class _WelcomeCoinDialogState extends State<_WelcomeCoinDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.92,
      upperBound: 1.08,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 306,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF101516),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD6FF00), width: 1.6),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD6FF00).withValues(alpha: 0.22),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 136,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD6FF00).withValues(
                            alpha: 0.14,
                          ),
                          border: Border.all(
                            color: const Color(0xFFD6FF00),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      top: 18,
                      child: Transform.rotate(
                        angle: -0.22,
                        child: Image.asset(
                          'assets/images/Carabiner.png',
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 28,
                      bottom: 16,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: Image.asset(
                          'assets/images/Quickdraw.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/Hangboard.png',
                      width: 86,
                      height: 86,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const Text(
                'First Ascent Drop',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+${widget.coins} coins',
                style: const TextStyle(
                  color: Color(0xFFD6FF00),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your chalk bag is loaded for Crux Radar, deep spot cards, and project boosts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.32,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6FF00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Clip In',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CragTabSwitcher extends InheritedWidget {
  const CragTabSwitcher({
    required this.selectTab,
    required super.child,
    super.key,
  });

  final ValueChanged<int> selectTab;

  static CragTabSwitcher? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CragTabSwitcher>();
  }

  @override
  bool updateShouldNotify(CragTabSwitcher oldWidget) {
    return selectTab != oldWidget.selectTab;
  }
}

class _CragBottomTabBar extends StatelessWidget {
  const _CragBottomTabBar({
    required this.activeIndex,
    required this.tabs,
    required this.onTabSelected,
  });

  final int activeIndex;
  final List<_CragTabSpec> tabs;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF121516),
        borderRadius: BorderRadius.zero,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 94,
        child: Row(
          children: [
            for (var index = 0; index < tabs.length; index += 1)
              Expanded(
                child: _CragTabButton(
                  spec: tabs[index],
                  selected: index == activeIndex,
                  onPressed: () => onTabSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CragTabButton extends StatelessWidget {
  const _CragTabButton({
    required this.spec,
    required this.selected,
    required this.onPressed,
  });

  final _CragTabSpec spec;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: spec.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Center(
          child: Image.asset(
            selected ? spec.activeAsset : spec.inactiveAsset,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _CragTabSpec {
  const _CragTabSpec({
    required this.label,
    required this.inactiveAsset,
    required this.activeAsset,
  });

  final String label;
  final String inactiveAsset;
  final String activeAsset;
}
