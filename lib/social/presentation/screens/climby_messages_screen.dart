import 'package:flutter/material.dart';

import '../../data/climby_social_store.dart';
import 'climby_chat_screen.dart';
import 'climby_home_screen.dart';
import 'moderation_report_screen.dart';

class ClimbyMessagesScreen extends StatefulWidget {
  const ClimbyMessagesScreen({super.key});

  @override
  State<ClimbyMessagesScreen> createState() => _ClimbyMessagesScreenState();
}

class _ClimbyMessagesScreenState extends State<ClimbyMessagesScreen> {
  final _store = ClimbySocialStore.instance;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: Colors.black,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          final users = _usersForFilter();
          return Padding(
            padding: EdgeInsets.fromLTRB(14, topInset + 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ChatTitle(),
                const SizedBox(height: 14),
                SizedBox(
                  height: 86,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _AddFriendTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddFriendScreen(store: _store),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      for (final user in _storyUsers()) ...[
                        _MessageStoryAvatar(
                          user: user,
                          onTap: () => _openProfile(user),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                _MessageFilterTabs(
                  active: _filter,
                  onChanged: (filter) => setState(() => _filter = filter),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: users.isEmpty
                      ? const _MessagesEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                          itemCount: users.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                            indent: 58,
                          ),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final messages = _store.messagesFor(user.id);
                            return _MessageConversationRow(
                              user: user,
                              messages: messages,
                              following: _store.isFollowing(user.id),
                              mutual: _store.isMutualFollow(user.id),
                              showFollow: _filter == 'Popular',
                              onTap: () => _filter == 'Popular'
                                  ? _openProfile(user)
                                  : _openChat(user),
                              onAvatarTap: () => _openProfile(user),
                              onToggleFollow: () =>
                                  _store.toggleFollow(user.id),
                              onReport: () => openModerationScreen(
                                context: context,
                                store: _store,
                                target: ModerationTarget(
                                  kind: ModerationKind.user,
                                  key: 'user:${user.id}',
                                  title: user.name,
                                  userId: user.id,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ClimbyUser> _storyUsers() {
    final users = _store.visibleUsers
        .where((user) => !_store.isUserBlocked(user.id))
        .toList(growable: false);
    return users.take(8).toList(growable: false);
  }

  List<ClimbyUser> _usersForFilter() {
    final users = _store.visibleUsers
        .where((user) => !_store.isUserBlocked(user.id))
        .toList(growable: false);

    if (_filter == 'Following') {
      return users
          .where((user) => _store.isFollowing(user.id))
          .toList(growable: false);
    }
    if (_filter == 'Popular') {
      final sorted = [...users]
        ..sort((a, b) => _activityScore(b).compareTo(_activityScore(a)));
      return sorted.take(10).toList(growable: false);
    }

    final withMessages = users.where((user) {
      return _store.messagesFor(user.id).isNotEmpty ||
          _store.isMutualFollow(user.id);
    }).toList();
    withMessages.sort((a, b) {
      final aTime = _lastMessageTime(a.id);
      final bTime = _lastMessageTime(b.id);
      return bTime.compareTo(aTime);
    });
    return withMessages;
  }

  int _activityScore(ClimbyUser user) {
    final postScore =
        _store
            .visiblePosts()
            .where((post) => post.userId == user.id)
            .fold<int>(0, (sum, post) => sum + post.likeCount) +
        user.age;
    return postScore;
  }

  int _lastMessageTime(String userId) {
    final messages = _store.messagesFor(userId);
    if (messages.isEmpty) {
      return _store.isMutualFollow(userId) ? 1 : 0;
    }
    final parsed = DateTime.tryParse(messages.last.createdIso);
    return parsed?.millisecondsSinceEpoch ?? 0;
  }

  void _openChat(ClimbyUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClimbyChatScreen(store: _store, user: user),
      ),
    );
  }

  void _openProfile(ClimbyUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UserProfileScreen(store: _store, user: user),
      ),
    );
  }
}

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({required this.store, super.key});

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
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: topInset + 2,
            child: SizedBox(
              height: 50,
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
                    'Add Friend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final users = store.visibleUsers
                  .where((user) => !store.isUserBlocked(user.id))
                  .toList(growable: false);
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, topInset + 70, 16, 24),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _AddFriendRow(
                    user: user,
                    following: store.isFollowing(user.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            UserProfileScreen(store: store, user: user),
                      ),
                    ),
                    onToggleFollow: () => store.toggleFollow(user.id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'C',
            style: TextStyle(color: Color(0xFFD6FF00)),
          ),
          TextSpan(text: 'hat'),
        ],
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AddFriendTile extends StatelessWidget {
  const _AddFriendTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        'assets/images/Journal.png',
        width: 72,
        height: 82,
        fit: BoxFit.fill,
      ),
    );
  }
}

class _MessageStoryAvatar extends StatelessWidget {
  const _MessageStoryAvatar({required this.user, required this.onTap});

  final ClimbyUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFD6FF00),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(user.avatarAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageFilterTabs extends StatelessWidget {
  const _MessageFilterTabs({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = ['All', 'Following', 'Popular'];
    return Row(
      children: [
        for (final tab in tabs) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(tab),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tab,
                    style: TextStyle(
                      color: active == tab
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.48),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: active == tab ? 32 : 0,
                    height: 3,
                    child: const ColoredBox(color: Color(0xFFD6FF00)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ],
    );
  }
}

class _MessageConversationRow extends StatelessWidget {
  const _MessageConversationRow({
    required this.user,
    required this.messages,
    required this.following,
    required this.mutual,
    required this.showFollow,
    required this.onTap,
    required this.onAvatarTap,
    required this.onToggleFollow,
    required this.onReport,
  });

  final ClimbyUser user;
  final List<ClimbyMessage> messages;
  final bool following;
  final bool mutual;
  final bool showFollow;
  final VoidCallback onTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onToggleFollow;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final preview = _previewText();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onAvatarTap,
              child: ClipOval(
                child: Image.asset(
                  user.avatarAsset,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Text(
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
                  ),
                  const SizedBox(height: 6),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (showFollow)
              _FollowActionButton(following: following, onTap: onToggleFollow)
            else
              Text(
                _lastMessageLabel(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            IconButton(
              constraints: const BoxConstraints.tightFor(width: 32, height: 40),
              padding: EdgeInsets.zero,
              onPressed: onReport,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _previewText() {
    if (messages.isNotEmpty) {
      return messages.last.text;
    }
    if (mutual) {
      return 'Ready to chat after the next send.';
    }
    if (following) {
      return 'Waiting for follow back to unlock chat.';
    }
    return user.bio;
  }

  String _lastMessageLabel() {
    if (messages.isEmpty) {
      return mutual ? 'Start' : '';
    }
    final parsed = DateTime.tryParse(messages.last.createdIso)?.toLocal();
    if (parsed == null) {
      return 'Now';
    }
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _FollowActionButton extends StatelessWidget {
  const _FollowActionButton({required this.following, required this.onTap});

  final bool following;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: following
          ? Container(
              width: 86,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF151A1B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6FF00), width: 1.2),
              ),
              child: const Text(
                'Following',
                style: TextStyle(
                  color: Color(0xFFD6FF00),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            )
          : Image.asset(
              'assets/images/Flash.png',
              width: 86,
              height: 34,
              fit: BoxFit.fill,
            ),
    );
  }
}

class _MessagesEmptyState extends StatelessWidget {
  const _MessagesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/Ascent.png',
            width: 118,
            height: 156,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            'No data',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
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

class _AddFriendRow extends StatelessWidget {
  const _AddFriendRow({
    required this.user,
    required this.following,
    required this.onTap,
    required this.onToggleFollow,
  });

  final ClimbyUser user;
  final bool following;
  final VoidCallback onTap;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipOval(
            child: Image.asset(
              user.avatarAsset,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _FollowActionButton(following: following, onTap: onToggleFollow),
      ],
    );
  }
}
