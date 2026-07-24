import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Wraps the platform in-app-purchase plugin for POHPS Pro. Subscriptions
/// are bought via [InAppPurchase.buyNonConsumable] — the plugin has no
/// separate "buy subscription" call; auto-renewable subscriptions are
/// purchased the same way as non-consumables.
///
/// There is no backend for this app, so entitlement is always re-verified
/// live against the store (via [restorePurchases]) rather than trusted from
/// a locally cached flag alone.
class SubscriptionService {
  static const String monthlyProductId = 'pohps_pro_monthly';
  static const String annualProductId = 'pohps_pro_annual';
  static const Set<String> productIds = {monthlyProductId, annualProductId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails(productIds);
    return response.productDetails;
  }

  void listen({
    required void Function(List<PurchaseDetails> purchases) onUpdate,
    required void Function(Object error) onError,
  }) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(onUpdate, onError: onError);
  }

  Future<bool> buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> completePurchase(PurchaseDetails purchase) {
    if (purchase.pendingCompletePurchase) {
      return _iap.completePurchase(purchase);
    }
    return Future.value();
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
