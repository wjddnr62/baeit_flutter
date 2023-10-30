import 'package:baeit/config/base_bloc.dart';
import 'package:flutter/widgets.dart';

class ChatHelpBloc extends BaseBloc {
  ChatHelpBloc(BuildContext context) : super(BaseChatHelpState()) {
    on<ChatHelpInitEvent>(onChatHelpInitEvent);
  }

  onChatHelpInitEvent(ChatHelpInitEvent event, emit) {
    emit(ChatHelpInitState());
  }
}

class ChatHelpInitEvent extends BaseBlocEvent {}

class ChatHelpInitState extends BaseBlocState {}

class BaseChatHelpState extends BaseBlocState {}
