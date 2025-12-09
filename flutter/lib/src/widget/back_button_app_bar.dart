import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:hugeicons/hugeicons.dart';

class BackButtonAppBar extends PreferredSize {
  BackButtonAppBar(
    BuildContext context, {
    super.key,
    String? title,
    required VoidCallback onPressed,
  }) : super(
         preferredSize: const Size.fromHeight(kToolbarHeight),
         child: AppBar(
           automaticallyImplyLeading: false,
           scrolledUnderElevation: 0,
           leading: Transform.scale(
             scale: 0.7,
             child: DecoratedBox(
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 color: context.colorScheme.onSurface.withValues(alpha: 0.1),
               ),
               child: IconButton(
                 onPressed: onPressed,
                 icon: HugeIcon(
                   icon: HugeIcons.strokeRoundedArrowLeft02,
                   color: context.colorScheme.onSurface,
                 ),
                 iconSize: 30,
               ),
             ),
           ),
           title: title != null ? Text(title) : null,
           titleTextStyle: context.textTheme.displaySmall,
         ),
       );
}
