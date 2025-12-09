import 'dart:async';

import 'package:flutter/material.dart';

class ResendCodeWidget extends StatefulWidget {
  final VoidCallback? callback;

  const ResendCodeWidget({super.key, this.callback});

  @override
  State createState() => _ResendCodeWidgetState();
}

class _ResendCodeWidgetState extends State<ResendCodeWidget> {
  late Timer _timer;
  late int _seconds;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    setState(() {
      _seconds = 30;
    });
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_seconds == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _seconds--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _seconds == 0
          ? () {
              widget.callback?.call();
              startTimer();
            }
          : null,
      child: Text("Resend code${_seconds == 0 ? '' : ' ($_seconds)'}"),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
