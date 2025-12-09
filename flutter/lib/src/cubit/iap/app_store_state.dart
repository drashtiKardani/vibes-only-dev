part of 'app_store_cubit.dart';

class AppStoreState extends Equatable {
  final AppStoreStatus status;
  final List<Package> products;
  final PlatformException? error;

  const AppStoreState._({this.status = AppStoreStatus.unknown, this.products = const [], this.error});

  const AppStoreState.productsLoaded(List<Package> products)
      : this._(
          status: AppStoreStatus.productsLoaded,
          products: products,
        );

  const AppStoreState.errorLoadingProducts(PlatformException e)
      : this._(
          status: AppStoreStatus.errorLoadingProducts,
          error: e,
        );

  const AppStoreState.unknown() : this._();

  @override
  List<Object> get props => [status];
}

enum AppStoreStatus {
  productsLoaded,
  errorLoadingProducts,
  unknown,
}
