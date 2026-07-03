class AccessCopyLedger {
  const AccessCopyLedger._();

  static const termsUrl =
      'https://sites.google.com/view/crag-terms-of-service/home';
  static const privacyUrl =
      'https://sites.google.com/view/crag-privacy-policy/home';
  static const safetyContactEmail = 'safety@climby.app';

  static const emailPattern =
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

  static String trailNameFromEmail(String emailTrail) {
    final prefix = emailTrail.split('@').first.trim();
    if (prefix.isEmpty) {
      return 'Crag Partner';
    }
    final clean = prefix
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((piece) => piece.isNotEmpty)
        .map((piece) => piece[0].toUpperCase() + piece.substring(1))
        .join(' ');
    return clean.isEmpty ? 'Crag Partner' : clean;
  }

  static bool emailLooksReady(String emailTrail) {
    return RegExp(emailPattern).hasMatch(emailTrail.trim());
  }
}
