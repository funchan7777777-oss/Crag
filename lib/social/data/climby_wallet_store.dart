import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClimbyWalletStore extends ChangeNotifier {
  ClimbyWalletStore._();

  static final ClimbyWalletStore instance = ClimbyWalletStore._();

  static const welcomeCoins = 1200;
  static const _balanceKey = 'climby.wallet.balance.v1';
  static const _welcomeGrantedKey = 'climby.wallet.welcome.granted.v1';
  static const _processedPurchaseIdsKey =
      'climby.wallet.processed.purchase.ids.v1';
  static const _unlockedKeysKey = 'climby.wallet.unlocked.keys.v1';

  final InAppPurchase _iap = InAppPurchase.instance;
  SharedPreferences? _prefs;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final Set<String> _processedPurchaseIds = {};
  final Set<String> _unlockedKeys = {};
  bool _loaded = false;
  bool _welcomeGranted = false;
  int _balance = 0;
  String? _busyProductId;
  int _eventSerial = 0;
  WalletEvent? _latestEvent;

  bool get loaded => _loaded;
  bool get welcomeGranted => _welcomeGranted;
  int get balance => _balance;
  String? get busyProductId => _busyProductId;
  WalletEvent? get latestEvent => _latestEvent;
  int get eventSerial => _eventSerial;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    _balance = _prefs?.getInt(_balanceKey) ?? 0;
    _welcomeGranted = _prefs?.getBool(_welcomeGrantedKey) ?? false;
    _processedPurchaseIds.addAll(
      _prefs?.getStringList(_processedPurchaseIdsKey) ?? const <String>[],
    );
    _unlockedKeys.addAll(
      _prefs?.getStringList(_unlockedKeysKey) ?? const <String>[],
    );
    _purchaseSubscription ??= _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {
        _busyProductId = null;
        _publishEvent(
          const WalletEvent(
            title: 'Checkout paused',
            message: 'The App Store sheet did not finish. Try again later.',
          ),
        );
      },
    );
    _loaded = true;
    notifyListeners();
  }

  Future<int?> grantWelcomeCoinsIfNeeded() async {
    await load();
    if (_welcomeGranted) {
      return null;
    }
    _welcomeGranted = true;
    _balance += welcomeCoins;
    await _prefs?.setBool(_welcomeGrantedKey, true);
    await _writeBalance();
    _publishEvent(
      const WalletEvent(
        title: 'First ascent stash',
        message: '+1200 coins loaded into your chalk bag.',
      ),
    );
    return welcomeCoins;
  }

  bool isUnlocked(String key) {
    return _unlockedKeys.contains(key);
  }

  Future<WalletSpendResult> spend(WalletSpendFeature feature) async {
    await load();
    if (_balance < feature.cost) {
      return WalletSpendResult.insufficient;
    }
    _balance -= feature.cost;
    await _writeBalance();
    _publishEvent(
      WalletEvent(
        title: 'Coins clipped',
        message:
            '${feature.cost} coins burned on ${feature.title}. Chalk bag: $_balance.',
      ),
    );
    return WalletSpendResult.success;
  }

  Future<WalletSpendResult> unlock({
    required WalletSpendFeature feature,
    required String unlockKey,
  }) async {
    await load();
    if (_unlockedKeys.contains(unlockKey)) {
      return WalletSpendResult.alreadyUnlocked;
    }
    final result = await spend(feature);
    if (result != WalletSpendResult.success) {
      return result;
    }
    _unlockedKeys.add(unlockKey);
    await _prefs?.setStringList(_unlockedKeysKey, _unlockedKeys.toList());
    notifyListeners();
    return WalletSpendResult.success;
  }

  Future<void> buyPackage(ClimbyCoinPackage package) async {
    await load();
    if (_busyProductId != null) {
      _publishEvent(
        const WalletEvent(
          title: 'Hold the rope',
          message: 'One App Store checkout is already on the rope.',
        ),
      );
      return;
    }
    _busyProductId = package.productId;
    notifyListeners();

    final available = await _iap.isAvailable();
    if (!available) {
      _busyProductId = null;
      _publishEvent(
        const WalletEvent(
          title: 'Store unavailable',
          message: 'The App Store checkout route is not available right now.',
        ),
      );
      return;
    }

    final response = await _iap.queryProductDetails({package.productId});
    if (response.error != null || response.productDetails.isEmpty) {
      _busyProductId = null;
      _publishEvent(
        WalletEvent(
          title: 'Pack unavailable',
          message: 'This coin pack is not available from the App Store yet.',
        ),
      );
      return;
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    final started = await _iap.buyConsumable(purchaseParam: purchaseParam);
    if (!started) {
      _busyProductId = null;
      _publishEvent(
        const WalletEvent(
          title: 'Checkout not started',
          message: 'The App Store purchase sheet could not be opened.',
        ),
      );
      notifyListeners();
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    await load();
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        _busyProductId = purchase.productID;
        notifyListeners();
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        _busyProductId = null;
        _publishEvent(
          WalletEvent(
            title: 'Purchase failed',
            message:
                purchase.error?.message ??
                'The App Store checkout reported an error.',
          ),
        );
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _busyProductId = null;
        _publishEvent(
          const WalletEvent(
            title: 'Purchase canceled',
            message: 'No coins were added because the purchase was canceled.',
          ),
        );
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _creditPurchase(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _creditPurchase(PurchaseDetails purchase) async {
    final package = coinPackageByProductId(purchase.productID);
    if (package == null) {
      _busyProductId = null;
      _publishEvent(
        WalletEvent(
          title: 'Pack not matched',
          message: 'This App Store pack could not be matched to a coin refill.',
        ),
      );
      return;
    }

    final purchaseId =
        purchase.purchaseID ??
        '${purchase.productID}:${purchase.transactionDate ?? ''}';
    if (_processedPurchaseIds.contains(purchaseId)) {
      _busyProductId = null;
      notifyListeners();
      return;
    }

    _processedPurchaseIds.add(purchaseId);
    _balance += package.coins;
    await _prefs?.setStringList(
      _processedPurchaseIdsKey,
      _processedPurchaseIds.toList(),
    );
    await _writeBalance();
    _busyProductId = null;
    _publishEvent(
      WalletEvent(
        title: 'Coins secured',
        message: '+${package.coins} coins clipped in. Chalk bag: $_balance.',
      ),
    );
  }

  Future<void> _writeBalance() async {
    await _prefs?.setInt(_balanceKey, _balance);
    notifyListeners();
  }

  void _publishEvent(WalletEvent event) {
    _latestEvent = event;
    _eventSerial += 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

enum WalletSpendResult { success, insufficient, alreadyUnlocked }

class WalletEvent {
  const WalletEvent({required this.title, required this.message});

  final String title;
  final String message;
}

class WalletSpendFeature {
  const WalletSpendFeature({
    required this.id,
    required this.title,
    required this.cost,
    required this.description,
  });

  final String id;
  final String title;
  final int cost;
  final String description;
}

class ClimbyCoinPackage {
  const ClimbyCoinPackage({
    required this.productId,
    required this.coins,
    required this.fallbackPrice,
  });

  final String productId;
  final int coins;
  final String fallbackPrice;
}

const cruxRadarFeature = WalletSpendFeature(
  id: 'crux_radar',
  title: 'Crux Radar Scan',
  cost: 80,
  description: 'One focused movement scan with risk cues and send strategy.',
);

const spotDeepCardFeature = WalletSpendFeature(
  id: 'spot_deep_card',
  title: 'Spot Deep Card',
  cost: 60,
  description: 'Unlocks crowd timing, warmup circuit, and approach warnings.',
);

const projectBoostFeature = WalletSpendFeature(
  id: 'project_boost',
  title: 'Project Boost',
  cost: 120,
  description: 'Adds a neon spotlight pass to your submitted climbing post.',
);

const walletSpendFeatures = [
  cruxRadarFeature,
  spotDeepCardFeature,
  projectBoostFeature,
];

const climbyCoinPackages = [
  ClimbyCoinPackage(
    productId: 'hlcjzokvehlelfiw',
    coins: 50000,
    fallbackPrice: r'$99.99',
  ),
  ClimbyCoinPackage(
    productId: 'xdcjqwuzjrcmrhgt',
    coins: 25000,
    fallbackPrice: r'$49.99',
  ),
  ClimbyCoinPackage(
    productId: 'iodnmegoqkdrmyuk',
    coins: 10000,
    fallbackPrice: r'$19.99',
  ),
  ClimbyCoinPackage(
    productId: 'prtgzvfzgkwhoypa',
    coins: 5000,
    fallbackPrice: r'$9.99',
  ),
  ClimbyCoinPackage(
    productId: 'tapdbshkzpitcoio',
    coins: 2500,
    fallbackPrice: r'$4.99',
  ),
  ClimbyCoinPackage(
    productId: 'xavcaoduwoeomumo',
    coins: 1000,
    fallbackPrice: r'$1.99',
  ),
  ClimbyCoinPackage(
    productId: 'cubvxvzwwjhlyllz',
    coins: 500,
    fallbackPrice: r'$0.99',
  ),
];

ClimbyCoinPackage? coinPackageByProductId(String productId) {
  for (final package in climbyCoinPackages) {
    if (package.productId == productId) {
      return package;
    }
  }
  return null;
}
