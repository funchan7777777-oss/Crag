import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import 'crag_overview_screen.dart';

class CragHomeTabsScreen extends StatefulWidget {
  const CragHomeTabsScreen({super.key});

  @override
  State<CragHomeTabsScreen> createState() => _CragHomeTabsScreenState();
}

class _CragHomeTabsScreenState extends State<CragHomeTabsScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LedgePalette.chalkWhite,
      body: IndexedStack(
        index: _activeIndex,
        children: const [
          CragOverviewScreen(),
          _CragTabPlaceholder(
            title: 'League',
            iconAsset: 'assets/images/Squad.png',
          ),
          _CragTabPlaceholder(
            title: 'Signal',
            iconAsset: 'assets/images/Profile.png',
          ),
          _CragTabPlaceholder(
            title: 'Route',
            iconAsset: 'assets/images/Send.png',
          ),
        ],
      ),
      bottomNavigationBar: _CragBottomTabBar(
        activeIndex: _activeIndex,
        tabs: _tabs,
        onTabSelected: (index) => setState(() => _activeIndex = index),
      ),
    );
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

class _CragTabPlaceholder extends StatelessWidget {
  const _CragTabPlaceholder({required this.title, required this.iconAsset});

  final String title;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: LedgePalette.chalkWhite,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topInset + 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF121516),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset(
                      iconAsset,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
