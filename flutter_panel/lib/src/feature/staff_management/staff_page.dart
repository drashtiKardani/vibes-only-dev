import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_table_item.dart';
import 'package:flutter_panel/src/widget/crud/custom_paginated_crud_table.dart';
import 'package:flutter_panel/src/widget/custom_alert_dialog.dart';
import 'package:flutter_panel/src/widget/custom_icon_button.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:iconly/iconly.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  State createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  late final CrudCubit cubit;

  List<Widget>? items;
  int? previousOffset, nextOffset;
  int currentOffset = 0, pageCount = 1;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject())..getAllStaffs(Const.defaultRequestLimit, currentOffset);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllStaffs: (allStaff) {
          setState(() {
            items = _generateItems(context, allStaff.results);
          });
          return null;
        },
        itemsDeleted: () => cubit.getAllStaffs(Const.defaultRequestLimit, currentOffset),
        orElse: (crudState) {
          return null;
        },
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        isLoading: state.isLoading,
        title: strings.staffs,
        rows: [strings.name, strings.email, strings.phoneNumber, strings.actions],
        items: items,
        addButtonLabel: strings.addNewStaff,
        onAddButtonClick: () => context.router.push(const AddStaffRoute()),
        onSearchChanged: _searchBoxChangeHandler,
        nextPage: nextOffset != null
            ? () {
                cubit.getAllStaffs(Const.defaultRequestLimit, nextOffset!);
                setState(() {
                  currentOffset = nextOffset!;
                });
              }
            : null,
        previousPage: previousOffset != null
            ? () {
                cubit.getAllStaffs(Const.defaultRequestLimit, previousOffset!);
                setState(() {
                  currentOffset = previousOffset!;
                });
              }
            : null,
        pageCount: pageCount.toString(),
      ),
    );
  }

  List<Widget> _generateItems(BuildContext context, List<Staff> staffs) {
    final generatedItems = <Widget>[];

    for (final staff in staffs) {
      final fields = <Widget>[];
      fields.add(CustomText(
        text: '${staff.firstName ?? ''} ${staff.lastName ?? ''}',
      ));
      fields.add(CustomText(
        text: staff.email ?? '',
      ));
      fields.add(CustomText(
        text: staff.phoneNumber ?? '',
      ));
      fields.add(Row(
        children: [
          CustomIconButton(
            onClick: () => context.router.push(UpdateStaffRoute(id: staff.id.toString())),
            iconSize: 26,
            icon: IconlyBold.editSquare,
          ),
          CustomIconButton(
            onClick: () => showDialog(
              context: context,
              builder: (context) => CustomAlertDialog(
                  title: 'Attention',
                  message: strings.areYouSure,
                  onPositiveButtonClick: () {
                    cubit.deleteStaffs([staff.id]);
                    AutoRouter.of(context).maybePop();
                  }),
            ),
            iconSize: 26,
            icon: IconlyBold.delete,
            iconColor: Colors.red.shade400,
          ),
        ],
      ));
      generatedItems.add(CustomCrudTableItem(fields: fields));
    }

    return generatedItems;
  }

  void _searchBoxChangeHandler(String query) {
    setState(() {
      currentOffset = 0;
    });
    if (query.isNotEmpty) {
      cubit.getAllStaffs(Const.defaultRequestLimit, currentOffset, search: query);
    } else {
      cubit.getAllStaffs(Const.defaultRequestLimit, currentOffset);
    }
  }
}
