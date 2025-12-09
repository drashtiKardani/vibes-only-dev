import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/dialogs.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobx/mobx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/someone_in_control_screen.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/stores/initiate_store.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

import 'accept_dialog.dart';

class RemoteLoverInitiateScreen extends StatefulWidget {
  const RemoteLoverInitiateScreen({super.key});

  @override
  State<RemoteLoverInitiateScreen> createState() =>
      _RemoteLoverInitiateScreenState();
}

class _RemoteLoverInitiateScreenState extends State<RemoteLoverInitiateScreen> {
  final InitiateStore initiateStore = InitiateStore();

  void _initiateConnection() {
    if (!mounted) return; // if screen is disposed, do nothing
    initiateStore.initiate(
      toyName: BlocProvider.of<ToyCubit>(
        context,
      ).state.connectedDevice?.bluetoothName,
    );
    // Re-initialize the connection after 10 minutes of idleness (no request to join has received).
    Future.delayed(const Duration(minutes: 10), () {
      if (initiateStore.state == InitiateState.idle ||
          initiateStore.state == InitiateState.initiated) {
        _initiateConnection();
      }
    });
  }

  late final ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();
    _initiateConnection();

    reactionDisposer = reaction((_) => initiateStore.state, (state) async {
      if (state == InitiateState.joining) {
        RemoteLoverJoinRequest? request = initiateStore.request;

        if (request != null) {
          bool accepted =
              await showBlurredBackgroundBottomSheet(
                context: context,
                builder: (_) {
                  return RemoteLoverAcceptDialog(request: request);
                },
              ) ??
              false;
          initiateStore.setAcceptStatus(accepted);
          if (accepted && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SomeoneInControlScreen()),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    initiateStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.mediaQuery.size.height * 0.75,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Long Distance Lover',
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
            const SizedBox(height: 18),
            Text(
              'Share the code with your Partner',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Container(
              width: context.mediaQuery.size.width,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Observer(
                builder: (_) {
                  return initiateStore.state == InitiateState.idle
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                          children: initiateStore.code.split('').map((e) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  e,
                                  style: context.textTheme.headlineMedium
                                      ?.copyWith(fontSize: 40),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generated code is valid for 10 minutes',
              style: context.textTheme.titleLarge?.copyWith(
                fontSize: 12,
                color: context.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 25),
            VibesElevatedButton(
              text: 'Share',
              onPressed: () => initiateStore.state == InitiateState.idle
                  ? null
                  : SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Your partner wants you to take control. '
                            'Click the link below or enter your code in the Vibes Only app.\n'
                            'https://share.vibesonly.com/main/remote-lover/${initiateStore.code}\n'
                            'Code: ${initiateStore.code}',
                      ),
                    ),
            ),
            const SizedBox(height: 34),
            Container(
              width: context.mediaQuery.size.width,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn how long distance lover works',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        {
                          'Step 1': 'Turn on your vibe and click Connect',
                          'Step 2':
                              'Make sure your partner has the Vibes Only app installed',
                          'Step 3':
                              'Invite your partner by giving them the code or clicking Share',
                        }.entries.map((e) {
                          return Column(
                            spacing: 2,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key, style: context.textTheme.titleMedium),
                              Text(
                                e.value,
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
