import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/service/analytics.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Commodity> commodities =
        GetIt.I<CommoditiesStore>().commodities ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: assets.Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          if (Platform.isIOS)
            // iosShopSection()
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ).copyWith(top: context.viewPadding.top + kToolbarHeight + 10),
              child: GridView.builder(
                itemCount: commodities.length,
                padding: EdgeInsets.only(
                  bottom: context.viewPadding.bottom + 10,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 240,
                ),
                itemBuilder: (context, index) {
                  Commodity commodity = commodities[index];
                  return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      border: Border.all(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.2,
                        ),
                      ),
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Expanded(
                          flex: 6,
                          child: CachedNetworkImage(
                            imageUrl: commodity.controllerPagePicture ?? '',
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            spacing: 10,
                            children: [
                              Text(
                                commodity.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium,
                              ),
                              VibesElevatedButton(
                                size: Size(140, 40),
                                onPressed: commodity.shopUrl != null
                                    ? () {
                                        final Uri shopUri = Uri.parse(
                                          commodity.shopUrl!,
                                        );
                                        Analytics.logEvent(
                                          context: context,
                                          name: 'vibesBuy',
                                          parameters: {
                                            'vibesBuy__name': commodity.name,
                                          },
                                        );
                                        Platform.isAndroid
                                            ? launchUriExternalWithPopUp(
                                                context,
                                                shopUri,
                                              )
                                            : launchUrl(shopUri);
                                      }
                                    : null,
                                text: 'Buy',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void launchUriExternalWithPopUp(BuildContext context, Uri uri) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text(
            'You are about to visit an external link, do you want to proceed?',
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Proceed'),
                  onPressed: () {
                    Navigator.pop(context);
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
