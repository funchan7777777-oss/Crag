import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ClimbyGender { male, female }

enum ModerationKind { post, comment, user, spot }

class ClimbySocialStore extends ChangeNotifier {
  ClimbySocialStore._();

  static final ClimbySocialStore instance = ClimbySocialStore._();

  static const _reportedKey = 'climby.reported.keys.v1';
  static const _blockedUsersKey = 'climby.blocked.users.v1';
  static const _followRequestsKey = 'climby.follow.requests.v1';
  static const _mutualFollowsKey = 'climby.mutual.follows.v1';
  static const _messagesKey = 'climby.messages.v1';
  static const _commentsKey = 'climby.comments.v1';

  SharedPreferences? _prefs;
  bool _loaded = false;
  final Set<String> _reportedKeys = {};
  final Set<String> _blockedUserIds = {};
  final Set<String> _sentFollowRequests = {};
  final Set<String> _mutualFollowUserIds = {};
  final Map<String, List<ClimbyMessage>> _messagesByUser = {};
  final Map<String, List<ClimbyComment>> _localCommentsByPost = {};

  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    _reportedKeys.addAll(_readStringSet(_reportedKey));
    _blockedUserIds.addAll(_readStringSet(_blockedUsersKey));
    _sentFollowRequests.addAll(_readStringSet(_followRequestsKey));
    _mutualFollowUserIds.addAll(_readStringSet(_mutualFollowsKey));
    _messagesByUser.addAll(_readMessageMap(_messagesKey));
    _localCommentsByPost.addAll(_readCommentMap(_commentsKey));
    _loaded = true;
    notifyListeners();
  }

  List<ClimbyUser> get visibleUsers {
    return seedUsers
        .where(
          (user) =>
              !_blockedUserIds.contains(user.id) &&
              !_reportedKeys.contains('user:${user.id}'),
        )
        .toList(growable: false);
  }

  List<ClimbyPost> visiblePosts({String? category}) {
    return seedPosts
        .where((post) {
          if (category != null &&
              category != 'All' &&
              post.category != category) {
            return false;
          }
          return !_blockedUserIds.contains(post.userId) &&
              !_reportedKeys.contains('post:${post.id}') &&
              !_reportedKeys.contains('user:${post.userId}');
        })
        .toList(growable: false);
  }

  List<ClimbySpot> get visibleSpots {
    return seedSpots
        .where((spot) => !_reportedKeys.contains('spot:${spot.id}'))
        .toList(growable: false);
  }

  List<ClimbyComment> commentsFor(String postId) {
    final comments = [
      ...seedComments.where((comment) => comment.postId == postId),
      ...?_localCommentsByPost[postId],
    ];
    return comments
        .where((comment) {
          return !_reportedKeys.contains('comment:${comment.id}') &&
              !_blockedUserIds.contains(comment.userId) &&
              !_reportedKeys.contains('user:${comment.userId}');
        })
        .toList(growable: false);
  }

  List<ClimbyMessage> messagesFor(String userId) {
    if (_blockedUserIds.contains(userId)) {
      return const [];
    }
    return List.unmodifiable(_messagesByUser[userId] ?? const []);
  }

  ClimbyUser? userById(String userId) {
    for (final user in seedUsers) {
      if (user.id == userId) {
        return user;
      }
    }
    return null;
  }

  ClimbyPost? postById(String postId) {
    for (final post in seedPosts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  ClimbySpot? spotById(String spotId) {
    for (final spot in seedSpots) {
      if (spot.id == spotId) {
        return spot;
      }
    }
    return null;
  }

  bool isFollowRequested(String userId) {
    return _sentFollowRequests.contains(userId);
  }

  bool isMutualFollow(String userId) {
    return _mutualFollowUserIds.contains(userId);
  }

  bool isUserBlocked(String userId) {
    return _blockedUserIds.contains(userId);
  }

  Future<void> requestFollow(String userId) async {
    if (_blockedUserIds.contains(userId) ||
        _mutualFollowUserIds.contains(userId)) {
      return;
    }
    _sentFollowRequests.add(userId);
    await _writeStringSet(_followRequestsKey, _sentFollowRequests);
    notifyListeners();
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final comment = ClimbyComment(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      postId: postId,
      userId: currentUser.id,
      text: trimmed,
      createdLabel: 'now',
    );
    _localCommentsByPost.putIfAbsent(postId, () => []).add(comment);
    await _writeCommentMap();
    notifyListeners();
  }

  Future<void> sendMessage({
    required String userId,
    required String text,
  }) async {
    if (!isMutualFollow(userId)) {
      throw StateError('mutual-follow-required');
    }
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final message = ClimbyMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      text: trimmed,
      sentByMe: true,
      createdIso: DateTime.now().toIso8601String(),
    );
    _messagesByUser.putIfAbsent(userId, () => []).add(message);
    await _writeMessageMap();
    notifyListeners();
  }

  Future<void> report({
    required ModerationTarget target,
    required String reason,
  }) async {
    _reportedKeys.add(target.key);
    await _writeStringSet(_reportedKey, _reportedKeys);
    notifyListeners();
  }

  Future<void> block(ModerationTarget target) async {
    final userId = target.userId;
    if (userId != null) {
      _blockedUserIds.add(userId);
      _messagesByUser.remove(userId);
      await _writeStringSet(_blockedUsersKey, _blockedUserIds);
      await _writeMessageMap();
    } else {
      _reportedKeys.add(target.key);
      await _writeStringSet(_reportedKey, _reportedKeys);
    }
    notifyListeners();
  }

  Set<String> _readStringSet(String key) {
    return (_prefs?.getStringList(key) ?? const []).toSet();
  }

  Future<void> _writeStringSet(String key, Set<String> values) async {
    await _prefs?.setStringList(key, values.toList(growable: false)..sort());
  }

  Map<String, List<ClimbyMessage>> _readMessageMap(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }
    return decoded.map((userId, value) {
      final rows = value is List ? value : const [];
      return MapEntry(
        userId,
        rows
            .whereType<Map<String, dynamic>>()
            .map(ClimbyMessage.fromJson)
            .toList(),
      );
    });
  }

  Future<void> _writeMessageMap() async {
    final payload = _messagesByUser.map(
      (key, value) => MapEntry(
        key,
        value.map((message) => message.toJson()).toList(growable: false),
      ),
    );
    await _prefs?.setString(_messagesKey, jsonEncode(payload));
  }

  Map<String, List<ClimbyComment>> _readCommentMap(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return {};
    }
    return decoded.map((postId, value) {
      final rows = value is List ? value : const [];
      return MapEntry(
        postId,
        rows
            .whereType<Map<String, dynamic>>()
            .map(ClimbyComment.fromJson)
            .toList(),
      );
    });
  }

  Future<void> _writeCommentMap() async {
    final payload = _localCommentsByPost.map(
      (key, value) => MapEntry(
        key,
        value.map((comment) => comment.toJson()).toList(growable: false),
      ),
    );
    await _prefs?.setString(_commentsKey, jsonEncode(payload));
  }
}

class ClimbyUser {
  const ClimbyUser({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.city,
    required this.avatarAsset,
    required this.bio,
    required this.specialty,
  });

  final String id;
  final String name;
  final ClimbyGender gender;
  final int age;
  final String city;
  final String avatarAsset;
  final String bio;
  final String specialty;
}

class ClimbyPost {
  const ClimbyPost({
    required this.id,
    required this.userId,
    required this.imageAsset,
    required this.caption,
    required this.category,
    required this.timeAgo,
  });

  final String id;
  final String userId;
  final String imageAsset;
  final String caption;
  final String category;
  final String timeAgo;
}

class ClimbySpot {
  const ClimbySpot({
    required this.id,
    required this.title,
    required this.location,
    required this.imageAsset,
    required this.rating,
    required this.climbers,
    required this.style,
    required this.description,
  });

  final String id;
  final String title;
  final String location;
  final String imageAsset;
  final String rating;
  final String climbers;
  final String style;
  final String description;
}

class ClimbyComment {
  const ClimbyComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdLabel,
  });

  final String id;
  final String postId;
  final String userId;
  final String text;
  final String createdLabel;

  factory ClimbyComment.fromJson(Map<String, dynamic> json) {
    return ClimbyComment(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      createdLabel: json['createdLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'text': text,
      'createdLabel': createdLabel,
    };
  }
}

class ClimbyMessage {
  const ClimbyMessage({
    required this.id,
    required this.userId,
    required this.text,
    required this.sentByMe,
    required this.createdIso,
  });

  final String id;
  final String userId;
  final String text;
  final bool sentByMe;
  final String createdIso;

  factory ClimbyMessage.fromJson(Map<String, dynamic> json) {
    return ClimbyMessage(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sentByMe: json['sentByMe'] as bool? ?? false,
      createdIso: json['createdIso'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'sentByMe': sentByMe,
      'createdIso': createdIso,
    };
  }
}

class ModerationTarget {
  const ModerationTarget({
    required this.kind,
    required this.key,
    required this.title,
    this.userId,
  });

  final ModerationKind kind;
  final String key;
  final String title;
  final String? userId;
}

const currentUser = ClimbyUser(
  id: 'me',
  name: 'You',
  gender: ClimbyGender.male,
  age: 24,
  city: 'Local Crag',
  avatarAsset: 'assets/images/Grip.png',
  bio: 'Building a steady climbing log.',
  specialty: 'All-round',
);

const seedUsers = [
  ClimbyUser(
    id: 'alex',
    name: 'Alex R.',
    gender: ClimbyGender.male,
    age: 22,
    city: 'Los Angeles, CA',
    avatarAsset: 'assets/images/head/avatar_male_alex.jpg',
    bio: 'Love indoor bouldering and weekend outdoor trips.',
    specialty: 'Bouldering',
  ),
  ClimbyUser(
    id: 'maya',
    name: 'Maya C.',
    gender: ClimbyGender.female,
    age: 24,
    city: 'Denver, CO',
    avatarAsset: 'assets/images/head/avatar_female_maya.jpg',
    bio: 'Training finger strength and cleaner footwork.',
    specialty: 'Lead',
  ),
  ClimbyUser(
    id: 'noah',
    name: 'Noah K.',
    gender: ClimbyGender.male,
    age: 26,
    city: 'Austin, TX',
    avatarAsset: 'assets/images/head/avatar_male_noah.jpg',
    bio: 'Looking for patient partners for volume days.',
    specialty: 'Indoor',
  ),
  ClimbyUser(
    id: 'lina',
    name: 'Lina V.',
    gender: ClimbyGender.female,
    age: 23,
    city: 'Portland, OR',
    avatarAsset: 'assets/images/head/avatar_female_lina.jpg',
    bio: 'Slab balance, coffee, and early gym sessions.',
    specialty: 'Slab',
  ),
  ClimbyUser(
    id: 'sophia',
    name: 'Sophia M.',
    gender: ClimbyGender.female,
    age: 25,
    city: 'Boulder, CO',
    avatarAsset: 'assets/images/head/avatar_female_sophia.jpg',
    bio: 'Outdoor limestone weekends and training logs.',
    specialty: 'Outdoor',
  ),
  ClimbyUser(
    id: 'eli',
    name: 'Eli W.',
    gender: ClimbyGender.male,
    age: 27,
    city: 'Seattle, WA',
    avatarAsset: 'assets/images/head/avatar_male_eli.jpg',
    bio: 'Route reading and controlled overhang sessions.',
    specialty: 'Overhang',
  ),
  ClimbyUser(
    id: 'zoe',
    name: 'Zoe N.',
    gender: ClimbyGender.female,
    age: 21,
    city: 'San Diego, CA',
    avatarAsset: 'assets/images/head/avatar_female_zoe.jpg',
    bio: 'Comp-style boulders and dyno practice.',
    specialty: 'Dyno',
  ),
  ClimbyUser(
    id: 'clara',
    name: 'Clara P.',
    gender: ClimbyGender.female,
    age: 28,
    city: 'Salt Lake City, UT',
    avatarAsset: 'assets/images/head/avatar_female_clara.jpg',
    bio: 'Calm belays and long alpine days.',
    specialty: 'Alpine',
  ),
  ClimbyUser(
    id: 'kai',
    name: 'Kai T.',
    gender: ClimbyGender.male,
    age: 23,
    city: 'Chicago, IL',
    avatarAsset: 'assets/images/head/avatar_male_kai.jpg',
    bio: 'Power endurance and board climbing after work.',
    specialty: 'Board',
  ),
  ClimbyUser(
    id: 'iris',
    name: 'Iris F.',
    gender: ClimbyGender.female,
    age: 22,
    city: 'Phoenix, AZ',
    avatarAsset: 'assets/images/head/avatar_female_iris.jpg',
    bio: 'New to outdoor sport routes, steady learner.',
    specialty: 'Sport',
  ),
  ClimbyUser(
    id: 'nora',
    name: 'Nora H.',
    gender: ClimbyGender.female,
    age: 24,
    city: 'Brooklyn, NY',
    avatarAsset: 'assets/images/head/avatar_female_nora.jpg',
    bio: 'Gym regular, loves coordination problems.',
    specialty: 'Coordination',
  ),
  ClimbyUser(
    id: 'rhea',
    name: 'Rhea D.',
    gender: ClimbyGender.female,
    age: 26,
    city: 'Las Vegas, NV',
    avatarAsset: 'assets/images/head/avatar_female_rhea.jpg',
    bio: 'Desert trips, careful beta, and good snacks.',
    specialty: 'Trad',
  ),
  ClimbyUser(
    id: 'luca',
    name: 'Luca B.',
    gender: ClimbyGender.male,
    age: 25,
    city: 'Miami, FL',
    avatarAsset: 'assets/images/head/avatar_male_luca.jpg',
    bio: 'Training for stronger lockoffs.',
    specialty: 'Strength',
  ),
  ClimbyUser(
    id: 'ava',
    name: 'Ava S.',
    gender: ClimbyGender.female,
    age: 23,
    city: 'Los Angeles, CA',
    avatarAsset: 'assets/images/head/avatar_female_ava.jpg',
    bio: 'Projecting vertical climbs and sharing beta.',
    specialty: 'Vertical',
  ),
  ClimbyUser(
    id: 'theo',
    name: 'Theo J.',
    gender: ClimbyGender.male,
    age: 29,
    city: 'Boston, MA',
    avatarAsset: 'assets/images/head/avatar_male_theo.jpg',
    bio: 'Careful lead sessions and gym meetups.',
    specialty: 'Lead',
  ),
];

const seedPosts = [
  ClimbyPost(
    id: 'p01',
    userId: 'alex',
    imageAsset: 'assets/images/post/post_outdoor_limestone.jpg',
    caption: 'Finally sent my project!',
    category: 'Outdoor',
    timeAgo: '2h ago',
  ),
  ClimbyPost(
    id: 'p02',
    userId: 'maya',
    imageAsset: 'assets/images/post/post_boulder_jump.jpg',
    caption: 'Coordination day paid off.',
    category: 'Bouldering',
    timeAgo: '4h ago',
  ),
  ClimbyPost(
    id: 'p03',
    userId: 'noah',
    imageAsset: 'assets/images/post/post_rope_wall_start.jpg',
    caption: 'Warmup laps before work.',
    category: 'Training',
    timeAgo: '5h ago',
  ),
  ClimbyPost(
    id: 'p04',
    userId: 'lina',
    imageAsset: 'assets/images/post/post_blue_roof_move.jpg',
    caption: 'Roof sequence finally clicked.',
    category: 'Bouldering',
    timeAgo: '6h ago',
  ),
  ClimbyPost(
    id: 'p05',
    userId: 'sophia',
    imageAsset: 'assets/images/post/post_finish_smile.jpg',
    caption: 'Clean finish, clean day.',
    category: 'Outdoor',
    timeAgo: '8h ago',
  ),
  ClimbyPost(
    id: 'p06',
    userId: 'eli',
    imageAsset: 'assets/images/post/post_pink_slab_reach.jpg',
    caption: 'Small feet, big trust.',
    category: 'Training',
    timeAgo: '9h ago',
  ),
  ClimbyPost(
    id: 'p07',
    userId: 'zoe',
    imageAsset: 'assets/images/post/post_red_cave_match.jpg',
    caption: 'Cave session with fresh tape.',
    category: 'Bouldering',
    timeAgo: '10h ago',
  ),
  ClimbyPost(
    id: 'p08',
    userId: 'clara',
    imageAsset: 'assets/images/post/post_indoor_rope_class.jpg',
    caption: 'Partner checks before every burn.',
    category: 'Video',
    timeAgo: '12h ago',
  ),
  ClimbyPost(
    id: 'p09',
    userId: 'kai',
    imageAsset: 'assets/images/post/post_blue_volume_press.jpg',
    caption: 'Press, breathe, reset.',
    category: 'Bouldering',
    timeAgo: '1d ago',
  ),
  ClimbyPost(
    id: 'p10',
    userId: 'iris',
    imageAsset: 'assets/images/post/post_rope_clip_high.jpg',
    caption: 'Clipped smooth at the crux.',
    category: 'Outdoor',
    timeAgo: '1d ago',
  ),
  ClimbyPost(
    id: 'p11',
    userId: 'nora',
    imageAsset: 'assets/images/post/post_purple_wall_crux.jpg',
    caption: 'Purple wall felt wild.',
    category: 'Training',
    timeAgo: '1d ago',
  ),
  ClimbyPost(
    id: 'p12',
    userId: 'rhea',
    imageAsset: 'assets/images/post/post_gym_partner_beta.jpg',
    caption: 'Partner beta changed everything.',
    category: 'Bouldering',
    timeAgo: '2d ago',
  ),
  ClimbyPost(
    id: 'p13',
    userId: 'luca',
    imageAsset: 'assets/images/post/post_overhang_attempt.jpg',
    caption: 'One more overhang attempt.',
    category: 'Training',
    timeAgo: '2d ago',
  ),
  ClimbyPost(
    id: 'p14',
    userId: 'ava',
    imageAsset: 'assets/images/post/post_yellow_wall_send.jpg',
    caption: 'Yellow holds, calm feet.',
    category: 'Indoor',
    timeAgo: '2d ago',
  ),
  ClimbyPost(
    id: 'p15',
    userId: 'theo',
    imageAsset: 'assets/images/post/post_white_wall_pose.jpg',
    caption: 'Rest day turned into drills.',
    category: 'Training',
    timeAgo: '3d ago',
  ),
  ClimbyPost(
    id: 'p16',
    userId: 'alex',
    imageAsset: 'assets/images/post/post_green_volume_cross.jpg',
    caption: 'Cross move stayed honest.',
    category: 'Indoor',
    timeAgo: '3d ago',
  ),
];

const seedSpots = [
  ClimbySpot(
    id: 'summit',
    title: 'Summit Rock Gym',
    location: 'Denver, USA',
    imageAsset: 'assets/images/post/post_indoor_rope_class.jpg',
    rating: '4.9',
    climbers: '8.4K',
    style: 'Indoor',
    description:
        'A busy indoor gym with steep lead walls, bouldering circuits, and reliable evening partner hours.',
  ),
  ClimbySpot(
    id: 'valley',
    title: 'Valley Face',
    location: 'Boulder, USA',
    imageAsset: 'assets/images/post/post_outdoor_limestone.jpg',
    rating: '4.8',
    climbers: '6.2K',
    style: 'Outdoor',
    description:
        'A bright limestone area with approachable sport routes and long views over the valley.',
  ),
  ClimbySpot(
    id: 'campus',
    title: 'Campus Board Lab',
    location: 'Austin, USA',
    imageAsset: 'assets/images/post/post_blue_volume_press.jpg',
    rating: '4.7',
    climbers: '3.1K',
    style: 'Training',
    description:
        'Small training studio focused on finger strength, board circuits, and technique sessions.',
  ),
  ClimbySpot(
    id: 'cave',
    title: 'Red Cave Wall',
    location: 'Portland, USA',
    imageAsset: 'assets/images/post/post_red_cave_match.jpg',
    rating: '4.9',
    climbers: '5.7K',
    style: 'Bouldering',
    description:
        'Powerful indoor cave problems with frequent resets and a strong after-work crowd.',
  ),
];

const seedComments = [
  ClimbyComment(
    id: 'c01',
    postId: 'p01',
    userId: 'ava',
    text: 'See you at the gym!',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'c02',
    postId: 'p01',
    userId: 'kai',
    text: 'That upper section looks amazing.',
    createdLabel: '45m ago',
  ),
  ClimbyComment(
    id: 'c03',
    postId: 'p02',
    userId: 'zoe',
    text: 'Clean jump. Need that beta.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'c04',
    postId: 'p08',
    userId: 'clara',
    text: 'Partner check habits matter.',
    createdLabel: '5h ago',
  ),
];

const climbyCategories = ['All', 'Bouldering', 'Outdoor', 'Training', 'Video'];

const reportReasons = [
  'Spam or Advertising',
  'False Information',
  'Harassment or Bullying',
  'Hate Speech',
  'Other',
];
