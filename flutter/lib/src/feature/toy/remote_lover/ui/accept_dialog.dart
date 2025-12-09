import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/stores/accept_store.dart';
import 'package:vibes_only/src/widget/elevated_button_with_loading.dart';

class RemoteLoverAcceptDialog extends StatefulWidget {
  final RemoteLoverJoinRequest request;

  const RemoteLoverAcceptDialog({super.key, required this.request});

  @override
  State<RemoteLoverAcceptDialog> createState() =>
      _RemoteLoverAcceptDialogState();
}

class _RemoteLoverAcceptDialogState extends State<RemoteLoverAcceptDialog> {
  late final AcceptStore acceptStore = AcceptStore(request: widget.request);

  late final ReactionDisposer reactionDisposer;

  @override
  void initState() {
    super.initState();
    reactionDisposer = reaction((_) => acceptStore.state, (state) {
      if (state == AcceptState.accepted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    reactionDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Set to false if you want to block popping
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && acceptStore.state != AcceptState.accepted) {
          acceptStore.reject();
        }
      },
      child: Column(
        children: [
          Text(
            'Confirm Long Distance Lover',
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your partner wants to take control.\nReady to get off?',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            spacing: 14,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.maybePop(context, false);
                  },
                  style:
                      OutlinedButton.styleFrom(fixedSize: Size.fromHeight(48)),
                  child: Observer(
                    builder: (_) {
                      return acceptStore.state == AcceptState.accepting
                          ? const SizedBox.shrink()
                          : const Text('No');
                    },
                  ),
                ),
              ),
              Expanded(
                child: Observer(builder: (_) {
                  return ElevatedButtonWithLoading(
                    isLoading: acceptStore.state == AcceptState.accepting,
                    onPressed: () => acceptStore.accept(),
                    text: 'Yes',
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
