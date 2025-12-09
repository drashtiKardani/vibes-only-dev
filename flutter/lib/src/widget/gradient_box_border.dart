import 'package:flutter/widgets.dart';

/// A custom [BoxBorder] that draws a gradient border around a widget.
///
/// Supports both rectangular (with optional border radius) and circular shapes.
class GradientBoxBorder extends BoxBorder {
  /// Creates a [GradientBoxBorder] with the given [gradient] and optional [width].
  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  /// The gradient used to draw the border.
  final Gradient gradient;

  /// The width of the border.
  final double width;

  // These properties are overridden to indicate that the border has no individual sides.
  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  /// Returns the space the border occupies.
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  /// Whether the border is uniform (same on all sides).
  @override
  bool get isUniform => true;

  /// Paints the border on the provided [canvas] within the specified [rect].
  ///
  /// The border can be either a rectangle (optionally with [borderRadius]) or a circle.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    switch (shape) {
      case BoxShape.circle:
        // Circle shape should not have borderRadius.
        assert(
          borderRadius == null,
          'A borderRadius can only be given for rectangular boxes.',
        );
        _paintCircle(canvas, rect);
        break;

      case BoxShape.rectangle:
        // Paint rounded rectangle if borderRadius is provided.
        if (borderRadius != null) {
          _paintRRect(canvas, rect, borderRadius);
          return;
        }
        // Otherwise, paint a simple rectangle.
        _paintRect(canvas, rect);
        break;
    }
  }

  /// Paints a rectangle with gradient border.
  void _paintRect(Canvas canvas, Rect rect) {
    // Deflate the rect so that the border is drawn inside the original area.
    canvas.drawRect(rect.deflate(width / 2), _getPaint(rect));
  }

  /// Paints a rounded rectangle (RRect) with gradient border.
  void _paintRRect(Canvas canvas, Rect rect, BorderRadius borderRadius) {
    final rrect = borderRadius.toRRect(rect).deflate(width / 2);
    canvas.drawRRect(rrect, _getPaint(rect));
  }

  /// Paints a circular border with gradient.
  void _paintCircle(Canvas canvas, Rect rect) {
    final paint = _getPaint(rect);
    final radius = (rect.shortestSide - width) / 2.0;
    canvas.drawCircle(rect.center, radius, paint);
  }

  /// Returns a scaled version of this border.
  ///
  /// Since scaling doesn’t affect this implementation, return the same instance.
  @override
  ShapeBorder scale(double t) {
    return this;
  }

  /// Creates a [Paint] object configured with the gradient shader and stroke style.
  Paint _getPaint(Rect rect) {
    return Paint()
      ..strokeWidth = width
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke;
  }
}

class GradientTween extends Tween<LinearGradient> {
  GradientTween({required LinearGradient begin, required LinearGradient end})
      : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) {
    return LinearGradient(
      begin: begin!.begin,
      end: begin!.end,
      stops: _lerpStops(begin!.stops, end!.stops, t),
      colors: List.generate(begin!.colors.length, (i) {
        return Color.lerp(begin!.colors[i], end!.colors[i], t)!;
      }),
    );
  }

  List<double>? _lerpStops(List<double>? a, List<double>? b, double t) {
    if (a == null || b == null || a.length != b.length) return null;
    return List.generate(a.length, (i) => lerpDouble(a[i], b[i], t)!);
  }

  double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
