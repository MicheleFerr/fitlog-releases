library;

import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/services.dart' show PlatformException;
import 'package:gymbro_flutter_new/core/config/revenuecat_config.dart';
import 'package:gymbro_flutter_new/features/premium/data/datasources/revenuecat_datasource.dart';
import 'package:gymbro_flutter_new/features/premium/data/mappers/purchase_mappers.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/purchase_result.dart'
    as domain;
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_plan.dart';
import 'package:gymbro_flutter_new/features/premium/domain/entities/subscription_status.dart';
import 'package:gymbro_flutter_new/features/premium/domain/repositories/purchase_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl({required RevenueCatDatasource datasource})
    : _datasource = datasource;

  final RevenueCatDatasource _datasource;

  /// Cached offerings for purchase calls
  Offerings? _cachedOfferings;
  final Map<String, StoreProduct> _cachedStoreProducts =
      <String, StoreProduct>{};

  @override
  Future<void> initialize() async {
    if (!RevenueCatConfig.isConfigured) {
      _log(
        'initialize(): RevenueCat API key missing. '
        'Expected env var REVENUECAT_API_KEY. Skipping init.',
      );
      return;
    }
    try {
      _log(
        'initialize(): start with entitlement=${RevenueCatConfig.premiumEntitlementId}, '
        'productIds=['
        '${RevenueCatConfig.monthlyProductId}, '
        '${RevenueCatConfig.yearlyProductId}, '
        '${RevenueCatConfig.lifetimeProductId}]',
      );
      await _datasource.configure(RevenueCatConfig.apiKey);
      _log(
        'initialize(): success, datasourceConfigured=${_datasource.isConfigured}',
      );
    } catch (e) {
      _log('initialize(): failed with error=$e');
    }
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    if (!_datasource.isConfigured) {
      _log(
        'getAvailablePlans(): datasource not configured, returning empty list',
      );
      return [];
    }

    const maxAttempts = 3;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        _log('getAvailablePlans(): attempt $attempt/$maxAttempts');
        final plans = await _loadPlans();
        _log(
          'getAvailablePlans(): mapped ${plans.length} plan(s): ${_describePlans(plans)}',
        );
        if (plans.isEmpty) {
          _log(
            'getAvailablePlans(): no plans mapped from offerings or direct store lookup',
          );
        }

        if (plans.isNotEmpty || attempt == maxAttempts) {
          return plans;
        }
      } catch (e) {
        _log(
          'getAvailablePlans(): attempt $attempt/$maxAttempts failed with error=$e',
        );
        if (attempt == maxAttempts) {
          return [];
        }
      }

      await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
    }

    return [];
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (!_datasource.isConfigured) {
      if (!RevenueCatConfig.isConfigured) return SubscriptionStatus.free();
      throw StateError('RevenueCat not initialized');
    }

    try {
      _log('getSubscriptionStatus(): fetching customer info');
      final info = await _datasource.getCustomerInfo();
      final status = mapCustomerInfoToStatus(info);
      _log('getSubscriptionStatus(): ${_describeStatus(status)}');
      return status;
    } catch (e) {
      _log('getSubscriptionStatus(): failed with error=$e');
      rethrow;
    }
  }

  @override
  Stream<SubscriptionStatus> watchSubscriptionStatus() async* {
    if (!_datasource.isConfigured) {
      _log('watchSubscriptionStatus(): datasource not configured, yielding free');
      yield SubscriptionStatus.free();
      return;
    }

    // Emit current status first (the listener stream only fires on updates)
    try {
      _log('watchSubscriptionStatus(): fetching initial customer info');
      final info = await _datasource.getCustomerInfo();
      final status = mapCustomerInfoToStatus(info);
      _log('watchSubscriptionStatus(): initial ${_describeStatus(status)}');
      yield status;
    } catch (e) {
      _log('watchSubscriptionStatus(): initial fetch failed with error=$e');
      yield SubscriptionStatus.free();
    }

    // Then listen for future updates
    yield* _datasource.customerInfoStream.map((info) {
      final status = mapCustomerInfoToStatus(info);
      _log('watchSubscriptionStatus(): update ${_describeStatus(status)}');
      return status;
    });
  }

  @override
  Future<domain.PurchaseResult> purchase(SubscriptionPlan plan) async {
    if (!_datasource.isConfigured) {
      _log('purchase(): datasource not configured');
      return const domain.PurchaseError('RevenueCat not configured');
    }

    _log(
      'purchase(): requested plan id=${plan.id}, '
      'period=${plan.period.name}, '
      'price=${plan.priceString}, '
      'rcPackageIdentifier=${plan.rcPackageIdentifier}',
    );
    final package = _findPackage(plan);
    final directProduct = package == null ? _findDirectProduct(plan) : null;
    if (package == null && directProduct == null) {
      _log(
        'purchase(): product not found for plan=${plan.id}. '
        'cachedOfferingsPresent=${_cachedOfferings != null}, '
        'cachedStoreProducts=${_cachedStoreProducts.keys.toList()}',
      );
      return const domain.PurchaseError('Package not found');
    }

    try {
      final purchaseResult = package != null
          ? await _datasource.purchasePackage(package)
          : await _datasource.purchaseStoreProduct(directProduct!);
      final status = mapCustomerInfoToStatus(purchaseResult.customerInfo);
      if (!status.isActive) {
        _log(
          'purchase(): completed but entitlement inactive. ${_describeStatus(status)}',
        );
        return const domain.PurchaseError('premiumActivationFailed');
      }
      _log('purchase(): success ${_describeStatus(status)}');
      return const domain.PurchaseSuccess();
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      _log(
        'purchase(): platform exception code=${errorCode.name}, '
        'message=${e.message}, details=${e.details}',
      );
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return const domain.PurchaseCancelled();
      }
      return domain.PurchaseError(e.message ?? 'Purchase failed');
    }
  }

  @override
  Future<domain.PurchaseResult> restorePurchases() async {
    if (!_datasource.isConfigured) {
      _log('restorePurchases(): datasource not configured');
      return const domain.PurchaseError('RevenueCat not configured');
    }

    try {
      _log('restorePurchases(): start');
      final info = await _datasource.restorePurchases();
      final status = mapCustomerInfoToStatus(info);
      if (status.isActive) {
        _log('restorePurchases(): success ${_describeStatus(status)}');
        return const domain.PurchaseSuccess();
      }
      _log('restorePurchases(): completed but no active entitlement');
      return const domain.PurchaseError('noPurchasesToRestore');
    } on PlatformException catch (e) {
      _log(
        'restorePurchases(): platform exception code='
        '${PurchasesErrorHelper.getErrorCode(e).name}, '
        'message=${e.message}, details=${e.details}',
      );
      return domain.PurchaseError(e.message ?? 'Restore failed');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_datasource.isConfigured) {
      _log('setUserId(): datasource not configured, skipping userId=$userId');
      return;
    }
    try {
      _cachedOfferings = null;
      _cachedStoreProducts.clear();
      _log('setUserId(): logging into RevenueCat with userId=$userId');
      final result = await _datasource.logIn(userId);
      _log(
        'setUserId(): login success created=${result.created}, '
        '${_describeStatus(mapCustomerInfoToStatus(result.customerInfo))}',
      );
    } catch (e) {
      _log('setUserId(): failed for userId=$userId with error=$e');
    }
  }

  @override
  Future<void> logout() async {
    if (!_datasource.isConfigured) {
      _log('logout(): datasource not configured, nothing to do');
      return;
    }
    try {
      _cachedOfferings = null;
      _cachedStoreProducts.clear();
      _log('logout(): start');
      final info = await _datasource.logOut();
      _log('logout(): success ${_describeStatus(mapCustomerInfoToStatus(info))}');
    } catch (e) {
      _log('logout(): failed with error=$e');
    }
  }

  Package? _findPackage(SubscriptionPlan plan) {
    final offerings = _cachedOfferings;
    if (offerings == null) {
      _log('_findPackage(): no cached offerings for plan=${plan.id}');
      return null;
    }

    final currentPackages = offerings.current?.availablePackages ?? const [];
    final fallbackPackages = offerings.all.values.expand(
      (offering) => offering.availablePackages,
    );

    for (final pkg in [...currentPackages, ...fallbackPackages]) {
      if (pkg.storeProduct.identifier == plan.id ||
          pkg.identifier == plan.rcPackageIdentifier) {
        _log(
          '_findPackage(): matched plan=${plan.id} to package=${pkg.identifier} '
          '(productId=${pkg.storeProduct.identifier})',
        );
        return pkg;
      }
    }
    _log(
      '_findPackage(): no package match for plan=${plan.id}. '
      'searchedPackages=${[...currentPackages, ...fallbackPackages].map((pkg) => '${pkg.identifier}/${pkg.storeProduct.identifier}').toList()}',
    );
    return null;
  }

  StoreProduct? _findDirectProduct(SubscriptionPlan plan) {
    final product = _cachedStoreProducts[plan.id];
    if (product != null) {
      _log(
        '_findDirectProduct(): matched plan=${plan.id} '
        'to storeProduct=${product.identifier}',
      );
      return product;
    }

    _log(
      '_findDirectProduct(): no direct product match for plan=${plan.id}. '
      'cachedStoreProducts=${_cachedStoreProducts.keys.toList()}',
    );
    return null;
  }

  Future<List<SubscriptionPlan>> _loadPlans() async {
    _cachedStoreProducts.clear();

    try {
      final offerings = await _datasource.getOfferings();
      _cachedOfferings = offerings;

      final offeringPlans = _sortPlans(mapOfferingsToPlans(offerings));
      if (offeringPlans.isNotEmpty) {
        _log(
          '_loadPlans(): using RevenueCat offering plans '
          '${_describePlans(offeringPlans)}',
        );
        return offeringPlans;
      }

      _log(
        '_loadPlans(): offerings resolved but produced no plans. '
        'Falling back to direct store products.',
      );
    } catch (e) {
      _cachedOfferings = null;
      _log('_loadPlans(): getOfferings failed with error=$e');
      _log('_loadPlans(): falling back to direct store products');
    }

    return _loadDirectStoreProductPlans();
  }

  Future<List<SubscriptionPlan>> _loadDirectStoreProductPlans() async {
    final products = <StoreProduct>[
      ...await _loadProductsForCategory(
        <String>[
          RevenueCatConfig.monthlyProductId,
          RevenueCatConfig.yearlyProductId,
        ],
        productCategory: ProductCategory.subscription,
      ),
      ...await _loadProductsForCategory(
        <String>[RevenueCatConfig.lifetimeProductId],
        productCategory: ProductCategory.nonSubscription,
      ),
    ];

    for (final product in products) {
      _cachedStoreProducts[product.identifier] = product;
    }

    final plans = _sortPlans(products.map(mapStoreProductToPlan).toList());
    _log(
      '_loadDirectStoreProductPlans(): resolved ${plans.length} direct plan(s): '
      '${_describePlans(plans)}',
    );
    return plans;
  }

  Future<List<StoreProduct>> _loadProductsForCategory(
    List<String> productIds, {
    required ProductCategory productCategory,
  }) async {
    try {
      return await _datasource.getProducts(
        productIds,
        productCategory: productCategory,
      );
    } catch (e) {
      _log(
        '_loadProductsForCategory(): failed for '
        'category=${productCategory.name}, productIds=$productIds, error=$e',
      );
      return const <StoreProduct>[];
    }
  }

  List<SubscriptionPlan> _sortPlans(List<SubscriptionPlan> plans) {
    final dedupedPlans = <String, SubscriptionPlan>{};
    for (final plan in plans) {
      dedupedPlans[plan.id] = plan;
    }

    final sortedPlans = dedupedPlans.values.toList()
      ..sort(
        (a, b) => _periodSortOrder(a.period).compareTo(
          _periodSortOrder(b.period),
        ),
      );
    return sortedPlans;
  }

  int _periodSortOrder(SubscriptionPeriod period) {
    return switch (period) {
      SubscriptionPeriod.monthly => 0,
      SubscriptionPeriod.yearly => 1,
      SubscriptionPeriod.lifetime => 2,
    };
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[PurchaseRepo] $message');
    }
  }

  String _describePlans(List<SubscriptionPlan> plans) {
    if (plans.isEmpty) return '<empty>';
    return plans
        .map(
          (plan) =>
              '${plan.id}/${plan.period.name}@${plan.priceString}'
              '(rc=${plan.rcPackageIdentifier ?? '<null>'})',
        )
        .join(', ');
  }

  String _describeStatus(SubscriptionStatus status) {
    return 'active=${status.isActive}, '
        'productId=${status.productId ?? '<null>'}, '
        'willRenew=${status.willRenew}, '
        'isLifetime=${status.isLifetime}, '
        'expiration=${status.expirationDate?.toIso8601String() ?? '<none>'}, '
        'managementUrl=${status.managementUrl ?? '<null>'}';
  }
}
