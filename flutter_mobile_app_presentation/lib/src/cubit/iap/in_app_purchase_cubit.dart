import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';

abstract class InAppPurchaseCubit extends Cubit<InAppPurchaseState> {
  InAppPurchaseCubit(super.initialState);

  void checkUserSubscription() {}

  void simulateSubscribedUser() {}

  void simulateFreeUser() {}

  void restorePurchase() {}

  void makePurchase(dynamic product) {}
}

class InAppPurchaseMockCubit extends InAppPurchaseCubit {
  InAppPurchaseMockCubit() : super(const InAppPurchaseState.unknown());

  @override
  void simulateSubscribedUser() {
    emit(InAppPurchaseState.active(SimulatedSubscription()));
  }
}

class SimulatedSubscription extends AppSubscription {
  @override
  String? get exp => null;

  @override
  String get latestPurchaseDate => 'Some time in the future';

  @override
  String get originalPurchaseDate => 'Some time in the past';

  @override
  String get package => 'Simulated For Admin Panel';
}
