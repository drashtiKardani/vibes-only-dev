import 'package:flutter/material.dart';

class Logger {
  final String scope;
  final verboseLogging = false;

  const Logger(this.scope);

  void e(String errorMessage) {
    debugPrint('🛑 ERROR - $scope: $errorMessage');
  }

  void i(String message) {
    debugPrint('☞ INFO - $scope: $message');
  }

  void w(String warningMessage) {
    debugPrint('⚠️ WARNING - $scope: $warningMessage');
  }

  void v(String verboseMessage) {
    if (verboseLogging) {
      debugPrint('🗣 VERBOSE - $scope: $verboseMessage');
    }
  }

  static const push = Logger('Push Notification 🚀');
  static const storyTranscript = Logger('Story Transcript 📜');
  static const toy = Logger('Toy 🧸');
}
