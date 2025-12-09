import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart'
    as mobile_app;
import 'package:flutter_panel/src/cubit/push_notif/push_notif_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'generated/l10n.dart';
import 'src/cubit/login/login_cubit.dart';
import 'src/di/di.dart';
import 'src/route/router.dart';
import 'src/theme/theme.dart';

void main() async {
  // following lines are important for initialization of app simulator
  await mobile_app.VibesAudioHandler.init();
  await mobile_app.SyncSharedPreferences.init();
  mobile_app.Flavor.setToProduction();

  await setupDependencyInjection(mobile_app.Flavor.instance.baseUrl);

  // For handling conversion of time between admin-panel (Eastern Time) and server (UTC).
  tz.initializeTimeZones();

  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: lightTheme(),
      dark: darkTheme(),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (BuildContext context) => LoginCubit(inject(), inject()),
          ),
          BlocProvider(create: (context) => PushNotificationCubit(inject())),
        ],
        child: MaterialApp.router(
          title: 'Admin Panel',
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: theme,
          darkTheme: darkTheme,
          routeInformationProvider: _appRouter.routeInfoProvider(),
          routerDelegate: _appRouter.delegate(),
          routeInformationParser: _appRouter.defaultRouteParser(),
        ),
      ),
    );
  }
}
