import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_mobile_app_presentation/toy.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_only/src/feature/toy/cubit/toy_cubit.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toolbar.dart';
import 'package:vibes_only/src/feature/toy/remote_control/toy_picture.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/nodes/state.dart';
import 'package:vibes_only/src/feature/toy/remote_lover/service/service.dart';

class SomeoneInControlScreen extends StatefulWidget {
  const SomeoneInControlScreen({super.key});

  @override
  State<SomeoneInControlScreen> createState() => _SomeoneInControlScreenState();
}

class _SomeoneInControlScreenState extends State<SomeoneInControlScreen> {
  late final ToyCubitImpl toy;

  @override
  void initState() {
    super.initState();
    toy = BlocProvider.of<ToyCubit>(context) as ToyCubitImpl;
    (toy).setRemoteCommander(
        GetIt.I<RemoteLoverService>().activeConnection?.commands);

    // Leave this screen if connection is closed by other partner.
    GetIt.I<RemoteLoverService>()
        .activeConnection
        ?.state
        .stream
        .firstWhere((state) => state == ConnectionState.ended)
        .then(
      (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: AppColors.vibesPink,
          duration: Duration(seconds: 1),
          content: Text('Your partner left the connection.',
              style: TextStyle(color: Colors.white)),
        ));
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    toy.unsetRemoteCommander();
    GetIt.I<RemoteLoverService>().endConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToyRemoteControlToolbar(
          toy: toy, onToySwitchClicked: () => Navigator.pop(context)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ToyPicture(toy: toy),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 15, bottom: 35),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF3A3A3A).withValues(alpha: 0.25),
                        blurRadius: 15,
                        spreadRadius: 5)
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: FlareActor(
                        'assets/toy.flr',
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        animation: "Untitled",
                      ),
                    ),
                    const Text('Your partner is in control',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 245,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('End')),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
