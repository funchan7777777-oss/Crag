import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';
import '../../domain/models/cliff_sector_record.dart';

class SectorSelectorRibbon extends StatelessWidget {
  const SectorSelectorRibbon({
    required this.sectorLedger,
    required this.selectedSectorIndex,
    required this.onSectorPressed,
    super.key,
  });

  final List<CliffSectorRecord> sectorLedger;
  final int selectedSectorIndex;
  final ValueChanged<int> onSectorPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: sectorLedger.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sector = sectorLedger[index];
          final selected = index == selectedSectorIndex;
          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            avatar: Icon(
              selected ? Icons.place_rounded : Icons.landscape_rounded,
              size: 17,
              color: selected ? LedgePalette.chalkWhite : LedgePalette.ropeBlue,
            ),
            label: Text(sector.sectorHandle),
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? LedgePalette.chalkWhite : LedgePalette.shaleInk,
            ),
            selectedColor: LedgePalette.pineShadow,
            backgroundColor: LedgePalette.fogLine,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: selected
                    ? LedgePalette.pineShadow
                    : LedgePalette.fogLine,
              ),
            ),
            onSelected: (_) => onSectorPressed(index),
          );
        },
      ),
    );
  }
}
