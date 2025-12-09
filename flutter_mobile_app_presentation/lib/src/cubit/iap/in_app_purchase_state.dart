import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import 'models/app_subscription.dart';

class InAppPurchaseState extends Equatable {
  final InAppPurchaseStatus status;
  final AppSubscription? appSubscription;
  final PlatformException? error;

  const InAppPurchaseState._({this.status = InAppPurchaseStatus.unknown, this.appSubscription, this.error});

  const InAppPurchaseState.unknown() : this._();

  const InAppPurchaseState.userNotLoggedIn() : this._(status: InAppPurchaseStatus.userNotLoggedIn);

  const InAppPurchaseState.active(AppSubscription appSubscription)
      : this._(status: InAppPurchaseStatus.active, appSubscription: appSubscription);

  const InAppPurchaseState.makingPurchase() : this._(status: InAppPurchaseStatus.makingPurchase);

  const InAppPurchaseState.inactive() : this._(status: InAppPurchaseStatus.inactive);

  const InAppPurchaseState.error(PlatformException error) : this._(status: InAppPurchaseStatus.error, error: error);

  bool get isActive => status == InAppPurchaseStatus.active;

  bool isNotActive() => status != InAppPurchaseStatus.active;

  @override
  List<Object> get props => [status];
}

enum InAppPurchaseStatus {
  active,
  makingPurchase,
  inactive,
  unknown,
  userNotLoggedIn,
  error,
}
