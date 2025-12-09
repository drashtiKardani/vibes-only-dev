import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'push_notif_state.sealed.dart';

@Sealed()
abstract class _PushNotificationState {
  void initial();

  void loading();

  void deleting();

  void itemsDeleted();

  void getAllPushNotifications(List<PushResponse> pushNotifications);

  void sending();

  void successfullySent();

  void failure(@WithType('VibeError') error);
}
