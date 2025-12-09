import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'discovery_state.sealed.dart';

@Sealed()
abstract class _DiscoveryState {
  void initial();

  void loading();

  void success(Home homeResult);

  void failure(@WithType('VibeError') error);
}
