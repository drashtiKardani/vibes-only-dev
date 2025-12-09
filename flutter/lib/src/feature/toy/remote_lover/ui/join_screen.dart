import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobx/mobx.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vibes_only/src/feature/toy/cubit/remote_toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_remote_control.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/errors.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/stores/join_store.dart';
import 'package:vibes_only/src/widget/elevated_button_with_loading.dart';

class RemoteLoverEnterScreen extends StatefulWidget {
  const RemoteLoverEnterScreen({super.key, this.code});

  final String? code;

  @override
  State<RemoteLoverEnterScreen> createState() => _RemoteLoverEnterScreenState();
}

class _RemoteLoverEnterScreenState extends State<RemoteLoverEnterScreen> {
  String code = '';
  final JoinStore joinStore = JoinStore();

  StreamSubscription<DatabaseEvent>? databaseSubscription;

  late final ReactionDisposer reactionDisposer;

  late final TextEditingController joiningCodeTextFieldController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    reactionDisposer = reaction((_) => joinStore.state, (state) {
      if (state == JoinState.connected) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return ToyRemoteControl(
                commandExecutionTarget: RemoteToyCubit(
                  GetIt.I<RemoteLoverService>().activeConnection!,
                ),
              );
            },
          ),
        );
      }
    });
    // For when user has a code beforehand, for example by following a deep-linking
    if (widget.code != null) {
      joiningCodeTextFieldController.text = widget.code!;
      joinStore.join(code: widget.code!);
    }
  }

  @override
  void dispose() {
    joiningCodeTextFieldController.dispose();
    reactionDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color primary = context.colorScheme.onSurface.withValues(alpha: 0.05);

    return Observer(
      builder: (context) {
        RemoteLoverError? error = joinStore.error;
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
                const SizedBox(height: 24),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  controller: joiningCodeTextFieldController,
                  enabled: joinStore.state != JoinState.joining,
                  onChanged: (value) => code = value,
                  keyboardType: TextInputType.number,
                  enablePinAutofill: true,
                  textStyle: context.textTheme.headlineMedium?.copyWith(
                    fontSize: 40,
                  ),
                  pinTheme: PinTheme(
                    fieldHeight: 60,
                    fieldWidth: 50,
                    shape: PinCodeFieldShape.box,
                    fieldOuterPadding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(8),
                    errorBorderColor: context.colorScheme.error,
                    disabledColor: primary,
                    inactiveColor: primary,
                    inactiveFillColor: primary,
                    selectedColor: primary,
                    activeColor: primary,
                    activeFillColor: primary,
                    selectedFillColor: primary,
                  ),
                ),
                if (error != null) ...[
                  Text(
                    error.message,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButtonWithLoading(
                  onPressed: () {
                    joinStore.join(code: code);
                  },
                  isLoading: joinStore.state == JoinState.joining,
                  text: 'Connect',
                ),
                const SizedBox(height: 34),
                Container(
                  width: context.mediaQuery.size.width,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface.withValues(
                      alpha: 0.03,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
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
                                  Text(
                                    e.key,
                                    style: context.textTheme.titleMedium,
                                  ),
                                  Text(
                                    e.value,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(
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
      },
    );
  }
}
