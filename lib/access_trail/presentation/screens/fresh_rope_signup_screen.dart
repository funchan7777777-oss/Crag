import 'package:flutter/material.dart';

import '../../data/local_crag_access_cache.dart';
import '../controllers/access_copy_ledger.dart';
import '../widgets/access_text_field.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/crag_notice_dialog.dart';
import '../widgets/ledge_back_button.dart';
import '../widgets/neon_hold_button.dart';
import 'climber_profile_tuning_screen.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (!AccessCopyLedger.emailLooksReady(email)) {
      await showCragNoticeDialog(
        context: context,
        title: 'Email needed',
        message: 'Please enter a valid email to set up this local account.',
      );
      return;
    }
    if (password.trim().length < 6) {
      await showCragNoticeDialog(
        context: context,
        title: 'Password needed',
        message: 'Use at least 6 characters so the local account can be saved.',
      );
      return;
    }
    if (password != confirm) {
      await showCragNoticeDialog(
        context: context,
        title: 'Passwords differ',
        message: 'Please make both password fields match before signing up.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CragImageBackdrop(
            assetPath: 'assets/images/HarborWallBackdrop.png',
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
                  const SizedBox(height: 18),
                  AccessTextField(
                    label: 'Confirm password',
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
                  NeonHoldButton(label: 'Sign up', onPressed: _signUp),
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
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
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
