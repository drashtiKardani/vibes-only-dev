import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:intl/intl.dart';
import 'package:vibes_only/src/cubit/iap/constants.dart';
import 'package:flutter_mobile_app_presentation/in_app_purchase.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  final dateFormat = DateFormat('MMMM dd, yyyy');

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14)
                .copyWith(top: context.viewPadding.top + kToolbarHeight + 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: context.textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 20),
                BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
                    builder: (context, state) {
                  if (state.status == InAppPurchaseStatus.active) {
                    return Text.rich(
                      TextSpan(text: 'You current package : ', children: [
                        TextSpan(
                          text:
                              '${state.appSubscription?.package == IapConstants.kIdAnnual ? 'Annual' : 'Monthly'} plan',
                          style: context.textTheme.headlineMedium,
                        )
                      ]),
                      style:
                          context.textTheme.titleMedium?.copyWith(fontSize: 18),
                    );
                  } else if (state.status == InAppPurchaseStatus.inactive) {
                    return Text(
                      'Free plan',
                      style:
                          context.textTheme.titleMedium?.copyWith(fontSize: 18),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
