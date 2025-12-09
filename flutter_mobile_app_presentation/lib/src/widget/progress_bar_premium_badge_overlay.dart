import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../gen/assets.gen.dart';
import '../app_config.dart';
import '../cubit/iap/in_app_purchase_cubit.dart';
import '../cubit/iap/in_app_purchase_state.dart';

class PremiumBadgeOverlay extends StatelessWidget {
  final ProgressBar progressBar;
  final bool premium;
  final Duration? totalDuration;

  /// For manual positioning of overlay, because if [ProgressBar] displays time, its position inside its box changes.
  /// This is the case here, where StoryPlayer shows time below the seekbar, but VideoPlayer doesn't.
  final double verticalCorrection;

  const PremiumBadgeOverlay({
    super.key,
    required this.progressBar,
    required this.premium,
    required this.totalDuration,
    this.verticalCorrection = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InAppPurchaseCubit, InAppPurchaseState>(
        builder: (context, subscription) {
      return LayoutBuilder(builder: (context, constraints) {
        final mustShowPremiumBadgeOnSeekbar =
            premium && subscription.status != InAppPurchaseStatus.active;

        final totalDurationInMillis = totalDuration?.inMilliseconds;
        final premiumBadgeLeftPosition = totalDurationInMillis == null
            ? null
            : constraints.maxWidth *
                AppConfig.premiumContentPreviewLimit.inMilliseconds /
                totalDurationInMillis;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            progressBar,
            if (mustShowPremiumBadgeOnSeekbar &&
                premiumBadgeLeftPosition != null) ...[
              Positioned(
                left: premiumBadgeLeftPosition + 2,
                right: 0,
                top: verticalCorrection,
                child: Container(
                  height: 2,
                  color: const Color(0xffFF8D23),
                ),
              ),
              Positioned(
                left: premiumBadgeLeftPosition + 2,
                top: -15 + verticalCorrection,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF8D23),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Assets.images.iconPremium.image(width: 20),
                  ),
                ),
              ),
            ]
          ],
        );
      });
    });
  }
}
