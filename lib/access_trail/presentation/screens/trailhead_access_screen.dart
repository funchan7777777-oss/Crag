import 'package:flutter/material.dart';

import '../../data/local_crag_access_cache.dart';
import '../widgets/crag_image_backdrop.dart';
import '../widgets/neon_hold_button.dart';
import 'rope_account_entry_screen.dart';

class TrailheadAccessScreen extends StatelessWidget {
  const TrailheadAccessScreen({required this.cache, super.key});

  final LocalCragAccessCache cache;

  void _openPasswordLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RopeAccountEntryScreen(cache: cache),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: CragImageBackdrop(
        assetPath: 'assets/images/Carabiner.png',
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 0, 24, 44),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: NeonHoldButton(
              label: 'Get Start',
              onPressed: () => _openPasswordLogin(context),
            ),
          ),
        ),
      ),
    );
  }
}
