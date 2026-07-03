import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../access_trail/presentation/widgets/crag_notice_dialog.dart';
import '../../../foundation/safety/community_content_safety.dart';
import '../../data/climby_social_store.dart';
import '../../data/climby_wallet_store.dart';
import 'climby_wallet_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({required this.store, super.key});

  final ClimbySocialStore store;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();
  final List<String> _imagePaths = [];
  String _category = 'Bouldering';
  bool _spotlightBoost = false;
  bool _submitting = false;

  static const _categories = ['Bouldering', 'Outdoor', 'Training', 'Video'];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 88);
      if (picked.isEmpty || !mounted) {
        return;
      }
      setState(() {
        _imagePaths.addAll(picked.map((image) => image.path));
        if (_imagePaths.length > 4) {
          _imagePaths.removeRange(4, _imagePaths.length);
        }
      });
    } catch (_) {
      if (mounted) {
        await _showSmallNotice(
          title: 'Photo not added',
          message: 'Photo library access is needed to add a send photo.',
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
      );
      if (picked == null || !mounted) {
        return;
      }
      setState(() {
        _imagePaths.add(picked.path);
        if (_imagePaths.length > 4) {
          _imagePaths.removeRange(4, _imagePaths.length);
        }
      });
    } catch (_) {
      if (mounted) {
        await _showSmallNotice(
          title: 'Camera not opened',
          message: 'Camera access is needed to capture a fresh route note.',
        );
      }
    }
  }

  Future<void> _chooseMediaSource() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF121516),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            child: Row(
              children: [
                Expanded(
                  child: _MediaSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Album',
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickFromGallery();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MediaSourceButton(
                    icon: Icons.photo_camera_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.of(context).pop();
                      _takePhoto();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSmallNotice({
    required String title,
    required String message,
  }) {
    return showCragNoticeDialog(
      context: context,
      title: title,
      message: message,
    );
  }

  Future<void> _submit() async {
    final caption = _captionController.text.trim();
    if (_imagePaths.isEmpty || caption.isEmpty || _submitting) {
      await _showSmallNotice(
        title: 'Add your send',
        message: 'Add one route photo and a short note from the session.',
      );
      return;
    }
    final safety = CommunityContentSafety.validate(
      text: caption,
      surface: CommunityContentSurface.publicPost,
      maxLength: 220,
    );
    if (!safety.allowed) {
      await _showSmallNotice(
        title: 'Tune this post',
        message: safety.message ?? 'Tune this send note before submitting.',
      );
      return;
    }

    if (_spotlightBoost) {
      final paid = await spendCoinsOrOpenWallet(
        context: context,
        feature: projectBoostFeature,
      );
      if (!mounted || !paid) {
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      await widget.store.submitPostForReview(
        imagePaths: _imagePaths,
        caption: caption,
        category: _category,
        boosted: _spotlightBoost,
      );
    } on CommunityContentSafetyException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      await _showSmallNotice(
        title: 'Tune this post',
        message:
            error.decision.message ?? 'Tune this send note before submitting.',
      );
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    await showCragNoticeDialog(
      context: context,
      title: 'Post submitted',
      message: _spotlightBoost
          ? 'Your send is clipped to the review rope with a Crux Spotlight boost.'
          : 'Your send is clipped to the review rope and will appear after approval.',
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0D1112),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backdrop_night_wall.png',
            fit: BoxFit.fill,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(16, topInset + 68, 16, 112),
            children: [
              const Text(
                'Log the move',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _captionController,
                maxLines: 4,
                minLines: 3,
                cursorColor: const Color(0xFFD6FF00),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                decoration: InputDecoration(
                  hintText: 'Small feet, big trust...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF151A1B).withValues(alpha: 0.92),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD6FF00)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var index = 0; index < _imagePaths.length; index += 1)
                    _SelectedPhotoTile(
                      path: _imagePaths[index],
                      onRemove: () =>
                          setState(() => _imagePaths.removeAt(index)),
                    ),
                  if (_imagePaths.isEmpty)
                    GestureDetector(
                      onTap: _chooseMediaSource,
                      child: Image.asset(
                        'assets/images/creation_cheer_icon.png',
                        width: 108,
                        height: 108,
                        fit: BoxFit.fill,
                      ),
                    )
                  else if (_imagePaths.length < 4)
                    GestureDetector(
                      onTap: _chooseMediaSource,
                      child: Image.asset(
                        'assets/images/creation_harness_icon.png',
                        width: 142,
                        height: 52,
                        fit: BoxFit.fill,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in _categories)
                    ChoiceChip(
                      selected: _category == category,
                      label: Text(category),
                      selectedColor: const Color(0xFFD6FF00),
                      backgroundColor: const Color(0xFF151A1B),
                      labelStyle: TextStyle(
                        color: _category == category
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _category == category
                              ? const Color(0xFFD6FF00)
                              : Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _SpotlightBoostSwitch(
                active: _spotlightBoost,
                onTap: () => setState(() => _spotlightBoost = !_spotlightBoost),
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
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: bottomInset + 18,
            child: GestureDetector(
              onTap: _submit,
              child: SizedBox(
                height: 48,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/creation_partner_icon.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    if (_submitting)
                      const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightBoostSwitch extends StatelessWidget {
  const _SpotlightBoostSwitch({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF121819).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? const Color(0xFFD6FF00)
                : Colors.white.withValues(alpha: 0.12),
            width: active ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFD6FF00) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD6FF00)),
              ),
              child: Icon(
                active ? Icons.bolt_rounded : Icons.bolt_outlined,
                color: active ? Colors.black : const Color(0xFFD6FF00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crux Spotlight Boost',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optional. Burn 120 coins for a neon boost tag after review.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: active,
              activeThumbColor: Colors.black,
              activeTrackColor: const Color(0xFFD6FF00),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaSourceButton extends StatelessWidget {
  const _MediaSourceButton({
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
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2021),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD6FF00), size: 30),
            const SizedBox(height: 8),
            Text(
              label,
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
  }
}

class _SelectedPhotoTile extends StatelessWidget {
  const _SelectedPhotoTile({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            width: 86,
            height: 86,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: -8,
          top: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5D2A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
