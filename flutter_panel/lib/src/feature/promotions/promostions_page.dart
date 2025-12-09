import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/extension/constraint_extension.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_table_item.dart';
import 'package:flutter_panel/src/widget/crud/custom_paginated_crud_table.dart';
import 'package:flutter_panel/src/widget/custom_alert_dialog.dart';
import 'package:flutter_panel/src/widget/custom_icon_button.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:iconly/iconly.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  late final CrudCubit cubit;

  List<Promotion>? allPromotions;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject())..getAllPromotions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllPromotions: (promotions) => setState(() => allPromotions = promotions),
        itemsDeleted: () => cubit.getAllPromotions(),
        orElse: (state) => null,
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        title: strings.promotions,
        rows: [
          strings.title,
          strings.target,
          strings.subscriptionType,
          strings.frequency,
          strings.daysSinceMembershipStart,
          strings.daysSinceRegistration,
          strings.daysUntilSubscriptionEnd,
          strings.actions,
        ],
        addButtonLabel: strings.add,
        onAddButtonClick: () => context.router.push(const AddPromotionRoute()),
        isLoading: state.isLoading,
        items: _generateItems(),
      ),
    );
  }

  List<Widget> _generateItems() {
    List<Widget> listOfRows = [];
    for (Promotion promotion in allPromotions ?? []) {
      listOfRows.add(CustomCrudTableItem(fields: [
        CustomText(text: promotion.title),
        CustomText(text: promotion.target.name),
        CustomText(text: promotion.subscriptionType?.name ?? ''),
        CustomText(text: promotion.frequency?.toString() ?? ''),
        CustomText(
            text: "${promotion.daysSinceMembershipStartConstraint?.mathSymbol ?? ''}"
                " ${promotion.daysSinceMembershipStart?.toString() ?? ''}"),
        CustomText(
            text: "${promotion.daysSinceRegistrationConstraint?.mathSymbol ?? ''}"
                " ${promotion.daysSinceRegistration?.toString() ?? ''}"),
        CustomText(
            text: "${promotion.daysUntilSubscriptionEndConstraint?.mathSymbol ?? ''}"
                " ${promotion.daysUntilSubscriptionEnd?.toString() ?? ''}"),
        Row(
          children: [
            CustomIconButton(
              onClick: () => context.router.push(UpdatePromotionRoute(promotion: promotion)),
              iconSize: 26,
              icon: IconlyBold.edit,
            ),
            CustomIconButton(
              onClick: () => showDialog(
                context: context,
                builder: (context) => CustomAlertDialog(
                    title: 'Attention',
                    message: strings.areYouSure,
                    onPositiveButtonClick: () {
                      cubit.deletePromotion(promotion.id);
                      AutoRouter.of(context).maybePop();
                    }),
              ),
              iconSize: 26,
              icon: IconlyBold.delete,
              iconColor: Colors.red.shade400,
            ),
          ],
        ),
      ]));
    }
    return listOfRows;
  }
}
