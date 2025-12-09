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
import 'package:flutter_panel/src/widget/custom_network_image.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:iconly/iconly.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';

@RoutePage()
class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key});

  @override
  State createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  late final CrudCubit cubit;
  List<Widget>? items;

  int? previousOffset, nextOffset;
  int currentOffset = 0, pageCount = 1;

  @override
  void initState() {
    cubit = CrudCubit(api: inject(), uploadApi: inject())..getAllChannels(Const.defaultRequestLimit, currentOffset);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllChannels: (channels) {
          setState(() {
            items = _generateItems(context, channels.results);

            if (channels.next != null) {
              final url = Uri.parse(channels.next!);

              if (url.queryParameters.containsKey('offset')) {
                nextOffset = int.parse(url.queryParameters['offset']!);
              } else {
                nextOffset = 0;
              }
            } else {
              nextOffset = null;
            }

            if (channels.previous != null) {
              final url = Uri.parse(channels.previous!);

              if (url.queryParameters.containsKey('offset')) {
                previousOffset = int.parse(url.queryParameters['offset']!);
              } else {
                previousOffset = 0;
              }
            } else {
              previousOffset = null;
            }

            pageCount = (currentOffset ~/ Const.defaultRequestLimit) + 1;
          });
          return null;
        },
        itemsDeleted: () => cubit.getAllChannels(Const.defaultRequestLimit, currentOffset),
        orElse: (crudState) {
          return null;
        },
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        isLoading: state.isLoading,
        title: strings.channels,
        rows: [strings.title, strings.videoCounts, strings.image, strings.actions],
        items: items,
        addButtonLabel: strings.addNewChannel,
        onAddButtonClick: () => context.router.push(const AddChannelRoute()),
        onSearchChanged: _searchBoxChangeHandler,
        nextPage: nextOffset != null
            ? () {
          cubit.getAllChannels(Const.defaultRequestLimit, nextOffset!);
          setState(() {
            currentOffset = nextOffset!;
          });
        }
            : null,
        previousPage: previousOffset != null
            ? () {
          cubit.getAllChannels(Const.defaultRequestLimit, previousOffset!);
          setState(() {
            currentOffset = previousOffset!;
          });
        }
            : null,
        pageCount: pageCount.toString(),
      ),
    );
  }

  List<Widget> _generateItems(BuildContext context, List<Channel> channels) {
    final generatedItems = <Widget>[];

    for (final channel in channels) {
      final fields = <Widget>[];
      fields.add(CustomText(
        text: channel.title,
      ));
      fields.add(CustomText(
        text: channel.videosCount.toString(),
      ));
      fields.add(CustomNetworkImage(url: channel.image));
      fields.add(Row(
        children: [
          CustomIconButton(
            onClick: () => context.router.push(UpdateChannelRoute(id: channel.id.toString())),
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
                    cubit.deleteChannels([channel.id]);
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
      cubit.getAllChannels(Const.defaultRequestLimit, currentOffset, search: query);
    } else {
      cubit.getAllChannels(Const.defaultRequestLimit, currentOffset);
    }
  }
}
