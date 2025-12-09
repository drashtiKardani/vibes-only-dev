import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/src/feature/video/channel_screen.dart';
import 'package:get_it/get_it.dart';

import '../../data/network/vibe_api_new.dart';

class ChannelScreenById extends StatelessWidget {
  final String id;

  const ChannelScreenById({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I<VibeApiNew>().getChannel(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ChannelScreen(snapshot.data!);
        } else {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
