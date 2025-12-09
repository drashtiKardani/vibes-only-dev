import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/theme/context_extension.dart';

/// A custom bottom navigation bar with a center FAB spacer and blur highlight effects.
class VibesBottomNav extends StatelessWidget {
  final List<VibesBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onItemChanged;

  const VibesBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Create navigation items from the given list
    List<Widget> children = List.generate(
      items.length,
      (index) => _buildNavItem(
        context: context,
        index: index,
        item: items[index],
      ),
    );

    // Add a center spacer for a floating action button (FAB)
    children.insert(items.length >> 1, const SizedBox.square(dimension: 40));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 2,
            color: context.colorScheme.primary.withAlpha(25),
          ),
        ),
      ),
      child: BottomAppBar(
        height: 70,
        padding: EdgeInsets.zero,
        color: context.colorScheme.surface,
        child: Row(children: children),
      ),
    );
  }

  /// Builds a single navigation item with an icon, label, and highlight effect.
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required VibesBottomNavItem item,
  }) {
    final bool selected = index == currentIndex;

    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onItemChanged(index),
        child: Stack(
          children: [
            // Background blur glow when selected
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: AnimatedContainer(
                  duration: Durations.medium1,
                  height: selected ? 50 : 0,
                  width: selected ? 50 : 0,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        context.colorScheme.primary,
                        Colors.transparent,
                      ],
                      radius: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Icon and label section
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon transitions on selection
                  AnimatedSwitcher(
                    duration: Durations.medium1,
                    child: Icon(
                      key: ValueKey(index),
                      selected ? item.activeIcon : item.icon,
                      size: item.iconSize ?? 24,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Text label with animated style change
                  AnimatedDefaultTextStyle(
                    duration: Durations.medium3,
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: context.colorScheme.onSurface,
                    ),
                    child: Text(item.title),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for bottom navigation items.
class VibesBottomNavItem {
  final String title; // Label for the item
  final IconData icon; // Default icon
  final IconData activeIcon; // Icon when selected
  final double? iconSize; // Optional custom icon size

  const VibesBottomNavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    this.iconSize,
  });
}
