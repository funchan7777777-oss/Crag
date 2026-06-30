import '../domain/models/approach_corridor_brief.dart';
import '../domain/models/cliff_sector_record.dart';
import '../domain/models/line_project_note.dart';
import '../domain/models/weather_window_marker.dart';
import '../domain/value_objects/stone_condition_mark.dart';

class HighlandCragNotebook {
  const HighlandCragNotebook._();

  static const weatherWindow = WeatherWindowMarker(
    ridgeTimeBand: '08:40 to 12:15',
    skyLedger: 'high cloud with clean breaks',
    airTemperatureCelsius: 17,
    windThread: 'light crosswind along the upper wall',
    frictionPromise: 'best before the slabs warm',
    packingNudge: 'thin shell, brush, and spare tape',
  );

  static const sectorRecords = <CliffSectorRecord>[
    CliffSectorRecord(
      sectorHandle: 'North Pocket Wall',
      aspectBySun: 'shade until late lunch',
      stonePersonality: 'compact grey limestone with small scoops',
      baseLandingRead: 'flat gravel shelf with room for two pads',
      rememberedLineCount: 18,
      holdFeel: StoneConditionMark.crispEdges,
      quietHourWindow: 'early teams clear out around 11:30',
      approachThread: ApproachCorridorBrief(
        trailheadCallsign: 'old quarry turnout',
        parkingTexture: 'three-car pullout beside the low timber fence',
        footMinutesFromGate: 24,
        lastVisibleCue: 'split pine above the drainage step',
        carefulFootworkNotes: [
          'loose pea gravel on the second switchback',
          'muddy root shelf after rain',
          'stay right when the wall first appears',
        ],
      ),
      lineStack: [
        LineProjectNote(
          lineCallsign: 'Pocket Weather',
          gradeConversation: '5.10c',
          wallPositionMemory: 'left side of the scooped streak',
          clippedBoltCount: 8,
          asksForSmallRack: false,
          cruxShape: 'high feet into a shallow two-finger dish',
          restPocketHint: 'shake from the slanted slot before bolt six',
          sessionUse: 'warm focus burn',
        ),
        LineProjectNote(
          lineCallsign: 'Fence Shadow',
          gradeConversation: '5.11a',
          wallPositionMemory: 'straight line below the pale roof tooth',
          clippedBoltCount: 9,
          asksForSmallRack: false,
          cruxShape: 'tension move from sidepull to rounded pinch',
          restPocketHint: 'brief kneebar stance under the ripple',
          sessionUse: 'project lap',
        ),
      ],
      recentNotebookSnips: [
        'Brush the second rail; it polishes faster than the rest.',
        'Afternoon glare makes the last clip harder to read.',
      ],
    ),
    CliffSectorRecord(
      sectorHandle: 'Fern Ledge',
      aspectBySun: 'morning glints, calm by dusk',
      stonePersonality: 'dark orange bands with generous edges',
      baseLandingRead: 'narrow ledge, helmets stay useful',
      rememberedLineCount: 11,
      holdFeel: StoneConditionMark.warmSlab,
      quietHourWindow: 'soft light after 16:00',
      approachThread: ApproachCorridorBrief(
        trailheadCallsign: 'creek bridge start',
        parkingTexture: 'signed shoulder near the mossy culvert',
        footMinutesFromGate: 31,
        lastVisibleCue: 'fern bench where the trail cuts under a boulder',
        carefulFootworkNotes: [
          'wet boardwalk planks near the creek',
          'short scramble below the first anchor',
          'pack rope inside the narrow laurel tunnel',
        ],
      ),
      lineStack: [
        LineProjectNote(
          lineCallsign: 'Moss Clock',
          gradeConversation: '5.9',
          wallPositionMemory: 'orange slab before the ledge pinches down',
          clippedBoltCount: 7,
          asksForSmallRack: false,
          cruxShape: 'balanced step across a glassy ripple',
          restPocketHint: 'hands-free stance below the last face section',
          sessionUse: 'confidence mileage',
        ),
        LineProjectNote(
          lineCallsign: 'Thin Fern Direct',
          gradeConversation: '5.10d',
          wallPositionMemory: 'center face where the fern seam fades',
          clippedBoltCount: 6,
          asksForSmallRack: true,
          cruxShape: 'small cam placement before the final bolt',
          restPocketHint: 'flat edge beside the green scar',
          sessionUse: 'tech rehearsal',
        ),
      ],
      recentNotebookSnips: [
        'Belay stance takes only one pack comfortably.',
        'Evening air keeps the upper slab pleasant.',
      ],
    ),
    CliffSectorRecord(
      sectorHandle: 'Raven Shelf',
      aspectBySun: 'sunny shoulder, windy rim',
      stonePersonality: 'blocky basalt ribs with positive rails',
      baseLandingRead: 'tiered stones, keep ropes tucked',
      rememberedLineCount: 14,
      holdFeel: StoneConditionMark.windBuffed,
      quietHourWindow: 'wind settles after the ridge shadow lands',
      approachThread: ApproachCorridorBrief(
        trailheadCallsign: 'ridgetop bend',
        parkingTexture: 'packed dirt bay after the cattle grate',
        footMinutesFromGate: 18,
        lastVisibleCue: 'flat raven perch on the skyline block',
        carefulFootworkNotes: [
          'avoid the eroded shortcut by the fence post',
          'two hands helpful on the final basalt steps',
          'wind can lift an unweighted rope bag',
        ],
      ),
      lineStack: [
        LineProjectNote(
          lineCallsign: 'Black Rib Ledger',
          gradeConversation: '5.10a',
          wallPositionMemory: 'first tall rib facing the valley',
          clippedBoltCount: 8,
          asksForSmallRack: false,
          cruxShape: 'long reach between clean basalt rails',
          restPocketHint: 'stem across the shallow corner at mid-height',
          sessionUse: 'endurance primer',
        ),
        LineProjectNote(
          lineCallsign: 'Wind Receipt',
          gradeConversation: '5.11b',
          wallPositionMemory: 'right-hand face above the stepped stones',
          clippedBoltCount: 10,
          asksForSmallRack: false,
          cruxShape: 'body tension across a sloping lip',
          restPocketHint: 'shake at the sidepull pod before the headwall',
          sessionUse: 'limit sequence',
        ),
      ],
      recentNotebookSnips: [
        'Tape helped on the lower rib edges.',
        'Lower-off sits slightly right of the natural fall line.',
      ],
    ),
  ];
}
