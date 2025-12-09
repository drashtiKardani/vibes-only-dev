import 'package:flutter/material.dart';

extension Themeing on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
}
