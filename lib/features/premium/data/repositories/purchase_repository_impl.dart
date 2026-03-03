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

  @override
  Future<void> initialize() async {
    if (!RevenueCatConfig.isConfigured) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] RevenueCat API key not configured, skipping init');
      }
      return;
    }
    try {
      await _datasource.configure(RevenueCatConfig.apiKey);
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Initialized, isConfigured=${_datasource.isConfigured}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Failed to initialize RevenueCat: $e');
      }
    }
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    if (!_datasource.isConfigured) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Cannot get plans: datasource not configured');
      }
      return [];
    }

    try {
      final offerings = await _datasource.getOfferings();
      _cachedOfferings = offerings;
      final plans = mapOfferingsToPlans(offerings);
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Found ${plans.length} plans');
        if (plans.isEmpty) {
          debugPrint('[PurchaseRepo] Current offering: ${offerings.current?.identifier}');
          debugPrint('[PurchaseRepo] Packages: ${offerings.current?.availablePackages.length ?? 0}');
        }
      }
      return plans;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Failed to get offerings: $e');
      }
      return [];
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (!_datasource.isConfigured) return SubscriptionStatus.free();

    try {
      final info = await _datasource.getCustomerInfo();
      return mapCustomerInfoToStatus(info);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Failed to get status: $e');
      }
      return SubscriptionStatus.free();
    }
  }

  @override
  Stream<SubscriptionStatus> watchSubscriptionStatus() async* {
    if (!_datasource.isConfigured) {
      yield SubscriptionStatus.free();
      return;
    }

    // Emit current status first (the listener stream only fires on updates)
    try {
      final info = await _datasource.getCustomerInfo();
      yield mapCustomerInfoToStatus(info);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Failed to get initial status: $e');
      }
      yield SubscriptionStatus.free();
    }

    // Then listen for future updates
    yield* _datasource.customerInfoStream.map(mapCustomerInfoToStatus);
  }

  @override
  Future<domain.PurchaseResult> purchase(SubscriptionPlan plan) async {
    if (!_datasource.isConfigured) {
      return const domain.PurchaseError('RevenueCat not configured');
    }

    final package = _findPackage(plan);
    if (package == null) {
      return const domain.PurchaseError('Package not found');
    }

    try {
      await _datasource.purchasePackage(package);
      return const domain.PurchaseSuccess();
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return const domain.PurchaseCancelled();
      }
      return domain.PurchaseError(e.message ?? 'Purchase failed');
    }
  }

  @override
  Future<domain.PurchaseResult> restorePurchases() async {
    if (!_datasource.isConfigured) {
      return const domain.PurchaseError('RevenueCat not configured');
    }

    try {
      final info = await _datasource.restorePurchases();
      final status = mapCustomerInfoToStatus(info);
      if (status.isActive) {
        return const domain.PurchaseSuccess();
      }
      return const domain.PurchaseError('noPurchasesToRestore');
    } on PlatformException catch (e) {
      return domain.PurchaseError(e.message ?? 'Restore failed');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (!_datasource.isConfigured) return;
    try {
      await _datasource.logIn(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Failed to set user ID: $e');
      }
    }
  }

  @override
  Future<void> logout() async {
    if (!_datasource.isConfigured) return;
    try {
      await _datasource.logOut();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[PurchaseRepo] Failed to logout: $e');
      }
    }
  }

  Package? _findPackage(SubscriptionPlan plan) {
    final offerings = _cachedOfferings;
    if (offerings?.current == null) return null;

    for (final pkg in offerings!.current!.availablePackages) {
      if (pkg.storeProduct.identifier == plan.id ||
          pkg.identifier == plan.rcPackageIdentifier) {
        return pkg;
      }
    }
    return null;
  }
}
