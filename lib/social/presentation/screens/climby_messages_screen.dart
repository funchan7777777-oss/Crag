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
          final conversationUsers = _conversationUsers();
          final systemUsers = _systemMessageUsers();
          final itemCount = conversationUsers.length + systemUsers.length;
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
                const SizedBox(height: 14),
                Expanded(
                  child: itemCount == 0
                      ? const _MessagesEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                          itemCount: itemCount,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.08),
                            indent: 58,
                          ),
                          itemBuilder: (context, index) {
                            if (index >= conversationUsers.length) {
                              final user =
                                  systemUsers[index - conversationUsers.length];
                              return _SystemMessageRow(
                                user: user,
                                onTap: () => _openProfile(user),
                                onFollowBack: () =>
                                    _store.toggleFollow(user.id),
                              );
                            }

                            final user = conversationUsers[index];
                            final messages = _store.messagesFor(user.id);
                            return _MessageConversationRow(
                              user: user,
                              messages: messages,
                              onTap: () => _openChat(user),
                              onAvatarTap: () => _openProfile(user),
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
    final users = _store.followerUsers
        .where((user) => _store.isMutualFollow(user.id))
        .toList(growable: false);
    return users.take(8).toList(growable: false);
  }

  List<ClimbyUser> _conversationUsers() {
    final users = _store.visibleUsers
        .where((user) => _store.messagesFor(user.id).isNotEmpty)
        .toList(growable: false);
    users.sort((a, b) {
      final aTime = _lastMessageTime(a.id);
      final bTime = _lastMessageTime(b.id);
      return bTime.compareTo(aTime);
    });
    return users;
  }

  List<ClimbyUser> _systemMessageUsers() {
    return _store.followerUsers
        .where((user) => !_store.isFollowing(user.id))
        .toList(growable: false);
  }

  int _lastMessageTime(String userId) {
    final messages = _store.messagesFor(userId);
    if (messages.isEmpty) {
      return 0;
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
          AnimatedBuilder(
            animation: store,
            builder: (context, _) {
              final users = store.followerUsers;
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
                      onPressed: () => Navigator.of(context).maybePop(),
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

class _MessageConversationRow extends StatelessWidget {
  const _MessageConversationRow({
    required this.user,
    required this.messages,
    required this.onTap,
    required this.onAvatarTap,
    required this.onReport,
  });

  final ClimbyUser user;
  final List<ClimbyMessage> messages;
  final VoidCallback onTap;
  final VoidCallback onAvatarTap;
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
    return '';
  }

  String _lastMessageLabel() {
    if (messages.isEmpty) {
      return '';
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

class _SystemMessageRow extends StatelessWidget {
  const _SystemMessageRow({
    required this.user,
    required this.onTap,
    required this.onFollowBack,
  });

  final ClimbyUser user;
  final VoidCallback onTap;
  final VoidCallback onFollowBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD6FF00).withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Color(0xFFD6FF00),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${user.name} started following you',
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
          ),
          const SizedBox(width: 10),
          _FollowActionButton(
            following: false,
            onTap: onFollowBack,
            followLabel: 'Follow Back',
          ),
        ],
      ),
    );
  }
}

class _FollowActionButton extends StatelessWidget {
  const _FollowActionButton({
    required this.following,
    required this.onTap,
    this.followLabel,
  });

  final bool following;
  final VoidCallback onTap;
  final String? followLabel;

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
          : followLabel == null
          ? Image.asset(
              'assets/images/Flash.png',
              width: 86,
              height: 34,
              fit: BoxFit.fill,
            )
          : Container(
              width: 104,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD6FF00),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                followLabel!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
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
        _FollowActionButton(
          following: following,
          onTap: onToggleFollow,
          followLabel: 'Follow Back',
        ),
      ],
    );
  }
}
