import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/climber_access_card.dart';

class LocalCragAccessCache {
  const LocalCragAccessCache._(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeenKey = 'crag.routeCards.seen';
  static const _storedEmailKey = 'crag.localCredential.email';
  static const _storedPasswordKey = 'crag.localCredential.password';
  static const _activePrefix = 'crag.activeAccess.';

  static Future<LocalCragAccessCache> open() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalCragAccessCache._(prefs);
  }

  bool get hasSeenRouteCards => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> markRouteCardsSeen() async {
    await _prefs.setBool(_onboardingSeenKey, true);
  }

  Future<void> keepLocalCredential({
    required String emailTrail,
    required String passwordGrip,
  }) async {
    await _prefs.setString(_storedEmailKey, emailTrail.trim().toLowerCase());
    await _prefs.setString(_storedPasswordKey, passwordGrip);
  }

  bool localCredentialRejects({
    required String emailTrail,
    required String passwordGrip,
  }) {
    final storedEmail = _prefs.getString(_storedEmailKey);
    final storedPassword = _prefs.getString(_storedPasswordKey);
    if (storedEmail == null || storedPassword == null) {
      return false;
    }
    return storedEmail == emailTrail.trim().toLowerCase() &&
        storedPassword != passwordGrip;
  }

  String? storedTrailNameFor(String emailTrail) {
    final active = readActiveCard();
    if (active?.contactEmail?.toLowerCase() ==
        emailTrail.trim().toLowerCase()) {
      return active?.trailName;
    }
    return null;
  }

  ClimberAccessCard? readActiveCard() {
    final cacheMap = <String, String>{};
    for (final key in [
      'corridorKey',
      'accessRoute',
      'trailName',
      'fieldBio',
      'anchoredAtIso',
      'contactEmail',
      'avatarFilePath',
      'genderLabel',
      'birthDate',
      'city',
    ]) {
      final value = _prefs.getString('$_activePrefix$key');
      if (value != null) {
        cacheMap[key] = value;
      }
    }
    return ClimberAccessCard.fromCacheMap(cacheMap);
  }

  Future<void> anchorActiveCard(ClimberAccessCard card) async {
    final cacheMap = card.toCacheMap();
    for (final key in [
      'corridorKey',
      'accessRoute',
      'trailName',
      'fieldBio',
      'anchoredAtIso',
      'contactEmail',
      'avatarFilePath',
      'genderLabel',
      'birthDate',
      'city',
    ]) {
      final value = cacheMap[key];
      if (value == null) {
        await _prefs.remove('$_activePrefix$key');
      } else {
        await _prefs.setString('$_activePrefix$key', value);
      }
    }
  }

  Future<void> clearActiveCard() async {
    for (final key in [
      'corridorKey',
      'accessRoute',
      'trailName',
      'fieldBio',
      'anchoredAtIso',
      'contactEmail',
      'avatarFilePath',
      'genderLabel',
      'birthDate',
      'city',
    ]) {
      await _prefs.remove('$_activePrefix$key');
    }
  }

  Future<void> resetAfterAccountDeletion() async {
    await clearActiveCard();
    await _prefs.remove(_storedEmailKey);
    await _prefs.remove(_storedPasswordKey);
    await _prefs.remove(_onboardingSeenKey);
  }
}
