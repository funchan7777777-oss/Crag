import 'package:flutter/material.dart';

import '../../data/local_crag_access_cache.dart';
import '../controllers/access_copy_ledger.dart';
import '../widgets/access_text_field.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/crag_notice_dialog.dart';
import '../widgets/ledge_back_button.dart';
import '../widgets/neon_hold_button.dart';
import '../widgets/policy_agreement_strip.dart';
import 'climber_profile_tuning_screen.dart';
import 'policy_web_ledge_screen.dart';
import 'rope_account_entry_screen.dart';

class FreshRopeSignupScreen extends StatefulWidget {
  const FreshRopeSignupScreen({required this.cache, super.key});

  final LocalCragAccessCache cache;

  @override
  State<FreshRopeSignupScreen> createState() => _FreshRopeSignupScreenState();
}

class _FreshRopeSignupScreenState extends State<FreshRopeSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _acceptedPolicy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_guardAgreement()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (!AccessCopyLedger.emailLooksReady(email)) {
      await showCragNoticeDialog(
        context: context,
        title: 'Email needed',
        message: 'Add a valid email so Crag can save this local route card.',
      );
      return;
    }
    if (password.trim().length < 6) {
      await showCragNoticeDialog(
        context: context,
        title: 'Rope code needed',
        message: 'Use at least 6 characters for this local rope code.',
      );
      return;
    }
    if (password != confirm) {
      await showCragNoticeDialog(
        context: context,
        title: 'Passwords differ',
        message: 'Match both rope-code fields before setting the card.',
      );
      return;
    }

    await widget.cache.keepLocalCredential(
      emailTrail: email,
      passwordGrip: password,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClimberProfileTuningScreen(
          cache: widget.cache,
          accessRoute: 'password',
          corridorKey: 'mail:${email.toLowerCase()}',
          contactEmail: email,
          initialTrailName: AccessCopyLedger.trailNameFromEmail(email),
        ),
      ),
    );
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => RopeAccountEntryScreen(cache: widget.cache),
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
          'Review the route rules and privacy notes before setting your card.',
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
            assetPath: 'assets/images/backdrop_night_wall.png',
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
                  const SizedBox(height: 42),
                  AccessTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  AccessTextField(
                    label: 'Rope code',
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
                  const SizedBox(height: 18),
                  AccessTextField(
                    label: 'Confirm rope code',
                    controller: _confirmController,
                    obscureText: _hideConfirm,
                    trailing: IconButton(
                      onPressed: () {
                        setState(() => _hideConfirm = !_hideConfirm);
                      },
                      icon: Icon(
                        _hideConfirm
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  NeonHoldButton(label: 'Set Route Card', onPressed: _signUp),
                  const SizedBox(height: 22),
                  Center(
                    child: GestureDetector(
                      onTap: _openLogin,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                          children: const [
                            TextSpan(text: 'Already tied in? '),
                            TextSpan(
                              text: 'Clip in',
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
