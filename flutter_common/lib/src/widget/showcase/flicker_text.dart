import 'package:flutter/material.dart';

class FlickerText extends StatefulWidget {
  final Color? color;
  final String text;
  final bool shouldFlicker;
  final double fontSize;
  final FontWeight? fontWeight;
  final List<double> blurRadius;
  final List<double> spreadRadius;
  final double strokeWidth;
  final double letterSpacing;
  final TextAlign textAlign;

  const FlickerText({
    super.key,
    required this.text,
    this.color,
    this.shouldFlicker = false,
    this.fontSize = 18.0,
    this.fontWeight,
    this.strokeWidth = 1.5,
    this.letterSpacing = 1,
    this.blurRadius = const [1.0, 2.0, 2.0, 10.0],
    this.spreadRadius = const [1.0, 2.0, 2.0, 10],
    this.textAlign = TextAlign.center,
  });

  @override
  FlickerTextState createState() => FlickerTextState();
}

class FlickerTextState extends State<FlickerText>
    with TickerProviderStateMixin {
  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fadeInFadeOut = Tween<double>(begin: 1.0, end: 0.1).animate(animation);

    animation.addStatusListener((status) {
      if (disposed) return;
      if (status == AnimationStatus.completed) {
        animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (disposed) return;
          animation.forward();
        });
      }
    });
    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle strokeStyle = TextStyle(
      letterSpacing: widget.letterSpacing,
      fontSize: widget.fontSize,
      fontWeight: widget.fontWeight,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = widget.strokeWidth
        ..color = widget.color ?? Theme.of(context).primaryColor,
    );
    TextStyle glowStyle = TextStyle(
      letterSpacing: widget.letterSpacing,
      fontSize: widget.fontSize,
      fontWeight: widget.fontWeight,
      shadows: [
        BoxShadow(
          color: widget.color ?? Theme.of(context).primaryColor,
          blurRadius: widget.blurRadius[0],
          spreadRadius: widget.spreadRadius[0],
        ),
        BoxShadow(
          color: widget.color ?? Theme.of(context).primaryColor,
          blurRadius: widget.blurRadius[1],
          spreadRadius: widget.spreadRadius[1],
        ),
        BoxShadow(
          color: widget.color ?? Theme.of(context).primaryColor,
          blurRadius: widget.blurRadius[2],
          spreadRadius: widget.spreadRadius[2],
        ),
        BoxShadow(
          color: widget.color ?? Theme.of(context).primaryColor,
          blurRadius: widget.blurRadius[3],
          spreadRadius: widget.spreadRadius[3],
        ),
      ],
      color: Colors.white,
    );
    return widget.shouldFlicker
        ? FadeTransition(
            opacity: _fadeInFadeOut,
            child: Stack(
              children: [
                Text(widget.text,
                    textAlign: widget.textAlign, style: strokeStyle),
                Text(widget.text,
                    textAlign: widget.textAlign, style: glowStyle),
              ],
            ),
          )
        : Stack(
            children: [
              Text(widget.text,
                  textAlign: widget.textAlign, style: strokeStyle),
              Text(widget.text, textAlign: widget.textAlign, style: glowStyle),
            ],
          );
  }
}
