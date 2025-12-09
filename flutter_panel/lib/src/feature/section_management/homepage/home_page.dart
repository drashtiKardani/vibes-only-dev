import 'package:auto_route/annotations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/generated/l10n.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/screens.dart';
import 'package:flutter_mobile_app_presentation/services.dart';
import 'package:flutter_mobile_app_presentation/story.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:flutter_panel/src/feature/section_management/homepage/cubit/toy_cubit_mock.dart';
import 'package:flutter_panel/src/feature/section_management/homepage/simulator/simulator_theme.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void injectDependencies() {
    if (!GetIt.I.isRegistered<GoPremiumDialogProvider>()) {
      GetIt.I.registerSingleton(GoPremiumDialogProvider(
          onSubscribeButtonTapped: (BuildContext context) {
        BlocProvider.of<InAppPurchaseCubit>(context).simulateSubscribedUser();
      }));
    }
    if (!GetIt.I.isRegistered<AnalyticsService>()) {
      GetIt.I.registerSingleton<AnalyticsService>(AnalyticsMock());
    }
    if (!GetIt.I.isRegistered<ToyControlButtonsProvider>()) {
      GetIt.I.registerSingleton<ToyControlButtonsProvider>(
          DisabledToyControlInStoryPlayer());
    }
    if (!GetIt.I.isRegistered<ConnectToyDialogProvider>()) {
      GetIt.I.registerSingleton<ConnectToyDialogProvider>(
          DisabledConnectToyDialogProvider());
    }
  }

  @override
  Widget build(BuildContext context) {
    injectDependencies();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomTabCubit()),
        BlocProvider(create: (context) => AdviceCubit()),
        BlocProvider(create: (context) => ToyCubitMock()),
        BlocProvider(create: (context) => FavoritesCubit()),
        BlocProvider(create: (context) => NetSpeedCubit(dontTestSpeed: true)),
        BlocProvider<ToyCommandService>(
            create: (context) => ToyCommandServiceMock()),
        BlocProvider<InAppPurchaseCubit>(
            create: (context) => InAppPurchaseMockCubit()),
        BlocProvider(create: (context) => HeardStoriesCubit()),
      ],
      child: DevicePreview(
        builder: (context) => MaterialApp(
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          theme: darkTheme(),
          localizationsDelegates: const [
            S.delegate,
          ],
          home: const Scaffold(
            body: VibeMainScreen(),
          ),
        ),
      ),
    );
  }
}
