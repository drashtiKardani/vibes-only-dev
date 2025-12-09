import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sealed_annotations/sealed_annotations.dart';

part 'app_store_state.dart';

class AppStoreCubit extends Cubit<AppStoreState> {
  AppStoreCubit() : super(const AppStoreState.unknown());

  Future<void> loadProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;
      if (currentOffering != null && currentOffering.availablePackages.isNotEmpty) {
        // Display packages for sale
        emit(AppStoreState.productsLoaded(currentOffering.availablePackages));
      }
    } on PlatformException catch (e) {
      // optional error handling
      FirebaseCrashlytics.instance.recordError(e, null);
      emit(AppStoreState.errorLoadingProducts(e));
    }
  }
}
