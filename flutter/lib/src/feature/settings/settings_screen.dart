import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_cubit.dart';
import 'package:vibes_only/src/cubit/authentication/authentication_state.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:vibes_only/src/feature/favorites/favorites_screen.dart';
import 'package:vibes_only/src/feature/settings/delete_account_screen.dart';
import 'package:vibes_only/src/feature/settings/manage_subscription_screen.dart';
import 'package:vibes_only/src/feature/settings/notification_settings_screen.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      
      appBar: BackButtonAppBar(context, onPressed: () => context.pop()),
      // appBar: AppBar(
      //   title: RawGestureDetector(
      //     gestures: <Type, GestureRecognizerFactory>{
      //       LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
      //           LongPressGestureRecognizer>(
      //         () {
      //           return LongPressGestureRecognizer(
      //             debugOwner: this,
      //             duration: const Duration(seconds: 2),
      //           );
      //         },
      //         (LongPressGestureRecognizer instance) {
      //           instance.onLongPress = () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => const ExtraSettingsScreen(),
      //               ),
      //             );
      //           };
      //         },
      //       ),
      //     },
      //     child: const FlickerText(text: 'Settings', fontSize: 22),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   iconTheme: const IconThemeData(
      //     color: Colors.white,
      //   ),
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: context.viewPadding.top + kToolbarHeight + 10,
              bottom: context.viewPadding.bottom + 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocListener<AuthenticationCubit, AuthenticationState>(
                    listener: (context, state) {
                      if (state.isSignedOut) {
                        if (Flavor.isStaging()) {
                          // Delete the simulated subscription upon logging out from Staging App
                          BlocProvider.of<InAppPurchaseCubit>(
                            context,
                          ).simulateFreeUser();
                        }
                        context.go('/login');
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedCrown03,
                            title: 'Subscription',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const ManageSubscriptionScreen();
                                  },
                                ),
                              );
                            },
                          ),
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedNotification01,
                            title: 'Notifications',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const NotificationSettingsScreen();
                                  },
                                ),
                              );
                            },
                          ),
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedFavourite,
                            title: 'Favorites',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const FavoritesScreen();
                                  },
                                ),
                              );
                            },
                          ),
                          if (Platform.isIOS)
                            _SettingsListItem(
                              icon: HugeIcons.strokeRoundedShoppingBasket01,
                              title: 'Shop Vibes Only',
                              onPressed: () {
                                launchUrl(Uri.parse('https://vibesonly.com/'));
                              },
                            ),
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedCall02,
                            title: 'Contact Us',
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'https://vibesonly.com/pages/contact',
                                ),
                              );
                            },
                          ),
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedBookOpen01,
                            title: 'Terms & Conditions',
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'https://vibesonly.com/pages/terms-and-conditions',
                                ),
                              );
                            },
                          ),
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedPolicy,
                            title: 'Privacy Policy',
                            onPressed: () {
                              launchUrl(
                                Uri.parse(
                                  'https://vibesonly.com/pages/privacy-policy',
                                ),
                              );
                            },
                          ),
                          _SettingsListItem(
                            icon: HugeIcons.strokeRoundedDelete02,
                            title: 'Delete Account',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DeleteAccountScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedLogout04,
                    size: 22,
                    color: context.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    BlocProvider.of<AuthenticationCubit>(context).signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    fixedSize: Size(context.mediaQuery.size.width, 50),
                    foregroundColor: context.colorScheme.onSurface,
                    backgroundColor: context.colorScheme.onSurface.withValues(
                      alpha: 0.1,
                    ),
                  ),
                  label: const Text('Log out'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextButton buildSettingsTextButton(
    String text,
    VoidCallback? onPressed, {
    bool smallSize = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: smallSize ? 14 : 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SettingsListItem extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String title;
  final VoidCallback onPressed;

  const _SettingsListItem({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color foregroundColor = context.colorScheme.onSurface;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14),
      onPressed: onPressed,
      child: Row(
        spacing: 20,
        children: [
          HugeIcon(icon: icon, color: foregroundColor, size: 26),
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                color: foregroundColor,
              ),
            ),
          ),
          Icon(VibesV3.arrowRight, color: foregroundColor, size: 28),
        ],
      ),
    );
  }
}
