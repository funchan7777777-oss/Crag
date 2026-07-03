import 'package:flutter/material.dart';

import '../../../access_trail/presentation/widgets/crag_image_backdrop.dart';
import '../../../access_trail/presentation/widgets/crag_notice_dialog.dart';
import '../../data/climby_social_store.dart';

enum ModerationResult { reported, blocked }

Future<ModerationResult?> openModerationScreen({
  required BuildContext context,
  required ClimbySocialStore store,
  required ModerationTarget target,
}) {
  return Navigator.of(context).push<ModerationResult>(
    MaterialPageRoute<ModerationResult>(
      builder: (_) => ModerationReportScreen(store: store, target: target),
    ),
  );
}

Future<void> showClimbyNotice({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showCragNoticeDialog(context: context, title: title, message: message);
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
      title: 'Report clipped in',
      message: 'Thanks. This item is hidden while the safety route is checked.',
    );
    if (mounted) {
      Navigator.of(context).pop(ModerationResult.reported);
    }
  }

  Future<void> _block() async {
    await widget.store.block(widget.target);
    if (!mounted) {
      return;
    }
    await showClimbyNotice(
      context: context,
      title: 'Climber blocked',
      message: 'Their posts, comments, and chat notes are now off your wall.',
    );
    if (mounted) {
      Navigator.of(context).pop(ModerationResult.blocked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CragImageBackdrop(
        assetPath: 'assets/images/backdrop_harbor_wall.png',
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
