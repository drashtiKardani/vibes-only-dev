
part of 'card_game_cubit.dart';



/// Represents the state of the card game at any point in time.
class CardGameState {
  /// The current page index in the UI.
  final int pageIndex;

  /// The current turn index (e.g., which player's turn it is).
  final int turnIndex;

  /// The current page in game progression or flow.
  final int page;

  /// The current play type (e.g., Spin the Wheel, Draw Card, etc.).
  final PlayType? playType;

  /// The current prompt type (e.g., "Tell Me", "Show Me", etc.).
  final PromptType? promptType;

  /// All game cards available in the current state.
  final List<GameCard> gameCards;

  CardGameState({
    this.pageIndex = 0,
    this.turnIndex = 0,
    this.page = 0,
    this.playType,
    this.promptType,
    this.gameCards = const [],
  });

  /// Creates a new instance of [CardGameState] with updated fields.
  ///
  /// Use [Nullable<T>] wrapper for nullable fields to distinguish between
  /// "null as a new value" and "do not update".
  CardGameState copyWith({
    int? pageIndex,
    int? turnIndex,
    int? page,
    Nullable<PlayType>? playType,
    Nullable<PromptType>? promptType,
    List<GameCard>? gameCards,
  }) {
    return CardGameState(
      pageIndex: pageIndex ?? this.pageIndex,
      turnIndex: turnIndex ?? this.turnIndex,
      page: page ?? this.page,
      playType: playType != null ? playType.value : this.playType,
      promptType: promptType != null ? promptType.value : this.promptType,
      gameCards: gameCards ?? this.gameCards,
    );
  }
}