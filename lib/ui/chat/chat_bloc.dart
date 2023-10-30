import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/chat/chat_room.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:flutter/widgets.dart';

class ChatBloc extends BaseBloc {
  ChatBloc(BuildContext context) : super(BaseChatState());

  bool loading = false;
  UserData? userData;
  bool firstChat = false;
  bool secondChat = false;
  bool thirdChat = false;

  List<String> firstChatData = [
    '6세 육아 영어도\n클래스 가능하세요?',
    '후라이팬 베이킹도 클래스 가능하세요?',
    '블로그 꾸미기도 클래스 가능하세요?'
  ];
  List<String> secondChatData = [
    '네 가능해요~!\n놀이와 생활습관 지도 위주 커리큘럼 어떠신가요?',
    '넵 집에서 하실래요?\n아니면 오픈키친에서\n하실까요?',
    '네 :) 원하는 블로그 스타일 자료 모아서 오시면 안내 해드릴게요~!!'
  ];
  List<String> thirdChatData = [
    '네 좋아요~! 그럼 아파트 놀이터에서 주말에 봬요~!',
    '오픈 키친이 좋을 것 같아요 주말에 봬요~!',
    '감사해요! 그럼 카페에서 주말에 봬요~!'
  ];
  List<String> nonMemberChatData = [
    '일요일 오후 2시 동네카페에서 괜찮으실까요?',
    '네 가능해요~',
    '네! 그럼 그때 뵐게요 :)'
  ];

  int chatData = 0;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is ChatInitEvent) {
      var random = Random();
      chatData = random.nextInt(3);

      if (dataSaver.nonMember != null && !dataSaver.nonMember) {
        userData = UserData.fromJson(
            jsonDecode(prefs!.getString('userData').toString()));
      }

      if (prefs!.getString('chatData') != null) {
        dataSaver.chatRoom =
            ChatRoom.fromJson(jsonDecode(prefs!.getString('chatData')!));
      }

      yield ChatInitState();
    }

    if (event is ChatReloadEvent) {
      if ((dataSaver.chatRoom == null ||
              dataSaver.chatRoom!.roomData.length == 0) &&
          firstChat == false) {
        var random = Random();
        chatData = random.nextInt(3);
        firstChat = true;
        secondChat = true;
        thirdChat = true;
        if (prefs!.getString('chatData') != null) {
          dataSaver.chatRoom =
              ChatRoom.fromJson(jsonDecode(prefs!.getString('chatData')!));
        }
        yield CheckState();
      } else {
        if (prefs!.getString('chatData') != null) {
          dataSaver.chatRoom =
              ChatRoom.fromJson(jsonDecode(prefs!.getString('chatData')!));
        }
      }
      yield ChatReloadState();
    }

    if (event is AnimationStartEvent) {
      firstChat = true;
      yield AnimationStartState();
    }

    if (event is GetRoomDataEvent) {
      if (dataSaver.chatBloc != null &&
          (dataSaver.chatRoom == null ||
              dataSaver.chatRoom!.roomData.length == 0) &&
          !stompClient.connected) {
        // stompClient.deactivate();
        stompClient.activate();
        Timer(Duration(milliseconds: 3000), () {
          add(GetRoomDataEvent());
        });
      }
      yield GetRoomDataState();
    }
  }
}

class AnimationStartEvent extends BaseBlocEvent {}

class AnimationStartState extends BaseBlocState {}

class GetRoomDataEvent extends BaseBlocEvent {}

class GetRoomDataState extends BaseBlocState {}

class ChatReloadEvent extends BaseBlocEvent {}

class ChatReloadState extends BaseBlocState {}

class ChatInitEvent extends BaseBlocEvent {}

class ChatInitState extends BaseBlocState {}

class BaseChatState extends BaseBlocState {}
