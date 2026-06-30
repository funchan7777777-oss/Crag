import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/cliff_sector_record.dart';
import 'lineup_route_tile.dart';

class SectorStoryCard extends StatelessWidget {
  const SectorStoryCard({required this.sectorRecord, super.key});

  final CliffSectorRecord sectorRecord;

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
              Expanded(
                child: Text(
                  'Line rack',
                  style: textTheme.titleMedium?.copyWith(
                    color: LedgePalette.shaleInk,
                  ),
                ),
              ),
              Text(
                '${sectorRecord.rememberedLineCount} mapped',
                style: textTheme.labelMedium?.copyWith(
                  color: LedgePalette.graniteGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sectorRecord.stonePersonality,
            style: textTheme.bodyMedium?.copyWith(
              color: LedgePalette.graniteGrey,
            ),
          ),
          const SizedBox(height: 12),
          for (final lineMemo in sectorRecord.lineStack)
            LineupRouteTile(lineMemo: lineMemo),
          const SizedBox(height: 10),
          Text(
            'Notebook',
            style: textTheme.labelMedium?.copyWith(
              color: LedgePalette.copperSun,
            ),
          ),
          const SizedBox(height: 7),
          for (final snip in sectorRecord.recentNotebookSnips)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 16,
                    color: LedgePalette.ropeBlue,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      snip,
                      style: textTheme.bodyMedium?.copyWith(
                        color: LedgePalette.shaleInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
