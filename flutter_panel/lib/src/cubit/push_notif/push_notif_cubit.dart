import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/push_notif/push_notif_state.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:vibes_common/vibes.dart';

class PushNotificationCubit extends Cubit<PushNotificationState> {
  PushNotificationCubit(this.api) : super(const PushNotificationState.initial());

  final VibesPanelApi api;

  Future<void> getAllPushMessages() async {
    emit(const PushNotificationState.loading());
    final result = await api.getAllPushMessages().sealed();
    if (result.isSuccessful) {
      emit(PushNotificationState.getAllPushNotifications(pushNotifications: result.data));
    } else {
      emit(PushNotificationState.failure(error: result.error));
    }
  }

  Future<void> sendPush(String title, String body, PushMessageAudience targetAudience,
      PushMessageDestination destination, int? pageId, DateTime? scheduledDateTime) async {
    emit(const PushNotificationState.sending());
    var result = await api
        .sendPush(PushMessage(
          title: title,
          body: body,
          target: targetAudience,
          destination: destination,
          pageId: pageId,
          scheduledFor: scheduledDateTime,
        ))
        .sealed();
    if (result.isSuccessful) {
      emit(const PushNotificationState.successfullySent());
    } else {
      emit(PushNotificationState.failure(error: result.error));
    }
  }

  Future<void> deletePush(int id) async {
    emit(const PushNotificationState.deleting());
    await api.deletePush(id).sealed();
    emit(const PushNotificationState.itemsDeleted());
  }
}
