import 'package:flutter/material.dart';

Future<void> showCragNoticeDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 34),
        child: CragPeakNoticeCard(
          title: title,
          message: message,
          onContinue: () => Navigator.of(context).pop(),
        ),
      );
    },
  );
}

class CragPeakNoticeCard extends StatelessWidget {
  const CragPeakNoticeCard({
    required this.title,
    required this.message,
    required this.onContinue,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(240.0, 292.0);
        return Center(
          child: SizedBox(
            width: width,
            height: width * 1.27,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/dialog_peak_badge.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: 34,
                  right: 34,
                  top: width * 0.35,
                  bottom: width * 0.37,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF101516),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(
                              0xFF101516,
                            ).withValues(alpha: 0.72),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.32,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 48,
                  right: 48,
                  bottom: width * 0.16,
                  child: Semantics(
                    button: true,
                    label: 'Continue',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onContinue,
                      child: Image.asset(
                        'assets/images/dialog_lead_badge.png',
                        height: 48,
                        fit: BoxFit.fill,
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
}
