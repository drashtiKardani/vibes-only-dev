import 'package:flutter/material.dart';
import 'package:flutter_video_share_page/common/store_buttons.dart';
import 'package:flutter_video_share_page/common/vibes_share_page_scaffold.dart';

class DefaultPage extends StatelessWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VibesSharePageScaffold(
      builder: (BuildContext context, DisplayMode displayMode) {
        return Column(
          children: [
            Text(
              'Download the app',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            const StoreButtonsRow(),
          ],
        );
      },
    );
  }
}
