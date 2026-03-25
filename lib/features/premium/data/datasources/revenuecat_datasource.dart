library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatDatasource {
  bool _isConfigured = false;
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  bool get isConfigured => _isConfigured;

  Future<void> configure(String apiKey) async {
    if (_isConfigured) {
      _log('configure() skipped: datasource already configured');
      return;
    }

    _log(
      'configure() start: apiKeyPresent=${apiKey.isNotEmpty}, apiKeyPreview=${_redactApiKey(apiKey)}',
    );

    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _isConfigured = true;
    _log('configure() success: Purchases.configure completed');

    Purchases.addCustomerInfoUpdateListener((info) {
      _log(
        'customerInfoUpdateListener: ${_summarizeCustomerInfo(info)}',
      );
      _customerInfoController.add(info);
    });
  }

  Future<Offerings> getOfferings() async {
    _log('getOfferings() start');
    final offerings = await Purchases.getOfferings();
    _log('getOfferings() success: ${_summarizeOfferings(offerings)}');
    return offerings;
  }

  Future<List<StoreProduct>> getProducts(
    List<String> productIdentifiers, {
    ProductCategory productCategory = ProductCategory.subscription,
  }) async {
    if (productIdentifiers.isEmpty) {
      _log('getProducts() skipped: no identifiers for ${productCategory.name}');
      return const [];
    }

    _log(
      'getProducts() start: category=${productCategory.name}, '
      'productIds=$productIdentifiers',
    );
    final products = await Purchases.getProducts(
      productIdentifiers,
      productCategory: productCategory,
    );
    _log(
      'getProducts() success: category=${productCategory.name}, '
      '${_summarizeProducts(products)}',
    );
    return products;
  }

  Future<CustomerInfo> getCustomerInfo() async {
    _log('getCustomerInfo() start');
    final info = await Purchases.getCustomerInfo();
    _log('getCustomerInfo() success: ${_summarizeCustomerInfo(info)}');
    return info;
  }

  /// Returns the RC PurchaseResult which contains customerInfo + transaction
  Future<PurchaseResult> purchasePackage(Package package) async {
    _log(
      'purchasePackage() start: package=${package.identifier}, '
      'packageType=${package.packageType.name}, '
      'productId=${package.storeProduct.identifier}, '
      'price=${package.storeProduct.priceString}',
    );
    final result = await Purchases.purchase(PurchaseParams.package(package));
    _log(
      'purchasePackage() success: ${_summarizeCustomerInfo(result.customerInfo)}',
    );
    return result;
  }

  Future<PurchaseResult> purchaseStoreProduct(StoreProduct product) async {
    _log(
      'purchaseStoreProduct() start: productId=${product.identifier}, '
      'title=${product.title}, price=${product.priceString}, '
      'subscriptionPeriod=${product.subscriptionPeriod ?? '<none>'}',
    );
    final result = await Purchases.purchase(
      PurchaseParams.storeProduct(product),
    );
    _log(
      'purchaseStoreProduct() success: '
      '${_summarizeCustomerInfo(result.customerInfo)}',
    );
    return result;
  }

  Future<CustomerInfo> restorePurchases() async {
    _log('restorePurchases() start');
    final info = await Purchases.restorePurchases();
    _log('restorePurchases() success: ${_summarizeCustomerInfo(info)}');
    return info;
  }

  Future<LogInResult> logIn(String userId) async {
    _log('logIn() start: userId=$userId');
    final result = await Purchases.logIn(userId);
    _log(
      'logIn() success: created=${result.created}, '
      '${_summarizeCustomerInfo(result.customerInfo)}',
    );
    return result;
  }

  Future<CustomerInfo> logOut() async {
    _log('logOut() start');
    final info = await Purchases.logOut();
    _log('logOut() success: ${_summarizeCustomerInfo(info)}');
    return info;
  }

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  void dispose() {
    _log('dispose() closing customerInfo stream');
    _customerInfoController.close();
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[RevenueCatDatasource] $message');
    }
  }

  String _redactApiKey(String apiKey) {
    if (apiKey.isEmpty) return '<empty>';
    if (apiKey.length <= 8) return '${apiKey.substring(0, 2)}***';
    return '${apiKey.substring(0, 6)}***${apiKey.substring(apiKey.length - 4)}';
  }

  String _summarizeOfferings(Offerings offerings) {
    final current = offerings.current;
    final currentPackages = current?.availablePackages
            .map(
              (pkg) =>
                  '${pkg.identifier}/${pkg.packageType.name}'
                  '->${pkg.storeProduct.identifier}@${pkg.storeProduct.priceString}',
            )
            .join(', ') ??
        '<none>';

    return 'currentOffering=${current?.identifier ?? '<null>'}, '
        'offerings=${offerings.all.keys.toList()}, '
        'currentPackages=[$currentPackages]';
  }

  String _summarizeProducts(List<StoreProduct> products) {
    if (products.isEmpty) return 'products=<empty>';

    final summary = products
        .map(
          (product) =>
              '${product.identifier}@${product.priceString}'
              '(period=${product.subscriptionPeriod ?? '<none>'})',
        )
        .join(', ');

    return 'products=[$summary]';
  }

  String _summarizeCustomerInfo(CustomerInfo info) {
    final activeEntitlements = info.entitlements.active.keys.toList();
    final allEntitlements = info.entitlements.all.entries
        .map(
          (entry) =>
              '${entry.key}(active=${entry.value.isActive}, '
              'product=${entry.value.productIdentifier}, '
              'expires=${entry.value.expirationDate ?? '<none>'})',
        )
        .join(', ');

    return 'activeEntitlements=$activeEntitlements, '
        'allEntitlements=[$allEntitlements], '
        'managementUrl=${info.managementURL ?? '<null>'}';
  }
}
