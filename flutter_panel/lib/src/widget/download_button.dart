import 'package:flutter/material.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadButton extends StatelessWidget {
  final String url;
  final String? label;

  const DownloadButton({super.key, required this.url, this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async => launchUrl(Uri.parse(url)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            label ?? strings.downloadFile,
            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
