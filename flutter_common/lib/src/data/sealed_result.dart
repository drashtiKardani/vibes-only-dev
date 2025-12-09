import 'package:flutter/material.dart';
import 'package:vibes_common/src/model/errors.dart';
import 'package:vibes_common/src/model/models.dart';

/// [SealedResult] contains result of a Future whether it throw an exception or awaited successfully
/// use extension function Future.sealed() to create convert a Future<T> into  a Future<SealedResult<T>>
class SealedResult<T, E> {
  final T? _data;
  final E? _error;

  SealedResult._(this._data, this._error);

  factory SealedResult.error(E e) => SealedResult._(null, e);

  factory SealedResult.success(T value) => SealedResult._(value, null);

  /// use this method to consume the [SealedResult] values
  Future fold({
    required Future Function(T value) onSuccess,
    required Future Function(E error) onError,
  }) async {
    if (_data != null) {
      await onSuccess(_data as T);
    } else if (_error != null) {
      await onError(_error as E);
    }
  }

  bool get isFailure => _error != null;

  bool get isSuccessful => _error == null;

  T get data {
    if (isFailure) {
      throw Exception(
        'you cannot call getter data when Result has an error '
        'please use isSuccessful to check if Result is successful and has a data ',
      );
    }
    return _data!;
  }

  E get error {
    if (isSuccessful) {
      throw Exception(
        'you cannot call getter error when Result isSuccessful'
        'please use isFailure to check if Result has failed and has an error ',
      );
    }
    return _error!;
  }

  @override
  String toString() {
    return 'SealedResult{data: $_data, error: $_error}';
  }
}

extension SealedResultExt<T> on Future<T> {
  Future<SealedResult<T, VibeError>> sealed() async {
    try {
      var result = await this;
      return SealedResult.success(result);
    } catch (e) {
      debugPrint('$e');
      var error = VibeError.network(error: NetworkError(message: '', code: 0));
      return SealedResult.error(error);
    }
  }
}
