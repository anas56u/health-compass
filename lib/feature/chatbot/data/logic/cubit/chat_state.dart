import 'package:equatable/equatable.dart';
import 'package:health_compass/feature/chatbot/data/models/message_model.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<bot_MessageModel> messages;
  final String errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage = '',
  });

  ChatState copyWith({
    ChatStatus? status,
    List<bot_MessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [status, messages, errorMessage];
}
