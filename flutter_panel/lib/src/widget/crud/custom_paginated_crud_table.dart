import 'package:flutter/material.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/enum/view_count_mode.dart';
import 'package:flutter_panel/src/widget/crud/colors.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_table_filter.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_table_row_titles_widget.dart';
import 'package:flutter_panel/src/widget/crud/custom_search_box.dart';
import 'package:flutter_panel/src/widget/custom_icon_button.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';

class CustomPaginatedCrudTable extends StatelessWidget {
  final String title;
  final List<Widget>? items;
  final List<String> rows;
  final Function(String query)? onSearchChanged;
  final VoidCallback? onAddButtonClick;
  final String? addButtonLabel;
  final bool isLoading;
  final Function(String filter)? onSortClickHandler;
  final Function(String modeName)? onViewCountClickHandler;
  final List<Map<String, dynamic>>? filterOptions;
  final VoidCallback? nextPage;
  final VoidCallback? previousPage;
  final String pageCount;

  const CustomPaginatedCrudTable(
      {super.key,
      required this.title,
      required this.rows,
      this.items,
      this.onSearchChanged,
      this.onAddButtonClick,
      this.addButtonLabel,
      this.isLoading = false,
      this.onSortClickHandler,
      this.onViewCountClickHandler,
      this.filterOptions,
      this.nextPage,
      this.previousPage,
      this.pageCount = '1'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      margin: const EdgeInsets.all(16.0),
      color: cardBackgroundColor(context),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CustomSearchBox(
                  onChanged: onSearchChanged,
                ),
                const Spacer(),
                if (onAddButtonClick != null)
                  ElevatedButton(
                      onPressed: onAddButtonClick,
                      child: Text(addButtonLabel ?? strings.add)),
              ],
            ),
          ),
          _paginationButtons(context, pageCount, nextPage, previousPage),
          Expanded(
            child: Container(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .appBarTheme
                              .titleTextStyle!
                              .copyWith(fontSize: 24),
                        ),
                        const Spacer(),
                        if (onViewCountClickHandler != null)
                          CustomCrudTableFilter(
                            dialogTitle: 'View count mode',
                            icon: Icons.remove_red_eye,
                            callback: onViewCountClickHandler!,
                            options: viewCountModesAsOptions,
                          ),
                        if (onSortClickHandler != null && filterOptions != null)
                          CustomCrudTableFilter(
                            callback: onSortClickHandler!,
                            options: filterOptions!,
                          )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  CustomCrudTableRowTitlesWidget(rows: rows),
                  const SizedBox(
                    height: 16,
                  ),
                  const Divider(
                    height: 0,
                  ),
                  Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : items == null
                              ? Center(
                                  child: Text(strings.nothingFound),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: items!.length,
                                  itemBuilder: (context, index) =>
                                      items![index],
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                ))
                ],
              ),
            ),
          ),
          _paginationButtons(context, pageCount, nextPage, previousPage),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _paginationButtons(BuildContext context, String pageCount,
      VoidCallback? nextPage, VoidCallback? previousPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onClick: previousPage,
            iconColor: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .color!
                .withValues(alpha: previousPage == null ? 0.3 : 1),
          ),
        ),
        CustomText(text: strings.page(pageCount)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomIconButton(
            icon: Icons.arrow_forward_ios_rounded,
            onClick: nextPage,
            iconColor: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .color!
                .withValues(alpha: nextPage == null ? 0.3 : 1),
          ),
        ),
      ],
    );
  }
}
