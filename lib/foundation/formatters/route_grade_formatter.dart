class RouteGradeFormatter {
  const RouteGradeFormatter._();

  static String approachMinutes(int footMinutesFromGate) {
    if (footMinutesFromGate < 60) {
      return '$footMinutesFromGate min approach';
    }

    final hours = footMinutesFromGate ~/ 60;
    final minutes = footMinutesFromGate % 60;
    return minutes == 0
        ? '${hours}h approach'
        : '${hours}h ${minutes}m approach';
  }

  static String hardwareThread({
    required int clippedBoltCount,
    required bool asksForSmallRack,
  }) {
    final boltPhrase = clippedBoltCount == 1
        ? '1 bolt'
        : '$clippedBoltCount bolts';
    return asksForSmallRack ? '$boltPhrase and small rack' : boltPhrase;
  }
}
