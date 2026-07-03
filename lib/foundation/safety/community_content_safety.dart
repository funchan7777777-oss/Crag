enum CommunityContentSurface {
  profile,
  publicPost,
  comment,
  directMessage,
  assistantPrompt,
}

class CommunityContentDecision {
  const CommunityContentDecision._({required this.allowed, this.message});

  final bool allowed;
  final String? message;

  static const allowedDecision = CommunityContentDecision._(allowed: true);

  static CommunityContentDecision blocked(String message) {
    return CommunityContentDecision._(allowed: false, message: message);
  }
}

class CommunityContentSafetyException implements Exception {
  const CommunityContentSafetyException(this.decision);

  final CommunityContentDecision decision;

  @override
  String toString() {
    return decision.message ?? 'Community content safety check failed.';
  }
}

class CommunityContentSafety {
  const CommunityContentSafety._();

  static CommunityContentDecision validate({
    required String text,
    required CommunityContentSurface surface,
    int maxLength = 280,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return CommunityContentDecision.allowedDecision;
    }
    if (trimmed.length > maxLength) {
      return CommunityContentDecision.blocked(
        'Keep this line under $maxLength characters.',
      );
    }

    final normalized = _normalize(trimmed);
    if (_looksLikeSpam(normalized)) {
      return CommunityContentDecision.blocked(
        'Rewrite this as a real climbing note without repeats or off-route promotion.',
      );
    }
    if (_containsHighRiskSafetyContent(normalized)) {
      return CommunityContentDecision.blocked(
        'Rewrite this so it stays respectful, lawful, and climbing-focused.',
      );
    }
    if (_isPublicSurface(surface) && _containsPrivateContact(trimmed)) {
      return CommunityContentDecision.blocked(
        'Remove private contact details before posting publicly.',
      );
    }

    return CommunityContentDecision.allowedDecision;
  }

  static void enforce({
    required String text,
    required CommunityContentSurface surface,
    int maxLength = 280,
  }) {
    final decision = validate(
      text: text,
      surface: surface,
      maxLength: maxLength,
    );
    if (!decision.allowed) {
      throw CommunityContentSafetyException(decision);
    }
  }

  static bool _isPublicSurface(CommunityContentSurface surface) {
    return surface == CommunityContentSurface.profile ||
        surface == CommunityContentSurface.publicPost ||
        surface == CommunityContentSurface.comment;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .replaceAll(RegExp(r'[^a-z0-9@:+./\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _looksLikeSpam(String text) {
    if (RegExp(r'(.)\1{7,}').hasMatch(text)) {
      return true;
    }
    final linkCount = RegExp(r'(https?://|www\.)').allMatches(text).length;
    if (linkCount > 1) {
      return true;
    }
    return RegExp(
          r'\b(crypto|airdrop|loan|casino|betting|cashapp|telegram|whatsapp)\b',
        ).hasMatch(text) ||
        RegExp(r'(博彩|赌博|贷款|刷单|空投|虚拟币|加微信|加群)').hasMatch(text);
  }

  static bool _containsHighRiskSafetyContent(String text) {
    final patterns = [
      RegExp(r'\b(sex|sexual|nude|naked|porn|escort|hookup)\b'),
      RegExp(r'\b(kill|hurt|attack)\s+(you|u|yourself|them|him|her)\b'),
      RegExp(r'\b(suicide|self\s*harm|weapon|terror|cocaine|meth)\b'),
      RegExp(r'\b(hate\s*speech|harass|harassment|bully|bullying)\b'),
      RegExp(r'\b(scamming|scammer|fraud|fake\s*payment)\b'),
      RegExp(r'(色情|裸照|约炮|成人视频|黄片)'),
      RegExp(r'(杀了你|弄死|攻击你|自杀|自残|武器|恐怖)'),
      RegExp(r'(辱骂|骚扰|霸凌|仇恨|诈骗|虚假付款)'),
    ];
    return patterns.any((pattern) => pattern.hasMatch(text));
  }

  static bool _containsPrivateContact(String text) {
    return RegExp(
          r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
        ).hasMatch(text) ||
        RegExp(r'(?:(?:\+?\d[\s().-]?){8,})').hasMatch(text) ||
        RegExp(r'(https?://|www\.)', caseSensitive: false).hasMatch(text);
  }
}
