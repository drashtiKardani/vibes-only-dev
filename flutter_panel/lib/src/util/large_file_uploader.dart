import 'dart:async';

import 'package:flutter_panel/src/enum/file_types.dart';
import 'package:universal_html/html.dart' as html;

/// Callback exposing currently upload progress.
typedef UploadProgressListener = Function(int progress);

/// Callback exposing upload fail event.
typedef UploadFailureListener = Function();

/// Callback exposing upload complete event.
typedef UploadCompleteListener = Function(String response);

/// Callback exposing one or multiple files selected.
typedef OnFileSelectedListener = Function(html.File file);

/// Uploading large file util by using JS in flutter web.
class LargeFileUploader {
  static void pick({
    FileTypes type = FileTypes.file,
    String? customFileType,
    required OnFileSelectedListener callback,
  }) {
    html.FileUploadInputElement fileUploadInputElement = html.FileUploadInputElement();
    fileUploadInputElement.accept = customFileType ?? type.value;
    fileUploadInputElement.multiple = false;
    fileUploadInputElement.click();

    fileUploadInputElement.onChange.listen((_) {
      if (fileUploadInputElement.files != null) {
        callback.call(fileUploadInputElement.files!.first);
      }
    });
  }

  static void upload({
    required String uploadUrl,
    required UploadProgressListener onSendProgress,
    required Map<String, dynamic> data,
    String method = 'POST',
    Map<String, dynamic>? headers,
    int fakePreProcessMaxProgress = 30,
    int fakePreProcessProgressPeriodInMillisecond = 500,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    final uploader = _LargeFileUploader();
    uploader.upload(
      uploadUrl: uploadUrl,
      onSendProgress: onSendProgress,
      data: data,
      method: method,
      headers: headers,
      fakePreProcessMaxProgress: fakePreProcessMaxProgress,
      fakePreProcessProgressPeriodInMillisecond: fakePreProcessProgressPeriodInMillisecond,
      onSendWithFakePreProcessProgress: onSendWithFakePreProcessProgress,
      onFailure: onFailure,
      onComplete: onComplete,
    );
  }

  static void selectFileAndUpload({
    String method = 'POST',
    FileTypes type = FileTypes.file,
    String? customFileType,
    required String uploadUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    required UploadProgressListener onSendProgress,
    int fakePreProcessMaxProgress = 30,
    int fakePreProcessProgressPeriodInMillisecond = 500,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    final uploader = _LargeFileUploader();
    pick(
      type: type,
      customFileType: customFileType,
      callback: (file) {
        data ??= {};
        data!["file"] = file;
        uploader.upload(uploadUrl: uploadUrl, onSendProgress: onSendProgress, data: data!);
      },
    );
  }
}

/// Uploading large file util by using JS in flutter web.
class _LargeFileUploader {
  _LargeFileUploader() : _worker = html.Worker('upload_worker.js');

  final html.Worker _worker;
  Timer? _timer;
  int _fakeProgress = 0;

  void upload({
    required String uploadUrl,
    required UploadProgressListener onSendProgress,
    required Map<String, dynamic> data,
    String method = 'POST',
    Map<String, dynamic>? headers,
    int fakePreProcessMaxProgress = 30,
    int fakePreProcessProgressPeriodInMillisecond = 500,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    _worker.postMessage({
      'method': method,
      'uploadUrl': uploadUrl,
      'data': data,
      'headers': headers,
    });

    if (onSendWithFakePreProcessProgress != null) {
      _timer = Timer.periodic(Duration(milliseconds: fakePreProcessProgressPeriodInMillisecond), (Timer timer) {
        if (_fakeProgress != fakePreProcessMaxProgress) {
          _fakeProgress++;
          onSendWithFakePreProcessProgress.call(_fakeProgress);
        } else {
          _disposeTimerAndFakeProgress();
        }
      });
    }

    _worker.onMessage.listen((data) {
      _handleCallbacks(data.data,
          onSendProgress: onSendProgress,
          fakePreProcessMaxProgress: fakePreProcessMaxProgress,
          onSendWithFakePreProcessProgress: onSendWithFakePreProcessProgress,
          onFailure: onFailure,
          onComplete: onComplete);
    });
  }

  void _handleCallbacks(
    data, {
    required UploadProgressListener onSendProgress,
    required int fakePreProcessMaxProgress,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    if (data == null) return;

    if (data is int) {
      onSendProgress.call(data);
      if (data != 0) {
        _disposeTimerAndFakeProgress();
        onSendWithFakePreProcessProgress
            ?.call((fakePreProcessMaxProgress + (data * ((100 - fakePreProcessMaxProgress) / 100))).toInt());
      }
    } else if (data.toString() == 'request failed') {
      _disposeTimerAndFakeProgress();
      _worker.terminate();
      onFailure?.call();
    } else {
      onSendWithFakePreProcessProgress?.call(100);
      _disposeTimerAndFakeProgress();
      _worker.terminate();
      onComplete?.call(data);
    }
  }

  void _disposeTimerAndFakeProgress() {
    if (_timer?.isActive ?? false) {
      _fakeProgress = 0;
      _timer?.cancel();
    }
  }
}
