import 'package:flutter/material.dart';

import '../../../access_trail/presentation/widgets/crag_notice_dialog.dart';
import '../../data/climby_wallet_store.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  final _wallet = ClimbyWalletStore.instance;
  int _seenEventSerial = 0;

  @override
  void initState() {
    super.initState();
    _seenEventSerial = _wallet.eventSerial;
    _wallet.addListener(_handleWalletEvent);
    _wallet.load();
  }

  @override
  void dispose() {
    _wallet.removeListener(_handleWalletEvent);
    super.dispose();
  }

  void _handleWalletEvent() {
    if (!mounted || _wallet.eventSerial == _seenEventSerial) {
      return;
    }
    _seenEventSerial = _wallet.eventSerial;
    final event = _wallet.latestEvent;
    if (event == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showCragNoticeDialog(
        context: context,
        title: event.title,
        message: event.message,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Vibe.png', fit: BoxFit.fill),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          AnimatedBuilder(
            animation: _wallet,
            builder: (context, _) {
              return ListView(
                padding: EdgeInsets.fromLTRB(16, topInset + 76, 16, 28),
                children: [
                  _WalletBalancePanel(balance: _wallet.balance),
                  const SizedBox(height: 16),
                  const _WalletSectionTitle('Recharge rack'),
                  const SizedBox(height: 10),
                  for (final package in climbyCoinPackages) ...[
                    _CoinPackageRow(
                      package: package,
                      busy: _wallet.busyProductId == package.productId,
                      onTap: () => _wallet.buyPackage(package),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 18),
                  const _WalletSectionTitle('Coin burn map'),
                  const SizedBox(height: 10),
                  for (final feature in walletSpendFeatures) ...[
                    _SpendFeatureRow(feature: feature),
                    const SizedBox(height: 10),
                  ],
                  const _FreeChatNotice(),
                ],
              );
            },
          ),
          _WalletTopBar(topInset: topInset),
        ],
      ),
    );
  }
}

Future<bool> spendCoinsOrOpenWallet({
  required BuildContext context,
  required WalletSpendFeature feature,
}) async {
  final wallet = ClimbyWalletStore.instance;
  final result = await wallet.spend(feature);
  if (!context.mounted) {
    return false;
  }
  if (result == WalletSpendResult.success) {
    await showCragNoticeDialog(
      context: context,
      title: 'Coins clipped',
      message:
          '${feature.cost} coins used for ${feature.title}. Balance: ${wallet.balance}.',
    );
    return true;
  }
  await _showInsufficientAndOpenWallet(context, feature);
  return false;
}

Future<bool> unlockWithCoinsOrOpenWallet({
  required BuildContext context,
  required WalletSpendFeature feature,
  required String unlockKey,
}) async {
  final wallet = ClimbyWalletStore.instance;
  final result = await wallet.unlock(feature: feature, unlockKey: unlockKey);
  if (!context.mounted) {
    return false;
  }
  if (result == WalletSpendResult.alreadyUnlocked) {
    return true;
  }
  if (result == WalletSpendResult.success) {
    await showCragNoticeDialog(
      context: context,
      title: 'Route unlocked',
      message:
          '${feature.title} opened for ${feature.cost} coins. Balance: ${wallet.balance}.',
    );
    return true;
  }
  await _showInsufficientAndOpenWallet(context, feature);
  return false;
}

Future<void> _showInsufficientAndOpenWallet(
  BuildContext context,
  WalletSpendFeature feature,
) async {
  await showCragNoticeDialog(
    context: context,
    title: 'More coins needed',
    message:
        '${feature.title} needs ${feature.cost} coins. Recharge your chalk bag to continue.',
  );
  if (!context.mounted) {
    return;
  }
  await Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const MyWalletScreen()));
}

class _WalletTopBar extends StatelessWidget {
  const _WalletTopBar({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      top: topInset + 2,
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const Text(
              'My Wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletBalancePanel extends StatelessWidget {
  const _WalletBalancePanel({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121819).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6FF00), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD6FF00).withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/Quickdraw.png',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live coin balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCoins(balance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD6FF00),
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Purchases are fetched from Apple when you tap a package.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletSectionTitle extends StatelessWidget {
  const _WalletSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

class _CoinPackageRow extends StatelessWidget {
  const _CoinPackageRow({
    required this.package,
    required this.busy,
    required this.onTap,
  });

  final ClimbyCoinPackage package;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy ? null : onTap,
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141418).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFD6FF00).withValues(alpha: 0.36),
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/Quickdraw.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatCoins(package.coins)} coins',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    package.productId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 84,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: busy
                    ? const SizedBox(
                        key: ValueKey('busy'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Color(0xFFD6FF00),
                        ),
                      )
                    : Text(
                        package.fallbackPrice,
                        key: ValueKey(package.fallbackPrice),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFFD6FF00),
                          fontSize: 15,
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
  }
}

class _SpendFeatureRow extends StatelessWidget {
  const _SpendFeatureRow({required this.feature});

  final WalletSpendFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF121819).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFD6FF00),
              shape: BoxShape.circle,
            ),
            child: Text(
              feature.cost.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeChatNotice extends StatelessWidget {
  const _FreeChatNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF23302E).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Text(
        'Messaging, mutual follows, safety reports, and video calls never consume coins.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          height: 1.25,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

String _formatCoins(int coins) {
  final raw = coins.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < raw.length; index += 1) {
    final fromEnd = raw.length - index;
    buffer.write(raw[index]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}
