import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart'
    show showBlurredBackgroundBottomSheet, Flavor;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/service/analytics.dart';
import 'package:vibes_only/src/feature/toy/widget/toys_scanner.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

Future<bool> showToyConnectDialogIfNecessary(BuildContext context) async {
  if (BlocProvider.of<ToyCubit>(context).state.connectedDevice != null) {
    return true;
  }
  return showToySearchDialog(context);
}

Future<bool> showToySearchDialog(BuildContext context) async {
  final bool permissionGranted = await _checkPermissions(context);

  if (!permissionGranted) return false;

  if (!context.mounted) return false;

  when((_) => GetIt.I<CommoditiesStore>().commodities != null, () {
    print('We have loaded the commodities!');
    BlocProvider.of<ToyCubit>(context).search();
  });

  return showBlurredBackgroundBottomSheet<bool>(
        context: context,
        builder: (context) => Flavor.isProduction()
            ? _ToySearchBottomSheet()
            : _ToySearchBottomSheetStaging(),
      )
      .then((_) {
        BlocProvider.of<ToyCubit>(context).exitFromSearch();
      })
      .then((_) {
        return BlocProvider.of<ToyCubit>(context).state.connectedDevice != null;
      });
}

Future<bool> _checkPermissions(BuildContext context) async {
  List<Permission> bluetoothPermissions;
  if (Platform.isAndroid &&
      (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 31) {
    bluetoothPermissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ];
  } else {
    bluetoothPermissions = [Permission.bluetooth];
  }
  final Map<Permission, PermissionStatus> statues = await [
    Permission.location,
    ...bluetoothPermissions,
  ].request();
  print(statues);

  if (statues.values.every((status) => status.isGranted)) {
    return true;
  } else if (statues.values.any((status) => status.isPermanentlyDenied)) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              'You have rejected required permissions!',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            contentPadding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Your toy can only connect if you grant location and bluetooth permissions in app settings.',
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open app settings'),
              ),
            ],
          );
        },
      );
    }
    return false;
  } else {
    return false;
  }
}

void _connectToDevice(BuildContext context, ScanResult device) {
  BlocProvider.of<ToyCubit>(context).connect(device);
  Analytics.logEvent(
    context: context,
    name: 'toy_connected',
    parameters: {'toy_connected__name': device.bluetoothName},
  );
  Navigator.pop(context);
}

class _ToySearchBottomSheet extends StatelessWidget {
  final math.Random random = math.Random();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToyCubit, ToyState>(
      builder: (context, state) {
        List<ScanResult> scanResults = state.discoveredDevices;

        List<ToyResult> toyResults = scanResults.map((result) {
          return ToyResult(
            scanResult: result,
            icon: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _connectToDevice(context, result),
              child: result.toyImage ?? SizedBox.shrink(),
            ),
            angle: random.nextDouble() * 2 * math.pi,
            // Reduced distance (80-110px) to ensure bounds
            distance: 80 + random.nextDouble() * 30,
            size: 22 + random.nextDouble() * 6, // (22-28px)
          );
        }).toList();

        String labelText = toyResults.isNotEmpty
            ? '${toyResults.length} Device(s) found'
            : 'Searching For Device...';

        return Column(
          children: [
            ToysScanner(
              size: 300,
              centerWidget: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Icon(VibesV3.searchLined, color: Colors.white, size: 28),
              ),
              toyResults: toyResults,
            ),
            Gap(10),
            Text(
              labelText,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            Gap(24),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                fixedSize: Size(context.mediaQuery.size.width, 48),
              ),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _ToySearchBottomSheetStaging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToyCubit, ToyState>(
      builder: (context, state) {
        List<ScanResult> scanResults = state.discoveredDevices;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: context.mediaQuery.size.height * 0.75,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                width: context.mediaQuery.size.width,
                child: Text(
                  'Searching...',
                  style: context.textTheme.headlineLarge,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: scanResults.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: 14),
                  physics: ClampingScrollPhysics(),
                  separatorBuilder: (context, index) => Gap(14),
                  itemBuilder: (context, index) {
                    ScanResult result = scanResults[index];

                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _connectToDevice(context, result),

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.05,
                          ),
                          border: Border.all(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          spacing: 20,
                          children: [
                            SizedBox.square(
                              dimension: 40,
                              child: result.toyImage,
                            ),
                            Expanded(
                              child: Text(
                                result.displayName,
                                style: context.textTheme.titleMedium,
                              ),
                            ),
                            Icon(
                              VibesV3.arrowRight,
                              size: 28,
                              color: context.colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              VibesElevatedButton(
                onPressed: () => Navigator.pop(context),
                size: Size(context.mediaQuery.size.width, 48),
                text: 'Cancel',
              ),
            ],
          ),
        );
      },
    );
  }
}
