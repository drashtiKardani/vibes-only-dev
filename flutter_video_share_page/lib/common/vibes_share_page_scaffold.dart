import 'package:flutter/material.dart';
import 'package:flutter_video_share_page/common/vibes_logo.dart';

enum DisplayMode { mobile, web }

class VibesSharePageScaffold extends StatelessWidget {
  const VibesSharePageScaffold({Key? key, required this.builder}) : super(key: key);

  final Widget Function(BuildContext context, DisplayMode displayMode) builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final displayMode = detectDisplayModeUsing(constraints);
          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: displayMode == DisplayMode.web ? 50 : 40),
                  VibesLogo(height: displayMode == DisplayMode.web ? 74 : 54),
                  SizedBox(height: displayMode == DisplayMode.web ? 40 : 20),
                  builder(context, displayMode),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              'Copyright © 2022 Vibes Only All rights reserved',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }

  DisplayMode detectDisplayModeUsing(BoxConstraints constraints) =>
      constraints.maxWidth > 480 ? DisplayMode.web : DisplayMode.mobile;
}
