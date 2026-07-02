import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/local_crag_access_cache.dart';
import '../controllers/access_copy_ledger.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/crag_notice_dialog.dart';
import '../widgets/neon_hold_button.dart';
import '../widgets/policy_agreement_strip.dart';
import 'climber_profile_tuning_screen.dart';
import 'fresh_rope_signup_screen.dart';
import 'policy_web_ledge_screen.dart';
import 'rope_account_entry_screen.dart';

class TrailheadAccessScreen extends StatefulWidget {
  const TrailheadAccessScreen({required this.cache, super.key});

  final LocalCragAccessCache cache;

  @override
  State<TrailheadAccessScreen> createState() => _TrailheadAccessScreenState();
}

class _TrailheadAccessScreenState extends State<TrailheadAccessScreen> {
  bool _acceptedPolicy = false;
  bool _appleBusy = false;

  bool _guardAgreement() {
    if (_acceptedPolicy) {
      return true;
    }
    showCragNoticeDialog(
      context: context,
      title: 'Agreement needed',
      message:
          'Please agree to the Terms of Service and Privacy Policy before continuing.',
    );
    return false;
  }

  void _openPolicy(String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PolicyWebLedgeScreen(
          url: url,
          screenTitle: url == AccessCopyLedger.termsUrl
              ? 'Terms of Service'
              : 'Privacy Policy',
        ),
      ),
    );
  }

  void _openPasswordLogin() {
    if (!_guardAgreement()) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RopeAccountEntryScreen(cache: widget.cache),
      ),
    );
  }

  void _openSignup() {
    if (!_guardAgreement()) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FreshRopeSignupScreen(cache: widget.cache),
      ),
    );
  }

  Future<void> _startAppleRoute() async {
    if (!_guardAgreement()) {
      return;
    }
    setState(() => _appleBusy = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final parts = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((part) => part.trim().isNotEmpty);
      final appleName = parts.join(' ').trim();
      final cachedName = widget.cache.readAppleTrailName();
      final resolvedName = appleName.isNotEmpty
          ? appleName
          : cachedName ?? 'Crag Partner';
      await widget.cache.rememberAppleTrailName(resolvedName);

      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ClimberProfileTuningScreen(
            cache: widget.cache,
            accessRoute: 'apple',
            corridorKey: 'apple:${credential.userIdentifier ?? 'private'}',
            contactEmail: credential.email,
            initialTrailName: resolvedName,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      showCragNoticeDialog(
        context: context,
        title: 'Apple sign-in paused',
        message:
            'Apple sign-in did not complete. Please try again with your Apple account.',
      );
    } finally {
      if (mounted) {
        setState(() => _appleBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: CragImageBackdrop(
        assetPath: 'assets/images/HarborWallBackdrop.png',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 74, 24, 28),
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
              const Spacer(),
              NeonHoldButton(
                label: 'Continue with Apple',
                busy: _appleBusy,
                leading: const Icon(Icons.apple_rounded, color: Colors.black),
                onPressed: _startAppleRoute,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _openPasswordLogin,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/Mantle.png',
                    height: 56,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _openSignup,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/Team.png',
                    height: 56,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PolicyAgreementStrip(
                accepted: _acceptedPolicy,
                onChanged: (accepted) {
                  setState(() => _acceptedPolicy = accepted);
                },
                onOpenPolicy: _openPolicy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
