// import 'dart:io' show Platform;

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart'
//     show VibeApiNew;
// import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
// import 'package:flutter_mobile_app_presentation/theme.dart';
// import 'package:get_it/get_it.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vibes_common/vibes.dart';
// import 'package:vibes_only/src/data/commodities_store.dart';
// import 'package:vibes_only/src/service/analytics.dart';
// import 'package:vibes_only/src/widget/back_button_app_bar.dart';
// import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

// class ShopScreen extends StatefulWidget {
//   const ShopScreen({super.key});

//   @override
//   State<ShopScreen> createState() => _ShopScreenState();
// }

// class _ShopScreenState extends State<ShopScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final List<Commodity> commodities =
//         GetIt.I<CommoditiesStore>().commodities ?? [];

//     List<Commodity> activeCommodities = commodities
//         .where((c) => c.isActive)
//         .toList();
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: BackButtonAppBar(
//         context,
//         onPressed: () => Navigator.pop(context),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: assets.Assets.images.background.image(
//               filterQuality: FilterQuality.high,
//               package: 'flutter_mobile_app_presentation',
//             ),
//           ),
//           if (Platform.isIOS)
//             // iosShopSection()
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//               ).copyWith(top: context.viewPadding.top + kToolbarHeight + 10),
//               child: RefreshIndicator(
//                 onRefresh: () async {
//                   final store = GetIt.I<CommoditiesStore>();
//                   try {
//                     final commodities = await GetIt.I<VibeApiNew>()
//                         .getAllCommodities();
//                     store.commodities = commodities;
//                     setState(() async {
//                       activeCommodities = commodities
//                           .where((c) => c.isActive)
//                           .toList();
//                       store.error = null;
//                     });
//                   } catch (err) {
//                     print(err);
//                     store.error = err;
//                   }
//                 },
//                 child: GridView.builder(
//                   itemCount: activeCommodities.length,
//                   padding: EdgeInsets.only(
//                     bottom: context.viewPadding.bottom + 10,
//                   ),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 14,
//                     crossAxisSpacing: 14,
//                     mainAxisExtent: 240,
//                   ),
//                   itemBuilder: (context, index) {
//                     Commodity commodity = activeCommodities[index];
//                     return Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         color: context.colorScheme.onSurface.withValues(
//                           alpha: 0.05,
//                         ),
//                         border: Border.all(
//                           color: context.colorScheme.onSurface.withValues(
//                             alpha: 0.2,
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         spacing: 10,
//                         children: [
//                           Expanded(
//                             flex: 6,
//                             child: CachedNetworkImage(
//                               imageUrl: commodity.controllerPagePicture ?? '',
//                             ),
//                           ),
//                           Expanded(
//                             flex: 4,
//                             child: Column(
//                               spacing: 10,
//                               children: [
//                                 Text(
//                                   commodity.name,
//                                   textAlign: TextAlign.center,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: context.textTheme.titleMedium,
//                                 ),
//                                 VibesElevatedButton(
//                                   size: Size(140, 40),
//                                   onPressed: commodity.shopUrl != null
//                                       ? () {
//                                           final Uri shopUri = Uri.parse(
//                                             commodity.shopUrl!,
//                                           );
//                                           Analytics.logEvent(
//                                             context: context,
//                                             name: 'vibesBuy',
//                                             parameters: {
//                                               'vibesBuy__name': commodity.name,
//                                             },
//                                           );
//                                           Platform.isAndroid
//                                               ? launchUriExternalWithPopUp(
//                                                   context,
//                                                   shopUri,
//                                                 )
//                                               : launchUrl(shopUri);
//                                         }
//                                       : null,
//                                   text: 'Buy',
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void launchUriExternalWithPopUp(BuildContext context, Uri uri) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: const Text(
//             'You are about to visit an external link, do you want to proceed?',
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 TextButton(
//                   child: const Text('Proceed'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     launchUrl(uri, mode: LaunchMode.externalApplication);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart'
    show VibeApiNew;
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/service/analytics.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  /// ✅ UI state lives here
  List<Commodity> _activeCommodities = [];

  @override
  void initState() {
    super.initState();
    _syncFromStore();
  }

  /// Sync UI state from store (single responsibility)
  void _syncFromStore() {
    final commodities = GetIt.I<CommoditiesStore>().commodities ?? [];

    _activeCommodities = commodities.where((c) => c.isActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
        title: 'Shop',
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ).copyWith(top: context.viewPadding.top + kToolbarHeight + 10),
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _activeCommodities.isEmpty
                    ? const Center(child: Text('No products available'))
                    : GridView.builder(
                        padding: EdgeInsets.only(
                          bottom: context.viewPadding.bottom + 10,
                        ),
                        itemCount: _activeCommodities.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              mainAxisExtent: 240,
                            ),
                        itemBuilder: (context, index) {
                          return _CommodityCard(
                            commodity: _activeCommodities[index],
                            onBuyPressed: _onBuyPressed,
                          );
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }

  /// Pull-to-refresh handler (NO async in setState)
  Future<void> _onRefresh() async {
    final store = GetIt.I<CommoditiesStore>();

    try {
      final commodities = await GetIt.I<VibeApiNew>().getAllCommodities();

      store.commodities = commodities;
      store.error = null;

      setState(() {
        _activeCommodities = commodities.where((c) => c.isActive).toList();
      });
    } catch (err) {
      store.error = err;
    }
  }

  void _onBuyPressed(BuildContext context, Commodity commodity) {
    final Uri shopUri = Uri.parse(commodity.shopUrl!);

    Analytics.logEvent(
      context: context,
      name: 'vibesBuy',
      parameters: {'vibesBuy__name': commodity.name},
    );

    Platform.isAndroid
        ? launchUriExternalWithPopUp(context, shopUri)
        : launchUrl(shopUri);
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }
}

class _CommodityCard extends StatelessWidget {
  final Commodity commodity;
  final void Function(BuildContext, Commodity) onBuyPressed;

  const _CommodityCard({required this.commodity, required this.onBuyPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.colorScheme.onSurface.withValues(alpha: 0.05),
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.2),
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
                  size: const Size(140, 40),
                  text: 'Buy',
                  onPressed: commodity.shopUrl == null
                      ? null
                      : () => onBuyPressed(context, commodity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
