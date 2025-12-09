import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'search_state.sealed.dart';

@Sealed()
abstract class _SearchState {
  void initial();

  void loadingQuerySearch();

  void querySearchResult(List<SearchResult> searchResult);

  void failure(@WithType('VibeError') error);
}
