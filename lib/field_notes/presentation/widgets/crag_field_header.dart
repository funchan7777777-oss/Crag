import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/weather_window_marker.dart';
import 'cliff_silhouette_painter.dart';

class CragFieldHeader extends StatelessWidget {
  const CragFieldHeader({
    required this.weatherWindow,
    required this.visibleSectorCount,
    super.key,
  });

  final WeatherWindowMarker weatherWindow;
  final int visibleSectorCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 244,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: LedgePalette.shaleInk,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: const CliffSilhouettePainter()),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LedgePalette.shaleInk.withValues(alpha: 0.9),
                    LedgePalette.shaleInk.withValues(alpha: 0.56),
                    LedgePalette.copperSun.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crag',
                  style: textTheme.headlineLarge?.copyWith(
                    color: LedgePalette.chalkWhite,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 260,
                  child: Text(
                    'A compact board for sectors, approach cues, and route intent.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: LedgePalette.fogLine,
                    ),
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FieldMetricPill(
                      icon: Icons.terrain_rounded,
                      label: 'Sectors',
                      value: '$visibleSectorCount ready',
                    ),
                    _FieldMetricPill(
                      icon: Icons.air_rounded,
                      label: 'Window',
                      value: weatherWindow.ridgeTimeBand,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldMetricPill extends StatelessWidget {
  const _FieldMetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LedgePalette.chalkWhite.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: LedgePalette.chalkWhite.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: LedgePalette.lichenGold),
            const SizedBox(width: 7),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: LedgePalette.fogLine,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: LedgePalette.chalkWhite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
