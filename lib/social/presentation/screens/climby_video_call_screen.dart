import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../data/climby_social_store.dart';

class ClimbyVideoCallScreen extends StatefulWidget {
  const ClimbyVideoCallScreen({required this.user, super.key});

  final ClimbyUser user;

  @override
  State<ClimbyVideoCallScreen> createState() => _ClimbyVideoCallScreenState();
}

class _ClimbyVideoCallScreenState extends State<ClimbyVideoCallScreen> {
  CameraController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _prepareCamera();
  }

  Future<void> _prepareCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera available');
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            CameraPreview(controller)
          else
            Center(
              child: _error == null
                  ? const CircularProgressIndicator(color: Color(0xFFD6FF00))
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Camera or microphone permission is required before starting a video call.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.48),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.58),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: topInset + 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
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
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 28,
            child: SizedBox(
              height: 56,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4F42),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'End Call',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
