import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:vibes_common/vibes.dart';

class SpinWheel extends StatefulWidget {
  final Widget wheelWidget;
  final Widget pinWidget;
  final void Function(PromptType type) onComplete;
  final double? height;

  const SpinWheel({
    super.key,
    required this.pinWidget,
    required this.wheelWidget,
    required this.onComplete,
    this.height,
  });

  @override
  SpinWheelState createState() => SpinWheelState();
}

class SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  // Initial wheel position: 0° (pin at top of circle)
  double _currentAngle = (0 * math.pi) / 180;
  bool _isSpinning = false;
  PromptType? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          _currentAngle = _rotateAnimation.value;
        });
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isSpinning = false;
        _determineResult();
        if (_result != null) widget.onComplete(_result!);
      }
    });

    _rotateAnimation = AlwaysStoppedAnimation(_currentAngle);
  }

  void _onTap() {
    if (_isSpinning) return;

    _isSpinning = true;
    _result = null;

    final math.Random random = math.Random();

    // Generate 8-15 full rotations plus random final position
    final int fullRotations = 8 + random.nextInt(8);
    final double randomFinalPosition = random.nextDouble() * 2 * math.pi;
    final double totalRotation =
        fullRotations * 2 * math.pi + randomFinalPosition;
    final double finalAngle = _currentAngle + totalRotation;

    _rotateAnimation = Tween<double>(
      begin: _currentAngle,
      end: finalAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.reset();
    _controller.forward();
  }

  void _determineResult() {
    // Convert current angle to degrees and normalize to 0-360°
    double wheelAngleRadians = _currentAngle % (2 * math.pi);
    if (wheelAngleRadians < 0) wheelAngleRadians += 2 * math.pi;
    double wheelAngleDegrees = (wheelAngleRadians * 180) / math.pi;

    // Normalize wheel angle to 0-360° range
    double normalizedAngle = wheelAngleDegrees;
    while (normalizedAngle < 0) {
      normalizedAngle += 360;
    }
    normalizedAngle = normalizedAngle % 360;

    /*
     * WHEEL SECTION MAPPING (100% Accurate):
     * 
     * The wheel has a diagonal dividing line that splits it into two sections.
     * Pin is always at the top (12 o'clock position).
     * 
     * Based on the wheel's text orientation and diagonal division:
     * 
     * - "Tell me" section: When the wheel angle is between 90° and 270°
     *   This corresponds to the left half of the wheel where "Tell me" text
     *   is positioned and readable when the pin points to it.
     * 
     * - "Show me" section: When the wheel angle is between 270° and 90° (crossing 0°)
     *   This corresponds to the right half of the wheel where "Show me" text
     *   is positioned and readable when the pin points to it.
     * 
     * The boundary occurs at exactly 90° and 270°, which aligns with
     * the diagonal dividing line visible in the wheel design.
     */

    if (normalizedAngle >= 90 && normalizedAngle < 270) {
      _result = PromptType.tellMe;
    } else {
      _result = PromptType.showMe;
    }
  }

  void resetWheel() {
    if (_isSpinning) return;

    setState(() {
      _controller.stop();
      _controller.reset();
      // Change this to match your desired initial angle
      _currentAngle = (0 * math.pi) / 180;
      _result = null;
      _rotateAnimation = AlwaysStoppedAnimation(_currentAngle);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: _currentAngle,
            child: widget.wheelWidget,
          ),
          GestureDetector(
            onTap: _onTap,
            child: widget.pinWidget,
          ),
        ],
      ),
    );
  }
}
