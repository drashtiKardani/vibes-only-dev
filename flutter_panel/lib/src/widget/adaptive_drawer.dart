import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sealed_annotations/sealed_annotations.dart';

typedef OnTitleItemClicked = void Function(DrawerTitle item, int index);

abstract class DrawerItem extends Equatable {}

class DrawerTitle extends DrawerItem {
  DrawerTitle({
    required this.title,
    required this.icon,
    required this.destinationTo,
  });

  final String title;
  final IconData icon;
  final PageRouteInfo destinationTo;

  @override
  List<Object?> get props => [title];
}

class DrawerExpansion extends DrawerItem {
  DrawerExpansion({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<DrawerTitle> children;

  @override
  List<Object?> get props => [title];
}

class AdaptiveDrawer extends StatefulWidget {
  const AdaptiveDrawer(
      {super.key,
      required this.body,
      required this.items,
      this.currentIndex = 0,
      this.header,
      this.onTitleItemClicked});

  final Widget body;
  final Widget? header;
  final List<DrawerItem> items;
  final OnTitleItemClicked? onTitleItemClicked;
  final int currentIndex;

  @override
  State createState() => _AdaptiveDrawerState();
}

class _AdaptiveDrawerState extends State<AdaptiveDrawer> {
  late List<DrawerTitle> _titleItems;

  @override
  void initState() {
    super.initState();
    _titleItems = [];
    for (DrawerItem item in widget.items) {
      if (item is DrawerTitle) {
        _titleItems.add(item);
      } else if (item is DrawerExpansion) {
        _titleItems.addAll(item.children);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Drawer(
          child: ListView(
            children: [
              if (widget.header != null) widget.header!,
              ...widget.items.map<Widget>((item) {
                if (item is DrawerTitle) {
                  return _createTile(context, item);
                } else if (item is DrawerExpansion) {
                  return _createExpansionTile(context, item);
                }
                return Container();
              }),
            ],
          ),
        ),
        Expanded(
            child: Scaffold(
          body: widget.body,
        )),
      ],
    );
  }

  Widget _createTile(BuildContext context, DrawerTitle item) {
    var defaultColor = _defaultColor(context);
    return ListTileTheme(
      style: ListTileStyle.drawer,
      iconColor: defaultColor,
      textColor: defaultColor,
      child: ListTile(
        leading: Icon(item.icon),
        title: Text(item.title),
        selected: _titleItems.indexOf(item) == widget.currentIndex,
        onTap: () => _onItemClicked(item),
      ),
    );
  }

  Widget _createExpansionTile(BuildContext context, DrawerExpansion item) {
    var defaultColor = _defaultColor(context);
    return ListTileTheme(
      style: ListTileStyle.drawer,
      iconColor: defaultColor,
      textColor: defaultColor,
      child: ExpansionTile(
        leading: Icon(item.icon),
        title: Text(item.title),
        iconColor: defaultColor,
        collapsedIconColor: defaultColor,
        textColor: defaultColor,
        collapsedTextColor: defaultColor,
        children: item.children.map((e) => _createTile(context, e)).toList(),
      ),
    );
  }

  Color _defaultColor(BuildContext context) {
    var theme = Theme.of(context);
    var color = Colors.black87;
    if (theme.brightness == Brightness.dark) {
      color = theme.disabledColor;
    }
    return color;
  }

  void _onItemClicked(DrawerTitle item) {
    var index = _titleItems.indexOf(item);
    if (index != widget.currentIndex) {
      widget.onTitleItemClicked?.call(item, index);
    }
  }
}
