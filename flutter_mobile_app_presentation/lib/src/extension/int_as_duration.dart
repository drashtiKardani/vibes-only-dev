extension CanExpressDuration on int {
  Duration seconds() {
    return Duration(seconds: this);
  }
}
