// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
// Note: Ignoring false positive issues of using emit() in an extension of a Cubit.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:vibes_only/src/cubit/iap/models/app_subscription.dart';

class InAppPurchaseRevCatCubit extends InAppPurchaseCubit {
  Timer? _checkSubscriptionTimer;

  /// This has been set up on the RevenueCat panel.
  static const _proEntitlementId = 'pro';

  InAppPurchaseRevCatCubit() : super(const InAppPurchaseState.unknown());

  @override
  Future<void> makePurchase(dynamic product) async {
    assert(product is Package);

    emit(const InAppPurchaseState.makingPurchase());

    try {
      final PurchaseResult purchaseResult = await Purchases.purchase(product);
      _checkForActiveSubscription(purchaseResult.customerInfo);
    } on PlatformException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      emit(InAppPurchaseState.error(e));
    }
  }

  @override
  Future<void> restorePurchase() async {
    emit(const InAppPurchaseState.makingPurchase());

    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _checkForActiveSubscription(customerInfo);
    } on PlatformException catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      emit(InAppPurchaseState.error(e));
    }
  }

  @override
  Future<void> checkUserSubscription() async {
    if (Flavor.isStaging()) {
      emit(
        SyncSharedPreferences.simulatedSubscription.value
            ? InAppPurchaseState.active(_simulatedValidSubscriptionResponse)
            : const InAppPurchaseState.inactive(),
      );
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      emit(const InAppPurchaseState.userNotLoggedIn());
    } else {
      try {
        // Sync to migrate already subscribed users or
        // in case user did purchased a package outside the app flow, e.g. using a promo link.
        await Purchases.syncPurchases();

        CustomerInfo customerInfo = await Purchases.getCustomerInfo();
        _checkForActiveSubscription(customerInfo);
      } on PlatformException catch (e) {
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
        emit(InAppPurchaseState.error(e));
      }
    }
  }

  void _checkForActiveSubscription(CustomerInfo customerInfo) {
    final proEntitlement = customerInfo.entitlements.all[_proEntitlementId];

    if (proEntitlement?.isActive == true) {
      // Grant user "pro" access
      emit(InAppPurchaseState.active(AppSubscriptionRevCat(proEntitlement!)));

      _checkSubscriptionTimer ??= Timer.periodic(const Duration(minutes: 10), (
        timer,
      ) {
        print('\$\$\$ Check#${timer.tick}: Is subscription still valid?');
        checkUserSubscription();
      });
    } else {
      emit(const InAppPurchaseState.inactive());
      _checkSubscriptionTimer?.cancel();
      _checkSubscriptionTimer = null;
    }
  }

  @override
  void simulateSubscribedUser() {
    if (Flavor.isStaging()) {
      emit(InAppPurchaseState.active(_simulatedValidSubscriptionResponse));
      SyncSharedPreferences.simulatedSubscription.value = true;
    } else {
      print('NO EFFECT! This function is only for staging!');
    }
  }

  @override
  void simulateFreeUser() {
    if (Flavor.isStaging()) {
      emit(const InAppPurchaseState.inactive());
      SyncSharedPreferences.simulatedSubscription.value = false;
    } else {
      print('NO EFFECT! This function is only for staging!');
    }
  }
}

final _simulatedValidSubscriptionResponse = AppSubscriptionRevCat(
  const EntitlementInfo('Simulated', true, true, '', '', 'simulated', true),
);

extension AdminPanelSimulator on InAppPurchaseCubit {
  void simulateSubscribedUserForAdminPanel() {
    emit(InAppPurchaseState.active(_simulatedValidSubscriptionResponse));
  }
}
