import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that does some [calculation] at regular [period]s, and uses the result to build some other widget.
class PeriodicBuilder<T> extends StatefulWidget {
  const PeriodicBuilder({super.key, required this.period, required this.calculation, required this.builder});

  final Duration period;
  final Future<T> Function() calculation;
  final Widget Function(T?) builder;

  @override
  State<PeriodicBuilder<T>> createState() => _PeriodicBuilderState();
}

class _PeriodicBuilderState<T> extends State<PeriodicBuilder<T>> {
  late final Timer uiUpdateTimer;
  T? calculationResult;

  @override
  void initState() {
    super.initState();
    uiUpdateTimer = Timer.periodic(widget.period, (tick) async {
      calculationResult = await widget.calculation();
      setState(() {});
    });
  }

  @override
  void dispose() {
    uiUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(calculationResult);
  }
}
