import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as asset;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibes_only/gen/assets.gen.dart';

class CardGameAppBar extends PreferredSize {
  CardGameAppBar(BuildContext context, {super.key, Widget? leading})
    : super(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: leading,
          titleSpacing: 14,
          title: Row(
            spacing: 10,
            children: [
              asset.Assets.svgs.applogoIconOnlyBlackNWhite.svg(
                height: 34,
                width: 34,
                package: 'flutter_mobile_app_presentation',
              ),
              Assets.images.applogoTextOnly.image(
                width: 100,
                filterQuality: FilterQuality.high,
                color: context.colorScheme.onSurface,
              ),
            ],
          ),
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.only(right: 4),
              onPressed: () => context.go('/main'),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                size: 24,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
}
