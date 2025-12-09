import 'package:flutter/material.dart';
import 'package:flutter_panel/src/widget/multi_selector_dialog.dart';
import 'package:flutter_panel/generated/l10n.dart';

class MultiSelectorWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>>? data;
  final List<Map<String, dynamic>> selected;
  final Function(List<Map<String, dynamic>> selected) onChange;
  final bool error;
  final String? errorMessage;
  final bool isLoading;
  final bool isMultipleSelection;

  const MultiSelectorWidget(
      {super.key,
      required this.title,
      required this.data,
      required this.selected,
      required this.onChange,
      this.error = false,
      this.errorMessage,
      this.isLoading = false,
      this.isMultipleSelection = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openItemsDialog(context),
      child: Container(
        width: double.maxFinite,
        color: Theme.of(context).inputDecorationTheme.fillColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: isLoading
            ? const Wrap(
                alignment: WrapAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color:
                          Theme.of(context).appBarTheme.titleTextStyle!.color,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (selected.isNotEmpty)
                    Wrap(
                      children: [
                        for (final item in selected) ...[
                          Chip(
                            label: Text(
                              item['display'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          )
                        ]
                      ],
                    )
                  else
                    Chip(
                      backgroundColor: Theme.of(context).primaryColor,
                      label: Text(
                        S.of(context).select,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (error) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      errorMessage ?? S.of(context).fieldRequired,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
      ),
    );
  }

  Future _openItemsDialog(BuildContext context) async {
    final selectedValues = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectorDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          okButtonLabel: 'Ok',
          cancelButtonLabel: 'Cancel',
          items: data,
          initialSelectedValues: selected,
          isMultipleSelection: isMultipleSelection,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );

    if (selectedValues != null) {
      onChange.call(selectedValues as List<Map<String, dynamic>>);
    }
  }
}
