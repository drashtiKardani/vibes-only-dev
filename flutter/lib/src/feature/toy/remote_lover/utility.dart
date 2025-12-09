mixin class CastingUtility {
  static T? tryCast<T>(Object? object) {
    return object is T ? object : null;
  }
}
