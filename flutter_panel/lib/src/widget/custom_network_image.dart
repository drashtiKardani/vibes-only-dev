import 'package:flutter/material.dart';
import 'package:flutter_panel/src/di/di.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? url;

  const CustomNetworkImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    return url != null
        ? Image.network(
            url!,
            width: MediaQuery.of(context).size.width * 0.1,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _errorBuilder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )
        : _errorBuilder();
  }

  Widget _errorBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_rounded,
          color: Colors.red.shade400,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            strings.unableToLoadImage,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
