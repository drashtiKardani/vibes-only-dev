import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_cubit.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_state.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';

class CheckAccessScreen extends StatefulWidget {
  const CheckAccessScreen({super.key});

  @override
  State createState() => _CheckAccessScreenState();
}

class _CheckAccessScreenState extends State<CheckAccessScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state.isSignedOut) {
              context.pushReplacement('/intro');
            } else if (state.isSignedIn) {
              if (state.asSignedIn.user.email == 'vibesonlyteam@gmail.com') {
                // Direct access to main screen for GooglePlay tester.
                // This piece of code is repeated in [authentication_screen.dart]
                context.pushReplacement('/main');
                return;
              }
              BlocProvider.of<InAppPurchaseCubit>(context).checkUserSubscription();
            }
          },
        ),
        BlocListener<InAppPurchaseCubit, InAppPurchaseState>(
          listener: (context, state) {
            if (state.status == InAppPurchaseStatus.active) {
              context.pushReplacement('/main');
            } else if (state.status == InAppPurchaseStatus.inactive || state.status == InAppPurchaseStatus.error) {
              context.pushReplacement('/iap?skippable=true');
            }
          },
        ),
      ],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
