import 'package:flutter/material.dart';
import 'package:flutter_panel/src/widget/crud/custom_crud_filter_dialog.dart';

class CustomCrudTableFilter extends StatefulWidget {
  final Function(String choice) callback;
  final List<Map<String, dynamic>> options;
  final String? dialogTitle;
  final IconData icon;

  const CustomCrudTableFilter(
      {super.key,
      required this.callback,
      required this.options,
      this.dialogTitle,
      this.icon = Icons.filter_list_rounded});

  @override
  State<CustomCrudTableFilter> createState() => _CustomCrudTableFilterState();
}

class _CustomCrudTableFilterState extends State<CustomCrudTableFilter> {
  late Map<String, dynamic> option;

  @override
  void initState() {
    option = widget.options.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                option['display'],
                style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          CustomCrudFilterDialog(options: widget.options, onItemClick: _onItemClick, title: widget.dialogTitle),
    );
  }

  void _onItemClick(Map<String, dynamic> option) {
    widget.callback.call(option['value'] ?? '');
    setState(() {
      this.option = option;
    });
  }
}
