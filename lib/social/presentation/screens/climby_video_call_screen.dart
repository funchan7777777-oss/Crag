import 'dart:async';

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
  Timer? _durationTimer;
  bool _cameraEnabled = true;
  bool _micEnabled = true;
  bool _speakerEnabled = true;
  bool _connected = false;
  Duration _elapsed = Duration.zero;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _prepareCameraAndMic();
  }

  Future<void> _prepareCameraAndMic() async {
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
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _connected = true;
      });
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF071112),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.user.avatarAsset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.42),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: topInset + 92,
              padding: EdgeInsets.fromLTRB(18, topInset + 8, 18, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF071718).withValues(alpha: 0.96),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user.name.replaceAll('.', ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _connected ? _timeLabel : 'Calling...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.62),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: bottomInset + 178,
            child: _LocalPreview(
              controller: _controller,
              cameraEnabled: _cameraEnabled,
              error: _error,
            ),
          ),
          if (_error != null)
            Positioned(
              left: 22,
              right: 22,
              top: topInset + 118,
              child: const _PermissionPanel(),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(28, 26, 28, bottomInset + 28),
              decoration: BoxDecoration(
                color: const Color(0xFF071112).withValues(alpha: 0.98),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CallControlButton(
                    asset: _cameraEnabled
                        ? 'assets/images/Topout.png'
                        : 'assets/images/Approach.png',
                    onTap: () =>
                        setState(() => _cameraEnabled = !_cameraEnabled),
                  ),
                  _CallControlButton(
                    asset: _micEnabled
                        ? 'assets/images/Buddy.png'
                        : 'assets/images/Belay.png',
                    onTap: () => setState(() => _micEnabled = !_micEnabled),
                  ),
                  _CallControlButton(
                    asset: _speakerEnabled
                        ? 'assets/images/Roster.png'
                        : 'assets/images/Meetup.png',
                    onTap: () =>
                        setState(() => _speakerEnabled = !_speakerEnabled),
                  ),
                  _CallControlButton(
                    endCall: true,
                    onTap: () => Navigator.of(context).pop(),
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

class _LocalPreview extends StatelessWidget {
  const _LocalPreview({
    required this.controller,
    required this.cameraEnabled,
    required this.error,
  });

  final CameraController? controller;
  final bool cameraEnabled;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final ready = controller != null && controller!.value.isInitialized;
    return Container(
      width: 112,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF141A1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: cameraEnabled && ready
          ? _CameraPreviewBox(controller: controller!)
          : _PreviewFallback(
              icon: error == null
                  ? Icons.videocam_off_rounded
                  : Icons.lock_outline_rounded,
              text: error == null ? 'Camera off' : 'Permission',
            ),
    );
  }
}

class _CameraPreviewBox extends StatelessWidget {
  const _CameraPreviewBox({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _PreviewFallback extends StatelessWidget {
  const _PreviewFallback({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF151A1B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.76), size: 30),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionPanel extends StatelessWidget {
  const _PermissionPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111718).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6FF00)),
      ),
      child: const Text(
        'Camera and microphone access are required to preview yourself before this video call.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.onTap,
    this.asset,
    this.endCall = false,
  });

  final VoidCallback onTap;
  final String? asset;
  final bool endCall;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: endCall ? const Color(0xFFFF4F42) : const Color(0xFF212728),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: endCall
            ? const Icon(Icons.call_end_rounded, color: Colors.white, size: 32)
            : Image.asset(asset!, width: 62, height: 62, fit: BoxFit.contain),
      ),
    );
  }
}
