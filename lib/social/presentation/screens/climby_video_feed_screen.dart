import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/climby_social_store.dart';
import 'climby_create_post_screen.dart';
import 'climby_home_screen.dart';
import 'moderation_report_screen.dart';

class ClimbyVideoFeedScreen extends StatefulWidget {
  const ClimbyVideoFeedScreen({super.key});

  @override
  State<ClimbyVideoFeedScreen> createState() => _ClimbyVideoFeedScreenState();
}

class _ClimbyVideoFeedScreenState extends State<ClimbyVideoFeedScreen> {
  final _store = ClimbySocialStore.instance;
  final _pageController = PageController();
  final Set<String> _likedIds = {};
  String _activeFilter = 'For you';
  String? _burstId;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<ClimbyVideoClip> get _visibleVideos {
    final videos = switch (_activeFilter) {
      'Following' =>
        climbyVideoClips
            .where((clip) => _store.isFollowing(clip.userId))
            .toList(growable: false),
      'Popular' => [
        ...climbyVideoClips,
      ]..sort((a, b) => b.likeCount.compareTo(a.likeCount)),
      _ => climbyVideoClips,
    };
    return videos.isEmpty ? climbyVideoClips.take(3).toList() : videos;
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _like(ClimbyVideoClip clip) {
    setState(() {
      _likedIds.add(clip.id);
      _burstId = clip.id;
    });
    Future<void>.delayed(const Duration(milliseconds: 620), () {
      if (mounted && _burstId == clip.id) {
        setState(() => _burstId = null);
      }
    });
  }

  void _toggleLike(ClimbyVideoClip clip) {
    if (_likedIds.contains(clip.id)) {
      setState(() => _likedIds.remove(clip.id));
      return;
    }
    _like(clip);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final videos = _visibleVideos;
        return ColoredBox(
          color: const Color(0xFF0D1112),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final clip = videos[index];
                  return _VideoFeedPage(
                    clip: clip,
                    store: _store,
                    liked: _likedIds.contains(clip.id),
                    showBurst: _burstId == clip.id,
                    onLike: () => _like(clip),
                    onToggleLike: () => _toggleLike(clip),
                    onOpen: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ClimbyVideoWatchScreen(
                          clip: clip,
                          store: _store,
                          initiallyLiked: _likedIds.contains(clip.id),
                        ),
                      ),
                    ),
                    onReport: () => openModerationScreen(
                      context: context,
                      store: _store,
                      target: ModerationTarget(
                        kind: ModerationKind.post,
                        key: 'video:${clip.id}',
                        title: clip.title,
                        userId: clip.userId,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 16,
                right: 16,
                top: topInset + 8,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/Campus.png',
                      width: 98,
                      height: 33,
                      fit: BoxFit.contain,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CreatePostScreen(store: _store),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/Onsight.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: topInset + 54,
                child: _VideoFilterRail(
                  active: _activeFilter,
                  onChanged: _setFilter,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: _VideoReplyBar(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoFeedPage extends StatelessWidget {
  const _VideoFeedPage({
    required this.clip,
    required this.store,
    required this.liked,
    required this.showBurst,
    required this.onLike,
    required this.onToggleLike,
    required this.onOpen,
    required this.onReport,
  });

  final ClimbyVideoClip clip;
  final ClimbySocialStore store;
  final bool liked;
  final bool showBurst;
  final VoidCallback onLike;
  final VoidCallback onToggleLike;
  final VoidCallback onOpen;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final user = store.userById(clip.userId) ?? seedUsers.first;
    final likeCount = clip.likeCount + (liked ? 1 : 0);

    return GestureDetector(
      onTap: onOpen,
      onDoubleTap: onLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(clip.coverAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.82),
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: showBurst ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Image.asset(
                'assets/images/Hangboard.png',
                width: 128,
                height: 128,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 72,
            bottom: 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          UserProfileScreen(store: store, user: user),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _VideoAvatar(asset: user.avatarAsset, size: 42),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            clip.duration,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  clip.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 86,
            child: Column(
              children: [
                _VideoSideButton(
                  asset: liked
                      ? 'assets/images/Hangboard.png'
                      : 'assets/images/Edge.png',
                  label: likeCount.toString(),
                  onTap: onToggleLike,
                ),
                const SizedBox(height: 12),
                _VideoSideButton(
                  asset: 'assets/images/Beacon.png',
                  label: 'Report',
                  onTap: onReport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoFilterRail extends StatelessWidget {
  const _VideoFilterRail({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const filters = ['For you', 'Following', 'Popular'];
    return Row(
      children: [
        for (final filter in filters) ...[
          GestureDetector(
            onTap: () => onChanged(filter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filter,
                  style: TextStyle(
                    color: active == filter
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.56),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: active == filter ? 34 : 0,
                  height: 3,
                  child: const ColoredBox(color: Color(0xFFD6FF00)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
        ],
      ],
    );
  }
}

class _VideoSideButton extends StatelessWidget {
  const _VideoSideButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(asset, width: 34, height: 34, fit: BoxFit.contain),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoReplyBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2021).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Please enter...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.42),
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          Image.asset(
            'assets/images/Knot.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class ClimbyVideoWatchScreen extends StatefulWidget {
  const ClimbyVideoWatchScreen({
    required this.clip,
    required this.store,
    required this.initiallyLiked,
    super.key,
  });

  final ClimbyVideoClip clip;
  final ClimbySocialStore store;
  final bool initiallyLiked;

  @override
  State<ClimbyVideoWatchScreen> createState() => _ClimbyVideoWatchScreenState();
}

class _ClimbyVideoWatchScreenState extends State<ClimbyVideoWatchScreen> {
  late final VideoPlayerController _controller;
  late bool _liked;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.initiallyLiked;
    _controller = VideoPlayerController.asset(widget.clip.videoAsset)
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final user = widget.store.userById(widget.clip.userId) ?? seedUsers.first;
    final likeCount = widget.clip.likeCount + (_liked ? 1 : 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(widget.clip.coverAsset, fit: BoxFit.cover),
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFD6FF00)),
                ),
              ],
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.36),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: topInset + 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => openModerationScreen(
                    context: context,
                    store: widget.store,
                    target: ModerationTarget(
                      kind: ModerationKind.post,
                      key: 'video:${widget.clip.id}',
                      title: widget.clip.title,
                      userId: widget.clip.userId,
                    ),
                  ),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: bottomInset + 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          UserProfileScreen(store: widget.store, user: user),
                    ),
                  ),
                  child: Row(
                    children: [
                      _VideoAvatar(asset: user.avatarAsset, size: 42),
                      const SizedBox(width: 9),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _liked = !_liked),
                        child: Row(
                          children: [
                            Image.asset(
                              _liked
                                  ? 'assets/images/Hangboard.png'
                                  : 'assets/images/Edge.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likeCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.clip.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    if (!_ready) {
                      return;
                    }
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2021).withValues(alpha: 0.82),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _ready && _controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoAvatar extends StatelessWidget {
  const _VideoAvatar({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class ClimbyVideoClip {
  const ClimbyVideoClip({
    required this.id,
    required this.userId,
    required this.videoAsset,
    required this.coverAsset,
    required this.title,
    required this.duration,
    required this.likeCount,
  });

  final String id;
  final String userId;
  final String videoAsset;
  final String coverAsset;
  final String title;
  final String duration;
  final int likeCount;
}

const climbyVideoClips = [
  ClimbyVideoClip(
    id: 'v01',
    userId: 'alex',
    videoAsset: 'assets/videos/slab_rope_sequence.mp4',
    coverAsset: 'assets/images/video_covers/slab_rope_sequence.jpg',
    title: 'Smooth Slab Climb Technique',
    duration: '00:29',
    likeCount: 38,
  ),
  ClimbyVideoClip(
    id: 'v02',
    userId: 'maya',
    videoAsset: 'assets/videos/indoor_roof_project.mp4',
    coverAsset: 'assets/images/video_covers/indoor_roof_project.jpg',
    title: 'Roof project finally linked',
    duration: '00:27',
    likeCount: 57,
  ),
  ClimbyVideoClip(
    id: 'v03',
    userId: 'noah',
    videoAsset: 'assets/videos/campus_board_drill.mp4',
    coverAsset: 'assets/images/video_covers/campus_board_drill.jpg',
    title: 'Campus board contact drill',
    duration: '00:36',
    likeCount: 44,
  ),
  ClimbyVideoClip(
    id: 'v04',
    userId: 'lina',
    videoAsset: 'assets/videos/lead_wall_warmup.mp4',
    coverAsset: 'assets/images/video_covers/lead_wall_warmup.jpg',
    title: 'Lead wall warmup sequence',
    duration: '00:42',
    likeCount: 49,
  ),
  ClimbyVideoClip(
    id: 'v05',
    userId: 'sophia',
    videoAsset: 'assets/videos/boulder_volume_comp.mp4',
    coverAsset: 'assets/images/video_covers/boulder_volume_comp.jpg',
    title: 'Volume coordination run',
    duration: '00:09',
    likeCount: 63,
  ),
  ClimbyVideoClip(
    id: 'v06',
    userId: 'eli',
    videoAsset: 'assets/videos/outdoor_crux_beta.mp4',
    coverAsset: 'assets/images/video_covers/outdoor_crux_beta.jpg',
    title: 'Outdoor crux beta changed everything',
    duration: '00:06',
    likeCount: 41,
  ),
  ClimbyVideoClip(
    id: 'v07',
    userId: 'zoe',
    videoAsset: 'assets/videos/slab_balance_move.mp4',
    coverAsset: 'assets/images/video_covers/slab_balance_move.jpg',
    title: 'Slab balance without panic',
    duration: '00:13',
    likeCount: 52,
  ),
  ClimbyVideoClip(
    id: 'v08',
    userId: 'kai',
    videoAsset: 'assets/videos/dyno_coordination_run.mp4',
    coverAsset: 'assets/images/video_covers/dyno_coordination_run.jpg',
    title: 'Dyno timing in two tries',
    duration: '00:13',
    likeCount: 46,
  ),
  ClimbyVideoClip(
    id: 'v09',
    userId: 'rhea',
    videoAsset: 'assets/videos/overhang_power_link.mp4',
    coverAsset: 'assets/images/video_covers/overhang_power_link.jpg',
    title: 'Overhang power link and shakeout',
    duration: '00:13',
    likeCount: 59,
  ),
];
