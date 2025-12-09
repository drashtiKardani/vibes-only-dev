import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum _Flavor { production, staging }

/// Call detectUsing(PackageInfo) at the start of program.
class Flavor {
  // ignore: library_private_types_in_public_api
  final _Flavor flavor;
  final String name;
  final Color color;
  final String baseUrl;

  static late final Flavor _instance;
  static Flavor get instance => _instance;

  /// Must be called before any other Flavor methods.
  /// Dependents which want to mock Flavor (like admin panel) should call [setToProduction] or [setToStaging].
  static void detectUsing(PackageInfo packageInfo) {
    if (packageInfo.packageName.endsWith('staging')) {
      setToStaging();
    } else {
      setToProduction();
    }
  }

  static void setToProduction() {
    _instance = productionFlavor;
  }

  static void setToStaging() {
    _instance = stagingFlavor;
  }

  static final stagingFlavor = Flavor._(
    flavor: _Flavor.staging,
    name: 'Staging',
    color: Colors.purpleAccent,
    baseUrl: 'https://server-staging-temp.vibesonly.com/api/v1/',
  );

  static final productionFlavor = Flavor._(
    flavor: _Flavor.production,
    name: 'Production',
    color: Colors.green,
    baseUrl: 'https://app.vibesonly.com/api/v1/',
  );

  static bool isProduction() => _instance.flavor == _Flavor.production;
  static bool isStaging() => _instance.flavor == _Flavor.staging;

  Flavor._({
    required this.flavor,
    required this.name,
    required this.color,
    required this.baseUrl,
  });
}
