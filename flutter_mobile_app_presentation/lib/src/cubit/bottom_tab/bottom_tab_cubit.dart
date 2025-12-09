import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sealed_annotations/sealed_annotations.dart';

part 'bottom_tab_cubit.sealed.dart';

@Sealed()
abstract class _BottomTabState {
  void initial();

  void tabSwitched(Tab tab);
}

enum Tab {
  discovery,
  search,
  advice,
  toy,
}

class BottomTabCubit extends Cubit<BottomTabState> {
  BottomTabCubit() : super(const BottomTabState.initial());

  Future<void> onTabClicked(int index) async {
    var tab = Tab.discovery;
    if (index == 0) {
      tab = Tab.discovery;
    } else if (index == 1) {
      tab = Tab.search;
    } else if (index == 2) {
      tab = Tab.advice;
    } else {
      tab = Tab.toy;
    }
    emit(BottomTabState.tabSwitched(tab: tab));
  }
}
