import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../field_notes/presentation/screens/crag_overview_screen.dart';
import '../../data/local_crag_access_cache.dart';
import '../../domain/models/climber_access_card.dart';
import '../widgets/access_text_field.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/crag_notice_dialog.dart';
import '../widgets/ledge_back_button.dart';
import '../widgets/neon_hold_button.dart';
import '../widgets/profile_photo_picker.dart';

class ClimberProfileTuningScreen extends StatefulWidget {
  const ClimberProfileTuningScreen({
    required this.cache,
    required this.accessRoute,
    required this.corridorKey,
    required this.initialTrailName,
    this.contactEmail,
    super.key,
  });

  final LocalCragAccessCache cache;
  final String accessRoute;
  final String corridorKey;
  final String initialTrailName;
  final String? contactEmail;

  @override
  State<ClimberProfileTuningScreen> createState() =>
      _ClimberProfileTuningScreenState();
}

class _ClimberProfileTuningScreenState
    extends State<ClimberProfileTuningScreen> {
  late final TextEditingController _nameController;
  final _bioController = TextEditingController();
  final _picker = ImagePicker();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialTrailName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _choosePhotoSource() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: false,
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
              _PhotoSourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from library',
                onTap: () => _pickPhoto(ImageSource.gallery),
              ),
              _PhotoSourceTile(
                icon: Icons.photo_camera_rounded,
                label: 'Take a photo',
                onTap: () => _pickPhoto(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 86,
        maxWidth: 1200,
      );
      if (picked == null) {
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final extension = picked.name.split('.').lastOrNull ?? 'jpg';
      final stored = await File(picked.path).copy(
        '${directory.path}/crag_avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
      );
      if (mounted) {
        setState(() => _photoPath = stored.path);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      showCragNoticeDialog(
        context: context,
        title: 'Photo not added',
        message: 'Please allow photo or camera access, then try again.',
      );
    }
  }

  Future<void> _finishProfile() async {
    final trailName = _nameController.text.trim();
    final fieldBio = _bioController.text.trim();

    if (trailName.isEmpty) {
      await showCragNoticeDialog(
        context: context,
        title: 'Nickname needed',
        message: 'Please enter the name you want shown in Crag.',
      );
      return;
    }
    if (fieldBio.isEmpty) {
      await showCragNoticeDialog(
        context: context,
        title: 'Bio needed',
        message: 'Please add a short climbing note before continuing.',
      );
      return;
    }

    await widget.cache.anchorActiveCard(
      ClimberAccessCard(
        corridorKey: widget.corridorKey,
        accessRoute: widget.accessRoute,
        contactEmail: widget.contactEmail,
        trailName: trailName,
        fieldBio: fieldBio,
        avatarFilePath: _photoPath,
        anchoredAtIso: DateTime.now().toIso8601String(),
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const CragOverviewScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CragImageBackdrop(
            assetPath: 'assets/images/EveningWallProfile.png',
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 112, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crag',
                    style: TextStyle(
                      color: Color(0xFFD6FF00),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ProfilePhotoPicker(
                      photoPath: _photoPath,
                      onPressed: _choosePhotoSource,
                    ),
                  ),
                  const SizedBox(height: 26),
                  AccessTextField(
                    label: 'Nickname',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 22),
                  AccessTextField(
                    label: 'Bio',
                    controller: _bioController,
                    maxLines: 4,
                    hint: 'Share your current climbing note',
                  ),
                  const SizedBox(height: 34),
                  NeonHoldButton(label: 'Continue', onPressed: _finishProfile),
                ],
              ),
            ),
          ),
          const LedgeBackButton(),
        ],
      ),
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFFD6FF00)),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

extension _LastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
