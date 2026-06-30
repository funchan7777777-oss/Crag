import 'package:flutter/material.dart';

import '../../../foundation/theme/ledge_palette.dart';

class NotesSectionTitle extends StatelessWidget {
  const NotesSectionTitle({
    required this.eyebrow,
    required this.heading,
    this.trailingNote,
    super.key,
  });

  final String eyebrow;
  final String heading;
  final String? trailingNote;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: LedgePalette.copperSun,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    color: LedgePalette.shaleInk,
                  ),
                ),
              ],
            ),
          ),
          if (trailingNote != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                trailingNote!,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: LedgePalette.graniteGrey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
