import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/controllers.dart';
import 'package:flutter_mobile_app_presentation/flutter_mobile_app_presentation.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

part 'card_game_state.dart';

/// Cubit responsible for managing the game state and handling game logic.
class CardGameCubit extends Cubit<CardGameState> {
  CardGameCubit() : super(CardGameState());

  final VibeApiNew _api = GetIt.I.get<VibeApiNew>();
  final int _pageSize = 20;

  /// Fetches both 'show_me' and 'tell_me' game cards for the next page.
  Future<void> getAllGameCard() async {
    List<GameCard> gameCards = List<GameCard>.from(state.gameCards);
    int page = state.page + 1;

    final results = await Future.wait([
      _api.getGameCards(page, _pageSize, 'show_me').then((e) => e.results),
      _api.getGameCards(page, _pageSize, 'tell_me').then((e) => e.results),
    ]);

    gameCards.addAll(results.expand((e) => e));

    emit(state.copyWith(gameCards: gameCards, page: page));
  }

  void onPageChanged(int index) {
    emit(state.copyWith(pageIndex: index));
  }

  void onPlayTypeOrPromptTypeChanged(
    PlayType? playType,
    PromptType? promptType,
  ) {
    emit(
      state.copyWith(
        playType: Nullable(playType),
        promptType: Nullable(promptType),
      ),
    );
  }

  void onPromptTypeChanged(PromptType? promptType) {
    emit(state.copyWith(promptType: Nullable(promptType)));
  }

  /// Selects a random game card that matches the current prompt type.
  /// Triggers a card reload if the local pool becomes too small.
  List<GameCard> getMatchingCards() {
    return state.gameCards
        .where((e) => e.promptType == state.promptType)
        .toList();
  }

  void reset() => emit(CardGameState());
}
