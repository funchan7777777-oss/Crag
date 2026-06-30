import 'package:flutter/material.dart';

import '../../../foundation/formatters/route_grade_formatter.dart';
import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/line_project_note.dart';

class LineupRouteTile extends StatelessWidget {
  const LineupRouteTile({required this.lineMemo, super.key});

  final LineProjectNote lineMemo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hardwareThread = RouteGradeFormatter.hardwareThread(
      clippedBoltCount: lineMemo.clippedBoltCount,
      asksForSmallRack: lineMemo.asksForSmallRack,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LedgePalette.chalkWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LedgePalette.fogLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: LedgePalette.ropeBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.route_rounded,
                    size: 17,
                    color: LedgePalette.ropeBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lineMemo.lineCallsign,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: LedgePalette.shaleInk,
                      ),
                    ),
                    Text(
                      '${lineMemo.gradeConversation} - $hardwareThread',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: LedgePalette.graniteGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                lineMemo.sessionUse,
                style: textTheme.labelMedium?.copyWith(
                  color: LedgePalette.copperSun,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lineMemo.wallPositionMemory,
            style: textTheme.bodyMedium?.copyWith(
              color: LedgePalette.graniteGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crux: ${lineMemo.cruxShape}',
            style: textTheme.bodyMedium?.copyWith(
              color: LedgePalette.shaleInk,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Rest: ${lineMemo.restPocketHint}',
            style: textTheme.bodyMedium?.copyWith(color: LedgePalette.shaleInk),
          ),
        ],
      ),
    );
  }
}
