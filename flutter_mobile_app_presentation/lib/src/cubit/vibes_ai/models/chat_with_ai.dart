import 'package:flutter/material.dart';

enum ChatBy { user, ai }

class ChatWithAI {
  final int id;
  final ChatBy chatBy;
  final Widget content;
  final DateTime createdAt;

  const ChatWithAI({
    required this.id,
    required this.chatBy,
    required this.content,
    required this.createdAt,
  });
}
