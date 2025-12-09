part of 'vibes_ai_cubit.dart';

class VibesAiState {
  final List<ChatWithAI> chats;
  final Commodity? toy;

  const VibesAiState({this.chats = const [], this.toy});

  VibesAiState copyWith({List<ChatWithAI>? chats, Commodity? toy}) {
    return VibesAiState(chats: chats ?? this.chats, toy: toy ?? this.toy);
  }
}
