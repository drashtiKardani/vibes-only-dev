import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreButtonsRow extends StatelessWidget {
  const StoreButtonsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PlayStoreButton(),
        SizedBox(width: 16),
        AppStoreButton(),
      ],
    );
  }
}

class PlayStoreButton extends StatelessWidget {
  const PlayStoreButton({Key? key}) : super(key: key);

  static const _vibesUrl = 'https://onelink.to/vibesonly';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(_vibesUrl)),
      child: Image.asset(
        "assets/play_store_button.png",
        height: 40,
        width: 135,
      ),
    );
  }
}

class AppStoreButton extends StatelessWidget {
  const AppStoreButton({Key? key}) : super(key: key);

  static const _vibesUrl = 'https://onelink.to/vibesonly';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(_vibesUrl)),
      child: Image.asset(
        "assets/app_store_button.png",
        height: 40,
        width: 135,
      ),
    );
  }
}
