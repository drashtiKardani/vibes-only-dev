import 'package:flutter/material.dart';

abstract class ConnectToyDialogProvider {
  Future display(BuildContext context);
}

class DisabledConnectToyDialogProvider extends ConnectToyDialogProvider {
  @override
  Future display(BuildContext context) {
    return Future.value();
  }
}
