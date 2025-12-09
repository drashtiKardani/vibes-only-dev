import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/push_notif/push_notif_cubit.dart';
import 'package:flutter_panel/src/cubit/push_notif/push_notif_state.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:flutter_panel/src/widget/date_select_widget.dart';
import 'package:flutter_panel/src/widget/time_select_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/browser.dart' as tz;
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class SendPushNotificationPage extends StatefulWidget {
  const SendPushNotificationPage({super.key});

  @override
  State createState() => _SendPushNotificationPageState();
}

class _SendPushNotificationPageState extends State<SendPushNotificationPage> {
  final _titleTextEditingController = TextEditingController();
  final _bodyTextEditingController = TextEditingController();
  final ValueNotifier<DateTime?> _scheduleForDateNotifier = ValueNotifier<DateTime?>(null);
  final ValueNotifier<TimeOfDay?> _scheduleForTimeNotifier = ValueNotifier<TimeOfDay?>(null);

  bool _titleError = false, _bodyError = false;
  String? _scheduleDateTimeError;

  PushMessageAudience targetAudience = PushMessageAudience.all;
  PushMessageDestination destination = PushMessageDestination.tabHome;
  int? destinationPageId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PushNotificationCubit, PushNotificationState>(
      listener: (BuildContext context, state) {
        state.whenOrNull(
          sending: () => showBlurDialog(context, '', 'Sending Push Notification...'),
          successfullySent: () {
            Navigator.of(context).pop();
            AutoRouter.of(context).replace(const PushNotificationsRoute());
          },
          failure: (e) {
            Navigator.of(context).pop();
            showBlurDialog(context, '', 'Error sending push notification: $e');
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pop();
            });
          },
        );
      },
      child: CrudScaffold(
        title: strings.pushNotification,
        submitButtonLabel: strings.send,
        onResetClickHandler: _resetForm,
        onSubmitClickHandler: _submitForm,
        children: [
          CustomTextField(
            controller: _titleTextEditingController,
            label: strings.title,
            error: _titleError,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _bodyTextEditingController,
            hint: strings.body,
            error: _bodyError,
            maxLines: 6,
          ),
          const SizedBox(
            height: 16,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: CustomText(text: 'Schedule for (Eastern Time/${Const.tzNewYork.currentTimeZone.abbreviation}):'),
          ),
          Row(
            children: [
              Expanded(
                child: DateSelectWidget(
                  title: 'Date',
                  selectedDateNotifier: _scheduleForDateNotifier,
                  initialDate: tz.TZDateTime.now(Const.tzNewYork),
                ),
              ),
              Expanded(
                child: TimeSelectWidget(
                  title: 'Time',
                  selectedTimeNotifier: _scheduleForTimeNotifier,
                ),
              ),
            ],
          ),
          if (_scheduleDateTimeError != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CustomText(
                text: _scheduleDateTimeError!,
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ),
          const SizedBox(
            height: 16,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<PushMessageAudience>(
              value: targetAudience,
              items: const [
                DropdownMenuItem(
                  value: PushMessageAudience.all,
                  child: Text('Send to All'),
                ),
                DropdownMenuItem(
                  value: PushMessageAudience.paid,
                  child: Text('Send to Paid Users'),
                ),
                DropdownMenuItem(
                  value: PushMessageAudience.free,
                  child: Text('Send to Free Users'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    targetAudience = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('When user taps on the push notification, '),
              DropdownButton<PushMessageDestination>(
                value: destination,
                items: const [
                  DropdownMenuItem(
                    value: PushMessageDestination.tabHome,
                    child: Text('open home page of the app'),
                  ),
                  DropdownMenuItem(
                    value: PushMessageDestination.tabVideos,
                    child: Text('open videos tab of the app'),
                  ),
                  DropdownMenuItem(
                    value: PushMessageDestination.story,
                    child: Text('open the story page:'),
                  ),
                  DropdownMenuItem(
                    value: PushMessageDestination.video,
                    child: Text('open the video page:'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      destination = value;
                      destinationPageId = null;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          if (destination == PushMessageDestination.story || destination == PushMessageDestination.video)
            Autocomplete<SearchResult>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable.empty();
                }
                return GetIt.I<VibesPanelApi>().search(textEditingValue.text).then((value) => value
                    .where((e) => destination == PushMessageDestination.story ? e.story != null : e.video != null));
              },
              displayStringForOption: (option) =>
                  destination == PushMessageDestination.story ? option.story!.title : option.video!.title,
              onSelected: (result) {
                destinationPageId = destination == PushMessageDestination.story ? result.story!.id : result.video!.id;
              },
            ),
          const SizedBox(
            height: 96,
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    _bodyTextEditingController.clear();
    setState(() {
      targetAudience = PushMessageAudience.all;
      destination = PushMessageDestination.tabHome;
      destinationPageId = null;
      _scheduleForDateNotifier.value = null;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      tz.TZDateTime? scheduledDateTime;
      if (_scheduleForDateNotifier.value != null && _scheduleForTimeNotifier.value != null) {
        scheduledDateTime = tz.TZDateTime(
          Const.tzNewYork,
          _scheduleForDateNotifier.value!.year,
          _scheduleForDateNotifier.value!.month,
          _scheduleForDateNotifier.value!.day,
          _scheduleForTimeNotifier.value!.hour,
          _scheduleForTimeNotifier.value!.minute,
        );
      }

      BlocProvider.of<PushNotificationCubit>(context).sendPush(
        _titleTextEditingController.text,
        _bodyTextEditingController.text,
        targetAudience,
        destination,
        destinationPageId,
        scheduledDateTime?.toUtc(),
      );
    }
  }

  bool _validateFields() {
    var invalidFields = 0;

    if (_titleTextEditingController.text.isEmpty) {
      setState(() {
        _titleError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _titleError = false;
      });
    }

    if (_bodyTextEditingController.text.isEmpty) {
      setState(() {
        _bodyError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _bodyError = false;
      });
    }

    if (destination == PushMessageDestination.story || destination == PushMessageDestination.video) {
      if (destinationPageId == null) {
        invalidFields++;
      }
    }

    if ((_scheduleForDateNotifier.value == null) != (_scheduleForTimeNotifier.value == null)) {
      invalidFields++;
      setState(() {
        _scheduleDateTimeError = 'Select both date and time for a scheduled push, or none for an immediate one.';
      });
    } else {
      setState(() {
        _scheduleDateTimeError = null;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
