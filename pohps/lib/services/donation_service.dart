import 'dart:async';

import 'package:flutter/foundation.dart';
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
      if (iap == null) {
        debugPrint('Donations: no store plugin on this platform');
        return [];
      }
      if (!await iap.isAvailable()) {
        debugPrint('Donations: store unavailable (billing not connected)');
        return [];
      }
      final response = await iap.queryProductDetails(productIds.toSet());
      // Logged in release builds too (logcat tag "flutter"), so a Play-
      // installed build can show why the donation card is hidden.
      if (response.error != null) {
        debugPrint('Donations: query error ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Donations: products not found ${response.notFoundIDs}');
      }
      debugPrint('Donations: loaded '
          '${response.productDetails.map((p) => p.id).toList()}');
      return response.productDetails.toList()
        ..sort((a, b) =>
            productIds.indexOf(a.id).compareTo(productIds.indexOf(b.id)));
    } catch (e) {
      debugPrint('Donations: query failed $e');
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
    try {
      _subscription = _iap?.purchaseStream.listen(onUpdate, onError: onError);
    } catch (_) {
      // No store on this platform (e.g. desktop): nothing to listen to.
      _subscription = null;
    }
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
