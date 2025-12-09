import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/vibes_ai/models/chat_with_ai.dart';
import 'package:vibes_common/vibes.dart';

part 'vibes_ai_state.dart';

class VibesAiCubit extends Cubit<VibesAiState> {
  VibesAiCubit() : super(VibesAiState());

  void startChat({
    required Widget startContent,
    required Widget suggestionsForYouContent,
  }) {
    List<ChatWithAI> chats = List<ChatWithAI>.from(state.chats);

    chats.addAll([
      ChatWithAI(
        id: 0,
        chatBy: ChatBy.ai,
        content: startContent,
        createdAt: DateTime.now(),
      ),
      ChatWithAI(
        id: 1,
        chatBy: ChatBy.ai,
        content: suggestionsForYouContent,
        createdAt: DateTime.now(),
      ),
    ]);

    emit(state.copyWith(chats: chats));
  }

  void sentChat({required Widget content}) {
    List<ChatWithAI> chats = List<ChatWithAI>.from(state.chats);

    // Determine next ID (auto-increment)
    final int nextId = chats.isNotEmpty ? chats.last.id + 1 : 0;

    chats.add(
      ChatWithAI(
        id: nextId,
        chatBy: ChatBy.user,
        content: content,
        createdAt: DateTime.now(),
      ),
    );

    emit(state.copyWith(chats: chats));
  }

  void onToySelected(Commodity toy) {
    emit(state.copyWith(toy: toy));
  }

  @override
  void emit(VibesAiState state) {
    if (!isClosed) super.emit(state);
  }
}
