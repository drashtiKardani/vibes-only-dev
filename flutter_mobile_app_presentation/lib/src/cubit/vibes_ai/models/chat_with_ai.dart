import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'chat_with_ai.g.dart';

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

@JsonSerializable()
class ChatRequest {
  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'thread_id')
  final String threadId;

  final String message;

  ChatRequest({
    required this.userId,
    required this.threadId,
    required this.message,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}

@JsonSerializable()
class ChatResponse {
  final ChatResponseData response;

  ChatResponse({required this.response});

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}

@JsonSerializable()
class ChatResponseData {
  final String message;
  final String type;
  final List<Story>? stories;
  @JsonKey(name: 'suggested_toys')
  final List<Commodity>? suggestedToys;
  final List<int>? waves;

  ChatResponseData({
    required this.message,
    required this.type,
    this.stories,
    this.suggestedToys,
    this.waves,
  });

  factory ChatResponseData.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatResponseDataToJson(this);
}
