import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/dialog/go_premium_dialog_provider.dart';
import 'package:get_it/get_it.dart';

void showGoPremiumBottomSheet(BuildContext context,
    {PremiumType type = PremiumType.content}) {
  GetIt.I<GoPremiumDialogProvider>().display(context, type: type);
}
