import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/api.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/cubit/iap/constants.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:vibes_only/src/dialog/promotion_dialog.dart';

void fetchPromotionsAndShowPopup(BuildContext context) {
  GetIt.I<VibeApiNew>().getAllPromotions().then((allPromotions) {
    try {
      final membershipDate =
          FirebaseAuth.instance.currentUser?.metadata.creationTime;
      final memberForDays = membershipDate != null
          ? DateTime.now().difference(membershipDate).inDays
          : 0;

      final paidUser =
          BlocProvider.of<InAppPurchaseCubit>(context).state.isActive;

      final registrationDate = BlocProvider.of<InAppPurchaseCubit>(context)
          .state
          .appSubscription
          ?.originalPurchaseDate;
      final registeredForDays = registrationDate != null
          ? DateTime.parse(registrationDate).difference(DateTime.now()).inDays
          : null;

      final subExpDate = BlocProvider.of<InAppPurchaseCubit>(context)
          .state
          .appSubscription
          ?.exp;
      final expDateInDays = subExpDate != null
          ? DateTime.parse(subExpDate).difference(DateTime.now()).inDays
          : null;

      final subPackage = BlocProvider.of<InAppPurchaseCubit>(context)
          .state
          .appSubscription
          ?.package;
      final subIsMonthly =
          subPackage != null ? subPackage == IapConstants.kIdMonthly : null;

      print('-----' * 20);
      print('Membership date: $membershipDate; days since: $memberForDays');
      print('Is paid user: $paidUser');
      print(
          'Registration date: $registrationDate; days since: $registeredForDays');
      print('Expiration date: $subExpDate; days until: $expDateInDays');
      print('Subscribed to package: $subPackage; is monthly: $subIsMonthly');

      final eligiblePromotions = <Promotion>[];
      for (final promotion in allPromotions) {
        final cond1 = (promotion.target == PromotionTarget.paid) == paidUser;

        final cond2 = promotion.subscriptionType == null ||
            (promotion.subscriptionType ==
                    PromotionSubscriptionType.monthlyBilling) ==
                subIsMonthly;

        final cond3 = promotion.daysSinceMembershipStart == null ||
            promotion.daysSinceMembershipStartConstraint == null ||
            _compareDays(
                memberForDays,
                promotion.daysSinceMembershipStartConstraint!,
                promotion.daysSinceMembershipStart!);

        final cond4 = promotion.daysSinceRegistration == null ||
            promotion.daysSinceRegistrationConstraint == null ||
            registeredForDays == null ||
            _compareDays(
                registeredForDays,
                promotion.daysSinceRegistrationConstraint!,
                promotion.daysSinceRegistration!);

        final cond5 = promotion.daysUntilSubscriptionEnd == null ||
            promotion.daysUntilSubscriptionEndConstraint == null ||
            expDateInDays == null ||
            _compareDays(
                expDateInDays,
                promotion.daysUntilSubscriptionEndConstraint!,
                promotion.daysUntilSubscriptionEnd!);

        final cond6 = promotion.frequency == null ||
            _promoDisplayCount(promotion.id) < promotion.frequency! &&
                (_promoLastTimeDisplay(promotion.id) == null ||
                    DateTime.now()
                            .difference(_promoLastTimeDisplay(promotion.id)!)
                            .inHours >
                        24);

        print('-----' * 20);
        print('Promotion ${promotion.id} ${promotion.title}');
        print('Target: ${promotion.target}; cond1: $cond1');
        print('Sub type: ${promotion.subscriptionType}; cond2: $cond2');
        print('daysSinceMembershipStart: '
            '${promotion.daysSinceMembershipStartConstraint} '
            '${promotion.daysSinceMembershipStart}; cond3: $cond3');
        print('daysSinceRegistration: '
            '${promotion.daysSinceRegistrationConstraint} '
            '${promotion.daysSinceRegistration}; cond4: $cond4');
        print('daysUntilSubscriptionEnd: '
            '${promotion.daysUntilSubscriptionEndConstraint} '
            '${promotion.daysUntilSubscriptionEnd}; cond5: $cond5');
        print('frequency: ${promotion.frequency}; '
            'display count: ${_promoDisplayCount(promotion.id)}; '
            'last time: ${_promoLastTimeDisplay(promotion.id)}; cond6: $cond6');

        if (cond1 && cond2 && cond3 && cond4 && cond5 && cond6) {
          eligiblePromotions.add(promotion);
        }
      }
      print('-----' * 20);

      if (eligiblePromotions.isNotEmpty) {
        final promotionToShow =
            eligiblePromotions[Random().nextInt(eligiblePromotions.length)];

        _incrementPromoDisplayCount(promotionToShow.id);
        _setLastTimePromoDisplayToNow(promotionToShow.id);

        showPromotionDialog(
          context,
          title: promotionToShow.title,
          body: promotionToShow.body,
          code: promotionToShow.code,
        );
      }
    } catch (_) {}
  });
}

bool _compareDays(int userDays, Constraint constraint, int promotionDays) {
  switch (constraint) {
    case Constraint.moreThan:
      return userDays > promotionDays;
    case Constraint.equals:
      return userDays == promotionDays;
    case Constraint.lessThan:
      return userDays < promotionDays;
  }
}

const _promotionDisplayCountKey = 'PROMOTION_DISPLAY_COUNT';

String _promoCountKey(int id) => '${_promotionDisplayCountKey}_$id';

const _promotionLastTimeDisplayKey = 'PROMOTION_LAST_TIME_DISPLAY';

String _promoLastTimeKey(int id) => '${_promotionLastTimeDisplayKey}_$id';

int _promoDisplayCount(int promotionId) {
  return SyncSharedPreferences.instance.getInt(_promoCountKey(promotionId)) ??
      0;
}

void _incrementPromoDisplayCount(int promotionId) {
  SyncSharedPreferences.instance
      .setInt(_promoCountKey(promotionId), _promoDisplayCount(promotionId) + 1);
}

DateTime? _promoLastTimeDisplay(int promotionId) {
  final dateString =
      SyncSharedPreferences.instance.getString(_promoLastTimeKey(promotionId));
  return dateString != null ? DateTime.parse(dateString) : null;
}

void _setLastTimePromoDisplayToNow(int promotionId) {
  SyncSharedPreferences.instance.setString(
      _promoLastTimeKey(promotionId), DateTime.now().toIso8601String());
}
