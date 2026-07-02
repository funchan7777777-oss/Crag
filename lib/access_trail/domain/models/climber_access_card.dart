class ClimberAccessCard {
  const ClimberAccessCard({
    required this.corridorKey,
    required this.accessRoute,
    required this.trailName,
    required this.fieldBio,
    required this.anchoredAtIso,
    this.contactEmail,
    this.avatarFilePath,
  });

  final String corridorKey;
  final String accessRoute;
  final String trailName;
  final String fieldBio;
  final String anchoredAtIso;
  final String? contactEmail;
  final String? avatarFilePath;

  Map<String, String> toCacheMap() {
    final cacheMap = {
      'corridorKey': corridorKey,
      'accessRoute': accessRoute,
      'trailName': trailName,
      'fieldBio': fieldBio,
      'anchoredAtIso': anchoredAtIso,
    };
    final email = contactEmail;
    final avatarPath = avatarFilePath;
    if (email != null) {
      cacheMap['contactEmail'] = email;
    }
    if (avatarPath != null) {
      cacheMap['avatarFilePath'] = avatarPath;
    }
    return cacheMap;
  }

  static ClimberAccessCard? fromCacheMap(Map<String, String> cacheMap) {
    final corridorKey = cacheMap['corridorKey'];
    final accessRoute = cacheMap['accessRoute'];
    final trailName = cacheMap['trailName'];
    final fieldBio = cacheMap['fieldBio'];
    final anchoredAtIso = cacheMap['anchoredAtIso'];

    if (corridorKey == null ||
        accessRoute == null ||
        trailName == null ||
        fieldBio == null ||
        anchoredAtIso == null) {
      return null;
    }

    return ClimberAccessCard(
      corridorKey: corridorKey,
      accessRoute: accessRoute,
      trailName: trailName,
      fieldBio: fieldBio,
      anchoredAtIso: anchoredAtIso,
      contactEmail: cacheMap['contactEmail'],
      avatarFilePath: cacheMap['avatarFilePath'],
    );
  }
}
