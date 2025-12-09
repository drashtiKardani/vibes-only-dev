import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_cubit.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_state.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool notificationIsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: assets.Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          BlocListener<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state.isSignedOut) {
                context.go('/login');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).copyWith(
                top: context.viewPadding.top + kToolbarHeight + 10,
                bottom: context.mediaQuery.viewPadding.bottom + 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete Account',
                    style: context.textTheme.displaySmall?.copyWith(
                      fontSize: 24,
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ghosting us so soon? You currently have an active subscription to Vibes Only through the App Store.\n\n'
                    'Deleting your account will not cancel your App Store subscription.\n\n'
                    'To cancel your subscription, go to your App Store subscription settings.',
                    style: context.textTheme.titleMedium?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  Spacer(),
                  VibesElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Nevermind, I\'ll Keep Vibing',
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      fixedSize: Size(context.mediaQuery.size.width, 48),
                    ),
                    onPressed: () {
                      BlocProvider.of<AuthenticationCubit>(context)
                          .deleteAccount();
                    },
                    child: Text('I\'m Out'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
