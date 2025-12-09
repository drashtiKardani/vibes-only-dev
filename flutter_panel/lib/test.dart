// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:dio/dio.dart';
// import 'package:universal_io/io.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   final String title = 'File Picker Test';
//
//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         title: title,
//         theme: ThemeData(primarySwatch: Colors.deepOrange),
//         home: const FilePickerTestPage(),
//       );
// }
//
// class FilePickerTestPage extends StatefulWidget {
//   const FilePickerTestPage({Key? key}) : super(key: key);
//
//   @override
//   State<FilePickerTestPage> createState() => _FilePickerTestPageState();
// }
//
// class _FilePickerTestPageState extends State<FilePickerTestPage> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: ElevatedButton(
//             onPressed: () async {
//               var file = await _loadSingleFile();
//               if (file != null) {
//                 print('File retrieved');
//                 var f = File.fromRawPath(file.bytes!);
//                 var part = MultipartFile.fromFileSync(f.path,
//                     filename: file.path.split(Platform.pathSeparator).last);
//               }
//             },
//             child: Text('open files')));
//   }
//
//   Future<PlatformFile?> _loadSingleFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//
//     if (result != null) {
//       return result.files.single;
//     } else {
//       return null;
//       // User canceled the picker
//     }
//   }
// }
