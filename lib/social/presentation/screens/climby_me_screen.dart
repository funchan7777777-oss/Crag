import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../access_trail/data/local_crag_access_cache.dart';
import '../../../access_trail/domain/models/climber_access_card.dart';
import '../../../access_trail/presentation/controllers/access_copy_ledger.dart';
import '../../../access_trail/presentation/screens/policy_web_ledge_screen.dart';
import '../../../access_trail/presentation/screens/rope_account_entry_screen.dart';
import '../../../access_trail/presentation/screens/route_cards_onboarding_screen.dart';
import '../../../access_trail/presentation/widgets/access_text_field.dart';
import '../../../access_trail/presentation/widgets/crag_notice_dialog.dart';
import '../../../access_trail/presentation/widgets/neon_hold_button.dart';
import '../../../foundation/safety/community_content_safety.dart';
import '../../data/climby_social_store.dart';
import 'climby_home_screen.dart';
import 'climby_wallet_screen.dart';

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
              Image.asset(
                'assets/images/friend_invite_backdrop.png',
                fit: BoxFit.fill,
              ),
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
                            kind: _ProfileUserListKind.following,
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
                            kind: _ProfileUserListKind.follower,
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
                    child: Center(
                      child: Image.asset(
                        'assets/images/wallet_rack_banner.png',
                        width: 358,
                        height: 74,
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

  void _openUserList({
    required String title,
    required _ProfileUserListKind kind,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _ProfileUserListScreen(title: title, kind: kind, store: _store),
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

  Future<void> _chooseAvatarSource() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101A19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AvatarSourceTile(
                icon: Icons.photo_camera_rounded,
                label: 'Take a photo',
                onTap: () => _pickAvatar(ImageSource.camera),
              ),
              _AvatarSourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from library',
                onTap: () => _pickAvatar(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1200,
      );
      if (image == null || !mounted) {
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final extension = image.name.split('.').lastOrNull ?? 'jpg';
      final stored = await File(image.path).copy(
        '${directory.path}/crag_profile_avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      if (mounted) {
        setState(() => _avatarFilePath = stored.path);
      }
    } catch (_) {
      if (mounted) {
        await showCragNoticeDialog(
          context: context,
          title: 'Photo not opened',
          message:
              'Camera or library access is needed to reset your climber photo.',
        );
      }
    }
  }

  Future<void> _chooseGender() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101A19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SelectionTile(
                label: 'Male',
                selected: _genderController.text.trim() == 'Male',
                onTap: () => Navigator.of(context).pop('Male'),
              ),
              _SelectionTile(
                label: 'Female',
                selected: _genderController.text.trim() == 'Female',
                onTap: () => Navigator.of(context).pop('Female'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _genderController.text = selected);
    }
  }

  Future<void> _chooseAge() async {
    final currentAge = _ageFromBirthDate(_birthController.text);
    final ages = List<int>.generate(82, (index) => index + 18);
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF101A19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SizedBox(
          height: 360,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Text(
                  'Select age',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ages.length,
                  itemBuilder: (context, index) {
                    final age = ages[index];
                    return _SelectionTile(
                      label: '$age',
                      selected: age == currentAge,
                      onTap: () => Navigator.of(context).pop(age),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _birthController.text = _birthDateForAge(selected));
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
        message: 'Add the name that appears beside your route notes.',
      );
      return;
    }
    final nameSafety = CommunityContentSafety.validate(
      text: name,
      surface: CommunityContentSurface.profile,
      maxLength: 32,
    );
    if (!nameSafety.allowed) {
      await showCragNoticeDialog(
        context: context,
        title: 'Tune this name',
        message: nameSafety.message ?? 'Tune your climber name before saving.',
      );
      return;
    }
    final citySafety = CommunityContentSafety.validate(
      text: _cityController.text.trim(),
      surface: CommunityContentSurface.profile,
      maxLength: 48,
    );
    if (!citySafety.allowed) {
      await showCragNoticeDialog(
        context: context,
        title: 'Tune this city',
        message: citySafety.message ?? 'Tune your crag base before saving.',
      );
      return;
    }
    final bioText = _bioController.text.trim().isEmpty
        ? 'Logging quiet feet, clean beta, and better belays.'
        : _bioController.text.trim();
    final bioSafety = CommunityContentSafety.validate(
      text: bioText,
      surface: CommunityContentSurface.profile,
      maxLength: 160,
    );
    if (!bioSafety.allowed) {
      await showCragNoticeDialog(
        context: context,
        title: 'Tune this note',
        message: bioSafety.message ?? 'Tune your field note before saving.',
      );
      return;
    }
    setState(() => _saving = true);
    await widget.cache.anchorActiveCard(
      widget.card.copyWith(
        trailName: name,
        fieldBio: bioText,
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
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(20, topInset + 78, 20, 24),
            children: [
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _chooseAvatarSource,
                  child: SizedBox(
                    width: 220,
                    height: 150,
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
              _ProfileSelectField(
                label: 'Gender',
                value: _genderController.text,
                onTap: _chooseGender,
              ),
              const SizedBox(height: 18),
              _ProfileSelectField(
                label: 'Age',
                value: _ageFromBirthDate(_birthController.text).toString(),
                onTap: _chooseAge,
              ),
              const SizedBox(height: 18),
              AccessTextField(label: 'City', controller: _cityController),
              const SizedBox(height: 18),
              AccessTextField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              NeonHoldButton(
                label: 'Continue',
                busy: _saving,
                onPressed: _save,
              ),
              SizedBox(height: bottomInset + 18),
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
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(16, topInset + 78, 16, 28),
            children: [
              _SettingRow(
                label: 'Blocked Climbers',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlacklistScreen(store: store),
                  ),
                ),
              ),
              _SettingRow(
                label: 'Privacy Policy',
                onTap: () => _openPolicy(
                  context,
                  AccessCopyLedger.privacyUrl,
                  'Privacy Policy',
                ),
              ),
              _SettingRow(
                label: 'Terms of Service',
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
              _SettingRow(
                label: 'Safety Contact',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CommunityGuidelinesScreen(
                      focusSafetyContact: true,
                    ),
                  ),
                ),
              ),
              _SettingRow(
                label: 'Leave This Rope',
                onTap: () => _logout(context),
              ),
              _SettingRow(
                label: 'Delete Local Route Card',
                danger: true,
                onTap: () => _deleteAccount(context),
              ),
            ],
          ),
          _SimpleTopBar(title: 'Settings', topInset: topInset),
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
    await _showSettingLoading(context, 'Leaving rope');
    await cache.clearActiveCard();
    if (!context.mounted) {
      return;
    }
    await showCragNoticeDialog(
      context: context,
      title: 'Rope unclipped',
      message: 'This local session is closed.',
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
    await _showSettingLoading(context, 'Deleting route card');
    await cache.resetAfterAccountDeletion();
    if (!context.mounted) {
      return;
    }
    await showCragNoticeDialog(
      context: context,
      title: 'Route card deleted',
      message:
          'Your local profile, route notes, and session data have been removed.',
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
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final users = store.blockedUsers;
              if (users.isEmpty) {
                return const _ProfileEmptyState(message: '');
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
                          'assets/images/relation_crux_badge.png',
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
          _SimpleTopBar(title: 'Blocked Climbers', topInset: topInset),
        ],
      ),
    );
  }
}

enum _ProfileUserListKind { following, follower }

class _ProfileUserListScreen extends StatelessWidget {
  const _ProfileUserListScreen({
    required this.title,
    required this.kind,
    required this.store,
    super.key,
  });

  final String title;
  final _ProfileUserListKind kind;
  final ClimbySocialStore store;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final users = switch (kind) {
                _ProfileUserListKind.following => store.followingUsers,
                _ProfileUserListKind.follower => store.followerUsers,
              };
              if (users.isEmpty) {
                return const _ProfileEmptyState(message: '');
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, topInset + 78, 16, 24),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isFollowing = store.isFollowing(user.id);
                  return _ProfileUserListRow(
                    user: user,
                    isFollowing: isFollowing,
                    isFollowerList: kind == _ProfileUserListKind.follower,
                    onProfileTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            UserProfileScreen(store: store, user: user),
                      ),
                    ),
                    onFollowTap: () => store.toggleFollow(user.id),
                  );
                },
              );
            },
          ),
          _SimpleTopBar(title: title, topInset: topInset),
        ],
      ),
    );
  }
}

class _ProfileUserListRow extends StatelessWidget {
  const _ProfileUserListRow({
    required this.user,
    required this.isFollowing,
    required this.isFollowerList,
    required this.onProfileTap,
    required this.onFollowTap,
  });

  final ClimbyUser user;
  final bool isFollowing;
  final bool isFollowerList;
  final VoidCallback onProfileTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final actionLabel = isFollowing
        ? 'Unfollow'
        : isFollowerList
        ? 'Follow Back'
        : 'Follow';

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onProfileTap,
            child: Row(
              children: [
                _UserAvatar(asset: user.avatarAsset, size: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.54),
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
        ),
        const SizedBox(width: 12),
        _ProfileFollowActionButton(
          label: actionLabel,
          highlighted: !isFollowing,
          onTap: onFollowTap,
        ),
      ],
    );
  }
}

class _ProfileFollowActionButton extends StatelessWidget {
  const _ProfileFollowActionButton({
    required this.label,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 104,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFFD6FF00) : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFD6FF00), width: 1.4),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: highlighted ? Colors.black : const Color(0xFFD6FF00),
            fontSize: label.length > 9 ? 11 : 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
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
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final posts = store.pendingPosts;
              if (posts.isEmpty) {
                return Center(
                  child: Image.asset(
                    'assets/images/empty_state_ascent.png',
                    width: 128,
                    height: 166,
                    fit: BoxFit.contain,
                  ),
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

class _AvatarSourceTile extends StatelessWidget {
  const _AvatarSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 58,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF172221),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD6FF00), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
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
    );
  }
}

class _ProfileSelectField extends StatelessWidget {
  const _ProfileSelectField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 9),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF151F20).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFD6FF00),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFD6FF00).withValues(alpha: 0.16)
              : const Color(0xFF172221),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFFD6FF00)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                color: Color(0xFFD6FF00),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({this.focusSafetyContact = false, super.key});

  final bool focusSafetyContact;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const safetyContactRule = (
      'Safety Contact',
      'For urgent moderation support, contact ${AccessCopyLedger.safetyContactEmail}. Include the climber name, content type, and a short route note.',
    );
    final rules = [
      if (focusSafetyContact) safetyContactRule,
      (
        'Real climbers and clear consent',
        'Do not impersonate another climber or pressure someone into chat. Direct messages and calls open only after both climbers follow each other.',
      ),
      (
        'Respect the wall',
        'Targeted abuse, explicit adult material, scams, spam, unsafe pressure, and discriminatory attacks are off-route. Use report or block when a line feels wrong.',
      ),
      (
        'Reviewed send logs',
        'New posts may be reviewed before public display. Do not share trespass beta, private locations, or instructions that encourage unsafe climbing.',
      ),
      (
        'Privacy at the crag',
        'Do not publish private contact details, exact home locations, or photos of others without permission. Take extra care in gyms and youth spaces.',
      ),
      (
        'Moderation route',
        'Reported content is hidden locally and may be restricted. Blocking a climber removes their posts, comments, and chat notes from your wall.',
      ),
      if (!focusSafetyContact) safetyContactRule,
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
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
        _MeGearTag(
          icon: Icons.person_rounded,
          text: '${_genderSymbol(card)} ${_age(card)}',
        ),
        _MeGearTag(
          icon: Icons.place_rounded,
          text: card.city ?? 'Los Angeles, CA',
        ),
        const _MeGearTag(icon: Icons.terrain_rounded, text: 'Bouldering'),
      ],
    );
  }
}

class _MeGearTag extends StatelessWidget {
  const _MeGearTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 176),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121819).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD6FF00).withValues(alpha: 0.42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD6FF00), size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
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
      return SizedBox(
        width: double.infinity,
        height: 172,
        child: Center(
          child: Image.asset(
            'assets/images/empty_state_ascent.png',
            width: 128,
            height: 166,
            fit: BoxFit.contain,
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
                  'This send is clipped to the review rope and will appear after approval.',
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
    final boosted = post.status == 'boosted';
    return GestureDetector(
      onTap: () => showCragNoticeDialog(
        context: context,
        title: 'Under review',
        message:
            'This send is clipped to the review rope and will appear after approval.',
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
                      color: boosted
                          ? const Color(0xFFFF6A1D)
                          : const Color(0xFFD6FF00),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      boosted ? 'Boosted' : 'Reviewing',
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
            'assets/images/empty_state_ascent.png',
            width: 116,
            height: 150,
            fit: BoxFit.contain,
          ),
          if (message.trim().isNotEmpty) ...[
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
    trailName: 'Halou',
    fieldBio: 'Logging quiet feet, clean beta, and better belays.',
    anchoredAtIso: DateTime.now().toIso8601String(),
    contactEmail: null,
    genderLabel: 'Male',
    birthDate: '2004-01-01',
    city: 'Los Angeles, CA',
  );
}

String _displayName(ClimberAccessCard card) {
  final name = card.trailName.trim();
  return name.isEmpty ? 'Halou' : name;
}

String _bio(ClimberAccessCard card) {
  final bio = card.fieldBio.trim();
  return bio.isEmpty
      ? 'Logging quiet feet, clean beta, and better belays.'
      : bio;
}

String _genderSymbol(ClimberAccessCard card) {
  final gender = (card.genderLabel ?? '').toLowerCase();
  return gender.startsWith('f') ? '♀' : '♂';
}

int _age(ClimberAccessCard card) {
  return _ageFromBirthDate(card.birthDate ?? '');
}

int _ageFromBirthDate(String birthDate) {
  final birth = DateTime.tryParse(birthDate);
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

String _birthDateForAge(int age) {
  final now = DateTime.now();
  final year = now.year - age;
  return '${year.toString().padLeft(4, '0')}-01-01';
}

const _defaultAvatarAsset = 'assets/images/avatars/member_alex.jpg';
