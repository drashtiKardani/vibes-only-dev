import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Color? iconColor;
  final IconData icon;
  final VoidCallback? onClick;
  final double? iconSize;

  const CustomIconButton({super.key, this.iconColor, required this.icon, required this.onClick, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
