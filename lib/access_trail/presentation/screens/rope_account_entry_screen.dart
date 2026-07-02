import 'package:flutter/material.dart';

import '../../data/local_crag_access_cache.dart';
import '../../domain/models/climber_access_card.dart';
import '../controllers/access_copy_ledger.dart';
import '../widgets/access_text_field.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/crag_notice_dialog.dart';
import '../widgets/ledge_back_button.dart';
import '../widgets/neon_hold_button.dart';
import '../widgets/policy_agreement_strip.dart';
import 'fresh_rope_signup_screen.dart';
import 'policy_web_ledge_screen.dart';
import 'ridge_entry_loading_screen.dart';

class RopeAccountEntryScreen extends StatefulWidget {
  const RopeAccountEntryScreen({required this.cache, super.key});

  final LocalCragAccessCache cache;

  @override
  State<RopeAccountEntryScreen> createState() => _RopeAccountEntryScreenState();
}

class _RopeAccountEntryScreenState extends State<RopeAccountEntryScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _acceptedPolicy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_guardAgreement()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!AccessCopyLedger.emailLooksReady(email)) {
      await showCragNoticeDialog(
        context: context,
        title: 'Email needed',
        message: 'Please enter a valid email before starting.',
      );
      return;
    }
    if (password.trim().length < 6) {
      await showCragNoticeDialog(
        context: context,
        title: 'Password needed',
        message: 'Please enter at least 6 characters for the password.',
      );
      return;
    }
    if (widget.cache.localCredentialRejects(
      emailTrail: email,
      passwordGrip: password,
    )) {
      await showCragNoticeDialog(
        context: context,
        title: 'Grip check failed',
        message: 'The saved local password for this email does not match.',
      );
      return;
    }

    await widget.cache.keepLocalCredential(
      emailTrail: email,
      passwordGrip: password,
    );
    final trailName =
        widget.cache.storedTrailNameFor(email) ??
        AccessCopyLedger.trailNameFromEmail(email);
    await widget.cache.anchorActiveCard(
      ClimberAccessCard(
        corridorKey: 'mail:${email.toLowerCase()}',
        accessRoute: 'password',
        contactEmail: email,
        trailName: trailName,
        fieldBio: 'Keeping a quiet log of clean climbs and better footwork.',
        anchoredAtIso: DateTime.now().toIso8601String(),
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RidgeEntryLoadingScreen(cache: widget.cache),
      ),
    );
  }

  void _openSignup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FreshRopeSignupScreen(cache: widget.cache),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CragImageBackdrop(
            assetPath: 'assets/images/Vibe.png',
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
                  const SizedBox(height: 52),
                  AccessTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 22),
                  AccessTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    trailing: IconButton(
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  NeonHoldButton(label: 'Login', onPressed: _start),
                  const SizedBox(height: 22),
                  Center(
                    child: GestureDetector(
                      onTap: _openSignup,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                          children: const [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Color(0xFFD6FF00),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
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
          const LedgeBackButton(),
        ],
      ),
    );
  }
}
