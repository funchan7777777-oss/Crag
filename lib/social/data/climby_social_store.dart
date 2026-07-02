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
  static const _legacyFollowRequestsKey = 'climby.follow.requests.v1';
  static const _followingKey = 'climby.following.v1';
  static const _mutualFollowsKey = 'climby.mutual.follows.v1';
  static const _messagesKey = 'climby.messages.v1';
  static const _commentsKey = 'climby.comments.v1';

  SharedPreferences? _prefs;
  bool _loaded = false;
  final Set<String> _reportedKeys = {};
  final Set<String> _blockedUserIds = {};
  final Set<String> _followingUserIds = {};
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
    final legacyFollows = _readStringSet(_legacyFollowRequestsKey);
    _followingUserIds.addAll(legacyFollows);
    _followingUserIds.addAll(_readStringSet(_followingKey));
    _mutualFollowUserIds.addAll(_readStringSet(_mutualFollowsKey));
    _followingUserIds.addAll(_mutualFollowUserIds);
    if (legacyFollows.isNotEmpty) {
      await _writeStringSet(_followingKey, _followingUserIds);
      await _writeStringSet(_legacyFollowRequestsKey, const <String>{});
    }
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
    return isFollowing(userId);
  }

  bool isFollowing(String userId) {
    return _followingUserIds.contains(userId);
  }

  bool isMutualFollow(String userId) {
    return _mutualFollowUserIds.contains(userId);
  }

  bool isUserBlocked(String userId) {
    return _blockedUserIds.contains(userId);
  }

  Future<void> requestFollow(String userId) async {
    await followUser(userId);
  }

  Future<void> followUser(String userId) async {
    if (_blockedUserIds.contains(userId)) {
      return;
    }
    _followingUserIds.add(userId);
    await _writeStringSet(_followingKey, _followingUserIds);
    notifyListeners();
  }

  Future<void> unfollowUser(String userId) async {
    _followingUserIds.remove(userId);
    _mutualFollowUserIds.remove(userId);
    await _writeStringSet(_followingKey, _followingUserIds);
    await _writeStringSet(_legacyFollowRequestsKey, const <String>{});
    await _writeStringSet(_mutualFollowsKey, _mutualFollowUserIds);
    notifyListeners();
  }

  Future<void> toggleFollow(String userId) async {
    if (isFollowing(userId)) {
      await unfollowUser(userId);
      return;
    }
    await followUser(userId);
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
    required this.likeCount,
  });

  final String id;
  final String userId;
  final String imageAsset;
  final String caption;
  final String category;
  final String timeAgo;
  final int likeCount;
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
    likeCount: 128,
  ),
  ClimbyPost(
    id: 'p02',
    userId: 'maya',
    imageAsset: 'assets/images/post/post_boulder_jump.jpg',
    caption: 'Coordination day paid off.',
    category: 'Bouldering',
    timeAgo: '4h ago',
    likeCount: 64,
  ),
  ClimbyPost(
    id: 'p03',
    userId: 'noah',
    imageAsset: 'assets/images/post/post_rope_wall_start.jpg',
    caption: 'Warmup laps before work.',
    category: 'Training',
    timeAgo: '5h ago',
    likeCount: 37,
  ),
  ClimbyPost(
    id: 'p04',
    userId: 'lina',
    imageAsset: 'assets/images/post/post_blue_roof_move.jpg',
    caption: 'Roof sequence finally clicked.',
    category: 'Bouldering',
    timeAgo: '6h ago',
    likeCount: 92,
  ),
  ClimbyPost(
    id: 'p05',
    userId: 'sophia',
    imageAsset: 'assets/images/post/post_finish_smile.jpg',
    caption: 'Clean finish, clean day.',
    category: 'Outdoor',
    timeAgo: '8h ago',
    likeCount: 156,
  ),
  ClimbyPost(
    id: 'p06',
    userId: 'eli',
    imageAsset: 'assets/images/post/post_pink_slab_reach.jpg',
    caption: 'Small feet, big trust.',
    category: 'Training',
    timeAgo: '9h ago',
    likeCount: 48,
  ),
  ClimbyPost(
    id: 'p07',
    userId: 'zoe',
    imageAsset: 'assets/images/post/post_red_cave_match.jpg',
    caption: 'Cave session with fresh tape.',
    category: 'Bouldering',
    timeAgo: '10h ago',
    likeCount: 83,
  ),
  ClimbyPost(
    id: 'p08',
    userId: 'clara',
    imageAsset: 'assets/images/post/post_indoor_rope_class.jpg',
    caption: 'Partner checks before every burn.',
    category: 'Video',
    timeAgo: '12h ago',
    likeCount: 214,
  ),
  ClimbyPost(
    id: 'p09',
    userId: 'kai',
    imageAsset: 'assets/images/post/post_blue_volume_press.jpg',
    caption: 'Press, breathe, reset.',
    category: 'Bouldering',
    timeAgo: '1d ago',
    likeCount: 76,
  ),
  ClimbyPost(
    id: 'p10',
    userId: 'iris',
    imageAsset: 'assets/images/post/post_rope_clip_high.jpg',
    caption: 'Clipped smooth at the crux.',
    category: 'Outdoor',
    timeAgo: '1d ago',
    likeCount: 119,
  ),
  ClimbyPost(
    id: 'p11',
    userId: 'nora',
    imageAsset: 'assets/images/post/post_purple_wall_crux.jpg',
    caption: 'Purple wall felt wild.',
    category: 'Training',
    timeAgo: '1d ago',
    likeCount: 51,
  ),
  ClimbyPost(
    id: 'p12',
    userId: 'rhea',
    imageAsset: 'assets/images/post/post_gym_partner_beta.jpg',
    caption: 'Partner beta changed everything.',
    category: 'Bouldering',
    timeAgo: '2d ago',
    likeCount: 97,
  ),
  ClimbyPost(
    id: 'p13',
    userId: 'luca',
    imageAsset: 'assets/images/post/post_overhang_attempt.jpg',
    caption: 'One more overhang attempt.',
    category: 'Training',
    timeAgo: '2d ago',
    likeCount: 68,
  ),
  ClimbyPost(
    id: 'p14',
    userId: 'ava',
    imageAsset: 'assets/images/post/post_yellow_wall_send.jpg',
    caption: 'Yellow holds, calm feet.',
    category: 'Indoor',
    timeAgo: '2d ago',
    likeCount: 145,
  ),
  ClimbyPost(
    id: 'p15',
    userId: 'theo',
    imageAsset: 'assets/images/post/post_white_wall_pose.jpg',
    caption: 'Rest day turned into drills.',
    category: 'Training',
    timeAgo: '3d ago',
    likeCount: 33,
  ),
  ClimbyPost(
    id: 'p16',
    userId: 'alex',
    imageAsset: 'assets/images/post/post_green_volume_cross.jpg',
    caption: 'Cross move stayed honest.',
    category: 'Indoor',
    timeAgo: '3d ago',
    likeCount: 88,
  ),
];

const seedSpots = [
  ClimbySpot(
    id: 'summit',
    title: 'Summit Rock Gym',
    location: 'Denver, USA',
    imageAsset: 'assets/images/spots/spot_summit_rockville.jpg',
    rating: '4.9',
    climbers: '8.4K',
    style: 'Indoor',
    description:
        'A busy indoor gym with steep lead walls, a serious bouldering cave, and reliable evening partner hours.',
  ),
  ClimbySpot(
    id: 'valley',
    title: 'Valley Face',
    location: 'Boulder, USA',
    imageAsset: 'assets/images/spots/spot_valley_luch.jpg',
    rating: '4.8',
    climbers: '6.2K',
    style: 'Outdoor',
    description:
        'A bright wall circuit with approachable sport-style movement, long traverses, and strong weekend traffic.',
  ),
  ClimbySpot(
    id: 'campus',
    title: 'Campus Board Lab',
    location: 'Austin, USA',
    imageAsset: 'assets/images/spots/spot_campus_tokyo.jpg',
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
    imageAsset: 'assets/images/spots/spot_red_cave_seattle.jpg',
    rating: '4.9',
    climbers: '5.7K',
    style: 'Bouldering',
    description:
        'Powerful indoor cave problems with frequent resets and a strong after-work crowd.',
  ),
  ClimbySpot(
    id: 'harbor',
    title: 'Harbor Lead House',
    location: 'Seattle, USA',
    imageAsset: 'assets/images/spots/spot_harbor_aiguille.jpg',
    rating: '4.8',
    climbers: '4.9K',
    style: 'Lead',
    description:
        'Tall lead lanes, quiet auto-belays, and partner-friendly pacing for weeknight endurance sessions.',
  ),
  ClimbySpot(
    id: 'mesa',
    title: 'Mesa Rope Works',
    location: 'Phoenix, USA',
    imageAsset: 'assets/images/spots/spot_mesa_rei.jpg',
    rating: '4.6',
    climbers: '2.8K',
    style: 'Ropes',
    description:
        'A tall wall space with clean rope lines, intro clinics, and predictable afternoon openings.',
  ),
  ClimbySpot(
    id: 'ridge',
    title: 'North Ridge Yard',
    location: 'Boston, USA',
    imageAsset: 'assets/images/spots/spot_north_ridge_wall.jpg',
    rating: '4.7',
    climbers: '3.6K',
    style: 'Mixed',
    description:
        'Technical face climbs, compact training boards, and varied grades for steady progression.',
  ),
  ClimbySpot(
    id: 'bloc',
    title: 'Bloc Yard',
    location: 'Chicago, USA',
    imageAsset: 'assets/images/spots/spot_bloc_yard_mats.jpg',
    rating: '4.8',
    climbers: '4.2K',
    style: 'Bouldering',
    description:
        'A social bouldering room with clean mats, frequent problem resets, and strong beginner nights.',
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
  ClimbyComment(
    id: 'pc01',
    postId: 'p01',
    userId: 'sophia',
    text: 'That final body position looks so controlled.',
    createdLabel: '38m ago',
  ),
  ClimbyComment(
    id: 'pc02',
    postId: 'p02',
    userId: 'lina',
    text: 'The timing on that coordination move is clean.',
    createdLabel: '51m ago',
  ),
  ClimbyComment(
    id: 'pc03',
    postId: 'p02',
    userId: 'kai',
    text: 'Love how you stayed low before committing to the catch.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'pc04',
    postId: 'p03',
    userId: 'theo',
    text: 'Good call getting rope laps in before the gym gets crowded.',
    createdLabel: '42m ago',
  ),
  ClimbyComment(
    id: 'pc05',
    postId: 'p03',
    userId: 'clara',
    text: 'Those warmup laps look steady. Nice breathing rhythm.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc06',
    postId: 'p03',
    userId: 'iris',
    text: 'I need to copy this before-work routine.',
    createdLabel: '3h ago',
  ),
  ClimbyComment(
    id: 'pc07',
    postId: 'p04',
    userId: 'eli',
    text: 'Roof beta finally clicking is the best feeling.',
    createdLabel: '29m ago',
  ),
  ClimbyComment(
    id: 'pc08',
    postId: 'p04',
    userId: 'zoe',
    text: 'That heel tension looks like it saved the whole sequence.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'pc09',
    postId: 'p05',
    userId: 'maya',
    text: 'Clean finish and still smiling. Strong day.',
    createdLabel: '47m ago',
  ),
  ClimbyComment(
    id: 'pc10',
    postId: 'p05',
    userId: 'ava',
    text: 'That top-out energy is perfect.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc11',
    postId: 'p06',
    userId: 'nora',
    text: 'Tiny feet on slab always make me nervous.',
    createdLabel: '54m ago',
  ),
  ClimbyComment(
    id: 'pc12',
    postId: 'p06',
    userId: 'theo',
    text: 'Trusting that foothold takes real patience.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc13',
    postId: 'p07',
    userId: 'rhea',
    text: 'Fresh tape means the cave session got serious.',
    createdLabel: '25m ago',
  ),
  ClimbyComment(
    id: 'pc14',
    postId: 'p07',
    userId: 'luca',
    text: 'That match looks powerful. Hope the skin survived.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'pc15',
    postId: 'p08',
    userId: 'noah',
    text: 'Belay checks before every burn. Exactly right.',
    createdLabel: '39m ago',
  ),
  ClimbyComment(
    id: 'pc16',
    postId: 'p08',
    userId: 'maya',
    text: 'Partner habits like this make hard sessions feel safer.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc17',
    postId: 'p09',
    userId: 'alex',
    text: 'Press moves always expose whether the feet are working.',
    createdLabel: '33m ago',
  ),
  ClimbyComment(
    id: 'pc18',
    postId: 'p09',
    userId: 'lina',
    text: 'The reset before the press is such a useful cue.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'pc19',
    postId: 'p10',
    userId: 'clara',
    text: 'Smooth clipping at the crux is a skill by itself.',
    createdLabel: '44m ago',
  ),
  ClimbyComment(
    id: 'pc20',
    postId: 'p10',
    userId: 'eli',
    text: 'Nice stance. You looked calm before the clip.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc21',
    postId: 'p11',
    userId: 'zoe',
    text: 'Purple wall problems always look chaotic in the best way.',
    createdLabel: '58m ago',
  ),
  ClimbyComment(
    id: 'pc22',
    postId: 'p11',
    userId: 'kai',
    text: 'That crux probably needs more hip than arm.',
    createdLabel: '3h ago',
  ),
  ClimbyComment(
    id: 'pc23',
    postId: 'p12',
    userId: 'sophia',
    text: 'Good beta partners change the whole session.',
    createdLabel: '27m ago',
  ),
  ClimbyComment(
    id: 'pc24',
    postId: 'p12',
    userId: 'nora',
    text: 'The new foot sequence makes that move look much smoother.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc25',
    postId: 'p13',
    userId: 'maya',
    text: 'One more attempt is always how overhang days go.',
    createdLabel: '46m ago',
  ),
  ClimbyComment(
    id: 'pc26',
    postId: 'p13',
    userId: 'eli',
    text: 'Keep the hips tucked and that reach will feel shorter.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc27',
    postId: 'p14',
    userId: 'ava',
    text: 'Yellow holds and calm feet is a whole mood.',
    createdLabel: '31m ago',
  ),
  ClimbyComment(
    id: 'pc28',
    postId: 'p14',
    userId: 'iris',
    text: 'Looks like a perfect vertical project for footwork.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'pc29',
    postId: 'p15',
    userId: 'theo',
    text: 'Rest day drills still count as rest if you keep it easy, right?',
    createdLabel: '50m ago',
  ),
  ClimbyComment(
    id: 'pc30',
    postId: 'p15',
    userId: 'noah',
    text: 'Technique mileage on rest days pays off later.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'pc31',
    postId: 'p16',
    userId: 'rhea',
    text: 'That cross move looks balanced, not desperate.',
    createdLabel: '36m ago',
  ),
  ClimbyComment(
    id: 'pc32',
    postId: 'p16',
    userId: 'luca',
    text: 'Honest cross moves always force better core tension.',
    createdLabel: '3h ago',
  ),
  ClimbyComment(
    id: 'sc01',
    postId: 'spot:summit',
    userId: 'maya',
    text: 'Evening lead lanes move fast, but the reset cave is worth the wait.',
    createdLabel: '22m ago',
  ),
  ClimbyComment(
    id: 'sc02',
    postId: 'spot:summit',
    userId: 'eli',
    text:
        'Good partner scene after work. Plenty of people warming up around 6.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'sc03',
    postId: 'spot:summit',
    userId: 'clara',
    text: 'Staff keeps the rope area calm, which makes projecting much easier.',
    createdLabel: '3h ago',
  ),
  ClimbyComment(
    id: 'sc04',
    postId: 'spot:valley',
    userId: 'sophia',
    text: 'Best circuit if you want footwork practice without feeling rushed.',
    createdLabel: '36m ago',
  ),
  ClimbyComment(
    id: 'sc05',
    postId: 'spot:valley',
    userId: 'alex',
    text: 'The moderate wall has clean movement and a nice social pace.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'sc06',
    postId: 'spot:valley',
    userId: 'rhea',
    text: 'Weekend mornings are packed, but late afternoon feels perfect.',
    createdLabel: '5h ago',
  ),
  ClimbyComment(
    id: 'sc07',
    postId: 'spot:campus',
    userId: 'kai',
    text:
        'Board sessions here are compact and honest. Bring skin and patience.',
    createdLabel: '41m ago',
  ),
  ClimbyComment(
    id: 'sc08',
    postId: 'spot:campus',
    userId: 'nora',
    text: 'Great place to repeat drills because the layout is easy to read.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'sc09',
    postId: 'spot:campus',
    userId: 'theo',
    text: 'Small room, strong energy. I like using it before rope days.',
    createdLabel: '6h ago',
  ),
  ClimbyComment(
    id: 'sc10',
    postId: 'spot:cave',
    userId: 'lina',
    text: 'Powerful problems and good padding. The steep set stays fresh.',
    createdLabel: '18m ago',
  ),
  ClimbyComment(
    id: 'sc11',
    postId: 'spot:cave',
    userId: 'noah',
    text: 'Bring a spotter for the harder cave climbs. The crowd is helpful.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'sc12',
    postId: 'spot:cave',
    userId: 'zoe',
    text: 'Coordination problems here feel playful without getting gimmicky.',
    createdLabel: '4h ago',
  ),
  ClimbyComment(
    id: 'sc13',
    postId: 'spot:harbor',
    userId: 'eli',
    text: 'Tall routes, mellow vibe, and easy belay partner conversations.',
    createdLabel: '28m ago',
  ),
  ClimbyComment(
    id: 'sc14',
    postId: 'spot:harbor',
    userId: 'iris',
    text: 'Auto-belays are useful when you arrive before your partner.',
    createdLabel: '2h ago',
  ),
  ClimbyComment(
    id: 'sc15',
    postId: 'spot:mesa',
    userId: 'iris',
    text: 'Clinic nights are beginner-friendly and not awkward.',
    createdLabel: '52m ago',
  ),
  ClimbyComment(
    id: 'sc16',
    postId: 'spot:mesa',
    userId: 'ava',
    text:
        'Good rope spacing. I never feel like I am climbing into another team.',
    createdLabel: '3h ago',
  ),
  ClimbyComment(
    id: 'sc17',
    postId: 'spot:ridge',
    userId: 'theo',
    text: 'Technical wall is the highlight. Small holds, smart sequences.',
    createdLabel: '1h ago',
  ),
  ClimbyComment(
    id: 'sc18',
    postId: 'spot:ridge',
    userId: 'clara',
    text: 'A good spot for quiet mileage when the bigger gyms are packed.',
    createdLabel: '4h ago',
  ),
  ClimbyComment(
    id: 'sc19',
    postId: 'spot:bloc',
    userId: 'kai',
    text: 'Fresh mats, clear tags, and a friendly beginner night.',
    createdLabel: '24m ago',
  ),
  ClimbyComment(
    id: 'sc20',
    postId: 'spot:bloc',
    userId: 'nora',
    text: 'The reset style is fun: enough comp movement without chaos.',
    createdLabel: '2h ago',
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
