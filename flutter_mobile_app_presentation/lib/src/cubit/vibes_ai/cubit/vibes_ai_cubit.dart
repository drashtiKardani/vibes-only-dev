// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_mobile_app_presentation/src/cubit/vibes_ai/models/chat_with_ai.dart';
// import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
// import 'package:get_it/get_it.dart';
// import 'package:vibes_common/vibes.dart';

// part 'vibes_ai_state.dart';

// class VibesAiCubit extends Cubit<VibesAiState> {
//   VibesAiCubit() : super(VibesAiState());

//   void startChat({
//     required Widget startContent,
//     required Widget suggestionsForYouContent,
//   }) {
//     List<ChatWithAI> chats = List<ChatWithAI>.from(state.chats);

//     chats.addAll([
//       ChatWithAI(
//         id: 0,
//         chatBy: ChatBy.ai,
//         content: startContent,
//         createdAt: DateTime.now(),
//       ),
//       ChatWithAI(
//         id: 1,
//         chatBy: ChatBy.ai,
//         content: suggestionsForYouContent,
//         createdAt: DateTime.now(),
//       ),
//     ]);

//     emit(state.copyWith(chats: chats));
//   }

//   void sentChat({required Widget content, bool isThinking = false}) async {
//     List<ChatWithAI> chats = List<ChatWithAI>.from(state.chats);

//     // Determine next ID (auto-increment)
//     final int nextId = chats.isNotEmpty ? chats.last.id + 1 : 0;

//     chats.add(
//       ChatWithAI(
//         id: nextId,
//         chatBy: ChatBy.user,
//         content: content,
//         createdAt: DateTime.now(),
//       ),
//     );

//     emit(state.copyWith(chats: chats, isThinking: isThinking));
//   }

//   void onToySelected(Commodity toy) {
//     emit(state.copyWith(toy: toy));
//   }

//   @override
//   void emit(VibesAiState state) {
//     if (!isClosed) super.emit(state);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/vibes_ai/models/chat_with_ai.dart';
import 'package:flutter_mobile_app_presentation/src/data/network/vibe_api_new.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';

part 'vibes_ai_state.dart';

class VibesAiCubit extends Cubit<VibesAiState> {
  VibesAiCubit() : super(const VibesAiState());

  int _nextId = 0;

  /// Initializes chat with welcome messages
  void startChat({
    required Widget startContent,
    required Widget suggestionsForYouContent,
  }) {
    final chats = [
      ChatWithAI(
        id: _nextId++,
        chatBy: ChatBy.ai,
        content: startContent,
        createdAt: DateTime.now(),
      ),
      ChatWithAI(
        id: _nextId++,
        chatBy: ChatBy.ai,
        content: suggestionsForYouContent,
        createdAt: DateTime.now(),
      ),
    ];

    emit(state.copyWith(chats: chats));
  }

  /// Adds a new chat message
  void sendChat({
    required Widget content,
    required ChatBy chatBy,
    bool isThinking = false,
  }) {
    final newChat = ChatWithAI(
      id: _nextId++,
      chatBy: chatBy,
      content: content,
      createdAt: DateTime.now(),
    );

    emit(
      state.copyWith(chats: [...state.chats, newChat], isThinking: isThinking),
    );
  }

  /// Updates the thinking state
  void setThinking(bool isThinking) {
    emit(state.copyWith(isThinking: isThinking));
  }

  /// Handles toy selection
  void onToySelected(Commodity toy) {
    emit(state.copyWith(toy: toy));
  }

  /// Clears chat history
  void clearChat() {
    _nextId = 0;
    emit(const VibesAiState());
  }

  @override
  void emit(VibesAiState state) {
    if (!isClosed) super.emit(state);
  }
}
