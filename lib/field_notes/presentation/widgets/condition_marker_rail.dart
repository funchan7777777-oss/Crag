import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/cliff_sector_record.dart';
import '../../domain/value_objects/stone_condition_mark.dart';

class ConditionMarkerRail extends StatelessWidget {
  const ConditionMarkerRail({required this.sectorRecord, super.key});

  final CliffSectorRecord sectorRecord;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ConditionPebble(
            icon: Icons.touch_app_rounded,
            label: 'Stone',
            value: sectorRecord.holdFeel.fieldPhrase,
          ),
          _ConditionPebble(
            icon: Icons.wb_twilight_rounded,
            label: 'Aspect',
            value: sectorRecord.aspectBySun,
          ),
          _ConditionPebble(
            icon: Icons.groups_2_rounded,
            label: 'Base',
            value: sectorRecord.baseLandingRead,
          ),
          _ConditionPebble(
            icon: Icons.schedule_rounded,
            label: 'Quiet',
            value: sectorRecord.quietHourWindow,
          ),
        ],
      ),
    );
  }
}

class _ConditionPebble extends StatelessWidget {
  const _ConditionPebble({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 148, maxWidth: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: LedgePalette.cleanPanel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: LedgePalette.fogLine),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: LedgePalette.ropeBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: LedgePalette.graniteGrey,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LedgePalette.shaleInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
