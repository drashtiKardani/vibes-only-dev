// part of 'vibes_ai_cubit.dart';

// class VibesAiState {
//   final List<ChatWithAI> chats;
//   final Commodity? toy;
//   final bool isThinking;
//   const VibesAiState({
//     this.chats = const [],
//     this.toy,
//     this.isThinking = false,
//   });

//   VibesAiState copyWith({
//     List<ChatWithAI>? chats,
//     Commodity? toy,
//     bool? isThinking,
//   }) {
//     return VibesAiState(
//       chats: chats ?? this.chats,
//       toy: toy ?? this.toy,
//       isThinking: isThinking ?? this.isThinking,
//     );
//   }
// }
part of 'vibes_ai_cubit.dart';

class VibesAiState {
  final List<ChatWithAI> chats;
  final Commodity? toy;
  final bool isThinking;
  final String? error;

  const VibesAiState({
    this.chats = const [],
    this.toy,
    this.isThinking = false,
    this.error,
  });

  VibesAiState copyWith({
    List<ChatWithAI>? chats,
    Commodity? toy,
    bool? isThinking,
    String? error,
  }) {
    return VibesAiState(
      chats: chats ?? this.chats,
      toy: toy ?? this.toy,
      isThinking: isThinking ?? this.isThinking,
      error: error,
    );
  }

  bool get hasChats => chats.isNotEmpty;
  bool get hasError => error != null;
}
