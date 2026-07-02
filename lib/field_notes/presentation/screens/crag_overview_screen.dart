import 'package:flutter/material.dart';

import '../../data/highland_crag_notebook.dart';
import '../../domain/models/cliff_sector_record.dart';
import '../widgets/approach_memory_panel.dart';
import '../widgets/condition_marker_rail.dart';
import '../widgets/crag_field_header.dart';
import '../widgets/notes_section_title.dart';
import '../widgets/sector_selector_ribbon.dart';
import '../widgets/sector_story_card.dart';
import '../widgets/weather_window_panel.dart';

class CragOverviewScreen extends StatefulWidget {
  const CragOverviewScreen({super.key});

  @override
  State<CragOverviewScreen> createState() => _CragOverviewScreenState();
}

class _CragOverviewScreenState extends State<CragOverviewScreen> {
  final List<CliffSectorRecord> _sectorLedger =
      HighlandCragNotebook.sectorRecords;

  int _activeSectorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activeSector = _sectorLedger[_activeSectorIndex];
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: topInset + 12)),
          SliverToBoxAdapter(
            child: CragFieldHeader(
              weatherWindow: HighlandCragNotebook.weatherWindow,
              visibleSectorCount: _sectorLedger.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SectorSelectorRibbon(
              sectorLedger: _sectorLedger,
              selectedSectorIndex: _activeSectorIndex,
              onSectorPressed: (index) {
                setState(() => _activeSectorIndex = index);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: NotesSectionTitle(
              eyebrow: 'Current read',
              heading: activeSector.sectorHandle,
              trailingNote: activeSector.aspectBySun,
            ),
          ),
          SliverToBoxAdapter(
            child: ConditionMarkerRail(sectorRecord: activeSector),
          ),
          SliverToBoxAdapter(
            child: WeatherWindowPanel(
              weatherMarker: HighlandCragNotebook.weatherWindow,
            ),
          ),
          SliverToBoxAdapter(
            child: ApproachMemoryPanel(brief: activeSector.approachThread),
          ),
          SliverToBoxAdapter(
            child: SectorStoryCard(sectorRecord: activeSector),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}
