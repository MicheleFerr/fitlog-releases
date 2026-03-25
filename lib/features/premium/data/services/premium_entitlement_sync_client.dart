library;

import 'package:cloud_functions/cloud_functions.dart';

abstract class PremiumEntitlementSyncClient {
  Future<void> syncEntitlements(String userId);
}

class CloudFunctionPremiumEntitlementSyncClient
    implements PremiumEntitlementSyncClient {
  CloudFunctionPremiumEntitlementSyncClient({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<void> syncEntitlements(String userId) async {
    final callable = _functions.httpsCallable(
      'syncRevenueCatEntitlements',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
    );

    await callable.call<Map<String, dynamic>>({'userId': userId});
  }
}
