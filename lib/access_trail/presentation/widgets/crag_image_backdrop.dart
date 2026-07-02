import 'package:flutter/material.dart';

class CragImageBackdrop extends StatelessWidget {
  const CragImageBackdrop({
    required this.assetPath,
    this.child,
    this.scrimOpacity = 0,
    super.key,
  });

  final String assetPath;
  final Widget? child;
  final double scrimOpacity;

  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[Image.asset(assetPath, fit: BoxFit.fill)];

    if (scrimOpacity > 0) {
      layers.add(
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: scrimOpacity),
          ),
        ),
      );
    }

    final foreground = child;
    if (foreground != null) {
      layers.add(foreground);
    }

    return Stack(fit: StackFit.expand, children: layers);
  }
}
