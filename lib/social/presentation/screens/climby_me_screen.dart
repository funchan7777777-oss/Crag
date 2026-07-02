import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../access_trail/data/local_crag_access_cache.dart';
import '../../../access_trail/domain/models/climber_access_card.dart';
import '../../../access_trail/presentation/controllers/access_copy_ledger.dart';
import '../../../access_trail/presentation/screens/policy_web_ledge_screen.dart';
import '../../../access_trail/presentation/screens/rope_account_entry_screen.dart';
import '../../../access_trail/presentation/screens/route_cards_onboarding_screen.dart';
import '../../../access_trail/presentation/widgets/access_text_field.dart';
import '../../../access_trail/presentation/widgets/crag_notice_dialog.dart';
import '../../../access_trail/presentation/widgets/neon_hold_button.dart';
import '../../data/climby_social_store.dart';
import 'climby_home_screen.dart';

class ClimbyMeScreen extends StatefulWidget {
  const ClimbyMeScreen({super.key});

  @override
  State<ClimbyMeScreen> createState() => _ClimbyMeScreenState();
}

class _ClimbyMeScreenState extends State<ClimbyMeScreen> {
  final _store = ClimbySocialStore.instance;
  LocalCragAccessCache? _cache;
  ClimberAccessCard? _card;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _store.load();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final cache = await LocalCragAccessCache.open();
    final card = cache.readActiveCard() ?? _defaultCard();
    if (!mounted) {
      return;
    }
    setState(() {
      _cache = cache;
      _card = card;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    if (_loading || _cache == null || card == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFD6FF00)),
        ),
      );
    }

    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final followingCount = _store.followingUsers.length;
          final followerCount = _store.followerUsers.length;
          final pendingPosts = _store.pendingPosts;

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/Invite.png', fit: BoxFit.fill),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.02),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
              ListView(
                padding: EdgeInsets.fromLTRB(16, topInset + 96, 16, 24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        _ProfileAvatar(card: card, size: 112),
                        const SizedBox(height: 12),
                        Text(
                          _displayName(card),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MePills(card: card),
                        const SizedBox(height: 10),
                        Text(
                          _bio(card),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _MeStatCard(
                          label: 'Following',
                          value: followingCount.toString(),
                          onTap: () => _openUserList(
                            title: 'Following',
                            users: _store.followingUsers,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MeStatCard(
                          label: 'Follower',
                          value: followerCount.toString(),
                          onTap: () => _openUserList(
                            title: 'Follower',
                            users: _store.followerUsers,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MeStatCard(
                          label: 'Posts',
                          value: pendingPosts.length.toString(),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => MyPostsScreen(store: _store),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyWalletScreen(),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/Rack.png',
                        height: 62,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _MyPostHeader(),
                  const SizedBox(height: 10),
                  _PendingPostStrip(posts: pendingPosts),
                  SizedBox(height: bottomInset + 80),
                ],
              ),
              Positioned(
                left: 12,
                right: 12,
                top: topInset + 2,
                child: Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                EditMyProfileScreen(cache: _cache!, card: card),
                          ),
                        );
                        await _loadCard();
                      },
                      icon: const Icon(
                        Icons.edit_square,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              SettingScreen(cache: _cache!, store: _store),
                        ),
                      ),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 23,
                      ),
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

  void _openUserList({required String title, required List<ClimbyUser> users}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProfileUserListScreen(title: title, users: users, store: _store),
      ),
    );
  }
}

class EditMyProfileScreen extends StatefulWidget {
  const EditMyProfileScreen({
    required this.cache,
    required this.card,
    super.key,
  });

  final LocalCragAccessCache cache;
  final ClimberAccessCard card;

  @override
  State<EditMyProfileScreen> createState() => _EditMyProfileScreenState();
}

class _EditMyProfileScreenState extends State<EditMyProfileScreen> {
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _genderController;
  late final TextEditingController _birthController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;
  String? _avatarFilePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _displayName(widget.card));
    _genderController = TextEditingController(
      text: widget.card.genderLabel ?? 'Male',
    );
    _birthController = TextEditingController(
      text: widget.card.birthDate ?? '2001-01-01',
    );
    _cityController = TextEditingController(
      text: widget.card.city ?? 'Los Angeles, CA',
    );
    _bioController = TextEditingController(text: _bio(widget.card));
    _avatarFilePath = widget.card.avatarFilePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _birthController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (image == null || !mounted) {
        return;
      }
      setState(() => _avatarFilePath = image.path);
    } catch (_) {
      if (mounted) {
        await showCragNoticeDialog(
          context: context,
          title: 'Photo not opened',
          message: 'Please allow photo access, then choose your avatar again.',
        );
      }
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      await showCragNoticeDialog(
        context: context,
        title: 'Nickname needed',
        message: 'Please enter a nickname before continuing.',
      );
      return;
    }
    setState(() => _saving = true);
    await widget.cache.anchorActiveCard(
      widget.card.copyWith(
        trailName: name,
        fieldBio: _bioController.text.trim().isEmpty
            ? 'Building a steady climbing log.'
            : _bioController.text.trim(),
        avatarFilePath: _avatarFilePath,
        genderLabel: _genderController.text.trim(),
        birthDate: _birthController.text.trim(),
        city: _cityController.text.trim(),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(20, topInset + 78, 20, 106),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _ProfileAvatar(
                          card: widget.card.copyWith(
                            avatarFilePath: _avatarFilePath,
                          ),
                          size: 112,
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.black,
                            size: 27,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AccessTextField(label: 'Nickname', controller: _nameController),
              const SizedBox(height: 18),
              AccessTextField(label: 'Gender', controller: _genderController),
              const SizedBox(height: 18),
              AccessTextField(
                label: 'Birth of date',
                controller: _birthController,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 18),
              AccessTextField(label: 'City', controller: _cityController),
              const SizedBox(height: 18),
              AccessTextField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 2,
              ),
            ],
          ),
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
                  const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset + 18,
            child: NeonHoldButton(
              label: 'Continue',
              busy: _saving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({required this.cache, required this.store, super.key});

  final LocalCragAccessCache cache;
  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(16, topInset + 78, 16, 28),
            children: [
              _SettingRow(
                label: 'Blacklist',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlacklistScreen(store: store),
                  ),
                ),
              ),
              _SettingRow(
                label: 'Privacy agreement',
                onTap: () => _openPolicy(
                  context,
                  AccessCopyLedger.privacyUrl,
                  'Privacy Policy',
                ),
              ),
              _SettingRow(
                label: 'User agreement',
                onTap: () => _openPolicy(
                  context,
                  AccessCopyLedger.termsUrl,
                  'Terms of Service',
                ),
              ),
              _SettingRow(
                label: 'Community Guidelines',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CommunityGuidelinesScreen(),
                  ),
                ),
              ),
              _SettingRow(label: 'Log out', onTap: () => _logout(context)),
              _SettingRow(
                label: 'Deletion of account',
                danger: true,
                onTap: () => _deleteAccount(context),
              ),
            ],
          ),
          _SimpleTopBar(title: 'Setting', topInset: topInset),
        ],
      ),
    );
  }

  void _openPolicy(BuildContext context, String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PolicyWebLedgeScreen(url: url, screenTitle: title),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await _showSettingLoading(context, 'Logging out');
    await cache.clearActiveCard();
    if (!context.mounted) {
      return;
    }
    await showCragNoticeDialog(
      context: context,
      title: 'Logged out',
      message: 'You have safely left this account.',
    );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => RopeAccountEntryScreen(cache: cache),
      ),
      (_) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    await _showSettingLoading(context, 'Deleting account');
    await cache.resetAfterAccountDeletion();
    if (!context.mounted) {
      return;
    }
    await showCragNoticeDialog(
      context: context,
      title: 'Account deleted',
      message:
          'Your local account data has been removed. You will return to the welcome guide.',
    );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => RouteCardsOnboardingScreen(cache: cache),
      ),
      (_) => false,
    );
  }
}

class BlacklistScreen extends StatelessWidget {
  const BlacklistScreen({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final users = store.blockedUsers;
              if (users.isEmpty) {
                return const _ProfileEmptyState(message: 'No blocked users');
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, topInset + 78, 16, 24),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Row(
                    children: [
                      _UserAvatar(asset: user.avatarAsset, size: 50),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => store.unblockUser(user.id),
                        child: Image.asset(
                          'assets/images/Crux.png',
                          width: 92,
                          height: 42,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          _SimpleTopBar(title: 'Blacklist', topInset: topInset),
        ],
      ),
    );
  }
}

class ProfileUserListScreen extends StatelessWidget {
  const ProfileUserListScreen({
    required this.title,
    required this.users,
    required this.store,
    super.key,
  });

  final String title;
  final List<ClimbyUser> users;
  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          users.isEmpty
              ? const _ProfileEmptyState(message: 'No data')
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, topInset + 78, 16, 24),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              UserProfileScreen(store: store, user: user),
                        ),
                      ),
                      child: Row(
                        children: [
                          _UserAvatar(asset: user.avatarAsset, size: 50),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          _SimpleTopBar(title: title, topInset: topInset),
        ],
      ),
    );
  }
}

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final posts = store.pendingPosts;
              if (posts.isEmpty) {
                return const _ProfileEmptyState(
                  message: 'No submitted posts yet',
                );
              }
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(16, topInset + 80, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _PendingPostCard(post: posts[index]);
                },
              );
            },
          ),
          _SimpleTopBar(title: 'My Post', topInset: topInset),
        ],
      ),
    );
  }
}

class MyWalletScreen extends StatelessWidget {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const packages = [
      ('500', '\$9.99'),
      ('1200', '\$19.99'),
      ('2600', '\$39.99'),
      ('5200', '\$69.99'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          ListView(
            padding: EdgeInsets.fromLTRB(16, topInset + 76, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coins Power',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your Climb +',
                          style: TextStyle(
                            color: Color(0xFFD6FF00),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/Quickdraw.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              Text(
                'Use coins to unlock premium features, connect with climbers, and level up your experience.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.66),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose a coin Package',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              for (final pack in packages) ...[
                _CoinPackageRow(coins: pack.$1, price: pack.$2),
                const SizedBox(height: 12),
              ],
            ],
          ),
          _SimpleTopBar(title: 'My Wallet', topInset: topInset),
        ],
      ),
    );
  }
}

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final rules = [
      (
        'Real identity and consent',
        'Do not impersonate others, create anonymous harassment, or pressure another climber to chat. Direct messages and calls are only available when both climbers follow each other.',
      ),
      (
        'Respectful climbing community',
        'Harassment, bullying, hate speech, threats, sexual content, scams, and spam are not allowed. Use report or block when content or behavior feels unsafe.',
      ),
      (
        'Post review and safety',
        'New posts may be reviewed before public display. Do not share dangerous instructions, trespass beta, private locations, or content that encourages unsafe climbing.',
      ),
      (
        'Privacy and minors',
        'Do not publish private contact details, exact home locations, or images of others without permission. Extra care is required around minors and gym spaces.',
      ),
      (
        'Moderation actions',
        'Reported content can be hidden locally and may be restricted. Blocking a user hides their posts and chats from your experience.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          ListView.separated(
            padding: EdgeInsets.fromLTRB(18, topInset + 80, 18, 26),
            itemCount: rules.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rule = rules[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF151A1B).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.$1,
                      style: const TextStyle(
                        color: Color(0xFFD6FF00),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rule.$2,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 13,
                        height: 1.38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _SimpleTopBar(title: 'Community Guidelines', topInset: topInset),
        ],
      ),
    );
  }
}

class _SimpleTopBar extends StatelessWidget {
  const _SimpleTopBar({required this.title, required this.topInset});

  final String title;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}

class _MePills extends StatelessWidget {
  const _MePills({required this.card});

  final ClimberAccessCard card;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 7,
      children: [
        _SmallOrangePill(text: '${_genderSymbol(card)} ${_age(card)}'),
        _SmallOrangePill(text: card.city ?? 'Los Angeles, CA'),
        const _SmallOrangePill(text: 'Bouldering'),
      ],
    );
  }
}

class _SmallOrangePill extends StatelessWidget {
  const _SmallOrangePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF661F),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MeStatCard extends StatelessWidget {
  const _MeStatCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF3A4142).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyPostHeader extends StatelessWidget {
  const _MyPostHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 4),
        SizedBox(
          width: 48,
          height: 3,
          child: ColoredBox(color: Color(0xFFD6FF00)),
        ),
      ],
    );
  }
}

class _PendingPostStrip extends StatelessWidget {
  const _PendingPostStrip({required this.posts});

  final List<ClimbyPendingPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          'No submitted posts yet. New posts appear here while review is pending.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      );
    }

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showCragNoticeDialog(
              context: context,
              title: 'Under review',
              message:
                  'This post has been submitted successfully and will become public only after review approval.',
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: _LocalImage(path: posts[index].imagePaths.first),
            ),
          );
        },
      ),
    );
  }
}

class _PendingPostCard extends StatelessWidget {
  const _PendingPostCard({required this.post});

  final ClimbyPendingPost post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showCragNoticeDialog(
        context: context,
        title: 'Under review',
        message:
            'This post has been submitted successfully and will become public only after review approval.',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _LocalImage(path: post.imagePaths.first),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.74),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6FF00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Reviewing',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalImage extends StatelessWidget {
  const _LocalImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: 76,
        height: 76,
        color: const Color(0xFF151A1B),
        child: const Icon(Icons.image_not_supported, color: Colors.white),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF5A6365).withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: danger
                        ? const Color(0xFFFFC2B6)
                        : Colors.white.withValues(alpha: 0.94),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinPackageRow extends StatelessWidget {
  const _CoinPackageRow({required this.coins, required this.price});

  final String coins;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141418).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFD6FF00).withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/Quickdraw.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Text(
            coins,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.card, required this.size});

  final ClimberAccessCard card;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = card.avatarFilePath;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size > 100 ? 22 : size / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size > 100 ? 18 : size / 2),
        child: path == null || path.isEmpty
            ? Image.asset(
                _defaultAvatarAsset,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(path),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  _defaultAvatarAsset,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(asset, width: size, height: size, fit: BoxFit.cover),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/Ascent.png',
            width: 116,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showSettingLoading(BuildContext context, String label) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF101516),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD6FF00), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  color: Color(0xFFD6FF00),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  await Future<void>.delayed(const Duration(milliseconds: 850));
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

ClimberAccessCard _defaultCard() {
  return ClimberAccessCard(
    corridorKey: 'local:me',
    accessRoute: 'local',
    trailName: 'Alex R.',
    fieldBio: 'Finally sent my project! Finally sent my project!',
    anchoredAtIso: DateTime.now().toIso8601String(),
    contactEmail: null,
    genderLabel: 'Male',
    birthDate: '2004-01-01',
    city: 'Los Angeles, CA',
  );
}

String _displayName(ClimberAccessCard card) {
  final name = card.trailName.trim();
  return name.isEmpty ? 'Alex R.' : name;
}

String _bio(ClimberAccessCard card) {
  final bio = card.fieldBio.trim();
  return bio.isEmpty ? 'Building a steady climbing log.' : bio;
}

String _genderSymbol(ClimberAccessCard card) {
  final gender = (card.genderLabel ?? '').toLowerCase();
  return gender.startsWith('f') ? '♀' : '♂';
}

int _age(ClimberAccessCard card) {
  final birth = DateTime.tryParse(card.birthDate ?? '');
  if (birth == null) {
    return 22;
  }
  final now = DateTime.now();
  var age = now.year - birth.year;
  if (now.month < birth.month ||
      (now.month == birth.month && now.day < birth.day)) {
    age -= 1;
  }
  return age.clamp(13, 99);
}

const _defaultAvatarAsset = 'assets/images/head/avatar_male_alex.jpg';
