import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/toy/toy_cubit.dart';
import 'toy_command_model.dart';

enum ToyCommandServiceState { active, inactive }

abstract class ToyCommandService extends Cubit<ToyCommandServiceState> {
  ToyCommandService() : super(ToyCommandServiceState.active);

  bool get currentStoryContainsVibes;

  void pause();

  void resume();

  void executeSynchronizedWithAudio(List<AllToyCommands> toyCommands, ToyCubit toyCubit);

  void toyStateChanged(ToyState state, ToyCubit toyCubit);
}

class ToyCommandServiceMock extends ToyCommandService {
  @override
  bool get currentStoryContainsVibes => false;

  @override
  void executeSynchronizedWithAudio(List<AllToyCommands> toyCommands, ToyCubit toyCubit) {}

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  void toyStateChanged(ToyState state, ToyCubit toyCubit) {}
}
