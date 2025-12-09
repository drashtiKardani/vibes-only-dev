import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/generated/l10n.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/cubit/iap/app_store_cubit.dart';
import 'package:vibes_only/src/cubit/iap/constants.dart';
import 'package:vibes_only/src/service/analytics.dart';

enum PossibleRoutesToThisScreen { fromIntro, fromVibeMain }

class InAppPurchaseScreen extends StatefulWidget {
  final PossibleRoutesToThisScreen routeFrom;

  const InAppPurchaseScreen({super.key, bool comingFromMainScreen = false})
    : routeFrom = comingFromMainScreen
          ? PossibleRoutesToThisScreen.fromVibeMain
          : PossibleRoutesToThisScreen.fromIntro;

  @override
  State createState() => _InAppPurchaseScreenState();
}

class _InAppPurchaseScreenState extends State<InAppPurchaseScreen>
    with WidgetsBindingObserver {
  bool _progressDialogIsShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    BlocProvider.of<AppStoreCubit>(context).loadProducts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // User may have purchased a package outside the app flow
      BlocProvider.of<InAppPurchaseCubit>(context).checkUserSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            switch (widget.routeFrom) {
              case PossibleRoutesToThisScreen.fromIntro:
                context.pushReplacement('/intro');
                break;
              case PossibleRoutesToThisScreen.fromVibeMain:
                Navigator.pop(context);
                break;
            }
          },
        ),
        actions: [
          if (widget.routeFrom == PossibleRoutesToThisScreen.fromIntro)
            TextButton(
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              onPressed: () {
                SyncSharedPreferences.userSkippedInitialIAP.value = true;
                openHomeScreen(context);
              },
            ),
        ],
      ),
      body: BlocListener<InAppPurchaseCubit, InAppPurchaseState>(
        listener: (context, state) {
          if (state.status == InAppPurchaseStatus.makingPurchase) {
            _progressDialogIsShowing = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const AlertDialog(
                  content: Center(
                    heightFactor: 3,
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          } else {
            if (_progressDialogIsShowing) {
              Navigator.pop(context);
              _progressDialogIsShowing = false;
            }

            if (state.status == InAppPurchaseStatus.active) {
              switch (widget.routeFrom) {
                case PossibleRoutesToThisScreen.fromIntro:
                  Analytics.logEvent(
                    name:
                        'firstImpressionSub_${state.appSubscription?.package}',
                    context: context,
                  );
                  openHomeScreen(context);
                  break;
                case PossibleRoutesToThisScreen.fromVibeMain:
                  Analytics.logEvent(
                    name: 'popUpSub_${state.appSubscription?.package}',
                    context: context,
                  );
                  Navigator.pop(context);
                  break;
              }
            } else if (state.status == InAppPurchaseStatus.error) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Subscription Error'),
                    content: Text('${state.error}'),
                  );
                },
              );
            }
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: assets.Assets.images.background.image(
                filterQuality: FilterQuality.high,
                package: 'flutter_mobile_app_presentation',
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
                    bottom: context.mediaQuery.viewPadding.bottom + 14,
                  ),
                  child: Column(
                    children: [
                      assets.Assets.svgs.applogoIconOnlyBlackNWhite.svg(
                        package: 'flutter_mobile_app_presentation',
                      ),
                      Assets.images.applogoTextOnly.image(
                        filterQuality: FilterQuality.high,
                        color: context.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        S.of(context).inAppPurchaseTitle,
                        style: TextStyle(
                          fontSize: 28 / _textScaleFactor,
                          height: 35.0 / 30.0,
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        S.of(context).inAppPurchaseText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      if (Flavor.isStaging())
                        _MockSubscriptionButton(context: context)
                      else
                        BlocBuilder<AppStoreCubit, AppStoreState>(
                          builder: (context, state) {
                            switch (state.status) {
                              case AppStoreStatus.productsLoaded:
                                for (Package product in state.products) {
                                  print('------------------------------');
                                  print('rc_id: ${product.identifier}');
                                  print(
                                    'id: ${product.storeProduct.identifier}',
                                  );
                                  print('title: ${product.storeProduct.title}');
                                  print(
                                    'description: ${product.storeProduct.description}',
                                  );
                                  print('price: ${product.storeProduct.price}');
                                  print(
                                    'rawPrice: ${product.storeProduct.priceString}',
                                  );
                                  print(
                                    'currencyCode: ${product.storeProduct.currencyCode}',
                                  );
                                  print(
                                    'subscriptionPeriod: ${product.storeProduct.subscriptionPeriod}',
                                  );
                                  print('------------------------------');
                                }
                                return Column(
                                  children: [
                                    for (final product in state.products)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: SubscriptionButton(
                                          BlocProvider.of<InAppPurchaseCubit>(
                                            context,
                                          ),
                                          product,
                                          buttonTitle(
                                            product.storeProduct.identifier,
                                          ),
                                          buttonSubtitle(
                                            product.storeProduct.identifier,
                                          ),
                                          buttonSubSubtitle(
                                            product.storeProduct.identifier,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              case AppStoreStatus.errorLoadingProducts:
                                return Column(
                                  children: [
                                    for (var productId in IapConstants.kIds)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: _SubscriptionButtonWithError(
                                          buttonTitle(productId),
                                          buttonSubtitle(productId),
                                          buttonSubSubtitle(productId),
                                          error: 'Error loading product.',
                                          context: context,
                                        ),
                                      ),
                                  ],
                                );
                              default:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                            }
                          },
                        ),
                      if (Platform.isAndroid) ...[
                        const SizedBox(height: 20),
                        Text(
                          S.of(context).subscriptionNotice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).check,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SmallUnderlinedButton(
                              context: context,
                              foregroundColor: context.colorScheme.onSurface,
                              text: S.of(context).here,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              onPressed: () {
                                launchUrl(
                                  Uri.parse(
                                    'https://support.google.com/googleplay/answer/7018481?hl=en&co=GENIE.Platform%3DAndroid',
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              S.of(context).forMoreInfo,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 80),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          SmallUnderlinedButton(
                            context: context,
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'https://vibesonly.com/pages/terms-and-conditions',
                                ),
                              );
                            },
                            text: 'Terms & Conditions',
                          ),
                          SmallUnderlinedButton.separator(
                            context,
                            scaleFactor: _textScaleFactor,
                          ),
                          SmallUnderlinedButton(
                            context: context,
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'https://vibesonly.com/pages/privacy-policy',
                                ),
                              );
                            },
                            text: 'Privacy Policy',
                          ),
                          SmallUnderlinedButton.separator(
                            context,
                            scaleFactor: _textScaleFactor,
                          ),
                          SmallUnderlinedButton(
                            context: context,
                            onPressed: () {
                              launchUrl(
                                Uri.parse('https://vibesonly.com/pages/eula'),
                              );
                            },
                            text: 'Subscription',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SmallUnderlinedButton(
                        context: context,
                        onPressed: () {
                          BlocProvider.of<InAppPurchaseCubit>(
                            context,
                          ).restorePurchase();
                        },
                        text: 'Restore Purchase',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openHomeScreen(BuildContext context) {
    context.pushReplacement('/main');
  }

  Widget buttonTitle(String productId) {
    return Text(
      productId.startsWith(IapConstants.kIdAnnual)
          ? 'Annual  - 3 days free'
          : 'Monthly',
      style: TextStyle(
        fontSize: 16 / _textScaleFactor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget buttonSubtitle(String productId) {
    return Text(
      productId.startsWith(IapConstants.kIdAnnual)
          ? '\$49.99 USD / year (\$4.16 / month)'
          : '\$7.99 USD / month',
      style: TextStyle(
        fontSize: 14 / _textScaleFactor,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget buttonSubSubtitle(String productId) {
    return Text(
      productId.startsWith(IapConstants.kIdAnnual)
          ? 'Billed annually after trial ends'
          : 'Billed Monthly',
      style: TextStyle(
        fontSize: 12 / _textScaleFactor,
        fontWeight: FontWeight.w200,
      ),
    );
  }

  /* to make everything smaller */
  double get _textScaleFactor => MediaQuery.of(context).textScaler.scale(1.1);
}

class SubscriptionButton extends _SubscriptionButtonSkin {
  SubscriptionButton(
    InAppPurchaseCubit purchaseCubit,
    Package product,
    super.title,
    super.subtitle,
    super.subSubtile, {
    super.key,
  }) : super(
         onPressed: () {
           purchaseCubit.makePurchase(product);
         },
       );
}

class _SubscriptionButtonWithError extends _SubscriptionButtonSkin {
  _SubscriptionButtonWithError(
    super.title,
    super.subtitle,
    super.subSubtile, {
    required BuildContext context,
    required String error,
  }) : super(
         onPressed: () {
           showDialog(
             context: context,
             builder: (context) {
               return AlertDialog(
                 title: const Text('Error'),
                 content: Text(error),
                 actions: [
                   TextButton(
                     child: const Text('OK'),
                     onPressed: () => Navigator.pop(context),
                   ),
                 ],
               );
             },
           );
         },
       );
}

class _SubscriptionButtonSkin extends ElevatedButton {
  _SubscriptionButtonSkin(
    Widget title,
    Widget subtitle,
    Widget subSubtile, {
    super.key,
    super.onPressed,
  }) : super(
         child: SizedBox(
           width: double.infinity,
           height: 80,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.center,
             children: [title, subtitle, subSubtile],
           ),
         ),
       );
}

class _MockSubscriptionButton extends ElevatedButton {
  _MockSubscriptionButton({required BuildContext context})
    : super(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          fixedSize: Size(context.mediaQuery.size.width, 70),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Simulate Subscription',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              'For Staging App only',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            ),
          ],
        ),
        onPressed: () {
          BlocProvider.of<InAppPurchaseCubit>(context).simulateSubscribedUser();
        },
      );
}

class SmallUnderlinedButton extends TextButton {
  SmallUnderlinedButton({
    required BuildContext context,
    super.key,
    required String text,
    double? fontSize,
    TextDecoration? decoration,
    Color? foregroundColor,
    super.onPressed,
  }) : super(
         child: Text(
           text,
           style: TextStyle(
             fontSize: fontSize ?? 14,
             fontWeight: FontWeight.w300,
             decoration: decoration,
             decorationColor:
                 foregroundColor ??
                 context.colorScheme.onSurface.withValues(alpha: 0.5),
           ),
         ),
         style: TextButton.styleFrom(
           minimumSize: const Size(0, 20),
           padding: EdgeInsets.zero,
           foregroundColor:
               foregroundColor ??
               context.colorScheme.onSurface.withValues(alpha: 0.5),
           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
         ),
       );

  static Widget separator(BuildContext context, {double scaleFactor = 1.0}) {
    return Container(
      height: 4,
      width: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
