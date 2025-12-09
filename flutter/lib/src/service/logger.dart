class Logger {
  final String scope;
  final verboseLogging = false;

  const Logger(this.scope);

  void e(String errorMessage) {
    print('🛑 ERROR - $scope: $errorMessage');
  }

  void i(String message) {
    print('☞ INFO - $scope: $message');
  }

  void w(String warningMessage) {
    print('⚠️ WARNING - $scope: $warningMessage');
  }

  void v(String verboseMessage) {
    if (verboseLogging) {
      print('🗣 VERBOSE - $scope: $verboseMessage');
    }
  }

  static const push = Logger('Push Notification 🚀');
  static const storyTranscript = Logger('Story Transcript 📜');
  static const toy = Logger('Toy 🧸');
  static const remoteLover = Logger('Long Distance <💘>');
}
