import '../value_objects/stone_condition_mark.dart';
import 'approach_corridor_brief.dart';
import 'line_project_note.dart';

class CliffSectorRecord {
  const CliffSectorRecord({
    required this.sectorHandle,
    required this.aspectBySun,
    required this.stonePersonality,
    required this.baseLandingRead,
    required this.rememberedLineCount,
    required this.holdFeel,
    required this.quietHourWindow,
    required this.approachThread,
    required this.lineStack,
    required this.recentNotebookSnips,
  });

  final String sectorHandle;
  final String aspectBySun;
  final String stonePersonality;
  final String baseLandingRead;
  final int rememberedLineCount;
  final StoneConditionMark holdFeel;
  final String quietHourWindow;
  final ApproachCorridorBrief approachThread;
  final List<LineProjectNote> lineStack;
  final List<String> recentNotebookSnips;
}
