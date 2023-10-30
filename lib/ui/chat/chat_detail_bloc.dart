import 'dart:async';
import 'dart:io';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/chat/chat_room.dart';
import 'package:baeit/data/chat/members.dart';
import 'package:baeit/data/chat/repository/chat_repository.dart';
import 'package:baeit/data/chat/talk.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/common/service/image_multiple_upload_service.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/data/profile/repository/profile_repository.dart';
import 'package:baeit/ui/chat/chat_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/stomp.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class ChatDetailBloc extends BaseBloc {
  ChatDetailBloc(BuildContext context) : super(BaseChatDetailState());

  bool networkNone = false;

  bool loading = false;
  bool menuOpen = false;
  bool classCheck = false;
  bool communityCheck = false;
  String? classUuid;
  String? communityUuid;
  String? chatRoomUuid;
  RoomDatas? roomData;
  String type = 'TALK';
  String status = 'NORMAL';

  List<Talk> talk = [];
  List<String> date = [];
  List<Members> members = [];
  double bottomOffset = 0;
  bool scrollUnder = false;
  ClassInfo? classInfo;
  CommunityInfo? communityInfo;
  int nextData = 1;
  bool sendDisable = false;
  String? savePath;
  int dataIndex = 0;
  bool settingOpen = false;
  bool lock = false;
  int seq = 0;
  List<Talk> talkData = [];
  bool chatJump = false;
  List<TalkSend> cacheTalkData = [];

  dynamic readSubscribe;
  dynamic chatSubscribe;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is ChatDetailInitEvent) {
      loading = true;
      yield LoadingState();
      if (classUuid == null) classUuid = event.classUuid;
      if (communityUuid == null) communityUuid = event.communityUuid;
      if (chatRoomUuid == null) chatRoomUuid = event.chatRoomUuid;
      classCheck = event.classCheck;
      communityCheck = event.communityCheck;

      if (!stompClient.connected) {
        stompClient.activate();
        Timer(Duration(milliseconds: 1500), () {
          add(ChatDetailInitEvent(
            classUuid: event.classUuid,
            communityUuid: event.communityUuid,
            classCheck: event.classCheck,
            communityCheck: event.communityCheck,
            chatRoomUuid: event.chatRoomUuid,
          ));
        });
        return;
      }

      if (dataSaver.profileGet == null) {
        ProfileRepository.getProfile().then((value) {
          dataSaver.profileGet = ProfileGet.fromJson(value.data);
        });
      }

      if ((classUuid != null && classCheck) ||
          (communityUuid != null && communityCheck)) {
        loading = true;
        yield LoadingState();
        ReturnData returnData = await ChatRepository.chatOpen(
            classCheck: classCheck,
            communityCheck: communityCheck,
            classUuid: classUuid,
            communityUuid: communityUuid,
            introFlag: 1);

        if (returnData.code == 1) {
          chatRoomUuid = returnData.data['chatRoomUuid'];
          seq = returnData.data['seq'];
          status = returnData.data['status'];
          roomData = RoomDatas.fromJson(returnData.data);
          classUuid = null;
          communityUuid = null;
          members = (returnData.data['members'] as List)
              .map((e) => Members.fromJson(e))
              .toList();

          dataSaver.chatRoomUuid = chatRoomUuid;
          loading = false;
          yield LoadingState();
        }
      }

      if (classUuid == null && communityUuid == null) {
        loading = true;
        yield LoadingState();
        dataSaver.chatRoomUuid = chatRoomUuid;

        if (prefs!.getString(chatRoomUuid!) != null && talk.length == 0) {
          talk.addAll((jsonDecode(prefs!.getString(chatRoomUuid!)!) as List)
              .map((e) => Talk.fromJson(jsonDecode(e)))
              .toList());
          add(ChatDetailReloadEvent());
        }

        if (!(prefs!.getString(chatRoomUuid!) != null && talk.length == 0)) {
          ReturnData returnData =
              await ChatRepository.getMessageListService(chatRoomUuid!);

          for (int i = 0; i < (returnData.data['list'] as List).length; i++) {
            if (talk.indexWhere((element) =>
                    element.chatRoomMessageUuid ==
                    Talk.fromJson((returnData.data['list'] as List)[i])
                        .chatRoomMessageUuid) ==
                -1) {
              if (talk.indexWhere((element) =>
                          element.sendUuid ==
                          Talk.fromJson((returnData.data['list'] as List)[i])
                              .sendUuid) ==
                      -1 ||
                  Talk.fromJson((returnData.data['list'] as List)[i])
                          .sendUuid ==
                      null) {
                talk.add(Talk.fromJson((returnData.data['list'] as List)[i]));
                add(ChatDetailReloadEvent());
              }
            }
          }
        }

        ReturnData roomDataRes =
            await ChatRepository.getChatRoom(chatRoomUuid!);

        if (roomDataRes.code == 1) {
          if (roomDataRes.data['classInfo'] != null) {
            classInfo = ClassInfo.fromJson(roomDataRes.data['classInfo']);
          }
          if (roomDataRes.data['communityInfo'] != null) {
            communityInfo =
                CommunityInfo.fromJson(roomDataRes.data['communityInfo']);
          }
          status = roomDataRes.data['status'];
          members = (roomDataRes.data['members'] as List)
              .map((e) => Members.fromJson(e))
              .toList();
          roomData = RoomDatas.fromJson(roomDataRes.data);

          bool unread = false;

          if (chatSubscribe == null) {
            chatSubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/message/$chatRoomUuid',
                callback: (frame) async {
                  members[members.indexWhere((element) =>
                          element.member.memberUuid ==
                          Talk.fromJson(jsonDecode(frame.body!)).memberUuid)]
                      .messageCnt += 1;

                  if (Talk.fromJson(jsonDecode(frame.body!))
                          .status
                          .toString()
                          .toLowerCase() ==
                      'fail') {
                    if (frame.body != null &&
                        talk.length != 0 &&
                        talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid) !=
                            -1 &&
                        Talk.fromJson(jsonDecode(frame.body!)).memberUuid ==
                            dataSaver.profileGet!.memberUuid) {
                      if (cacheTalkData.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) !=
                          -1) {
                        cacheTalkData.removeAt(cacheTalkData.indexWhere(
                            (element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid));
                        await prefs!.setString(
                            'cacheTalk',
                            jsonEncode(
                                cacheTalkData.map((e) => e.toMap()).toList()));
                      }

                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .loading = false;
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .send = false;
                      add(ChatDetailReloadEvent());
                    }

                    List<String> talkBackUp =
                        talk.map((e) => jsonEncode(e.toMap())).toList();
                    await prefs!
                        .setString(chatRoomUuid!, jsonEncode(talkBackUp));

                    if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                        dataSaver.userData!.memberUuid) {
                      add(ReadMessageEvent());
                    } else {
                      add(ReloadChatDetailEvent());
                    }
                  } else {
                    if (frame.body != null &&
                        Talk.fromJson(jsonDecode(frame.body!)).type ==
                            'NOTICE') {
                      talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                      add(ChatDetailReloadEvent());
                    }
                    if (frame.body != null &&
                        talk.length != 0 &&
                        talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid) !=
                            -1 &&
                        Talk.fromJson(jsonDecode(frame.body!)).memberUuid ==
                            dataSaver.profileGet!.memberUuid) {
                      if (cacheTalkData.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) !=
                          -1) {
                        cacheTalkData.removeAt(cacheTalkData.indexWhere(
                            (element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid));
                        await prefs!.setString(
                            'cacheTalk',
                            jsonEncode(
                                cacheTalkData.map((e) => e.toMap()).toList()));
                      }

                      if (talk[talk.indexWhere((element) =>
                                  element.sendUuid ==
                                  Talk.fromJson(jsonDecode(frame.body!))
                                      .sendUuid)]
                              .memberUuid ==
                          dataSaver.userData!.memberUuid) {
                        talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .loading = false;
                        talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .send = true;
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .chatRoomMessageUuid =
                            Talk.fromJson(jsonDecode(frame.body!))
                                .chatRoomMessageUuid;
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .createDate =
                            Talk.fromJson(jsonDecode(frame.body!)).createDate;
                        if (talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .unreadCnt >
                            Talk.fromJson(jsonDecode(frame.body!)).unreadCnt) {
                          talk[talk.indexWhere((element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                                  .unreadCnt =
                              Talk.fromJson(jsonDecode(frame.body!)).unreadCnt;
                        }
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .nextCursor =
                            Talk.fromJson(jsonDecode(frame.body!)).nextCursor;
                        add(ChatDetailReloadEvent());
                      } else {
                        if (talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid) ==
                            -1) {
                          talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                          add(ChatDetailReloadEvent());
                        }
                      }

                      for (int i = 0; i < talk.length; i++) {
                        if (!date.contains(talk[i].createDate.yearMonthDay) &&
                            talk[i].type != 'EVENT') {
                          date.add(talk[i].createDate.yearMonthDay);
                        }
                      }
                      List<String> talkBackUp =
                          talk.map((e) => jsonEncode(e.toMap())).toList();
                      await prefs!
                          .setString(chatRoomUuid!, jsonEncode(talkBackUp));

                      if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                          dataSaver.userData!.memberUuid) {
                        add(ReadMessageEvent());
                      } else {
                        add(ReloadChatDetailEvent());
                      }
                    } else {
                      if (talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) ==
                          -1) {
                        talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                        add(ChatDetailReloadEvent());
                      }
                      if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                          dataSaver.userData!.memberUuid) {
                        add(ReadMessageEvent());
                      } else {
                        add(ReloadChatDetailEvent());
                      }
                    }
                  }
                  add(ChatDetailReloadEvent());
                });
          }

          if (readSubscribe == null) {
            readSubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/read/$chatRoomUuid',
                callback: (frame) async {
                  add(ReadUpdateEvent(
                      msgUuid:
                          (jsonDecode(frame.body!)['chatRoomMessageUuids']),
                      sendUuid: (jsonDecode(frame.body!)['sendUuids']),
                      talk: talk));
                  List<dynamic> removeFcmId = [];
                  removeFcmId.addAll(
                      (jsonDecode(frame.body!)['fcmMessageIds']).toList());
                  for (int i = 0; i < removeFcmId.length; i++) {
                    flutterLocalNotificationsPlugin!
                        .cancel(int.parse(removeFcmId[i].toString()));
                  }
                  flutterLocalNotificationsPlugin!
                      .cancel(jsonDecode(frame.body!)['seq']);
                });
          }

          ReturnData? returnData;
          if (talk.length != 0) {
            returnData = await ChatRepository.getUnreadMessageListService(
                chatRoomUuid!,
                chatRoomMessageUuid: talk.last.chatRoomMessageUuid);
          } else {
            returnData =
                await ChatRepository.getUnreadMessageListService(chatRoomUuid!);
          }
          if (returnData!.data.length != 0) {
            unread = true;
          }

          for (int i = 0; i < (returnData.data as List).length; i++) {
            if (talk.indexWhere((element) =>
                    element.chatRoomMessageUuid ==
                    Talk.fromJson((returnData!.data as List)[i])
                        .chatRoomMessageUuid) ==
                -1) {
              if (talk.indexWhere((element) =>
                          element.sendUuid ==
                          Talk.fromJson((returnData!.data as List)[i])
                              .sendUuid) ==
                      -1 ||
                  Talk.fromJson((returnData.data as List)[i]).sendUuid ==
                      null) {
                talk.add(Talk.fromJson((returnData.data as List)[i]));
                add(ChatDetailReloadEvent());
              }
              List<String> talkBackUp =
                  talk.map((e) => jsonEncode(e.toMap())).toList();
              await prefs!.setString(chatRoomUuid!, jsonEncode(talkBackUp));
            }
          }

          for (int i = 0; i < talk.length; i++) {
            if (!date.contains(talk[i].createDate.yearMonthDay) &&
                talk[i].type != 'EVENT') {
              date.add(talk[i].createDate.yearMonthDay);
            }
          }

          stompClient.send(
              destination: '/app/chat/room/read',
              body: jsonEncode({
                'chatRoomUuid': chatRoomUuid!,
                'memberUuid': dataSaver.userData!.memberUuid,
                'seq': dataSaver.chatRoom == null
                    ? seq
                    : dataSaver.chatRoom!.roomData.indexWhere((element) =>
                                element.chatRoomUuid == chatRoomUuid) ==
                            -1
                        ? seq
                        : dataSaver
                            .chatRoom!
                            .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                                (element) =>
                                    element.chatRoomUuid == chatRoomUuid)]
                            .seq
              }),
              headers: {'memberUuid': dataSaver.userData!.memberUuid});

          if (talk.lastIndexWhere((element) => element.unreadCnt >= 1) != -1) {
            int unreadSize = 0;
            for (int i = 0; i < talk.length; i++) {
              if (talk[i].unreadCnt == 1) {
                unreadSize += 1;
              }
            }
            ChatRepository.getMessageListService(chatRoomUuid!,
                    nextCursor: (talk.lastIndexWhere(
                                (element) => element.unreadCnt == 1) ==
                            talk.length - 1)
                        ? null
                        : talk[talk.lastIndexWhere(
                                    (element) => element.unreadCnt == 1) +
                                ((talk.lastIndexWhere((element) =>
                                            element.unreadCnt == 1) ==
                                        talk.length - 1)
                                    ? 0
                                    : 1)]
                            .nextCursor,
                    size: unreadSize)
                .then((value) {
              List<Talk> readCheckData = (value.data['list'] as List)
                  .map((e) => Talk.fromJson(e))
                  .toList();

              for (int i = 0; i < readCheckData.length; i++) {
                if (talk.indexWhere((element) =>
                        element.chatRoomMessageUuid ==
                        readCheckData[i].chatRoomMessageUuid) !=
                    -1) {
                  talk[talk.indexWhere((element) =>
                          element.chatRoomMessageUuid ==
                          readCheckData[i].chatRoomMessageUuid)]
                      .unreadCnt = readCheckData[i].unreadCnt;
                  add(ChatDetailReloadEvent());
                }
              }
              add(ReloadChatDetailEvent(save: true));
            });
          }

          loading = false;
          add(ChatCacheSendEvent());
          yield ChatDetailInitState(unread: unread);
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        loading = false;
        yield ChatDetailInitState();
      }
      lock = false;
      loading = false;
      yield LoadingState();
    }

    if (event is MenuOpenEvent) {
      menuOpen = !menuOpen;
      yield MenuOpenState();
    }

    if (event is SendMessageEvent) {
      loading = true;
      yield LoadingState();
      if ((classUuid != null && classCheck) ||
          (communityUuid != null && communityCheck)) {
        if (!networkNone && stompClient.connected) {
          if (production == 'prod-release' && kReleaseMode) {
            if (prefs!.getStringList('chatEvent') == null ||
                (prefs!.getStringList('chatEvent') != null &&
                    prefs!
                            .getStringList('chatEvent')!
                            .indexWhere((element) => element == chatRoomUuid) ==
                        -1)) {
              if (prefs!.getStringList('chatEvent') == null) {
                List<String> chatEvent = [chatRoomUuid!];
                await prefs!.setStringList('chatEvent', chatEvent);
              } else {
                List<String> chatEvent = prefs!.getStringList('chatEvent')!;
                chatEvent.add(chatRoomUuid!);
                await prefs!.setStringList('chatEvent', chatEvent);
              }
              if (communityInfo != null) {
                amplitudeRevenue(productId: 'chat_community_start', price: 10);
              }
              if (classInfo != null) {
                if (classInfo!.type == 'MADE') {
                  amplitudeRevenue(productId: 'chat_start', price: 10);
                }
                await facebookAppEvents.logPurchase(
                    amount: 1,
                    currency: dataSaver.abTest ?? 'KRW',
                    parameters: {
                      'fb_content_type': roomData!.classInfo!.title,
                      'fb_content_id': roomData!.classInfo!.classUuid
                    });
              }
            }
          }

          ReturnData returnData = await ChatRepository.chatOpen(
              classCheck: classCheck,
              communityCheck: communityCheck,
              classUuid: classUuid,
              communityUuid: communityUuid,
              introFlag: 1);

          if (returnData.code == 1) {
            // 채팅 보내기
            chatRoomUuid = returnData.data['chatRoomUuid'];
            seq = returnData.data['seq'];
            status = returnData.data['status'];
            roomData = RoomDatas.fromJson(returnData.data);
            classUuid = null;
            communityUuid = null;

            dataSaver.chatRoomUuid = chatRoomUuid;

            if (chatSubscribe == null) {
              chatSubscribe = stompClient.subscribe(
                  destination: '/topic/chat/room/message/$chatRoomUuid',
                  callback: (frame) async {
                    if (frame.body != null &&
                        talk.length != 0 &&
                        talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid) !=
                            -1) {
                      if (frame.body != null &&
                          Talk.fromJson(jsonDecode(frame.body!)).type ==
                              'NOTICE') {
                        talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                        add(ChatDetailReloadEvent());
                      }
                      if (cacheTalkData.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) !=
                          -1) {
                        cacheTalkData.removeAt(cacheTalkData.indexWhere(
                            (element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid));
                        prefs!.setString(
                            'cacheTalk',
                            jsonEncode(
                                cacheTalkData.map((e) => e.toMap()).toList()));
                      }

                      if (talk[talk.indexWhere((element) =>
                                  element.sendUuid ==
                                  Talk.fromJson(jsonDecode(frame.body!))
                                      .sendUuid)]
                              .memberUuid ==
                          dataSaver.userData!.memberUuid) {
                        talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .loading = false;
                        talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .send = true;
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .chatRoomMessageUuid =
                            Talk.fromJson(jsonDecode(frame.body!))
                                .chatRoomMessageUuid;
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .createDate =
                            Talk.fromJson(jsonDecode(frame.body!)).createDate;
                        if (talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .unreadCnt >
                            Talk.fromJson(jsonDecode(frame.body!)).unreadCnt) {
                          talk[talk.indexWhere((element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                                  .unreadCnt =
                              Talk.fromJson(jsonDecode(frame.body!)).unreadCnt;
                        }
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .nextCursor =
                            Talk.fromJson(jsonDecode(frame.body!)).nextCursor;
                        add(ChatDetailReloadEvent());
                      } else {
                        if (talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid) ==
                            -1) {
                          talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                          add(ChatDetailReloadEvent());
                        }
                      }

                      for (int i = 0; i < talk.length; i++) {
                        if (!date.contains(talk[i].createDate.yearMonthDay) &&
                            talk[i].type != 'EVENT') {
                          date.add(talk[i].createDate.yearMonthDay);
                        }
                      }
                      List<String> talkBackUp =
                          talk.map((e) => jsonEncode(e.toMap())).toList();
                      await prefs!
                          .setString(chatRoomUuid!, jsonEncode(talkBackUp));

                      if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                          dataSaver.userData!.memberUuid) {
                        add(ReadMessageEvent());
                      } else {
                        add(ReloadChatDetailEvent());
                      }
                    } else {
                      if (talk.indexWhere((element) =>
                                  element.sendUuid ==
                                  Talk.fromJson(jsonDecode(frame.body!))
                                      .sendUuid) ==
                              -1 ||
                          Talk.fromJson(jsonDecode(frame.body!)).sendUuid ==
                              null) {
                        talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                        add(ChatDetailReloadEvent());
                      }
                      if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                          dataSaver.userData!.memberUuid) {
                        add(ReadMessageEvent());
                      } else {
                        add(ReloadChatDetailEvent());
                      }
                    }
                  });
            }

            if (readSubscribe == null) {
              readSubscribe = stompClient.subscribe(
                  destination: '/topic/chat/room/read/$chatRoomUuid',
                  callback: (frame) async {
                    List<dynamic> removeFcmId = [];
                    removeFcmId.addAll(
                        (jsonDecode(frame.body!)['fcmMessageIds']).toList());
                    for (int i = 0; i < removeFcmId.length; i++) {
                      flutterLocalNotificationsPlugin!
                          .cancel(int.parse(removeFcmId[i].toString()));
                    }
                    add(ReadUpdateEvent(
                        msgUuid:
                            (jsonDecode(frame.body!)['chatRoomMessageUuids']),
                        sendUuid: (jsonDecode(frame.body!)['sendUuids']),
                        talk: talk));
                  });
            }

            Member member = Member(
                memberUuid: dataSaver.userData!.memberUuid,
                nickName: dataSaver.profileGet!.nickName,
                phone: '',
                profile: dataSaver.profileGet!.profile);

            TalkSend talkSend = TalkSend(
                chatRoomUuid: chatRoomUuid!,
                type: 'TALK',
                nickName: member.nickName,
                profile: member.profile,
                message: event.msg,
                sendUuid: Uuid().v1(),
                subType: event.subType,
                memberUuid: dataSaver.userData!.memberUuid,
                seq: dataSaver.chatRoom == null
                    ? seq
                    : dataSaver.chatRoom!.roomData.indexWhere((element) =>
                                element.chatRoomUuid == chatRoomUuid) ==
                            -1
                        ? seq
                        : dataSaver
                            .chatRoom!
                            .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                                (element) =>
                                    element.chatRoomUuid == chatRoomUuid)]
                            .seq,
                sendDate: DateTime.now());

            if (talk.indexWhere(
                    (element) => element.sendUuid == talkSend.sendUuid) ==
                -1) {
              talk.add(Talk(
                  sendUuid: talkSend.sendUuid,
                  chatRoomMessageUuid: '',
                  memberUuid: dataSaver.userData!.memberUuid,
                  nextCursor: '',
                  type: talkSend.type,
                  chatRoomUuid: chatRoomUuid!,
                  createDate: DateTime.now(),
                  files: [],
                  unreadCnt: members.length - 1,
                  message: talkSend.message,
                  loading: true,
                  send: false));
              add(ChatDetailReloadEvent());
            }

            for (int i = 0; i < talk.length; i++) {
              if (!date.contains(talk[i].createDate.yearMonthDay) &&
                  talk[i].type != 'EVENT') {
                date.add(talk[i].createDate.yearMonthDay);
              }
            }

            stompClient.send(
                destination: '/app/chat/room/message',
                body: jsonEncode(talkSend.toMap()),
                headers: {'memberUuid': dataSaver.userData!.memberUuid});

            loading = false;
            yield SendMessageState();
          } else {
            loading = false;
            yield ErrorState();
          }
        } else {
          yield CheckState();
        }
      } else {
        Member member = Member(
            memberUuid: dataSaver.userData!.memberUuid,
            nickName: dataSaver.profileGet!.nickName,
            phone: '',
            profile: dataSaver.profileGet!.profile);

        TalkSend talkSend = TalkSend(
            chatRoomUuid: chatRoomUuid!,
            type: type,
            nickName: member.nickName,
            profile: member.profile,
            message: event.msg,
            subType: event.subType,
            sendUuid: Uuid().v1(),
            memberUuid: dataSaver.userData!.memberUuid,
            seq: dataSaver.chatRoom == null
                ? seq
                : dataSaver.chatRoom!.roomData.indexWhere((element) =>
                            element.chatRoomUuid == chatRoomUuid) ==
                        -1
                    ? seq
                    : dataSaver
                        .chatRoom!
                        .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                            (element) => element.chatRoomUuid == chatRoomUuid)]
                        .seq,
            sendDate: DateTime.now());

        cacheTalkData.add(talkSend);
        await prefs!.setString('cacheTalk',
            jsonEncode(cacheTalkData.map((e) => e.toMap()).toList()));

        if (talk.indexWhere(
                (element) => element.sendUuid == talkSend.sendUuid) ==
            -1) {
          talk.add(Talk(
              sendUuid: talkSend.sendUuid,
              chatRoomMessageUuid: '',
              memberUuid: dataSaver.userData!.memberUuid,
              nextCursor: '',
              type: talkSend.type,
              chatRoomUuid: chatRoomUuid!,
              createDate: DateTime.now(),
              files: [],
              unreadCnt: members.length - 1,
              message: talkSend.message,
              send: false,
              loading: true));
          add(ChatDetailReloadEvent());
          for (int i = 0; i < talk.length; i++) {
            if (!date.contains(talk[i].createDate.yearMonthDay) &&
                talk[i].type != 'EVENT') {
              date.add(talk[i].createDate.yearMonthDay);
            }
          }
        }

        if (!networkNone && stompClient.connected) {
          if (production == 'prod-release' && kReleaseMode) {
            if (prefs!.getStringList('chatEvent') == null ||
                (prefs!.getStringList('chatEvent') != null &&
                    prefs!
                            .getStringList('chatEvent')!
                            .indexWhere((element) => element == chatRoomUuid) ==
                        -1)) {
              if (prefs!.getStringList('chatEvent') == null) {
                List<String> chatEvent = [chatRoomUuid!];
                await prefs!.setStringList('chatEvent', chatEvent);
              } else {
                List<String> chatEvent = prefs!.getStringList('chatEvent')!;
                chatEvent.add(chatRoomUuid!);
                await prefs!.setStringList('chatEvent', chatEvent);
              }
              if (communityInfo != null) {
                amplitudeRevenue(productId: 'chat_community_start', price: 10);
              }
              if (classInfo != null) {
                if (classInfo!.type == 'MADE') {
                  amplitudeRevenue(productId: 'chat_start', price: 10);
                }
                await facebookAppEvents.logPurchase(
                    amount: 1,
                    currency: dataSaver.abTest ?? 'KRW',
                    parameters: {
                      'fb_content_type': classInfo!.title,
                      'fb_content_id': classInfo!.classUuid
                    });
              }
            }
          }

          if (chatSubscribe == null) {
            chatSubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/message/$chatRoomUuid',
                callback: (frame) async {
                  if (frame.body != null &&
                      talk.length != 0 &&
                      talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) !=
                          -1) {
                    if (frame.body != null &&
                        Talk.fromJson(jsonDecode(frame.body!)).type ==
                            'NOTICE') {
                      talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                      add(ChatDetailReloadEvent());
                    }
                    if (talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .memberUuid ==
                        dataSaver.userData!.memberUuid) {
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .loading = false;
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .send = true;
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .chatRoomMessageUuid = Talk.fromJson(
                              jsonDecode(frame.body!))
                          .chatRoomMessageUuid;
                      talk[talk.indexWhere(
                                  (element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                              .createDate =
                          Talk.fromJson(jsonDecode(frame.body!)).createDate;
                      if (talk[talk.indexWhere((element) =>
                                  element.sendUuid ==
                                  Talk.fromJson(jsonDecode(frame.body!))
                                      .sendUuid)]
                              .unreadCnt >
                          Talk.fromJson(jsonDecode(frame.body!)).unreadCnt) {
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .unreadCnt =
                            Talk.fromJson(jsonDecode(frame.body!)).unreadCnt;
                      }
                      talk[talk.indexWhere(
                                  (element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                              .nextCursor =
                          Talk.fromJson(jsonDecode(frame.body!)).nextCursor;
                    } else {
                      if (talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) ==
                          -1) {
                        talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                        add(ChatDetailReloadEvent());
                      }
                    }

                    for (int i = 0; i < talk.length; i++) {
                      if (!date.contains(talk[i].createDate.yearMonthDay) &&
                          talk[i].type != 'EVENT') {
                        date.add(talk[i].createDate.yearMonthDay);
                      }
                    }
                    List<String> talkBackUp =
                        talk.map((e) => jsonEncode(e.toMap())).toList();
                    await prefs!
                        .setString(chatRoomUuid!, jsonEncode(talkBackUp));

                    if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                        dataSaver.userData!.memberUuid) {
                      add(ReadMessageEvent());
                    } else {
                      add(ReloadChatDetailEvent());
                    }
                  } else {
                    if (talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid) ==
                        -1) {
                      talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                      add(ChatDetailReloadEvent());
                    }
                    if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                        dataSaver.userData!.memberUuid) {
                      add(ReadMessageEvent());
                    } else {
                      add(ReloadChatDetailEvent());
                    }
                  }
                });
          }

          if (readSubscribe == null) {
            readSubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/read/$chatRoomUuid',
                callback: (frame) async {
                  List<dynamic> removeFcmId = [];
                  removeFcmId.addAll(
                      (jsonDecode(frame.body!)['fcmMessageIds']).toList());
                  for (int i = 0; i < removeFcmId.length; i++) {
                    flutterLocalNotificationsPlugin!
                        .cancel(int.parse(removeFcmId[i].toString()));
                  }
                  add(ReadUpdateEvent(
                      msgUuid:
                          (jsonDecode(frame.body!)['chatRoomMessageUuids']),
                      sendUuid: (jsonDecode(frame.body!)['sendUuids']),
                      talk: talk));
                });
          }
          stompClient.send(
              destination: '/app/chat/room/message',
              body: jsonEncode(talkSend.toMap()),
              headers: {'memberUuid': dataSaver.userData!.memberUuid});
        }

        loading = false;
        yield SendMessageState();
      }
    }

    if (event is ReadMessageEvent) {
      stompClient.send(
          destination: '/app/chat/room/read',
          body: jsonEncode({
            'chatRoomUuid': chatRoomUuid!,
            'memberUuid': dataSaver.userData!.memberUuid,
            'seq': dataSaver.chatRoom == null
                ? seq
                : dataSaver.chatRoom!.roomData.indexWhere((element) =>
                            element.chatRoomUuid == chatRoomUuid) ==
                        -1
                    ? seq
                      : dataSaver
                        .chatRoom!
                        .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                            (element) => element.chatRoomUuid == chatRoomUuid)]
                        .seq
          }),
          headers: {'memberUuid': dataSaver.userData!.memberUuid});
      yield ReadMessageState();
    }

    if (event is ReadUpdateEvent) {
      for (int i = 0; i < event.msgUuid.length; i++) {
        if (event.talk.lastIndexWhere(
                (element) => element.chatRoomMessageUuid == event.msgUuid[i]) !=
            -1) {
          event
              .talk[event.talk.lastIndexWhere(
                  (element) => element.chatRoomMessageUuid == event.msgUuid[i])]
              .unreadCnt = -1;
        } else {
          if (event.talk.lastIndexWhere(
                  (element) => element.sendUuid == event.sendUuid[i]) !=
              -1) {
            event
                .talk[event.talk.lastIndexWhere(
                    (element) => element.sendUuid == event.sendUuid[i])]
                .unreadCnt = -1;
          }
        }
        if (date.isEmpty) {
          return;
        }
        talkData = event.talk
            .where((element) =>
                element.createDate.yearMonthDay ==
                date[date.lastIndexWhere(
                    (e) => e == element.createDate.yearMonthDay)])
            .toList();
        talkData.sort((a, b) => a.createDate.compareTo(b.createDate));
        if (talkData.lastIndexWhere(
                (element) => element.chatRoomMessageUuid == event.msgUuid[i]) !=
            -1) {
          talkData[talkData.lastIndexWhere(
                  (element) => element.chatRoomMessageUuid == event.msgUuid[i])]
              .unreadCnt = -1;
        } else {
          if (talkData.lastIndexWhere(
                  (element) => element.sendUuid == event.sendUuid[i]) !=
              -1) {
            talkData[talkData.lastIndexWhere(
                    (element) => element.sendUuid == event.sendUuid[i])]
                .unreadCnt = -1;
          }
        }
        List<String> talkBackUp =
            event.talk.map((e) => jsonEncode(e.toMap())).toList();
        await prefs!.setString(chatRoomUuid!, jsonEncode(talkBackUp));
      }
      yield ReadUpdateState(msgUuid: event.msgUuid);
    }

    if (event is ReloadChatDetailEvent) {
      if (event.save) {
        List<String> talkBackUp =
            talk.map((e) => jsonEncode(e.toMap())).toList();
        await prefs!.setString(chatRoomUuid!, jsonEncode(talkBackUp));
      }
      yield ReloadChatDetailState();
    }

    if (event is GetDataEvent) {
      if (talk.length >= nextData * 40) {
        // yield CheckState();

        ReturnData returnData = await ChatRepository.getMessageListService(
            chatRoomUuid!,
            nextCursor: talk.first.nextCursor);

        if (returnData.code == 1) {
          talk.insertAll(
              0,
              (returnData.data['list'] as List)
                  .map((e) => Talk.fromJson(e))
                  .toList());

          for (int i = 0; i < talk.length; i++) {
            if (!date.contains(talk[i].createDate.yearMonthDay) &&
                talk[i].type != 'EVENT') {
              date.add(talk[i].createDate.yearMonthDay);
            }
          }

          date.sort();

          List<String> talkBackUp =
              talk.map((e) => jsonEncode(e.toMap())).toList();
          await prefs!.setString(chatRoomUuid!, jsonEncode(talkBackUp));

          nextData += 1;

          yield GetDataState();
          // add(GetDataEvent());
        } else {
          yield ErrorState();
        }
      }
    }

    if (event is SendFileEvent) {
      loading = true;
      yield LoadingState();

      if ((classUuid != null && classCheck) ||
          (communityUuid != null && communityCheck)) {
        ReturnData returnData = await ChatRepository.chatOpen(
            classCheck: classCheck,
            communityCheck: communityCheck,
            classUuid: classUuid,
            communityUuid: communityUuid,
            introFlag: 1);

        if (returnData.code == 1) {
          // 채팅 보내기
          chatRoomUuid = returnData.data['chatRoomUuid'];
          seq = returnData.data['seq'];
          status = returnData.data['status'];
          roomData = RoomDatas.fromJson(returnData.data);
          classUuid = null;

          dataSaver.chatRoomUuid = chatRoomUuid;

          if (chatSubscribe == null)
            chatSubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/message/$chatRoomUuid',
                callback: (frame) async {
                  if (frame.body != null &&
                      talk.length != 0 &&
                      talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) !=
                          -1) {
                    if (frame.body != null &&
                        Talk.fromJson(jsonDecode(frame.body!)).type ==
                            'NOTICE') {
                      talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                      add(ChatDetailReloadEvent());
                    }
                    if (talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .memberUuid ==
                        dataSaver.userData!.memberUuid) {
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .loading = false;
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .send = true;
                      talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .chatRoomMessageUuid = Talk.fromJson(
                              jsonDecode(frame.body!))
                          .chatRoomMessageUuid;
                      talk[talk.indexWhere(
                                  (element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                              .createDate =
                          Talk.fromJson(jsonDecode(frame.body!)).createDate;
                      if (talk[talk.indexWhere((element) =>
                                  element.sendUuid ==
                                  Talk.fromJson(jsonDecode(frame.body!))
                                      .sendUuid)]
                              .unreadCnt >
                          Talk.fromJson(jsonDecode(frame.body!)).unreadCnt) {
                        talk[talk.indexWhere((element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                                .unreadCnt =
                            Talk.fromJson(jsonDecode(frame.body!)).unreadCnt;
                      }
                      talk[talk.indexWhere(
                                  (element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                              .nextCursor =
                          Talk.fromJson(jsonDecode(frame.body!)).nextCursor;
                    } else {
                      if (talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!))
                                  .sendUuid) ==
                          -1) {
                        talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                        add(ChatDetailReloadEvent());
                      }
                    }

                    for (int i = 0; i < talk.length; i++) {
                      if (!date.contains(talk[i].createDate.yearMonthDay) &&
                          talk[i].type != 'EVENT') {
                        date.add(talk[i].createDate.yearMonthDay);
                      }
                    }
                    List<String> talkBackUp =
                        talk.map((e) => jsonEncode(e.toMap())).toList();
                    await prefs!
                        .setString(chatRoomUuid!, jsonEncode(talkBackUp));

                    if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                        dataSaver.userData!.memberUuid) {
                      add(ReadMessageEvent());
                    } else {
                      add(ReloadChatDetailEvent());
                    }
                  } else {
                    if (talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid) ==
                        -1) {
                      talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                      add(ChatDetailReloadEvent());
                    }
                    if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                        dataSaver.userData!.memberUuid) {
                      add(ReadMessageEvent());
                    } else {
                      add(ReloadChatDetailEvent());
                    }
                  }
                });
          if (readSubscribe == null) {
            readSubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/read/$chatRoomUuid',
                callback: (frame) async {
                  List<dynamic> removeFcmId = [];
                  removeFcmId.addAll(
                      (jsonDecode(frame.body!)['fcmMessageIds']).toList());
                  for (int i = 0; i < removeFcmId.length; i++) {
                    flutterLocalNotificationsPlugin!
                        .cancel(int.parse(removeFcmId[i].toString()));
                  }
                  add(ReadUpdateEvent(
                      msgUuid:
                          (jsonDecode(frame.body!)['chatRoomMessageUuids']),
                      sendUuid: (jsonDecode(frame.body!)['sendUuids']),
                      talk: talk));
                });
          }
          members = (returnData.data['members'] as List)
              .map((e) => Members.fromJson(e))
              .toList();
          Member member = Member(
              memberUuid: dataSaver.userData!.memberUuid,
              nickName: members[members.indexWhere((element) =>
                      element.member.memberUuid ==
                      dataSaver.userData!.memberUuid)]
                  .member
                  .nickName,
              phone: '',
              profile: members[members.indexWhere((element) =>
                      element.member.memberUuid ==
                      dataSaver.userData!.memberUuid)]
                  .member
                  .profile);
          List<Data> data = await ImageMultipleUploadService(
                  imageFiles: event.files,
                  image: event.type == '앨범' ? true : false)
              .start();
          TalkSend talkSend = TalkSend(
              chatRoomUuid: chatRoomUuid!,
              type: type,
              nickName: member.nickName,
              profile: member.profile,
              sendUuid: Uuid().v1(),
              files: data.map((e) => e.toMap()).toList(),
              memberUuid: dataSaver.userData!.memberUuid,
              seq: dataSaver.chatRoom == null
                  ? seq
                  : dataSaver.chatRoom!.roomData.indexWhere((element) =>
                              element.chatRoomUuid == chatRoomUuid) ==
                          -1
                      ? seq
                      : dataSaver
                          .chatRoom!
                          .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                              (element) =>
                                  element.chatRoomUuid == chatRoomUuid)]
                          .seq,
              sendDate: DateTime.now());

          stompClient.send(
              destination: '/app/chat/room/message',
              body: jsonEncode(talkSend.toMap()),
              headers: {'memberUuid': dataSaver.userData!.memberUuid});
          loading = false;
          yield SendMessageState();
        } else {
          loading = false;
          yield ErrorState();
        }
      } else {
        Member member = Member(
            memberUuid: dataSaver.userData!.memberUuid,
            nickName: members[members.indexWhere((element) =>
                    element.member.memberUuid ==
                    dataSaver.userData!.memberUuid)]
                .member
                .nickName,
            phone: '',
            profile: members[members.indexWhere((element) =>
                    element.member.memberUuid ==
                    dataSaver.userData!.memberUuid)]
                .member
                .profile);
        if (event.files.length == 1) {
          int sizeInBytes = event.files.first.lengthSync();
          double sizeInMb = sizeInBytes / (1024 * 1024);
          if (sizeInMb > 10) {
            loading = false;
            yield FileSizeOverState();
            return;
          }
        }
        ImageMultipleUploadService(
                imageFiles: event.files,
                image: event.type == '앨범' ? true : false)
            .start()
            .then((value) {
          List<Data> data = value;
          TalkSend talkSend = TalkSend(
              chatRoomUuid: chatRoomUuid!,
              type: 'FILE',
              nickName: member.nickName,
              profile: member.profile,
              sendUuid: Uuid().v1(),
              files: data.map((e) => e.toMap()).toList(),
              memberUuid: dataSaver.userData!.memberUuid,
              seq: dataSaver.chatRoom == null
                  ? seq
                  : dataSaver.chatRoom!.roomData.indexWhere((element) =>
                              element.chatRoomUuid == chatRoomUuid) ==
                          -1
                      ? seq
                      : dataSaver
                          .chatRoom!
                          .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                              (element) =>
                                  element.chatRoomUuid == chatRoomUuid)]
                          .seq,
              sendDate: DateTime.now());
          stompClient.send(
              destination: '/app/chat/room/message',
              body: jsonEncode(talkSend.toMap()),
              headers: {'memberUuid': dataSaver.userData!.memberUuid});
        });
      }
      loading = false;
      yield SendFileState();
    }

    if (event is SettingControlEvent) {
      settingOpen = event.control;
      yield SettingControlState();
    }

    if (event is ReceiveEvent) {
      loading = true;
      yield LoadingState();

      ReturnData receiveData = await ChatRepository.chatReceive(
          chatRoomUuid!, event.noticeReceiveFlag);

      if (receiveData.code == 1) {
        members[members.indexWhere((element) =>
                element.member.memberUuid == dataSaver.userData!.memberUuid)]
            .noticeReceiveFlag = members[members.indexWhere((element) =>
                        element.member.memberUuid ==
                        dataSaver.userData!.memberUuid)]
                    .noticeReceiveFlag ==
                1
            ? 0
            : 1;
        dataSaver
            .chatRoom!
            .roomData[dataSaver.chatRoom!.roomData
                .indexWhere((element) => element.chatRoomUuid == chatRoomUuid!)]
            .noticeReceiveFlag = members[members.indexWhere((element) =>
                element.member.memberUuid == dataSaver.userData!.memberUuid)]
            .noticeReceiveFlag;
        dataSaver.chatBloc!.add(ChatReloadEvent());
        loading = false;
        yield ReceiveState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is ExitEvent) {
      loading = true;
      yield LoadingState();

      ReturnData exit = await ChatRepository.chatExit(chatRoomUuid!);

      if (exit.code == 1) {
        await prefs!.remove(chatRoomUuid!);

        loading = false;
        yield ExitState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is ExitBlockEvent) {
      loading = true;
      yield LoadingState();

      ReturnData exit = await ChatRepository.chatBlock(chatRoomUuid!);

      if (exit.code == 1) {
        await prefs!.remove(chatRoomUuid!);

        loading = false;
        yield ExitBlockState();
      } else {
        loading = false;
        yield ErrorState();
      }
    }

    if (event is ChatDetailLoadingEndEvent) {
      loading = false;
      yield ChatDetailLoadingEndState();
    }

    if (event is ChatReadSubscribeEvent) {
      if (readSubscribe == null) {
        readSubscribe = stompClient.subscribe(
            destination: '/topic/chat/room/read/$chatRoomUuid',
            callback: (frame) async {
              List<dynamic> removeFcmId = [];
              removeFcmId
                  .addAll((jsonDecode(frame.body!)['fcmMessageIds']).toList());
              for (int i = 0; i < removeFcmId.length; i++) {
                flutterLocalNotificationsPlugin!
                    .cancel(int.parse(removeFcmId[i].toString()));
              }
              flutterLocalNotificationsPlugin!
                  .cancel(jsonDecode(frame.body!)['seq']);
              add(ReadUpdateEvent(
                  msgUuid: (jsonDecode(frame.body!)['chatRoomMessageUuids']),
                  sendUuid: (jsonDecode(frame.body!)['sendUuids']),
                  talk: talk));
            });
      }
      yield ChatReadSubscribeState();
    }

    if (event is ChatCacheSendEvent) {
      if (prefs!.getString('cacheTalk') != null) {
        cacheTalkData.addAll(
            (jsonDecode(prefs!.getString('cacheTalk')!) as List)
                .map((e) => TalkSend.fromJson(e))
                .toList());
        for (int i = 0; i < cacheTalkData.length; i++) {
          if (talk.indexWhere((element) =>
                  element.sendUuid == cacheTalkData[i].sendUuid &&
                  element.send == false) !=
              -1) {
            cacheTalkData[i].sendDate = DateTime.now();
            stompClient.send(
                destination: '/app/chat/room/message',
                body: jsonEncode(cacheTalkData[i].toMap()),
                headers: {'memberUuid': dataSaver.userData!.memberUuid});
            talk[talk.indexWhere((element) =>
                    element.sendUuid == cacheTalkData[i].sendUuid &&
                    element.send == false)]
                .send = true;
            cacheTalkData.removeAt(i);
            await prefs!.setString('cacheTalk',
                jsonEncode(cacheTalkData.map((e) => e.toMap()).toList()));
          } else {
            cacheTalkData.removeAt(i);
            await prefs!.setString('cacheTalk',
                jsonEncode(cacheTalkData.map((e) => e.toMap()).toList()));
          }
        }
      }

      if (prefs!.getString('cacheTalk') == null ||
          prefs!.getString('cacheTalk') == '[]') {
        while (true) {
          if (talk.indexWhere((element) => element.chatRoomMessageUuid == '') !=
              -1) {
            talk.removeAt(talk
                .indexWhere((element) => element.chatRoomMessageUuid == ''));
          } else {
            break;
          }
        }
      }
      yield ChatCacheSendState();
    }

    if (event is ChatReSendEvent) {
      loading = true;
      yield LoadingState();

      Member member = Member(
          memberUuid: dataSaver.userData!.memberUuid,
          nickName: dataSaver.profileGet!.nickName,
          phone: '',
          profile: dataSaver.profileGet!.profile);

      TalkSend talkSend = TalkSend(
          chatRoomUuid: chatRoomUuid!,
          type: type,
          nickName: member.nickName,
          profile: member.profile,
          message: event.talkData.message,
          sendUuid: event.talkData.sendUuid!,
          memberUuid: dataSaver.userData!.memberUuid,
          seq: dataSaver.chatRoom == null
              ? seq
              : dataSaver.chatRoom!.roomData.indexWhere(
                          (element) => element.chatRoomUuid == chatRoomUuid) ==
                      -1
                  ? seq
                  : dataSaver
                      .chatRoom!
                      .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                          (element) => element.chatRoomUuid == chatRoomUuid)]
                      .seq,
          sendDate: DateTime.now());

      cacheTalkData.add(talkSend);
      await prefs!.setString('cacheTalk',
          jsonEncode(cacheTalkData.map((e) => e.toMap()).toList()));

      talk[talk.indexWhere(
              (element) => element.sendUuid == event.talkData.sendUuid)]
          .loading = true;
      talk[talk.indexWhere(
              (element) => element.sendUuid == event.talkData.sendUuid)]
          .send = false;
      talk[talk.indexWhere(
              (element) => element.sendUuid == event.talkData.sendUuid)]
          .status = null;

      talkData[talkData.indexWhere(
              (element) => element.sendUuid == event.talkData.sendUuid)]
          .loading = true;
      talkData[talkData.indexWhere(
              (element) => element.sendUuid == event.talkData.sendUuid)]
          .send = false;
      talkData[talkData.indexWhere(
              (element) => element.sendUuid == event.talkData.sendUuid)]
          .status = null;
      add(ChatDetailReloadEvent());

      if (!networkNone && stompClient.connected) {
        if (chatSubscribe == null) {
          chatSubscribe = stompClient.subscribe(
              destination: '/topic/chat/room/message/$chatRoomUuid',
              callback: (frame) async {
                if (frame.body != null &&
                    talk.length != 0 &&
                    talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid) !=
                        -1) {
                  if (talk[talk.indexWhere((element) =>
                              element.sendUuid ==
                              Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                          .memberUuid ==
                      dataSaver.userData!.memberUuid) {
                    talk[talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                        .loading = false;
                    talk[talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                        .send = true;
                    talk[talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid)]
                        .chatRoomMessageUuid = Talk.fromJson(
                            jsonDecode(frame.body!))
                        .chatRoomMessageUuid;
                    talk[talk.indexWhere(
                                (element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                            .createDate =
                        Talk.fromJson(jsonDecode(frame.body!)).createDate;
                    if (talk[talk.indexWhere((element) =>
                                element.sendUuid ==
                                Talk.fromJson(jsonDecode(frame.body!))
                                    .sendUuid)]
                            .unreadCnt >
                        Talk.fromJson(jsonDecode(frame.body!)).unreadCnt) {
                      talk[talk.indexWhere(
                                  (element) =>
                                      element.sendUuid ==
                                      Talk.fromJson(jsonDecode(frame.body!))
                                          .sendUuid)]
                              .unreadCnt =
                          Talk.fromJson(jsonDecode(frame.body!)).unreadCnt;
                    }
                    talk[talk.indexWhere(
                                (element) =>
                                    element.sendUuid ==
                                    Talk.fromJson(jsonDecode(frame.body!))
                                        .sendUuid)]
                            .nextCursor =
                        Talk.fromJson(jsonDecode(frame.body!)).nextCursor;
                    add(ChatDetailReloadEvent());
                  } else {
                    if (talk.indexWhere((element) =>
                            element.sendUuid ==
                            Talk.fromJson(jsonDecode(frame.body!)).sendUuid) ==
                        -1) {
                      talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                      add(ChatDetailReloadEvent());
                    }
                  }

                  for (int i = 0; i < talk.length; i++) {
                    if (!date.contains(talk[i].createDate.yearMonthDay) &&
                        talk[i].type != 'EVENT') {
                      date.add(talk[i].createDate.yearMonthDay);
                    }
                  }
                  List<String> talkBackUp =
                      talk.map((e) => jsonEncode(e.toMap())).toList();
                  await prefs!.setString(chatRoomUuid!, jsonEncode(talkBackUp));

                  if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                      dataSaver.userData!.memberUuid) {
                    add(ReadMessageEvent());
                  } else {
                    add(ReloadChatDetailEvent());
                  }
                } else {
                  if (talk.indexWhere((element) =>
                          element.sendUuid ==
                          Talk.fromJson(jsonDecode(frame.body!)).sendUuid) ==
                      -1) {
                    talk.add(Talk.fromJson(jsonDecode(frame.body!)));
                    add(ChatDetailReloadEvent());
                  }
                  if (Talk.fromJson(jsonDecode(frame.body!)).memberUuid !=
                      dataSaver.userData!.memberUuid) {
                    add(ReadMessageEvent());
                  } else {
                    add(ReloadChatDetailEvent());
                  }
                }
              });
        }

        if (readSubscribe == null) {
          readSubscribe = stompClient.subscribe(
              destination: '/topic/chat/room/read/$chatRoomUuid',
              callback: (frame) async {
                List<dynamic> removeFcmId = [];
                removeFcmId.addAll(
                    (jsonDecode(frame.body!)['fcmMessageIds']).toList());
                for (int i = 0; i < removeFcmId.length; i++) {
                  flutterLocalNotificationsPlugin!
                      .cancel(int.parse(removeFcmId[i].toString()));
                }
                add(ReadUpdateEvent(
                    msgUuid: (jsonDecode(frame.body!)['chatRoomMessageUuids']),
                    sendUuid: (jsonDecode(frame.body!)['sendUuids']),
                    talk: talk));
              });
        }
        stompClient.send(
            destination: '/app/chat/room/message',
            body: jsonEncode(talkSend.toMap()),
            headers: {'memberUuid': dataSaver.userData!.memberUuid});
      }

      loading = true;
      yield ChatReSendState();
    }

    if (event is ChatRemoveEvent) {
      talk.removeAt(talk.indexWhere(
          (element) => element.sendUuid == event.talkData.sendUuid));
      talkData.removeAt(talkData.indexWhere(
          (element) => element.sendUuid == event.talkData.sendUuid));

      List<String> talkBackUp = talk.map((e) => jsonEncode(e.toMap())).toList();
      await prefs!.setString(chatRoomUuid!, jsonEncode(talkBackUp));

      yield ChatRemoveState();
    }
  }
}

class ChatDetailReloadEvent extends BaseBlocEvent {}

class ChatDetailReloadState extends BaseBlocState {}

class ChatReSendEvent extends BaseBlocEvent {
  final Talk talkData;

  ChatReSendEvent({required this.talkData});
}

class ChatReSendState extends BaseBlocState {}

class ChatRemoveEvent extends BaseBlocEvent {
  final Talk talkData;

  ChatRemoveEvent({required this.talkData});
}

class ChatRemoveState extends BaseBlocState {}

class ChatCacheSendEvent extends BaseBlocEvent {}

class ChatCacheSendState extends BaseBlocState {}

class ChatReadSubscribeEvent extends BaseBlocEvent {}

class ChatReadSubscribeState extends BaseBlocState {}

class ChatDetailLoadingEndEvent extends BaseBlocEvent {}

class ChatDetailLoadingEndState extends BaseBlocState {}

class ChatDetailBlocSetState extends BaseBlocState {}

class FileSizeOverState extends BaseBlocState {}

class ExitEvent extends BaseBlocEvent {}

class ExitState extends BaseBlocState {}

class ExitBlockEvent extends BaseBlocEvent {}

class ExitBlockState extends BaseBlocState {}

class ReceiveEvent extends BaseBlocEvent {
  final int noticeReceiveFlag;

  ReceiveEvent({required this.noticeReceiveFlag});
}

class ReceiveState extends BaseBlocState {}

class SettingControlEvent extends BaseBlocEvent {
  final bool control;

  SettingControlEvent({required this.control});
}

class SettingControlState extends BaseBlocState {}

class SendFileEvent extends BaseBlocEvent {
  final String type;
  final List<File> files;

  SendFileEvent({required this.type, required this.files});
}

class SendFileState extends BaseBlocState {}

class GetDataEvent extends BaseBlocEvent {}

class GetDataState extends BaseBlocState {}

class ReloadChatDetailEvent extends BaseBlocEvent {
  final bool save;

  ReloadChatDetailEvent({this.save = false});
}

class ReloadChatDetailState extends BaseBlocState {}

class ReadUpdateEvent extends BaseBlocEvent {
  final List<dynamic> msgUuid;
  final List<dynamic> sendUuid;
  final List<Talk> talk;

  ReadUpdateEvent(
      {required this.msgUuid, required this.sendUuid, required this.talk});
}

class ReadUpdateState extends BaseBlocState {
  final List<dynamic> msgUuid;

  ReadUpdateState({required this.msgUuid});
}

class ReadMessageEvent extends BaseBlocEvent {}

class ReadMessageState extends BaseBlocState {}

class SendMessageEvent extends BaseBlocEvent {
  final String msg;
  final String? subType;

  SendMessageEvent({required this.msg, this.subType});
}

class SendMessageState extends BaseBlocState {}

class MenuOpenEvent extends BaseBlocEvent {}

class MenuOpenState extends BaseBlocState {}

class ChatDetailInitEvent extends BaseBlocEvent {
  final String? chatRoomUuid;
  final String? classUuid;
  final String? communityUuid;
  final bool classCheck;
  final bool communityCheck;
  final bool reConnect;

  ChatDetailInitEvent(
      {this.chatRoomUuid,
      this.classUuid,
      this.communityUuid,
      this.reConnect = false,
      this.classCheck = false,
      this.communityCheck = false});
}

class ChatDetailInitState extends BaseBlocState {
  final bool unread;

  ChatDetailInitState({this.unread = false});
}

class BaseChatDetailState extends BaseBlocState {}
