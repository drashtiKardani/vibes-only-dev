part of 'freestyle_mode_ui.dart';

class _Pad extends StatefulWidget {
  const _Pad({required this.onNewPadValue});

  /// [value] will be in range of +1 (finger is at the top) to -1 (finger at the bottom).
  /// 0 means user is not touching the pad (center position).
  final void Function(double value) onNewPadValue;

  @override
  State<_Pad> createState() => _PadState();
}

class _PadState extends State<_Pad> {
  Offset? _fingerPos;
  double? height;

  static const k = 2;

  Offset? get fingerPos => _fingerPos;

  set fingerPos(Offset? pos) {
    _fingerPos = pos;
    widget.onNewPadValue(pos == null || height == null
        ? 0
        : k * (height! / 2 - pos.dy) / (height! / 2));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        height = constraints.maxHeight;

        return Listener(
          onPointerDown: (event) {
            setState(() => fingerPos = event.localPosition);
          },
          onPointerUp: (event) => setState(() => fingerPos = null),
          onPointerMove: (event) {
            setState(() => fingerPos = event.localPosition);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: CustomPaint(
                  painter: _PadMesh(),
                  child: Container(),
                ),
              ),
              Positioned(
                left: fingerPos?.dx.minus(_PadButton.width / 2),
                top: fingerPos?.dy.minus(_PadButton.height / 2),
                child: const _PadButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on double {
  double minus(double other) => this - other;
}

class _PadButton extends StatelessWidget {
  const _PadButton();

  static const double width = 80.0;
  static const double height = 80.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
        color: context.colorScheme.onSurface.withValues(alpha: 0.2),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _PadMesh extends CustomPainter {
  final _paint = Paint()
    ..color = Colors.white.withValues(alpha: 0.15)
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final numDotsInRows = (size.width / 16).floor() + 1;
    final numDotsInCols = (size.height / 16).floor() + 1;
    final points = <Offset>[];
    for (var x in List.generate(
        numDotsInRows, (index) => index * size.width / numDotsInRows)) {
      for (var y in List.generate(
          numDotsInCols, (index) => index * size.height / numDotsInCols)) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(PointMode.points, points, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
