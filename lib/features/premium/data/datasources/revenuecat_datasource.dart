library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatDatasource {
  bool _isConfigured = false;
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  bool get isConfigured => _isConfigured;

  Future<void> configure(String apiKey) async {
    if (_isConfigured) return;

    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _isConfigured = true;

    Purchases.addCustomerInfoUpdateListener((info) {
      _customerInfoController.add(info);
    });

    if (kDebugMode) {
      debugPrint('[RevenueCat] Configured successfully');
    }
  }

  Future<Offerings> getOfferings() async {
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return Purchases.getCustomerInfo();
  }

  /// Returns the RC PurchaseResult which contains customerInfo + transaction
  Future<PurchaseResult> purchasePackage(Package package) async {
    return Purchases.purchase(PurchaseParams.package(package));
  }

  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }

  Future<LogInResult> logIn(String userId) async {
    return Purchases.logIn(userId);
  }

  Future<CustomerInfo> logOut() async {
    return Purchases.logOut();
  }

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  void dispose() {
    _customerInfoController.close();
  }
}
