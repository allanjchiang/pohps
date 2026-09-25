import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Optional one-time donations. Nothing is unlocked by a donation — the
/// products are consumables, so they can be bought again and there is no
/// entitlement to restore or verify.
///
/// Every call is guarded: on platforms without a store (or when the store is
/// unreachable) donations simply become unavailable and the UI hides them.
class DonationService {
  static const String smallProductId = 'dev_donation_small';
  static const String mediumProductId = 'dev_donation_medium';
  static const String largeProductId = 'dev_donation_large';

  /// Display order, smallest first.
  static const List<String> productIds = [
    smallProductId,
    mediumProductId,
    largeProductId,
  ];

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  InAppPurchase? get _iap {
    try {
      return InAppPurchase.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductDetails>> queryProducts() async {
    try {
      final iap = _iap;
      if (iap == null || !await iap.isAvailable()) return [];
      final response = await iap.queryProductDetails(productIds.toSet());
      return response.productDetails.toList()
        ..sort((a, b) =>
            productIds.indexOf(a.id).compareTo(productIds.indexOf(b.id)));
    } catch (_) {
      return [];
    }
  }

  /// Listens for purchase results for the whole app session, so a donation
  /// that finishes after the dialog closes (or an interrupted one delivered
  /// on the next launch) is still completed with the store.
  void listen({
    required void Function(List<PurchaseDetails> purchases) onUpdate,
    required void Function(Object error) onError,
  }) {
    _subscription?.cancel();
    _subscription = _iap?.purchaseStream.listen(onUpdate, onError: onError);
  }

  Future<bool> donate(ProductDetails product) async {
    try {
      final iap = _iap;
      if (iap == null) return false;
      return await iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _iap?.completePurchase(purchase);
    } catch (_) {}
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
