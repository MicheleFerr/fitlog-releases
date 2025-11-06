/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: presentation/providers
/// 🎯 Feature: premium
/// 🔧 Type: provider (purchase management)
/// 
/// Handles premium subscription purchases through Apple/Google payment systems
/// with automatic profile refresh and error handling
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/auth/presentation/providers/user_profile_provider.dart';

/// Premium upgrade state
class PremiumUpgradeState {
  
  const PremiumUpgradeState({
    this.isProcessing = false,
    this.errorMessage,
    this.availableProducts = const [],
    this.isRestoring = false,
    this.lastPurchaseStatus,
  });
  final bool isProcessing;
  final String? errorMessage;
  final List<ProductDetails> availableProducts;
  final bool isRestoring;
  final PurchaseStatus? lastPurchaseStatus;
  
  PremiumUpgradeState copyWith({
    bool? isProcessing,
    String? errorMessage,
    List<ProductDetails>? availableProducts,
    bool? isRestoring,
    PurchaseStatus? lastPurchaseStatus,
  }) {
    return PremiumUpgradeState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      availableProducts: availableProducts ?? this.availableProducts,
      isRestoring: isRestoring ?? this.isRestoring,
      lastPurchaseStatus: lastPurchaseStatus ?? this.lastPurchaseStatus,
    );
  }
}

/// Premium plan types matching UI
enum PremiumPlan {
  monthly,
  yearly,
  lifetime,
}

/// Premium upgrade provider
class PremiumUpgradeNotifier extends StateNotifier<PremiumUpgradeState> {
  
  PremiumUpgradeNotifier(this._ref) : super(const PremiumUpgradeState()) {
    _initialize();
  }
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  // Product IDs for App Store and Google Play
  static const Map<PremiumPlan, String> _iosProductIds = {
    PremiumPlan.monthly: 'com.gymbro.premium.monthly',
    PremiumPlan.yearly: 'com.gymbro.premium.yearly',
    PremiumPlan.lifetime: 'com.gymbro.premium.lifetime',
  };
  
  static const Map<PremiumPlan, String> _androidProductIds = {
    PremiumPlan.monthly: 'premium_monthly',
    PremiumPlan.yearly: 'premium_yearly',
    PremiumPlan.lifetime: 'premium_lifetime',
  };
  
  /// Initialize IAP and load products
  Future<void> _initialize() async {
    try {
      // Check if IAP is available
      final available = await _iap.isAvailable();
      if (!available) {
        state = state.copyWith(
          errorMessage: 'In-app purchases not available on this device',
        );
        return;
      }
      
      // Listen to purchase updates
      _purchaseSubscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdate,
        onError: (error) {
          debugPrint('❌ Purchase stream error: $error');
          state = state.copyWith(
            errorMessage: 'Purchase error: $error',
            isProcessing: false,
          );
        },
      );
      
      // Load available products
      await _loadProducts();
      
    } catch (e) {
      debugPrint('❌ IAP initialization error: $e');
      state = state.copyWith(
        errorMessage: 'Failed to initialize purchases: $e',
      );
    }
  }
  
  /// Load available products from stores
  Future<void> _loadProducts() async {
    try {
      // Get product IDs based on platform
      final productIds = Platform.isIOS 
          ? _iosProductIds.values.toSet()
          : _androidProductIds.values.toSet();
      
      // Query product details
      final response = await _iap.queryProductDetails(productIds);
      
      if (response.error != null) {
        debugPrint('❌ Product query error: ${response.error}');
        state = state.copyWith(
          errorMessage: 'Failed to load products: ${response.error}',
        );
        return;
      }
      
      // Sort products by price
      final products = response.productDetails..sort((a, b) {
        final priceA = double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        final priceB = double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        return priceA.compareTo(priceB);
      });
      
      state = state.copyWith(
        availableProducts: products,
        errorMessage: null,
      );
      
      debugPrint('✅ Loaded ${products.length} products');
      
    } catch (e) {
      debugPrint('❌ Load products error: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load products: $e',
      );
    }
  }
  
  /// Purchase premium subscription
  Future<bool> purchasePremium(PremiumPlan plan) async {
    try {
      state = state.copyWith(
        isProcessing: true,
        errorMessage: null,
        lastPurchaseStatus: null,
      );
      
      // Get product ID based on platform
      final productId = Platform.isIOS 
          ? _iosProductIds[plan]
          : _androidProductIds[plan];
      
      if (productId == null) {
        throw Exception('Product not found for plan: $plan');
      }
      
      // Find product details
      final product = state.availableProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('Product $productId not loaded'),
      );
      
      // Create purchase param
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: FirebaseAuth.instance.currentUser?.uid,
      );
      
      // Initiate purchase
      final success = plan == PremiumPlan.lifetime
          ? await _iap.buyNonConsumable(purchaseParam: purchaseParam)
          : await _iap.buyConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        throw Exception('Purchase initiation failed');
      }
      
      // Wait for purchase completion (handled in stream listener)
      // The actual success/failure will be handled by _handlePurchaseUpdate
      
      // Return true to indicate purchase was initiated
      // The UI will wait for the actual result via state updates
      return true;
      
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
  
  /// Handle purchase updates from store
  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('📦 Purchase update: ${purchase.status}');
      
      state = state.copyWith(lastPurchaseStatus: purchase.status);
      
      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Purchase is pending (e.g., waiting for approval)
          debugPrint('⏳ Purchase pending: ${purchase.productID}');
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Purchase successful!
          debugPrint('✅ Purchase successful: ${purchase.productID}');
          
          // Verify purchase with backend
          final verified = await _verifyPurchase(purchase);
          
          if (verified) {
            // Complete the purchase
            await _iap.completePurchase(purchase);
            
            // Refresh user profile immediately
            // Note: currentUserProvider is a StreamProvider, it will auto-update
            // when the backend updates the user document
            await Future.delayed(const Duration(seconds: 1)); // Give backend time to update
            
            state = state.copyWith(
              isProcessing: false,
              errorMessage: null,
            );
            
            debugPrint('🎉 Premium activated successfully!');
          } else {
            // Verification failed
            state = state.copyWith(
              isProcessing: false,
              errorMessage: 'Purchase verification failed',
            );
          }
          break;
          
        case PurchaseStatus.error:
          // Purchase failed
          debugPrint('❌ Purchase error: ${purchase.error}');
          
          await _iap.completePurchase(purchase);
          
          state = state.copyWith(
            isProcessing: false,
            errorMessage: _getErrorMessage(purchase.error),
          );
          break;
          
        case PurchaseStatus.canceled:
          // User cancelled
          debugPrint('🚫 Purchase cancelled');
          
          await _iap.completePurchase(purchase);
          
          state = state.copyWith(
            isProcessing: false,
            errorMessage: null, // Don't show error for cancellation
          );
          break;
      }
    }
  }
  
  /// Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ No authenticated user for verification');
        return false;
      }
      
      // Call Cloud Function to verify and activate premium
      final callable = _functions.httpsCallable('verifyPremiumPurchase');
      final result = await callable.call({
        'userId': user.uid,
        'productId': purchase.productID,
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'purchaseId': purchase.purchaseID,
      });
      
      final success = result.data['success'] as bool? ?? false;
      
      if (success) {
        debugPrint('✅ Purchase verified by backend');
      } else {
        debugPrint('❌ Backend verification failed: ${result.data['error']}');
      }
      
      return success;
      
    } catch (e) {
      debugPrint('❌ Verification error: $e');
      
      // In development, auto-approve for testing
      if (kDebugMode) {
        debugPrint('⚠️ DEBUG MODE: Auto-approving purchase');
        
        // Simulate backend update
        await Future.delayed(const Duration(seconds: 1));
        
        // Force refresh profile
        // Note: currentUserProvider is a StreamProvider, it will auto-update
        await Future.delayed(const Duration(seconds: 1)); // Give backend time to update
        
        return true;
      }
      
      return false;
    }
  }
  
  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      state = state.copyWith(
        isRestoring: true,
        errorMessage: null,
      );
      
      await _iap.restorePurchases();
      
      // Restoration results will come through purchase stream
      // Wait a bit for processing
      await Future.delayed(const Duration(seconds: 2));
      
      state = state.copyWith(isRestoring: false);
      
      // Check if user is now premium
      // Wait for the stream to update
      await Future.delayed(const Duration(seconds: 1));
      
      final userProfileAsync = _ref.read(userProfileProvider);
      final userProfile = userProfileAsync.value;
      
      // Check if the user has premium using UserProfile which has isPremium property
      if (userProfile?.isPremium ?? false) {
        debugPrint('✅ Premium restored successfully');
      } else {
        state = state.copyWith(
          errorMessage: 'No premium purchases found to restore',
        );
      }
      
    } catch (e) {
      debugPrint('❌ Restore error: $e');
      state = state.copyWith(
        isRestoring: false,
        errorMessage: 'Failed to restore purchases: $e',
      );
    }
  }
  
  /// Get user-friendly error message
  String _getErrorMessage(IAPError? error) {
    if (error == null) return 'Unknown error occurred';
    
    switch (error.code) {
      case 'purchase_cancelled':
        return 'Purchase was cancelled';
      case 'payment_invalid':
        return 'Payment information is invalid';
      case 'payment_not_allowed':
        return 'Purchases are not allowed on this device';
      case 'store_product_not_available':
        return 'Product is not available in the store';
      case 'cloud_service_permission_denied':
        return 'Cloud service permission denied';
      case 'cloud_service_network_connection_failed':
        return 'Network connection failed. Please try again.';
      default:
        return error.message ?? 'Purchase failed. Please try again.';
    }
  }
  
  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Check if a specific plan is available
  bool isPlanAvailable(PremiumPlan plan) {
    final productId = Platform.isIOS 
        ? _iosProductIds[plan]
        : _androidProductIds[plan];
    
    return state.availableProducts.any((p) => p.id == productId);
  }
  
  /// Get price for a specific plan
  String? getPlanPrice(PremiumPlan plan) {
    final productId = Platform.isIOS 
        ? _iosProductIds[plan]
        : _androidProductIds[plan];
    
    try {
      final product = state.availableProducts.firstWhere(
        (p) => p.id == productId,
      );
      return product.price;
    } catch (_) {
      return null;
    }
  }
  
  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

/// Premium upgrade provider
final premiumUpgradeProvider = StateNotifierProvider<PremiumUpgradeNotifier, PremiumUpgradeState>((ref) {
  return PremiumUpgradeNotifier(ref);
});

/// Check if purchase is in progress
final isPurchasingProvider = Provider<bool>((ref) {
  return ref.watch(premiumUpgradeProvider).isProcessing;
});

/// Get available products
final availableProductsProvider = Provider<List<ProductDetails>>((ref) {
  return ref.watch(premiumUpgradeProvider).availableProducts;
});

/// Get purchase error
final purchaseErrorProvider = Provider<String?>((ref) {
  return ref.watch(premiumUpgradeProvider).errorMessage;
});