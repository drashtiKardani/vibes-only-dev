import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_table_item.dart';
import 'package:flutter_panel/src/widget/crud/custom_paginated_crud_table.dart';
import 'package:flutter_panel/src/widget/custom_alert_dialog.dart';
import 'package:flutter_panel/src/widget/custom_icon_button.dart';
import 'package:flutter_panel/src/widget/custom_network_image.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:iconly/iconly.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class DevicesAndCommoditiesPage extends StatefulWidget {
  const DevicesAndCommoditiesPage({super.key});

  @override
  State<DevicesAndCommoditiesPage> createState() => _DevicesAndCommoditiesPageState();
}

class _DevicesAndCommoditiesPageState extends State<DevicesAndCommoditiesPage> {
  late final CrudCubit cubit;

  List<Commodity>? allCommodities;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject())..getAllCommodities();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllCommodities: (commodities) => setState(() => allCommodities = commodities),
        itemsDeleted: () => cubit.getAllCommodities(),
        orElse: (state) => null,
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        title: strings.devicesAndCommodities,
        rows: [
          strings.name,
          strings.bluetoothName,
          strings.numberOfMotors,
          strings.isToy,
          strings.shopPicture,
          strings.controllerPicture,
          strings.actions,
        ],
        addButtonLabel: strings.add,
        onAddButtonClick: () => context.router.push(const AddDeviceOrCommodityRoute()),
        isLoading: state.isLoading,
        items: _generateItems(),
      ),
    );
  }

  List<Widget> _generateItems() {
    List<Widget> listOfRows = [];
    for (Commodity commodity in allCommodities ?? []) {
      listOfRows.add(CustomCrudTableItem(fields: [
        CustomText(text: commodity.name),
        CustomText(text: commodity.bluetoothName ?? ''),
        CustomText(text: commodity.numberOfMotors?.toString() ?? ''),
        CustomText(text: commodity.isToy ? 'Yes' : 'No'),
        CustomNetworkImage(url: commodity.shopPicture),
        commodity.controllerPagePicture != null
            ? CustomNetworkImage(url: commodity.controllerPagePicture)
            : const SizedBox.shrink(),
        Row(
          children: [
            CustomIconButton(
              onClick: () => context.router.push(UpdateDeviceOrCommodityRoute(commodity: commodity)),
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
                      cubit.deleteCommodity(commodity.id);
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
