import 'package:flutter/material.dart';

import '../controllers/access_copy_ledger.dart';

class PolicyAgreementStrip extends StatelessWidget {
  const PolicyAgreementStrip({
    required this.accepted,
    required this.onChanged,
    required this.onOpenPolicy,
    super.key,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onOpenPolicy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: accepted,
            activeColor: const Color(0xFFD6FF00),
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white, width: 1.4),
            onChanged: (value) => onChanged(value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('I have read and agree to the ', style: _copyStyle()),
              GestureDetector(
                onTap: () => onOpenPolicy(AccessCopyLedger.termsUrl),
                child: Text('Terms of Service', style: _linkStyle()),
              ),
              Text(' and ', style: _copyStyle()),
              GestureDetector(
                onTap: () => onOpenPolicy(AccessCopyLedger.privacyUrl),
                child: Text('Privacy Policy', style: _linkStyle()),
              ),
              Text('.', style: _copyStyle()),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _copyStyle() {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0,
    );
  }

  TextStyle _linkStyle() {
    return const TextStyle(
      color: Color(0xFFD6FF00),
      fontSize: 12,
      fontWeight: FontWeight.w800,
      height: 1.35,
      letterSpacing: 0,
    );
  }
}
