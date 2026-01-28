import 'dart:io' show Platform;
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobile_app_presentation/audio.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/generated/l10n.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/preferences.dart';
import 'package:flutter_mobile_app_presentation/screens.dart';
import 'package:flutter_mobile_app_presentation/story.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vibes_only/firebase_options_staging.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_cubit.dart';
import 'package:vibes_only/src/cubit/iap/app_store_cubit.dart';
import 'package:vibes_only/src/cubit/iap/in_app_purchase_cubit.dart';
import 'package:vibes_only/src/feature/authentication/authentication_screen.dart';
import 'package:vibes_only/src/feature/card_game/card_game_screen.dart';
import 'package:vibes_only/src/feature/card_game/show_card_screen.dart';
import 'package:vibes_only/src/feature/check_access/check_access_screen.dart';
import 'package:vibes_only/src/feature/iap/iap_screen.dart';
import 'package:vibes_only/src/feature/settings/settings_screen.dart';
import 'package:vibes_only/src/feature/story_player/toy_command_service.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit_mock.dart';
import 'package:vibes_only/src/feature/vibes_ai/vibes_ai_screen.dart';
import 'package:vibes_only/src/feature/vibes_tab/vibes_tab.dart';
import 'package:vibes_only/src/service/promotion_checker.dart';
import 'package:vibes_only/src/service/push_notification/push_notification.dart';

import 'firebase_options.dart';
import 'src/di/di.dart';
import 'src/feature/intro/intro_screen.dart';
import 'src/feature/toy/remote_lover/ui/join_screen.dart';
import 'src/service/in_app_purchase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Flavor.detectUsing(packageInfo);

  await setupDependencyInjection();
  final themeMode = await getThemeMode();
  updateStatusBar(themeMode);
  await VibesAudioHandler.init();
  await SyncSharedPreferences.init();

  if (Flavor.isStaging()) {
    await Firebase.initializeApp(
      name: 'Staging-App',
      options: StagingAppFirebaseOptions.currentPlatform,
    );
  } else {
    // production app
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /**
   * >> Disable Analytics in debug builds:
   * Firebase analytics in Android doesn't respect this command and reports a user anyway.
   * To disable in Android: debug/AndroidManifest.xml -> firebase_analytics_collection_deactivated
   * In iOS we can also set: Info.plist -> FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED
   * With these two additions, the following line is no longer necessary,
   * but we keep it as a document point and also for good measure.
   */
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  // Pass all uncaught errors from the framework to Crashlytics.
  // see: https://firebase.flutter.dev/docs/crashlytics/usage#handling-uncaught-errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // also see: https://firebase.flutter.dev/docs/crashlytics/usage#zoned-errors

  PushNotificationService.setupFCM();
  await InAppPurchaseService.initPlatformState(); // Setup RevenueCat

  /* App is locked to portrait mode */
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(VibesOnly(themeMode: themeMode));
}

class VibesOnly extends StatefulWidget {
  const VibesOnly({required this.themeMode, super.key});

  final AdaptiveThemeMode themeMode;

  @override
  State<VibesOnly> createState() => _VibesOnlyState();
}

class _VibesOnlyState extends State<VibesOnly> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppStoreCubit()),
        // Note that we have to assert the type of Bloc in the next line.
        BlocProvider<InAppPurchaseCubit>(
          create: (context) => InAppPurchaseRevCatCubit(),
        ),
        BlocProvider(create: (context) => AuthenticationCubit()),
        BlocProvider(create: (context) => BottomTabCubit()),
        BlocProvider(create: (context) => AdviceCubit()),
        BlocProvider<ToyCubit>(
          create: (context) => kDebugMode ? ToyCubitMock() : ToyCubitImpl(),
        ),
        BlocProvider(create: (context) => FavoritesCubit()),
        BlocProvider(create: (context) => HeardStoriesCubit()),
        BlocProvider(create: (context) => NetSpeedCubit(), lazy: false),
        BlocProvider<ToyCommandService>(
          create: (context) => ToyCommandServiceImpl(),
        ),
      ],
      child: AdaptiveTheme(
        initial: AdaptiveThemeMode.dark,
        light: lightTheme(),
        dark: darkTheme(),
        builder: (ThemeData light, ThemeData dark) {
          return BlocListener<InAppPurchaseCubit, InAppPurchaseState>(
            listener: (context, state) async {
              await PushNotificationService.setupTopics(
                userHasSubscription: state.status == InAppPurchaseStatus.active,
              );
            },
            child: MaterialApp.router(
              routerConfig: _router,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              title: 'Vibes Only',
              theme: light,
              darkTheme: dark,
              builder: (context, child) {
                return FlavorBanner(child: child!);
              },
            ),
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  navigatorKey: GlobalNavigatorKey.get,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CheckAccessScreen(),
      redirect: (context, state) {
        if (Platform.isAndroid) {
          if (FirebaseAuth.instance.currentUser != null) {
            return '/main';
          }
          return '/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
      redirect: (context, state) {
        if (Platform.isAndroid) {
          if (FirebaseAuth.instance.currentUser != null) {
            return '/main';
          }
          return '/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthenticationScreen(),
    ),
    GoRoute(
      path: '/iap',
      builder: (context, state) => const InAppPurchaseScreen(),
      redirect: (context, state) {
        if (FirebaseAuth.instance.currentUser == null) {
          return '/login';
        } else if (Platform.isAndroid ||
            (state.uri.queryParameters['skippable'] == 'true' &&
                SyncSharedPreferences.userSkippedInitialIAP.value)) {
          return '/main';
        } else {
          return null;
        }
      },
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) {
        return VibeMainScreen(
          vibesTab: const VibesTab(),
          settingsScreen: const SettingsScreen(),
          fetchPromotionsAndShowPopup: fetchPromotionsAndShowPopup,
          onStartCardGame: () => context.go(CardGameScreen.path),
          whitneyScreen: const VibesAiScreen(),
        );
      },
      redirect: (context, state) {
        if (FirebaseAuth.instance.currentUser == null) {
          return '/login';
        } else {
          return null;
        }
      },
      routes: [
        GoRoute(
          path: 'remote-lover/:code',
          builder: (context, state) {
            return RemoteLoverEnterScreen(code: state.pathParameters['code']);
          },
        ),
      ],
    ),
    GoRoute(
      path: CardGameScreen.path,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => CardGameCubit(),
          child: const CardGameScreen(),
        );
      },
    ),
    GoRoute(
      path: ShowCardScreen.path,
      pageBuilder: (context, state) {
        CardGameDetails cardGameDetails = CardGameDetails.fromJson(
          state.extra as Map<String, dynamic>,
        );

        return FadeTransitionPage(
          child: ShowCardScreen(cardGameDetails: cardGameDetails),
        );
      },
    ),
  ],
);

/// Custom transition page with fade animation.
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  /// Constructor for a page with fade transition functionality.
  const FadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(transitionsBuilder: _transitionsBuilder);

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
