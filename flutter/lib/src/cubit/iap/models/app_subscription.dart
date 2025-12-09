import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';

class AppSubscriptionRevCat extends AppSubscription {
  @override
  String get package => proEntitlement.productIdentifier;

  @override
  String? get exp => proEntitlement.expirationDate;

  @override
  String get originalPurchaseDate => proEntitlement.originalPurchaseDate;

  @override
  String get latestPurchaseDate => proEntitlement.latestPurchaseDate;

  final EntitlementInfo proEntitlement;

  AppSubscriptionRevCat(this.proEntitlement);
}
