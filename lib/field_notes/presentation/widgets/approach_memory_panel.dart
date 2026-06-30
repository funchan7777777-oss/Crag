import 'package:flutter/material.dart';

import '../../../foundation/formatters/route_grade_formatter.dart';
import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/approach_corridor_brief.dart';

class ApproachMemoryPanel extends StatelessWidget {
  const ApproachMemoryPanel({required this.brief, super.key});

  final ApproachCorridorBrief brief;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LedgePalette.cleanPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LedgePalette.fogLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                size: 20,
                color: LedgePalette.copperSun,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  brief.trailheadCallsign,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: LedgePalette.shaleInk,
                  ),
                ),
              ),
              Text(
                RouteGradeFormatter.approachMinutes(brief.footMinutesFromGate),
                style: textTheme.labelMedium?.copyWith(
                  color: LedgePalette.ropeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            brief.parkingTexture,
            style: textTheme.bodyMedium?.copyWith(
              color: LedgePalette.graniteGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last cue: ${brief.lastVisibleCue}',
            style: textTheme.bodyMedium?.copyWith(
              color: LedgePalette.shaleInk,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final note in brief.carefulFootworkNotes)
                _FootworkNoteChip(noteCopy: note),
            ],
          ),
        ],
      ),
    );
  }
}

class _FootworkNoteChip extends StatelessWidget {
  const _FootworkNoteChip({required this.noteCopy});

  final String noteCopy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LedgePalette.fogLine.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          noteCopy,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: LedgePalette.shaleInk),
        ),
      ),
    );
  }
}
