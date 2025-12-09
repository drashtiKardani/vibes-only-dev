import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibes_only/src/feature/toy/dev/hex.dart';

void main() {
  group("test", () {
    test("block", () async {
      final encrypter =
          Encrypter(AES(Key.fromUtf8('jdk#ekl%y8aloiei'), mode: AESMode.ecb));
      final iv = IV.fromLength(16);
      final encrypted = encrypter.encrypt('Battery;', iv: iv);
      print(encrypted.bytes);
      print(HEX.encode(encrypted.bytes));
      int i =32;
      String s = i.toString().padLeft(2, '0');
      print(s);
    });
  });
}

// roject I/System.out: Battery;
//  [B@e968d0d
//  0BFC2D3E6F4AE25C3DE1AB0CE641E1D0
