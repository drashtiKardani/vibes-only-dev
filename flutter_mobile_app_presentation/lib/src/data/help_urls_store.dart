import 'package:flutter_mobile_app_presentation/api.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:vibes_common/vibes.dart';

part 'help_urls_store.g.dart';

// ignore: library_private_types_in_public_api
class HelpUrlsStore = _HelpUrlsStore with _$HelpUrlsStore;

abstract class _HelpUrlsStore with Store {
  _HelpUrlsStore() {
    GetIt.I<VibeApiNew>().getHelpUrls().then((helpUrls) {
      this.helpUrls = helpUrls;
    }).catchError((err) {
      error = err;
    });
  }

  @observable
  HelpUrls? helpUrls;

  @observable
  dynamic error;
}
