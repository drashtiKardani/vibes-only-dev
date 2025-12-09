import 'package:flutter/material.dart';

import 'flavor_config.dart';

class FlavorBanner extends StatefulWidget {
  final Widget child;
  final BannerConfig bannerConfig;
  FlavorBanner({super.key, required this.child})
      : bannerConfig = _getDefaultBanner();

  @override
  State<FlavorBanner> createState() => _FlavorBannerState();

  static BannerConfig _getDefaultBanner() {
    return BannerConfig(
        bannerName: Flavor.instance.name, bannerColor: Flavor.instance.color);
  }
}

class _FlavorBannerState extends State<FlavorBanner> {
  // bool serverSwapDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    if (Flavor.isProduction()) return widget.child;
    return Stack(
      children: <Widget>[
        widget.child,
        _buildBanner(context),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 50,
        height: 50,
        child: CustomPaint(
          painter: BannerPainter(
              message: widget.bannerConfig.bannerName,
              textDirection: Directionality.of(context),
              layoutDirection: Directionality.of(context),
              location: BannerLocation.topStart,
              color: widget.bannerConfig.bannerColor),
        ),
      ),
      onTap: () {
        /** Instead of banner, double tap on logo in home tab brings up the 'staging options' dialog.
         * The following code is kept for now, for its sentimental value. */
        // if (serverSwapDialogOpen) {
        //   Navigator.pop(GlobalNavigatorKey.get.currentContext!);
        // } else {
        //   showStagingOptionsDialog().then((value) => serverSwapDialogOpen = false);
        // }
        // serverSwapDialogOpen = !serverSwapDialogOpen;
      },
    );
  }
}

class BannerConfig {
  final String bannerName;
  final Color bannerColor;
  BannerConfig({required this.bannerName, required this.bannerColor});
}
