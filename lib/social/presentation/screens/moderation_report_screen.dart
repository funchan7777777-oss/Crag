import 'package:flutter/material.dart';

import '../../../access_trail/presentation/widgets/crag_image_backdrop.dart';
import '../../data/climby_social_store.dart';

Future<void> openModerationScreen({
  required BuildContext context,
  required ClimbySocialStore store,
  required ModerationTarget target,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ModerationReportScreen(store: store, target: target),
    ),
  );
}

Future<void> showClimbyNotice({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF121516),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/Knot.png',
                width: 42,
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD6FF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showMutualFollowRequiredDialog(BuildContext context) {
  return showClimbyNotice(
    context: context,
    title: 'Mutual follow required',
    message:
        'For safety, chat messages and video calls unlock only after both climbers follow each other.',
  );
}

class ModerationReportScreen extends StatefulWidget {
  const ModerationReportScreen({
    required this.store,
    required this.target,
    super.key,
  });

  final ClimbySocialStore store;
  final ModerationTarget target;

  @override
  State<ModerationReportScreen> createState() => _ModerationReportScreenState();
}

class _ModerationReportScreenState extends State<ModerationReportScreen> {
  String _selectedReason = reportReasons.first;

  Future<void> _report() async {
    await widget.store.report(target: widget.target, reason: _selectedReason);
    if (!mounted) {
      return;
    }
    await showClimbyNotice(
      context: context,
      title: 'Report submitted',
      message: 'Thanks for helping keep the climbing community clean.',
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _block() async {
    await widget.store.block(widget.target);
    if (!mounted) {
      return;
    }
    await showClimbyNotice(
      context: context,
      title: 'Blocked',
      message: 'This content will no longer appear in your local experience.',
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CragImageBackdrop(
        assetPath: 'assets/images/HarborWallBackdrop.png',
        scrimOpacity: 0.22,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, topInset + 6, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 46,
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
                      'Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              for (final reason in reportReasons) ...[
                _ReasonButton(
                  label: reason,
                  selected: reason == _selectedReason,
                  onPressed: () => setState(() => _selectedReason = reason),
                ),
                const SizedBox(height: 18),
              ],
              const SizedBox(height: 8),
              SizedBox(
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD6FF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _report,
                  child: const Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF694D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _block,
                  child: const Text(
                    'Block',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonButton extends StatelessWidget {
  const _ReasonButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF151D1E).withValues(alpha: 0.94),
          foregroundColor: Colors.white,
          side: BorderSide(
            color: selected
                ? const Color(0xFFD6FF00)
                : Colors.white.withValues(alpha: 0.22),
            width: selected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
