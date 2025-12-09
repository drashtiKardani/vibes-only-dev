import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/data/commodities_store.dart';

class ToyPicture extends StatelessWidget {
  const ToyPicture({super.key, required this.toy});

  final ToyCubit toy;

  Commodity? get connectedToy =>
      GetIt.I<CommoditiesStore>().toyWithName(toy.connectedDeviceName);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: connectedToy?.controllerPagePicture != null
          ? CachedNetworkImage(
              height: 140,
              width: 140,
              imageUrl: connectedToy!.controllerPagePicture!,
            )
          : null,
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 20),
    //   child: Stack(
    //     alignment: Alignment.center,
    //     children: [
    //       /// Only show light and battery when it is in local mode (not for Long Distance).
    //       if (toy is ToyCubitImpl) ...[
    //         Positioned(
    //           right: 10,
    //           child: Row(
    //             children: [
    //               const SizedBox(width: 4),
    //               Container(
    //                 width: 50,
    //                 height: 50,
    //                 padding: const EdgeInsets.symmetric(horizontal: 8),
    //                 child: BlocBuilder<ToyCubit, ToyState>(
    //                     builder: (context, state) {
    //                   return Image.asset(
    //                     _batteryAssetForBatteryPercentage(
    //                         state.batteryPercentage),
    //                   );
    //                 }),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Positioned(
    //           left: 10,
    //           child: SizedBox.square(
    //             dimension: 44,
    //             child: BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
    //               builder: (context, subscription) {
    //                 return BlocBuilder<ToyCubit, ToyState>(
    //                     builder: (context, state) {
    //                   return ElevatedButton(
    //                     onPressed: () {
    //                       if (subscription.isNotActive()) {
    //                         return showGoPremiumDialog(context,
    //                             type: PremiumType.feature);
    //                       }
    //                       BlocProvider.of<ToyCubit>(context).switchLight();
    //                     },
    //                     style: ElevatedButton.styleFrom(
    //                       shape: const CircleBorder(),
    //                       padding: EdgeInsets.zero,
    //                       elevation: 0,
    //                       backgroundColor: state.isLightOn
    //                           ? AppColors.vibesPink
    //                           : AppColors.grey2F,
    //                     ),
    //                     child: const Icon(VibesV2.light),
    //                   );
    //                 });
    //               },
    //             ),
    //           ),
    //         )
    //       ],
    //       Center(
    //         child: connectedToy?.controllerPagePicture != null
    //             ? CachedNetworkImage(
    //                 height: 120,
    //                 width: 120,
    //                 imageUrl: connectedToy!.controllerPagePicture!,
    //               )
    //             : const SizedBox.square(dimension: 80),
    //       ),
    //     ],
    //   ),
    // );
  }
}
