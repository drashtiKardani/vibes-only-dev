import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState.initial());
  // TODO - use this value properly and remove ignore lint
  // ignore: prefer_final_fields
  String _lastSearchQuery = '';

  Future<void> search(String query) async {
    if (query.length < 2) {
      emit(const SearchState.initial());
    }
    if (_lastSearchQuery == query || query.length < 2) {
      return;
    }
    emit(const SearchState.loadingQuerySearch());
    final result = await GetIt.I.get<VibeApiNew>().search(query).sealed();
    if (result.isSuccessful) {
      emit(SearchState.querySearchResult(searchResult: result.data));
    } else {
      emit(SearchState.failure(error: result.error));
    }
  }
}
