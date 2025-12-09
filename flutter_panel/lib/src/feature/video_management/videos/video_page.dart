import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/enum/story_ordering.dart';
import 'package:flutter_panel/src/enum/view_count_mode.dart';
import 'package:flutter_panel/src/extension/date_extension.dart';
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
class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late final CrudCubit cubit;
  late String order;
  ViewCountMode _currentViewCountMode = ViewCountMode.values.first;

  int? previousOffset, nextOffset;
  int currentOffset = 0, pageCount = 1;

  @override
  void initState() {
    order = StoryOrdering.publishDateDESC.value;
    cubit = CrudCubit(api: inject(), uploadApi: inject())
      ..getAllVideos(Const.defaultRequestLimit, currentOffset, ordering: order);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllVideos: (allVideo) {
          setState(() {
            if (allVideo.next != null) {
              final url = Uri.parse(allVideo.next!);

              if (url.queryParameters.containsKey('offset')) {
                nextOffset = int.parse(url.queryParameters['offset']!);
              } else {
                nextOffset = 0;
              }
            } else {
              nextOffset = null;
            }

            if (allVideo.previous != null) {
              final url = Uri.parse(allVideo.previous!);

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
        itemsDeleted: () => cubit.getAllVideos(Const.defaultRequestLimit, currentOffset, ordering: order),
        orElse: (crudState) {
          return null;
        },
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        isLoading: state.isLoading,
        title: strings.videos,
        rows: [
          strings.title,
          strings.addDate,
          // strings.publishDate,
          strings.thumbnail,
          strings.status,
          strings.qStSh,
          // strings.transcript,
          _currentViewCountMode.displayName,
          strings.actions
        ],
        items: _generateItems(context, state.isGetAllVideos ? state.asGetAllVideos.allVideo.results : []),
        addButtonLabel: strings.addNewVideo,
        onAddButtonClick: () => context.router.push(const AddVideoRoute()),
        onSearchChanged: _searchBoxChangeHandler,
        filterOptions: List.from(StoryOrdering.values.map((e) => {"display": e.name, "value": e.value})),
        onSortClickHandler: _onFilterChangeHandler,
        onViewCountClickHandler: _onViewCountModeChange,
        nextPage: nextOffset != null
            ? () {
                cubit.getAllVideos(Const.defaultRequestLimit, nextOffset!, ordering: order);
                setState(() {
                  currentOffset = nextOffset!;
                });
              }
            : null,
        previousPage: previousOffset != null
            ? () {
                cubit.getAllVideos(Const.defaultRequestLimit, previousOffset!, ordering: order);
                setState(() {
                  currentOffset = previousOffset!;
                });
              }
            : null,
        pageCount: pageCount.toString(),
      ),
    );
  }

  List<Widget> _generateItems(BuildContext context, List<Video> videos) {
    final generatedItems = <Widget>[];

    for (final video in videos) {
      final fields = <Widget>[];
      fields.add(CustomText(
        text: video.title,
      ));
      fields.add(CustomText(
        text: video.dateCreated != null
            ? '${video.dateCreated!.day}/${video.dateCreated!.firstThreeLetterOfMonthName}/${video.dateCreated!.year}'
            : strings.notApproved,
      ));

      fields.add(CustomNetworkImage(url: video.thumbnail));

      fields.add(_videoStatus(video.status));
      fields.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            video.videoQualityStatus == 'Processing'
                ? 'assets/icons/loading.png'
                : video.videoQualityStatus == 'Finished'
                    ? 'assets/icons/check.png'
                    : 'assets/icons/close.png',
            height: 20,
            width: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('-'),
          ),
          Image.asset(
            video.videoShortVersionStatus == 'Processing'
                ? 'assets/icons/loading.png'
                : video.videoShortVersionStatus == 'Finished'
                    ? 'assets/icons/check.png'
                    : 'assets/icons/close.png',
            height: 20,
            width: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text('-'),
          ),
          Image.asset(
            video.transcriptStatus == 'Processing'
                ? 'assets/icons/loading.png'
                : video.transcriptStatus == 'Finished'
                    ? 'assets/icons/check.png'
                    : 'assets/icons/close.png',
            height: 20,
            width: 20,
          ),
        ],
      ));
      fields.add(Text('${_currentViewCountMode.viewCountOfVideo(video)}'));
      fields.add(Row(
        children: [
          CustomIconButton(
            onClick: () => context.router.push(UpdateVideoRoute(id: video.id.toString())),
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
                    cubit.deleteVideos([video.id]);
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

  Widget _videoStatus(String? status) {
    var text = strings.simulator;

    if (status != null) {
      switch (status) {
        case 'approved':
          text = strings.simulator;
          break;
        case 'published':
          text = strings.production;
          break;
      }
    }
    return CustomText(
      text: text,
      textAlign: TextAlign.start,
    );
  }

  void _searchBoxChangeHandler(String query) {
    setState(() {
      currentOffset = 0;
    });
    if (query.isNotEmpty) {
      cubit.getAllVideos(Const.defaultRequestLimit, currentOffset, search: query);
    } else {
      cubit.getAllVideos(Const.defaultRequestLimit, currentOffset, ordering: order);
    }
  }

  void _onFilterChangeHandler(String optionValue) {
    if (optionValue == viewCountOrderingDESC || optionValue == viewCountOrderingASC) {
      optionValue += _currentViewCountMode.name;
    }
    setState(() {
      order = optionValue;
      currentOffset = 0;
    });
    cubit.getAllVideos(Const.defaultRequestLimit, currentOffset, ordering: order);
  }

  void _onViewCountModeChange(String viewCountModeName) {
    setState(
          () {
        _currentViewCountMode = ViewCountMode.values.firstWhere((element) => element.name == viewCountModeName);
      },
    );
    if (order.startsWith(viewCountOrderingDESC) || order.startsWith(viewCountOrderingASC)) {
      cubit.getAllVideos(Const.defaultRequestLimit, currentOffset, ordering: order);
    }
  }
}
