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
class VideoCreatorsPage extends StatefulWidget {
  const VideoCreatorsPage({super.key});

  @override
  State<VideoCreatorsPage> createState() => _VideoCreatorsPageState();
}

class _VideoCreatorsPageState extends State<VideoCreatorsPage> {
  late final CrudCubit cubit;

  List<VideoCreator>? allVideoCreators;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject());
    _fetchListFromServer();
  }

  void _fetchListFromServer() => cubit.getAllVideoCreators();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllVideoCreators: (data) => setState(() => allVideoCreators = data),
        itemsDeleted: _fetchListFromServer,
        orElse: (state) => null,
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        title: strings.videoCreators,
        rows: [
          strings.name,
          strings.photo,
          strings.bio,
          strings.isStaffChoice,
          strings.order,
          strings.actions,
        ],
        addButtonLabel: strings.add,
        onAddButtonClick: () => context.router.push(const AddVideoCreatorRoute()),
        isLoading: state.isLoading,
        items: _generateItems(),
      ),
    );
  }

  List<Widget> _generateItems() {
    List<Widget> listOfRows = [];
    for (VideoCreator videoCreator in allVideoCreators ?? []) {
      listOfRows.add(CustomCrudTableItem(fields: [
        CustomText(text: videoCreator.name),
        CustomNetworkImage(url: videoCreator.photo),
        CustomText(text: videoCreator.bio),
        CustomText(text: videoCreator.isStaffChoice ? 'Yes' : 'No'),
        CustomText(text: videoCreator.order.toString()),
        Row(
          children: [
            CustomIconButton(
              onClick: () => context.router.push(UpdateVideoCreatorRoute(videoCreator: videoCreator)),
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
                      cubit.deleteVideoCreator(videoCreator.id);
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
