import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:harmony_auth/harmony_auth.dart';

import '../../route/router.gr.dart';

@RoutePage()
class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  final AuthRepository authRepository = inject();

  @override
  void initState() {
    authRepository.getToken().then((token) {
      if (token != null && token.access.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 200), () {
          context.pushRoute(const DashboardRoute());
        });
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          context.pushRoute(const LoginRoute());
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
