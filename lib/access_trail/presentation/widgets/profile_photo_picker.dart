import 'dart:io';

import 'package:flutter/material.dart';

class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    required this.photoPath,
    required this.onPressed,
    super.key,
  });

  final String? photoPath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.4,
              ),
              image: DecorationImage(
                image: hasPhoto
                    ? FileImage(File(photoPath!))
                    : const AssetImage('assets/images/brand_grip_mark.png')
                          as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(
                Icons.photo_camera_rounded,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
