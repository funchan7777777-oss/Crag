import 'dart:async';

import 'package:flutter/material.dart';

import '../../../field_notes/presentation/screens/crag_home_tabs_screen.dart';
import '../../data/climby_social_store.dart';
import 'climby_chat_screen.dart';
import 'climby_create_post_screen.dart';
import 'climby_video_call_screen.dart';
import 'moderation_report_screen.dart';

class ClimbyHomeScreen extends StatefulWidget {
  const ClimbyHomeScreen({super.key});

  @override
  State<ClimbyHomeScreen> createState() => _ClimbyHomeScreenState();
}

class _ClimbyHomeScreenState extends State<ClimbyHomeScreen> {
  final _store = ClimbySocialStore.instance;
  String _activeCategory = 'All';
  Timer? _heroPostTimer;
  int _heroPostIndex = 0;

  @override
  void initState() {
    super.initState();
    _store.load();
    _heroPostTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) {
        return;
      }
      final posts = _store.visiblePosts(category: _activeCategory);
      if (posts.length < 2) {
        return;
      }
      setState(() {
        _heroPostIndex = (_heroPostIndex + 1) % posts.length;
      });
    });
  }

  @override
  void dispose() {
    _heroPostTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1112),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Clip.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          AnimatedBuilder(
            animation: _store,
            builder: (context, _) {
              final posts = _store.visiblePosts(category: _activeCategory);
              final heroPostIndex = posts.isEmpty
                  ? 0
                  : _heroPostIndex % posts.length;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: topInset > 14 ? topInset - 14 : 0),
                  ),
                  SliverToBoxAdapter(
                    child: _HomeHero(
                      store: _store,
                      posts: posts,
                      activePostIndex: heroPostIndex,
                    ),
                  ),
                  SliverToBoxAdapter(child: _FeatureDock(store: _store)),
                  SliverToBoxAdapter(child: _HomeActionGrid(store: _store)),
                  SliverToBoxAdapter(
                    child: _CategoryRail(
                      active: _activeCategory,
                      onChanged: (category) {
                        setState(() {
                          _activeCategory = category;
                          _heroPostIndex = 0;
                        });
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 112),
                    sliver: posts.isEmpty
                        ? const SliverToBoxAdapter(child: _EmptyFeedPanel())
                        : SliverGrid.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.62,
                                ),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return _PostTile(
                                key: ValueKey(posts[index].id),
                                store: _store,
                                post: posts[index],
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD6FF00),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () => _push(context, CreatePostScreen(store: _store)),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.store,
    required this.posts,
    required this.activePostIndex,
  });

  final ClimbySocialStore store;
  final List<ClimbyPost> posts;
  final int activePostIndex;

  @override
  Widget build(BuildContext context) {
    final sourcePosts = posts.isNotEmpty ? posts : store.visiblePosts();
    final highlight = sourcePosts.isNotEmpty
        ? sourcePosts[activePostIndex % sourcePosts.length]
        : seedPosts.first;
    final user = store.userById(highlight.userId) ?? seedUsers.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SizedBox(
        height: 184,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -8,
              top: -46,
              child: GestureDetector(
                onTap: () => _openPost(context, store, highlight),
                child: SizedBox(
                  width: 198,
                  height: 236,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 24,
                        top: 54,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: SizedBox(
                            width: 164,
                            height: 150,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 24,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 320,
                                        ),
                                        switchInCurve: Curves.easeOutCubic,
                                        switchOutCurve: Curves.easeInCubic,
                                        child: Image.asset(
                                          highlight.imageAsset,
                                          key: ValueKey(highlight.id),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 68,
                        child: Image.asset(
                          'assets/images/Pocket.png',
                          width: 74,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 22,
              child: Image.asset(
                'assets/images/Campus.png',
                width: 98,
                height: 33,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 18,
              top: 70,
              right: 164,
              child: GestureDetector(
                onTap: () => _openPost(context, store, highlight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Climbing Picks",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(
                      width: 142,
                      height: 2,
                      child: ColoredBox(color: Color(0xFFFF6A1D)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      highlight.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _openProfile(context, store, user),
                      child: Row(
                        children: [
                          _Avatar(asset: user.avatarAsset, size: 22),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              user.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureDock extends StatelessWidget {
  const _FeatureDock({required this.store});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final features = [
      _HomeFeature(
        label: 'Climbing\nSpots',
        asset: 'assets/images/Dyno.png',
        onTap: () => _push(context, PopularSpotsScreen(store: store)),
      ),
      _HomeFeature(
        label: 'AI Coach',
        asset: 'assets/images/Quest.png',
        onTap: () => _push(context, const AiCoachScreen()),
      ),
      _HomeFeature(
        label: 'Videos',
        asset: 'assets/images/Beta.png',
        onTap: () => CragTabSwitcher.of(context)?.selectTab(1),
      ),
      _HomeFeature(
        label: 'Community',
        asset: 'assets/images/Nut.png',
        onTap: () => _push(
          context,
          TrendingPostsScreen(store: store, title: 'Community'),
        ),
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151A1B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: const Color(0xFF667174), width: 1.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: features,
      ),
    );
  }
}

class _HomeFeature extends StatelessWidget {
  const _HomeFeature({
    required this.label,
    required this.asset,
    required this.onTap,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 51,
                height: 48,
                child: Image.asset(asset, fit: BoxFit.fill),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionGrid extends StatelessWidget {
  const _HomeActionGrid({required this.store});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: 173,
            height: 142,
            child: GestureDetector(
              onTap: () => _push(context, PartnerListScreen(store: store)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/Flow.png',
                  width: 173,
                  height: 142,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 171,
            child: Column(
              children: [
                _ImagePillButton(
                  asset: 'assets/images/Wall.png',
                  onTap: () => _push(
                    context,
                    TrendingPostsScreen(store: store, title: 'Trending'),
                  ),
                ),
                const SizedBox(height: 12),
                _ImagePillButton(
                  asset: 'assets/images/Valley.png',
                  onTap: () => _push(context, PopularSpotsScreen(store: store)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePillButton extends StatelessWidget {
  const _ImagePillButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(asset, width: 171, height: 64, fit: BoxFit.fill),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: climbyCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final category = climbyCategories[index];
          final selected = category == active;
          return GestureDetector(
            onTap: () => onChanged(category),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.58),
                    fontSize: selected ? 18 : 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                if (selected)
                  Image.asset(
                    'assets/images/Helmet.png',
                    width: 28,
                    height: 5,
                    fit: BoxFit.fill,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PostTile extends StatefulWidget {
  const _PostTile({required this.store, required this.post, super.key});

  final ClimbySocialStore store;
  final ClimbyPost post;

  @override
  State<_PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<_PostTile> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.store.userById(widget.post.userId);
    final likeCount = widget.post.likeCount + (_liked ? 1 : 0);
    if (user == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _openPost(context, widget.store, widget.post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                widget.post.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openProfile(context, widget.store, user),
                child: Row(
                  children: [
                    _Avatar(asset: user.avatarAsset, size: 24),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 58,
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _liked = !_liked),
                child: Image.asset(
                  _liked
                      ? 'assets/images/Hangboard.png'
                      : 'assets/images/Edge.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                likeCount.toString(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PopularSpotsScreen extends StatelessWidget {
  const PopularSpotsScreen({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    return _CliffScreenFrame(
      title: 'Popular Spots',
      backgroundAsset: 'assets/images/Vibe.png',
      backgroundFit: BoxFit.fill,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final spots = store.visibleSpots;
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 68,
              16,
              24,
            ),
            itemCount: spots.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final spot = spots[index];
              return _SpotCard(
                spot: spot,
                onTap: () =>
                    _push(context, SpotDetailScreen(store: store, spot: spot)),
                onModerate: () => openModerationScreen(
                  context: context,
                  store: store,
                  target: ModerationTarget(
                    kind: ModerationKind.spot,
                    key: 'spot:${spot.id}',
                    title: spot.title,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({
    required this.spot,
    required this.onTap,
    required this.onModerate,
  });

  final ClimbySpot spot;
  final VoidCallback onTap;
  final VoidCallback onModerate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3A4243),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  spot.imageAsset,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spot.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onModerate,
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    _SpotMetric(
                      iconAsset: 'assets/images/Traverse.png',
                      text: spot.location,
                    ),
                    _SpotMetric(
                      iconAsset: 'assets/images/Chat.png',
                      text: '${spot.climbers} Climbers',
                    ),
                    _SpotMetric(
                      icon: Icons.groups_rounded,
                      text: '${spot.rating} · ${spot.style}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -2,
          top: 20,
          child: GestureDetector(
            onTap: onTap,
            child: Image.asset(
              'assets/images/Pitch.png',
              width: 72,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotMetric extends StatelessWidget {
  const _SpotMetric({required this.text, this.iconAsset, this.icon});

  final String text;
  final String? iconAsset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          if (iconAsset != null)
            Image.asset(iconAsset!, width: 16, height: 16, fit: BoxFit.contain)
          else
            Icon(icon, size: 16, color: Colors.lightBlue.shade100),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpotDetailScreen extends StatelessWidget {
  const SpotDetailScreen({required this.store, required this.spot, super.key});

  final ClimbySocialStore store;
  final ClimbySpot spot;

  @override
  Widget build(BuildContext context) {
    return _CliffScreenFrame(
      title: spot.title,
      actions: [
        IconButton(
          onPressed: () => openModerationScreen(
            context: context,
            store: store,
            target: ModerationTarget(
              kind: ModerationKind.spot,
              key: 'spot:${spot.id}',
              title: spot.title,
            ),
          ),
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
        ),
      ],
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final comments = store.commentsFor('spot:${spot.id}');
          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 64,
              16,
              28,
            ),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 292,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(spot.imageAsset, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spot.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _DetailMetric(
                                  asset: 'assets/images/Traverse.png',
                                  text: spot.location,
                                ),
                                _DetailMetric(
                                  asset: 'assets/images/Chat.png',
                                  text: '${spot.climbers} Climbers',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _SpotDetailStat(
                    label: 'Rating',
                    value: spot.rating,
                    icon: Icons.star_rounded,
                  ),
                  const SizedBox(width: 10),
                  _SpotDetailStat(
                    label: 'Style',
                    value: spot.style,
                    icon: Icons.terrain_rounded,
                  ),
                  const SizedBox(width: 10),
                  _SpotDetailStat(
                    label: 'Crowd',
                    value: spot.climbers,
                    icon: Icons.groups_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SpotInfoPanel(
                title: 'About this spot',
                child: Text(
                  spot.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.38,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _SpotInfoPanel(
                title: 'Good for',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SpotTag(text: 'Partner meetups'),
                    _SpotTag(text: 'Fresh resets'),
                    _SpotTag(text: 'Evening sessions'),
                    _SpotTag(text: 'Skill progression'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SpotInfoPanel(
                title: 'Comments',
                child: comments.isEmpty
                    ? Text(
                        'No visible comments yet.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      )
                    : Column(
                        children: [
                          for (final comment in comments)
                            _CommentRow(store: store, comment: comment),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpotDetailStat extends StatelessWidget {
  const _SpotDetailStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151A1B).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFD6FF00), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotInfoPanel extends StatelessWidget {
  const _SpotInfoPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151A1B).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SpotTag extends StatelessWidget {
  const _SpotTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD6FF00).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFD6FF00).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD6FF00),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.asset, required this.text});

  final String asset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 18, height: 18, fit: BoxFit.contain),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class PartnerListScreen extends StatelessWidget {
  const PartnerListScreen({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    return _CliffScreenFrame(
      title: 'Climbing Partners',
      backgroundAsset: 'assets/images/Vibe.png',
      backgroundFit: BoxFit.fill,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final users = store.visibleUsers;
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 68,
              16,
              24,
            ),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _PartnerCard(store: store, user: users[index]);
            },
          );
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.store, required this.user});

  final ClimbySocialStore store;
  final ClimbyUser user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openProfile(context, store, user),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF151A1B).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                user.avatarAsset,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _ProfilePill(
                        text:
                            '${user.gender == ClimbyGender.male ? '♂' : '♀'} ${user.age}',
                      ),
                      _ProfilePill(text: user.city),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => openModerationScreen(
                    context: context,
                    store: store,
                    target: ModerationTarget(
                      kind: ModerationKind.user,
                      key: 'user:${user.id}',
                      title: user.name,
                      userId: user.id,
                    ),
                  ),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: _FollowToggleButton(
                    store: store,
                    user: user,
                    compact: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowToggleButton extends StatelessWidget {
  const _FollowToggleButton({
    required this.store,
    required this.user,
    this.compact = false,
  });

  final ClimbySocialStore store;
  final ClimbyUser user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final following = store.isFollowing(user.id);
    return SizedBox(
      height: compact ? 34 : 44,
      width: compact ? 94 : 168,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: following
              ? const Color(0xFF202728)
              : const Color(0xFFD6FF00),
          foregroundColor: following ? const Color(0xFFD6FF00) : Colors.black,
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compact ? 9 : 12),
            side: BorderSide(
              color: following
                  ? const Color(0xFFD6FF00).withValues(alpha: 0.8)
                  : const Color(0xFFD6FF00),
            ),
          ),
        ),
        onPressed: () => store.toggleFollow(user.id),
        child: Text(
          following ? 'Following' : 'Follow',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: compact ? 11 : 13,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class TrendingPostsScreen extends StatefulWidget {
  const TrendingPostsScreen({
    required this.store,
    required this.title,
    this.category,
    super.key,
  });

  final ClimbySocialStore store;
  final String title;
  final String? category;

  @override
  State<TrendingPostsScreen> createState() => _TrendingPostsScreenState();
}

class _TrendingPostsScreenState extends State<TrendingPostsScreen> {
  Timer? _liveTimer;
  int _liveTick = 0;

  @override
  void initState() {
    super.initState();
    _liveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _liveTick += 1;
      });
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  int _postNumber(ClimbyPost post) {
    return int.tryParse(post.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  int _liveHotScore(ClimbyPost post) {
    final number = _postNumber(post);
    return post.likeCount + ((number * 17 + _liveTick * 19) % 71);
  }

  List<ClimbyPost> _liveSortedPosts(List<ClimbyPost> posts) {
    final ordered = [...posts];
    ordered.sort((a, b) => _liveHotScore(b).compareTo(_liveHotScore(a)));
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    return _CliffScreenFrame(
      title: widget.title,
      backgroundAsset: 'assets/images/Vibe.png',
      backgroundFit: BoxFit.fill,
      child: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          final posts = _liveSortedPosts(
            widget.store.visiblePosts(category: widget.category),
          );
          final topPadding = MediaQuery.paddingOf(context).top + 68;

          if (posts.isEmpty) {
            return ListView(
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 24),
              children: const [_EmptyFeedPanel()],
            );
          }

          final featured = posts.first;
          final gridPosts = posts.length > 1
              ? posts.sublist(1)
              : <ClimbyPost>[];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, topPadding, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _TrendingHeroCard(
                      key: ValueKey('${featured.id}-$_liveTick'),
                      store: widget.store,
                      post: featured,
                      rank: 1,
                      hotScore: _liveHotScore(featured),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _TrendingPulseStrip(
                    totalPosts: posts.length,
                    liveScore: _liveHotScore(featured),
                    topLikes: featured.likeCount,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Text(
                        'Hot Feed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 42,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6A1A),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (gridPosts.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.6,
                        ),
                    itemCount: gridPosts.length,
                    itemBuilder: (context, index) {
                      final post = gridPosts[index];
                      return _PostTile(
                        key: ValueKey(post.id),
                        store: widget.store,
                        post: post,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TrendingHeroCard extends StatelessWidget {
  const _TrendingHeroCard({
    required this.store,
    required this.post,
    required this.rank,
    required this.hotScore,
    super.key,
  });

  final ClimbySocialStore store;
  final ClimbyPost post;
  final int rank;
  final int hotScore;

  @override
  Widget build(BuildContext context) {
    final user = store.userById(post.userId);
    if (user == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _openPost(context, store, post),
      child: Container(
        height: 232,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD9FF00).withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(post.imageAsset, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.34),
                      Colors.black.withValues(alpha: 0.86),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.64),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: const Color(0xFFD9FF00).withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD9FF00),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'LIVE #$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6A1A),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$hotScore heat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _openProfile(context, store, user),
                          child: Row(
                            children: [
                              _Avatar(asset: user.avatarAsset, size: 30),
                              const SizedBox(width: 8),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          'assets/images/Hangboard.png',
                          width: 21,
                          height: 21,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          post.likeCount.toString(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.84),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendingPulseStrip extends StatelessWidget {
  const _TrendingPulseStrip({
    required this.totalPosts,
    required this.liveScore,
    required this.topLikes,
  });

  final int totalPosts;
  final int liveScore;
  final int topLikes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TrendingStatPill(
            label: 'Live Heat',
            value: liveScore.toString(),
            color: const Color(0xFFD9FF00),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TrendingStatPill(
            label: 'Posts',
            value: totalPosts.toString(),
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TrendingStatPill(
            label: 'Likes',
            value: topLikes.toString(),
            color: const Color(0xFFFF6A1A),
          ),
        ),
      ],
    );
  }
}

class _TrendingStatPill extends StatelessWidget {
  const _TrendingStatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151A1B).withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({required this.store, required this.post, super.key});

  final ClimbySocialStore store;
  final ClimbyPost post;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _liked = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    await widget.store.addComment(
      postId: widget.post.id,
      text: _commentController.text,
    );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.store.userById(widget.post.userId);

    return _CliffScreenFrame(
      title: 'Post',
      actions: [
        IconButton(
          onPressed: () => openModerationScreen(
            context: context,
            store: widget.store,
            target: ModerationTarget(
              kind: ModerationKind.post,
              key: 'post:${widget.post.id}',
              title: widget.post.caption,
              userId: widget.post.userId,
            ),
          ),
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
        ),
      ],
      bottom: _CommentComposer(
        controller: _commentController,
        onSend: _addComment,
        showLeading: false,
      ),
      child: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          final comments = widget.store.commentsFor(widget.post.id);
          final likeCount = widget.post.likeCount + (_liked ? 1 : 0);
          return ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 68,
              16,
              96,
            ),
            children: [
              if (user != null)
                GestureDetector(
                  onTap: () => _openProfile(context, widget.store, user),
                  child: Row(
                    children: [
                      _Avatar(asset: user.avatarAsset, size: 54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              widget.post.timeAgo,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.62),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                widget.post.caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  widget.post.imageAsset,
                  height: 360,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _liked = !_liked),
                    child: Image.asset(
                      _liked
                          ? 'assets/images/Hangboard.png'
                          : 'assets/images/Edge.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    likeCount.toString(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final comment in comments)
                _CommentRow(store: widget.store, comment: comment),
            ],
          );
        },
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.store, required this.comment});

  final ClimbySocialStore store;
  final ClimbyComment comment;

  @override
  Widget build(BuildContext context) {
    final user = store.userById(comment.userId) ?? currentUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: user.id == currentUser.id
                ? null
                : () => _openProfile(context, store, user),
            child: _Avatar(asset: user.avatarAsset, size: 42),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: user.id == currentUser.id
                      ? null
                      : () => _openProfile(context, store, user),
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          if (user.id != currentUser.id)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => openModerationScreen(
                context: context,
                store: store,
                target: ModerationTarget(
                  kind: ModerationKind.comment,
                  key: 'comment:${comment.id}',
                  title: comment.text,
                  userId: comment.userId,
                ),
              ),
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.onSend,
    this.showLeading = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset + 14,
      child: Container(
        height: 54,
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2021).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Row(
          children: [
            if (showLeading) ...[
              Image.asset(
                'assets/images/Campus.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                controller: controller,
                cursorColor: const Color(0xFFD6FF00),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  hintText: 'Please enter...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onSend,
              icon: Image.asset(
                'assets/images/Knot.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({required this.store, required this.user, super.key});

  final ClimbySocialStore store;
  final ClimbyUser user;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final userPosts = store
        .visiblePosts()
        .where((post) => post.userId == user.id)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF244D00),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/Invite.png', fit: BoxFit.fill),
              Positioned(
                left: 0,
                right: 0,
                top: topInset + 210,
                bottom: 0,
                child: Image.asset(
                  user.avatarAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: topInset + 176,
                child: Center(
                  child: Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.94),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.34),
                          blurRadius: 20,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: _Avatar(asset: user.avatarAsset, size: 80),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
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
                        store: store,
                        target: ModerationTarget(
                          kind: ModerationKind.user,
                          key: 'user:${user.id}',
                          title: user.name,
                          userId: user.id,
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
                left: 20,
                right: 20,
                bottom: MediaQuery.paddingOf(context).bottom + 22,
                child: Column(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ProfilePill(
                          text:
                              '${user.gender == ClimbyGender.male ? '♂' : '♀'} ${user.age}',
                        ),
                        _ProfilePill(text: user.city),
                        _ProfilePill(text: user.specialty),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FollowToggleButton(store: store, user: user),
                    const SizedBox(height: 12),
                    _ProfilePostStrip(store: store, posts: userPosts),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _push(
                              context,
                              ClimbyChatScreen(store: store, user: user),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/Gear.png',
                                height: 56,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openVideoCall(context, store, user),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/Scout.png',
                                height: 56,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _ProfilePostStrip extends StatelessWidget {
  const _ProfilePostStrip({required this.store, required this.posts});

  final ClimbySocialStore store;
  final List<ClimbyPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(
          'No posts yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      );
    }

    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final post = posts[index];
          return GestureDetector(
            onTap: () => _openPost(context, store, post),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                post.imageAsset,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _controller = TextEditingController();
  final List<_AiCoachMessage> _notes = [
    const _AiCoachMessage(
      text:
          'Hi, I am your AI Climbing Coach. Ready to improve your climbing skills today?',
      sentByMe: false,
    ),
  ];
  final List<String> _coachReplies = const [
    'Start with one movement cue: quiet feet. Climb an easy route and make every foot placement silent before you try harder grades.',
    'For your next session, warm up on three climbs below your limit, then choose one project and give it three focused attempts with long rests.',
    'If the crux feels powerful, slow the move before it. Most failed attempts happen because the setup position is rushed.',
    'Try this drill: pause for two seconds before each hand move. It forces better balance and shows where your feet are doing too little.',
    'For overhangs, keep your hips close and pull with your toes before you reach. Think tension first, reach second.',
    'If your forearms pump out quickly, add route-reading breaks. Plan clipping stances and shake points before you leave the ground.',
    'When a move feels impossible, change only one variable per attempt: foot position, hip angle, or hand timing. That keeps beta clear.',
    'A good training day is not maximum effort all day. Mix skill work, one hard block, then finish with easy volume.',
    'For slabs, trust the shoe and stand taller. Bent arms often mean you are pulling away from the wall instead of weighting your feet.',
    'Log your attempts with three notes: what worked, what failed, and one cue for next time. That makes progress visible.',
  ];
  bool _isTyping = false;
  int _replyIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) {
      return;
    }
    setState(() {
      _notes.add(_AiCoachMessage(text: text, sentByMe: true));
      _isTyping = true;
      _controller.clear();
    });

    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (!mounted) {
      return;
    }

    setState(() {
      _notes.add(
        _AiCoachMessage(
          text: _coachReplies[_replyIndex % _coachReplies.length],
          sentByMe: false,
        ),
      );
      _replyIndex += 1;
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return _CliffScreenFrame(
      title: 'AI Coach',
      backgroundAsset: 'assets/images/Vibe.png',
      backgroundFit: BoxFit.fill,
      bottom: _CommentComposer(
        controller: _controller,
        onSend: _send,
        showLeading: false,
      ),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, topInset + 74, 16, bottomInset + 92),
        itemCount: _notes.length + (_isTyping ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (_isTyping && index == _notes.length) {
            return const Align(
              alignment: Alignment.centerLeft,
              child: _AiTypingBubble(),
            );
          }
          final note = _notes[index];
          return Align(
            alignment: note.sentByMe
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: note.sentByMe
                      ? const Color(0xFF2E3A3B)
                      : const Color(0xFF1B2021),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    note.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiCoachMessage {
  const _AiCoachMessage({required this.text, required this.sentByMe});

  final String text;
  final bool sentByMe;
}

class _AiTypingBubble extends StatelessWidget {
  const _AiTypingBubble();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2021),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 5),
            _TypingDot(delay: 160),
            const SizedBox(width: 5),
            _TypingDot(delay: 320),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const CircleAvatar(radius: 3, backgroundColor: Color(0xFFD6FF00)),
    );
  }
}

class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  bool _joined = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1112),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + 6,
          16,
          24,
        ),
        children: [
          _BackTitle(title: 'Bouldering'),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/post/post_boulder_jump.jpg',
              height: 292,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFF526E08),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/images/Map.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bouldering',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '12.4K members · 320 online',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => setState(() => _joined = true),
            child: _joined
                ? Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF91BD22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Joined',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Image.asset(
                          'assets/images/Topo.png',
                          height: 56,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Image.asset(
                            'assets/images/Quickdraw.png',
                            width: 34,
                            height: 34,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 22),
          TrendingPostsScreenInline(store: widget.store),
        ],
      ),
    );
  }
}

class TrendingPostsScreenInline extends StatelessWidget {
  const TrendingPostsScreenInline({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final posts = store.visiblePosts(category: 'Bouldering').take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => _PostTile(
        key: ValueKey(posts[index].id),
        store: store,
        post: posts[index],
      ),
    );
  }
}

class _CliffScreenFrame extends StatelessWidget {
  const _CliffScreenFrame({
    required this.title,
    required this.child,
    this.actions = const [],
    this.backgroundAsset = 'assets/images/HarborWallBackdrop.png',
    this.backgroundFit = BoxFit.cover,
    this.bottom,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final String backgroundAsset;
  final BoxFit backgroundFit;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(backgroundAsset, fit: backgroundFit),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
          child,
          Positioned(
            left: 12,
            right: 12,
            top: topInset + 2,
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  if (actions.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }
}

class _BackTitle extends StatelessWidget {
  const _BackTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFF6D1A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _EmptyFeedPanel extends StatelessWidget {
  const _EmptyFeedPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF151A1B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'No visible posts here.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.62),
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

void _openProfile(
  BuildContext context,
  ClimbySocialStore store,
  ClimbyUser user,
) {
  _push(context, UserProfileScreen(store: store, user: user));
}

void _openPost(BuildContext context, ClimbySocialStore store, ClimbyPost post) {
  _push(context, PostDetailScreen(store: store, post: post));
}

Future<void> _openVideoCall(
  BuildContext context,
  ClimbySocialStore store,
  ClimbyUser user,
) async {
  await store.load();
  if (!store.isMutualFollow(user.id)) {
    if (context.mounted) {
      await showMutualFollowRequiredDialog(context);
    }
    return;
  }
  if (!context.mounted) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ClimbyVideoCallScreen(user: user)),
  );
}
