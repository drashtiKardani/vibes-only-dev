import 'dart:io' show Platform;

import 'package:purchases_flutter/purchases_flutter.dart';

/// A single-method class for initializing RevenueCat.
abstract class InAppPurchaseService {
  static Future<void> initPlatformState() async {
    PurchasesConfiguration configuration = Platform.isAndroid
        ? PurchasesConfiguration('goog_ksWGQKZKPpMYfhGBIXuwKOfumnH') // Android
        : PurchasesConfiguration('appl_JURCjNAFPsDtSOzOYsNsUmFUpvZ'); // iOS

    await Purchases.configure(configuration);
  }
}
