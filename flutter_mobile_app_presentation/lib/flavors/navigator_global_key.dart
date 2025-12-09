import 'package:flutter/material.dart';

/// This is the global key to the app's [NavigatorState].
/// Using this, one can push/pop routes or access the context of the app's [Navigator],
/// which was otherwise unavailable.
/// For example, an overlay on top of every screen, created using [build] property of [MaterialApp], does not
/// have access to the [NavigatorState] of the app, nor can it obtain access to it using [Navigator.of(context)].
/// In case of this app, we need this for showing a server selection dialog, when the "Staging" banner is tapped.
/// Hence, it currently resides in the "flavors" directory.
/// This may not be the preferred way to do it, but to my knowledge it is the only way. Improvements are welcome.
class GlobalNavigatorKey {
  GlobalNavigatorKey._();

  static final _navigatorKey = GlobalKey<NavigatorState>();
  static GlobalKey<NavigatorState> get get => _navigatorKey;
}
