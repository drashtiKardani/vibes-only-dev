import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/ui/initiate_screen.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/ui/join_screen.dart';
import 'package:vibes_only/src/feature/toy/toy_search_dialog.dart';

void openRemoteLoverModeBottomSheet(BuildContext context) {
  showBlurredBackgroundBottomSheet(
    context: context,
    builder: (context) => _RemoteLoverMode(),
  );
}

class _RemoteLoverMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tap to Connect',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
              InkWell(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: context.colorScheme.onSurface,
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          Gap(26),
          BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
            builder: (context, subscription) {
              return OutlinedButton.icon(
                label: const Text('Provide Code'),
                iconAlignment: IconAlignment.end,
                style: OutlinedButton.styleFrom(fixedSize: Size.fromHeight(48)),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight02,
                  color: context.colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () {
                  showToyConnectDialogIfNecessary(context).then((connected) {
                    if (connected) {
                      Navigator.pop(context); // This dialog
                      if (subscription.isActive) {
                        showBlurredBackgroundBottomSheet(
                          context: context,
                          builder: (context) => RemoteLoverInitiateScreen(),
                        );
                      } else {
                        showGoPremiumBottomSheet(context);
                      }
                    }
                  });
                },
              );
            },
          ),
          Gap(16),
          OutlinedButton.icon(
            iconAlignment: IconAlignment.end,
            style: OutlinedButton.styleFrom(fixedSize: Size.fromHeight(48)),
            label: const Text('Connect Using Code'),
            onPressed: () {
              Navigator.pop(context);
              showBlurredBackgroundBottomSheet(
                context: context,
                builder: (context) => RemoteLoverEnterScreen(),
              );
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight02,
              color: context.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
