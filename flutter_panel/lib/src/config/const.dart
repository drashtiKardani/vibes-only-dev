import 'package:timezone/browser.dart' as tz;

class Const {
  static const unlimitedRequestLimit = 1000000;
  static const defaultRequestLimit = 20;

  static final tzNewYork = tz.getLocation('America/New_York');
}
