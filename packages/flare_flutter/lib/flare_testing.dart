import 'flare_cache.dart';
import 'flare_cache_asset.dart';

mixin FlareTesting {
  static void setup() {
    FlareCache.doesPrune = false;
    FlareCacheAsset.useCompute = false;
  }
}
