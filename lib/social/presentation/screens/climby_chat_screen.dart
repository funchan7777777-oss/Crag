import 'package:flutter/material.dart';

import '../../data/climby_social_store.dart';
import 'climby_home_screen.dart';
import 'climby_video_call_screen.dart';
import 'moderation_report_screen.dart';

class ClimbyChatScreen extends StatefulWidget {
  const ClimbyChatScreen({
    required this.store,
    required this.user,
    this.openVideoFirst = false,
    super.key,
  });

  final ClimbySocialStore store;
  final ClimbyUser user;
  final bool openVideoFirst;

  @override
  State<ClimbyChatScreen> createState() => _ClimbyChatScreenState();
}

class _ClimbyChatScreenState extends State<ClimbyChatScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.store.load();
    if (widget.openVideoFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startVideo());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!widget.store.isMutualFollow(widget.user.id)) {
      await showMutualFollowRequiredDialog(context);
      return;
    }
    try {
      await widget.store.sendMessage(
        userId: widget.user.id,
        text: _controller.text,
      );
      _controller.clear();
    } on StateError {
      if (mounted) {
        await showMutualFollowRequiredDialog(context);
      }
    }
  }

  Future<void> _startVideo() async {
    if (!mounted) {
      return;
    }
    if (!widget.store.isMutualFollow(widget.user.id)) {
      await showMutualFollowRequiredDialog(context);
      return;
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClimbyVideoCallScreen(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/HarborWallBackdrop.png',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: topInset + 14,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => UserProfileScreen(
                        store: widget.store,
                        user: widget.user,
                      ),
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.user.avatarAsset,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => UserProfileScreen(
                          store: widget.store,
                          user: widget.user,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.user.name,
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
                ),
                IconButton(
                  onPressed: _startVideo,
                  icon: const Icon(Icons.videocam_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: widget.store,
            builder: (context, _) {
              final messages = widget.store.messagesFor(widget.user.id);
              if (messages.isEmpty) {
                return Positioned.fill(
                  top: topInset + 88,
                  bottom: bottomInset + 86,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        widget.store.isMutualFollow(widget.user.id)
                            ? 'No messages yet.'
                            : 'Chat unlocks only after both climbers follow each other.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  topInset + 92,
                  16,
                  bottomInset + 94,
                ),
                itemCount: messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _ChatBubble(message: messages[index]);
                },
              );
            },
          ),
          Positioned(
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
                  Expanded(
                    child: TextField(
                      controller: _controller,
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
                    onPressed: _send,
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
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ClimbyMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sentByMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: message.sentByMe
                ? const Color(0xFF2E3A3B)
                : const Color(0xFF151A1B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.28,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
