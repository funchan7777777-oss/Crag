class ApproachCorridorBrief {
  const ApproachCorridorBrief({
    required this.trailheadCallsign,
    required this.parkingTexture,
    required this.footMinutesFromGate,
    required this.lastVisibleCue,
    required this.carefulFootworkNotes,
  });

  final String trailheadCallsign;
  final String parkingTexture;
  final int footMinutesFromGate;
  final String lastVisibleCue;
  final List<String> carefulFootworkNotes;
}
