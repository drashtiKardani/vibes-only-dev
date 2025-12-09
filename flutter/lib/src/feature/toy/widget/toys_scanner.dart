import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class ToysScanner extends StatefulWidget {
  final double size;
  final Widget centerWidget;
  final List<ToyResult> toyResults;

  const ToysScanner({
    super.key,
    required this.size,
    required this.centerWidget,
    required this.toyResults,
  });

  @override
  ToysScannerState createState() => ToysScannerState();
}

class ToysScannerState extends State<ToysScanner>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final Duration _animationDuration = Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _animationController =
        AnimationController(duration: _animationDuration, vsync: this);

    // Create multiple controllers for staggered effect
    _controllers = List.generate(3, (index) {
      return AnimationController(duration: _animationDuration, vsync: this);
    });

    // Create animations with different delays
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Start animations with staggered delays
    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 800), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated circles
          ...List.generate(_animations.length, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  width: 60 + (200 * _animations[index].value),
                  height: 60 + (200 * _animations[index].value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: (1 - _animations[index].value) * 0.4,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Random device icons
          ClipRect(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                children: widget.toyResults.map((toy) {
                  double bountry = widget.size;

                  // Calculate position ensuring it stays within bounds and away from center
                  double iconX =
                      (bountry / 2) + toy.distance * math.cos(toy.angle);
                  double iconY =
                      (bountry / 2) + toy.distance * math.sin(toy.angle);

                  // Ensure icon container stays fully within bounds (icon + padding)
                  double iconContainerSize = toy.size + 20;
                  double minPos = iconContainerSize / 2;
                  double maxPos = bountry - (iconContainerSize / 2);

                  // Ensure icon stays within container bounds (with padding)
                  iconX = math.max(minPos, math.min(maxPos, iconX));
                  iconY = math.max(minPos, math.min(maxPos, iconY));

                  return Positioned(
                    left: iconX - (toy.size + 20) / 2,
                    top: iconY - (toy.size + 20) / 2,
                    child: SizedBox(
                      width: toy.size + 20,
                      height: toy.size + 20,
                      child: toy.icon,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          widget.centerWidget
        ],
      ),
    );
  }
}

class ToyResult {
  final ScanResult scanResult;
  final Widget? icon;
  final double angle;
  final double distance;
  final double size;

  const ToyResult({
    required this.scanResult,
    required this.icon,
    required this.angle,
    required this.distance,
    required this.size,
  });
}
