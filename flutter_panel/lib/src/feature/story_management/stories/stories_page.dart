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
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_common/vibes.dart';

import '../../../route/router.gr.dart';

@RoutePage()
class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  late final CrudCubit cubit;
  late String order;
  ViewCountMode _currentViewCountMode = ViewCountMode.values.first;

  int? previousOffset, nextOffset;
  int currentOffset = 0, pageCount = 1;

  @override
  void initState() {
    order = StoryOrdering.publishDateDESC.value;
    cubit = CrudCubit(api: inject(), uploadApi: inject())
      ..getAllStories(Const.defaultRequestLimit, currentOffset, ordering: order);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllStories: (stories) {
          setState(() {
            if (stories.next != null) {
              final url = Uri.parse(stories.next!);

              if (url.queryParameters.containsKey('offset')) {
                nextOffset = int.parse(url.queryParameters['offset']!);
              } else {
                nextOffset = 0;
              }
            } else {
              nextOffset = null;
            }

            if (stories.previous != null) {
              final url = Uri.parse(stories.previous!);

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
        itemsDeleted: () => cubit.getAllStories(Const.defaultRequestLimit, currentOffset, ordering: order),
        orElse: (crudState) {
          return null;
        },
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        isLoading: state.isLoading,
        title: strings.stories,
        rows: [
          strings.title,
          strings.addDate,
          strings.audio,
          strings.vibes,
          strings.status,
          _currentViewCountMode.displayName,
          strings.actions
        ],
        items: _generateItems(context, state.isGetAllStories ? state.asGetAllStories.allStories.results : []),
        addButtonLabel: strings.addNewStory,
        onAddButtonClick: () => context.router.push(const AddStoryRoute()),
        onSearchChanged: _searchBoxChangeHandler,
        onSortClickHandler: _onFilterChangeHandler,
        filterOptions: List.from(StoryOrdering.values.map((e) => {"display": e.name, "value": e.value})),
        onViewCountClickHandler: _onViewCountModeChange,
        nextPage: nextOffset != null
            ? () {
                cubit.getAllStories(Const.defaultRequestLimit, nextOffset!, ordering: order);
                setState(() {
                  currentOffset = nextOffset!;
                });
              }
            : null,
        previousPage: previousOffset != null
            ? () {
                cubit.getAllStories(Const.defaultRequestLimit, previousOffset!, ordering: order);
                setState(() {
                  currentOffset = previousOffset!;
                });
              }
            : null,
        pageCount: pageCount.toString(),
      ),
    );
  }

  List<Widget> _generateItems(BuildContext context, List<Story> stories) {
    final generatedItems = <Widget>[];

    for (final story in stories) {
      final fields = <Widget>[];
      fields.add(CustomText(
        text: story.title,
      ));

      fields.add(CustomText(
        text: story.dateCreated != null
            ? '${story.dateCreated!.day}/${story.dateCreated!.firstThreeLetterOfMonthName}/${story.dateCreated!.year}'
            : strings.notApproved,
      ));

      fields.add(Row(
        children: [
          if (story.audio != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async => launchUrl(Uri.parse(story.audio!)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.download),
                  )),
            ),
          const SizedBox(
            width: 4,
          ),
          if (story.audio != null)
            Image.asset(
              'assets/icons/check.png',
              height: 20,
              width: 20,
            )
          else
            TextButton(
              onPressed: () => context.router.push(UpdateStoryRoute(id: story.id.toString())),
              child: Text(strings.add),
            ),
        ],
      ));

      fields.add(Row(
        children: story.beat != null
            ? [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => launchUrl(Uri.parse("https://studio.vibesonly.com/?uid=${story.uid}")),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icons/check.png',
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => CustomAlertDialog(
                          title: 'Attention',
                          message: strings.areYouSure,
                          onPositiveButtonClick: () {
                            cubit.deleteStoryVibes(story.id);
                            AutoRouter.of(context).maybePop();
                          }),
                    ),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/icons/close.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => launchUrl(Uri.parse("https://studio.vibesonly.com/?uid=${story.uid}")),
                  child: Text(strings.add),
                )
              ],
      ));
      fields.add(_storiesStatus(story.status));
      fields.add(Text('${_currentViewCountMode.viewCountOf(story)}'));
      fields.add(Row(
        children: [
          CustomIconButton(
            onClick: () => context.router.push(UpdateStoryRoute(id: story.id.toString())),
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
                    cubit.deleteStories([story.id]);
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

  Widget _storiesStatus(String? status) {
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
      cubit.getAllStories(Const.defaultRequestLimit, currentOffset, search: query);
    } else {
      cubit.getAllStories(Const.defaultRequestLimit, currentOffset, ordering: order);
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
    cubit.getAllStories(Const.unlimitedRequestLimit, currentOffset, ordering: optionValue);
  }

  void _onViewCountModeChange(String viewCountModeName) {
    setState(
      () {
        _currentViewCountMode = ViewCountMode.values.firstWhere((element) => element.name == viewCountModeName);
      },
    );
    if (order.startsWith(viewCountOrderingDESC) || order.startsWith(viewCountOrderingASC)) {
      cubit.getAllStories(Const.unlimitedRequestLimit, currentOffset, ordering: order);
    }
  }
}
