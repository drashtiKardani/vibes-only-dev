import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String? label;
}

class MultiSelectorDialog extends StatefulWidget {
  final List<Map<String, dynamic>>? items;
  final List<Map<String, dynamic>>? initialSelectedValues;
  final Widget? title;
  final String? okButtonLabel;
  final String? cancelButtonLabel;
  final TextStyle labelStyle;
  final Color? checkBoxCheckColor;
  final Color? checkBoxActiveColor;
  final bool isMultipleSelection;

  const MultiSelectorDialog(
      {super.key,
      this.items,
      this.initialSelectedValues,
      this.title,
      this.okButtonLabel,
      this.cancelButtonLabel,
      this.labelStyle = const TextStyle(),
      this.checkBoxActiveColor,
      this.checkBoxCheckColor,
      this.isMultipleSelection = true});

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectorDialog> {
  final _selectedValues = <Map<String, dynamic>>[];

  @override
  void initState() {
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues!);
    }
    super.initState();
  }

  void _onItemCheckedChange(Map<String, dynamic> itemValue, bool? checked) {
    setState(() {
      if (widget.isMultipleSelection) {
        if (checked!) {
          _selectedValues.add(itemValue);
        } else {
          _selectedValues.remove(itemValue);
        }
      } else {
        _selectedValues.clear();
        _selectedValues.add(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 60 * (widget.items!.length + 1),
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            widget.title ?? const SizedBox(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items!.length,
                itemBuilder: (context, index) => _buildItem(widget.items![index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _onCancelTap,
                  child: Text(widget.cancelButtonLabel!),
                ),
                TextButton(
                  onPressed: _onSubmitTap,
                  child: Text(widget.okButtonLabel!),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final checked = _selectedValues.contains(item);
    return CheckboxListTile(
      value: checked,
      checkColor: widget.checkBoxCheckColor,
      activeColor: widget.checkBoxActiveColor,
      title: Text(
        item['display'],
        style: widget.labelStyle,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item, checked),
    );
  }
}
