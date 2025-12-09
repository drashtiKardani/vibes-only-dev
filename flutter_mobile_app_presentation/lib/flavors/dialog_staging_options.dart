import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/local_storage/sync_shared_preferences.dart';
import 'package:flutter_mobile_app_presentation/src/theme/theme.dart';

import '../in_app_purchase.dart';
import 'navigator_global_key.dart';
import 'server_swapper.dart';

Future showStagingOptionsDialog() {
  return showDialog(
    context: GlobalNavigatorKey.get.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(
        'Staging options',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: Theme(
        data: Theme.of(context).copyWith(
          // This will be the color of radio buttons when they are unselected.
          unselectedWidgetColor: Colors.grey,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SectionTitle(title: 'Select server:'),
            for (final server in ServerSwapper.selectableServers.entries)
              ServerSelectorRadioListTile(
                title: server.key,
                baseUrl: server.value,
                onSelectAlsoDo: () {
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Simulate free/paid user:'),
            BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
              builder: (context, subscription) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('Free user'),
                    Switch(
                      value: subscription.status == InAppPurchaseStatus.active,
                      onChanged: (simulatePaidUser) {
                        if (simulatePaidUser) {
                          BlocProvider.of<InAppPurchaseCubit>(
                            context,
                          ).simulateSubscribedUser();
                        } else {
                          BlocProvider.of<InAppPurchaseCubit>(
                            context,
                          ).simulateFreeUser();
                        }
                      },
                      activeThumbColor: AppColors.vibesPink,
                    ),
                    const Text('Paid user'),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Discover every Bluetooth device:'),
            StatefulBuilder(
              builder: (context, setState) {
                return Switch(
                  value:
                      SyncSharedPreferences.bluetoothDiscoverEverything.value,
                  onChanged: (valueChanged) {
                    setState(() {
                      SyncSharedPreferences.bluetoothDiscoverEverything.value =
                          !SyncSharedPreferences
                              .bluetoothDiscoverEverything
                              .value;
                    });
                  },
                  activeThumbColor: AppColors.vibesPink,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
