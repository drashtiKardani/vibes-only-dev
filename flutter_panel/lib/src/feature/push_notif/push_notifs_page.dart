import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/push_notif/push_notif_cubit.dart';
import 'package:flutter_panel/src/cubit/push_notif/push_notif_state.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_table_item.dart';
import 'package:flutter_panel/src/widget/crud/custom_paginated_crud_table.dart';
import 'package:flutter_panel/src/widget/custom_alert_dialog.dart';
import 'package:flutter_panel/src/widget/custom_icon_button.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:timezone/browser.dart' as tz;
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class PushNotificationsPage extends StatefulWidget {
  const PushNotificationsPage({super.key});

  @override
  State<PushNotificationsPage> createState() => _PushNotificationsPageState();
}

class _PushNotificationsPageState extends State<PushNotificationsPage> {
  List<PushResponse>? allPushes;
  List<PushResponse>? filteredPushes;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<PushNotificationCubit>(context).getAllPushMessages();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PushNotificationCubit, PushNotificationState>(
      listener: (context, state) => state.maybeWhen(
        getAllPushNotifications: (allPushes) => setState(() => this.allPushes = allPushes),
        itemsDeleted: () => BlocProvider.of<PushNotificationCubit>(context).getAllPushMessages(),
        orElse: (state) => null,
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        title: 'Push Notifications'
            ' - all times are Eastern Time (${Const.tzNewYork.currentTimeZone.abbreviation})',
        rows: [
          strings.title,
          'Target',
          'Status',
          'Scheduled For',
          strings.actions,
        ],
        addButtonLabel: 'Send a Push',
        onAddButtonClick: () => context.router.push(const SendPushNotificationRoute()),
        isLoading: state.isLoading,
        items: _generateItems(),
        onSearchChanged: _searchBoxChangeHandler,
      ),
    );
  }

  List<Widget> _generateItems() {
    List<Widget> listOfRows = [];
    for (PushResponse push in filteredPushes ?? allPushes ?? []) {
      listOfRows.add(CustomCrudTableItem(fields: [
        CustomText(text: push.title),
        CustomText(text: push.target),
        CustomText(text: push.status),
        if (push.scheduledFor != null)
          CustomText(
            text: '${DateFormat('d/MMM/yyyy hh:mm').format(
              tz.TZDateTime.from(push.scheduledFor!, Const.tzNewYork),
            )} ${Const.tzNewYork.currentTimeZone.abbreviation}',
          )
        else
          const CustomText(text: 'Not scheduled'),
        CustomIconButton(
          onClick: () => showDialog(
            context: context,
            builder: (context) => CustomAlertDialog(
                title: 'Attention',
                message: strings.areYouSure,
                onPositiveButtonClick: () {
                  BlocProvider.of<PushNotificationCubit>(context).deletePush(push.id);
                  AutoRouter.of(context).maybePop();
                }),
          ),
          iconSize: 26,
          icon: IconlyBold.delete,
          iconColor: Colors.red.shade400,
        ),
      ]));
    }
    return listOfRows;
  }

  void _searchBoxChangeHandler(String query) {
    setState(() {
      filteredPushes = allPushes?.where((push) => push.title.contains(query)).toList();
    });
  }
}
