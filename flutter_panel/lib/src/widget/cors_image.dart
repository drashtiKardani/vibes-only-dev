import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class CorsImage extends StatelessWidget {
  const CorsImage({super.key, this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    var url = image ?? '';
    if (image != null) {
      try {
        var uri = Uri.parse(image!);
        var https = Uri.https(uri.authority, uri.path);
        url = https.toString();
      } catch (e) {
        // TODO log
      }
    }
    return SizedBox(
      width: 50,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: FadeInImage.memoryNetwork(
              image: url, placeholder: kTransparentImage),
        ),
      ),
    );
  }
}
