class ClimberAccessCard {
  const ClimberAccessCard({
    required this.corridorKey,
    required this.accessRoute,
    required this.trailName,
    required this.fieldBio,
    required this.anchoredAtIso,
    this.contactEmail,
    this.avatarFilePath,
    this.genderLabel,
    this.birthDate,
    this.city,
  });

  final String corridorKey;
  final String accessRoute;
  final String trailName;
  final String fieldBio;
  final String anchoredAtIso;
  final String? contactEmail;
  final String? avatarFilePath;
  final String? genderLabel;
  final String? birthDate;
  final String? city;

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
    final gender = genderLabel;
    final birth = birthDate;
    final homeCity = city;
    if (gender != null) {
      cacheMap['genderLabel'] = gender;
    }
    if (birth != null) {
      cacheMap['birthDate'] = birth;
    }
    if (homeCity != null) {
      cacheMap['city'] = homeCity;
    }
    return cacheMap;
  }

  ClimberAccessCard copyWith({
    String? trailName,
    String? fieldBio,
    String? contactEmail,
    String? avatarFilePath,
    String? genderLabel,
    String? birthDate,
    String? city,
  }) {
    return ClimberAccessCard(
      corridorKey: corridorKey,
      accessRoute: accessRoute,
      trailName: trailName ?? this.trailName,
      fieldBio: fieldBio ?? this.fieldBio,
      anchoredAtIso: anchoredAtIso,
      contactEmail: contactEmail ?? this.contactEmail,
      avatarFilePath: avatarFilePath ?? this.avatarFilePath,
      genderLabel: genderLabel ?? this.genderLabel,
      birthDate: birthDate ?? this.birthDate,
      city: city ?? this.city,
    );
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
      genderLabel: cacheMap['genderLabel'],
      birthDate: cacheMap['birthDate'],
      city: cacheMap['city'],
    );
  }
}
