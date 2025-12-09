import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/config/const.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/enum/category_ordering.dart';
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
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final CrudCubit cubit;
  late String order;

  List<Widget>? items;
  int? previousOffset, nextOffset;
  int currentOffset = 0, pageCount = 1;

  @override
  void initState() {
    order = CategoryOrdering.titleASC.value;
    cubit = CrudCubit(api: inject(), uploadApi: inject())
      ..getAllCategories(Const.defaultRequestLimit, currentOffset, ordering: order);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (context, state) => state.maybeWhen(
        getAllCategories: (categories) {
          setState(() {
            items = _generateItems(context, categories.results);

            if (categories.next != null) {
              final url = Uri.parse(categories.next!);

              if (url.queryParameters.containsKey('offset')) {
                nextOffset = int.parse(url.queryParameters['offset']!);
              } else {
                nextOffset = 0;
              }
            } else {
              nextOffset = null;
            }

            if (categories.previous != null) {
              final url = Uri.parse(categories.previous!);

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
        itemsDeleted: () => cubit.getAllCategories(Const.defaultRequestLimit, currentOffset, ordering: order),
        orElse: (crudState) {
          return null;
        },
      ),
      builder: (context, state) => CustomPaginatedCrudTable(
        isLoading: state.isLoading,
        title: strings.categories,
        rows: [strings.title, strings.image, strings.status, strings.stories, strings.actions],
        items: items,
        addButtonLabel: strings.addNewCategory,
        onAddButtonClick: () => context.router.push(const AddCategoryRoute()),
        onSearchChanged: _searchBoxChangeHandler,
        onSortClickHandler: _onFilterChangeHandler,
        filterOptions: List.from(CategoryOrdering.values.map((e) => {"display": e.name, "value": e.value})),
        nextPage: nextOffset != null
            ? () {
                cubit.getAllCategories(Const.defaultRequestLimit, nextOffset!, ordering: order);
                setState(() {
                  currentOffset = nextOffset!;
                });
              }
            : null,
        previousPage: previousOffset != null
            ? () {
                cubit.getAllCategories(Const.defaultRequestLimit, previousOffset!, ordering: order);
                setState(() {
                  currentOffset = previousOffset!;
                });
              }
            : null,
        pageCount: pageCount.toString(),
      ),
    );
  }

  List<Widget> _generateItems(BuildContext context, List<Category> categories) {
    final generatedItems = <Widget>[];

    for (final category in categories) {
      final fields = <Widget>[];
      fields.add(CustomText(
        text: category.title,
      ));
      fields.add(CustomNetworkImage(url: category.image));

      fields.add(_categoriesStatus(category.status));

      // fields.add(Row(
      //   children: [
      //     Row(
      //       children: [
      //         const Text('S'),
      //         const SizedBox(
      //           width: 4,
      //         ),
      //         Icon(category.status == 'simulator' ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
      //       ],
      //     ),
      //     const SizedBox(
      //       width: 16,
      //     ),
      //     Row(
      //       children: [
      //         const Text('P'),
      //         const SizedBox(
      //           width: 4,
      //         ),
      //         Icon(category.status == 'published' ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
      //       ],
      //     ),
      //   ],
      // ));
      fields.add(CustomText(
        text: category.storiesCount != null ? category.storiesCount.toString() : '0',
      ));

      fields.add(Row(
        children: [
          CustomIconButton(
            onClick: () => context.router.push(UpdateCategoryRoute(id: category.id.toString())),
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
                    cubit.deleteCategories([category.id]);
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

  Widget _categoriesStatus(String? status) {
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
      cubit.getAllCategories(Const.defaultRequestLimit, currentOffset, search: query);
    } else {
      cubit.getAllCategories(Const.defaultRequestLimit, currentOffset, ordering: order);
    }
  }

  void _onFilterChangeHandler(String optionValue) {
    setState(() {
      order = optionValue;
      currentOffset = 0;
    });
    cubit.getAllCategories(Const.unlimitedRequestLimit, currentOffset, ordering: order);
  }
}
