import 'package:shared_preferences/shared_preferences.dart';

class SyncSharedPreferences {
  static late final SharedPreferences instance;

  static init() async {
    instance = await SharedPreferences.getInstance();
  }

  static const isSubtitleOn = Preference('IS_SUBTITLE_ON');

  static const doNotAskToConnectToy = Preference('DO_NOT_ASK_TO_CONNECT_TOY');

  static const userSkippedInitialIAP = Preference('USER_SKIPPED_INITIAL_IAP');

  static const simulatedSubscription = Preference('SIMULATED_SUBSCRIPTION');

  static const bluetoothDiscoverEverything = Preference('BLUETOOTH_DISCOVER_EVERYTHING');

  static const enableNotifications = Preference('ENABLE_NOTIFICATION', defaultValue: true);

  static const doNotShowVibeStudioIntro = Preference('DO_NOT_SHOW_VIBE_STUDIO_INTRO');
  static const doNotShowToySoundControlIntro = Preference('DO_NOT_SHOW_TOY_SOUND_CONTROL_INTRO');
  static const doNotShowMagicWandIntro = Preference('DO_NOT_SHOW_MAGIC_WAND_INTRO');
  static const doNotShowFourWayControllerIntro = Preference('DO_NOT_SHOW_FOUR_WAY_CONTROLLER_INTRO');

  static const doNotShowHowToPlayForCardGame = Preference('DO_NOT_SHOW_HOW_TO_PLAY_FOR_CARD_GAME');

}

class Preference {
  final String _key;
  final bool _defaultValue;

  const Preference(this._key, {bool defaultValue = false}) : _defaultValue = defaultValue;

  bool get value => SyncSharedPreferences.instance.getBool(_key) ?? _defaultValue;

  set value(bool value) => SyncSharedPreferences.instance.setBool(_key, value);
}
