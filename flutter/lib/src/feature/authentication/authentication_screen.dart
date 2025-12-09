import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:vibes_only/gen/assets.gen.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_cubit.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_state.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  late AuthenticationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<AuthenticationCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state.isSignedIn) {
            if (state.asSignedIn.user.email == 'vibesonlyteam@gmail.com' ||
                Platform.isAndroid) {
              // Direct access to main screen for GooglePlay tester and Android users
              context.pushReplacement('/main');
              return;
            }
            BlocProvider.of<InAppPurchaseCubit>(
              context,
            ).checkUserSubscription();
            context.go('/iap?skippable=true');
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ).copyWith(bottom: context.mediaQuery.viewPadding.bottom + 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
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
                    'Welcome to Vibes Only',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  if (Platform.isIOS)
                    _buildSignInButton(
                      text: 'Sign in with Apple',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      image: Assets.svg.apple.svg(),
                      onPressed: () => _cubit.signInWith(SignInMethod.apple),
                    ),
                  if (Platform.isAndroid)
                    _buildSignInButton(
                      text: 'Sign in with Google',
                      backgroundColor: Colors.red,
                      image: Assets.images.logoGoogle.image(),
                      onPressed: () => _cubit.signInWith(SignInMethod.google),
                    ),
                  const SizedBox(height: 18),
                  if (Flavor.isStaging())
                    _buildSignInButton(
                      text: 'Sign in anonymously (For Staging App only)',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: () => _cubit.signInAnonymously(),
                    ),
                  const SizedBox(height: 40),
                  Text(
                    'By clicking the "Sign in with ${Platform.isIOS ? 'Apple' : 'Google'}" button'
                    ' you agree to Vibes Only terms of service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required String text,
    Color? foregroundColor,
    Color? backgroundColor,
    VoidCallback? onPressed,
    Widget? image,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        fixedSize: Size(context.mediaQuery.size.width, 52),
      ),
      child: Row(
        spacing: 6,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) image,
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
