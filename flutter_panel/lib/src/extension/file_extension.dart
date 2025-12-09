import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:http/http.dart' as http;

import 'dart:typed_data';

extension FileModifier on html.File {
  Future<Uint8List> asBytes() async {
    final bytesFile = Completer<List<int>>();
    final reader = html.FileReader();
    reader.onLoad.listen((event) => bytesFile.complete(reader.result as FutureOr<List<int>>?));
    reader.readAsArrayBuffer(this);
    return Uint8List.fromList(await bytesFile.future);
  }
}

extension FileBytes on Uri {
  Future<Uint8List> asBytes() async {
    final request = await http.get(this);
    return request.bodyBytes;
  }
}
