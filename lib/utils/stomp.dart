import 'dart:async';

import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/chat/chat_room.dart';
import 'package:baeit/data/signup/signup.dart';
import 'package:baeit/ui/chat/chat_bloc.dart';
import 'package:baeit/ui/chat/chat_detail_bloc.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:uuid/uuid.dart';

import 'data_saver.dart';

Timer? errorTimer;
Timer? disconnectTimer;
Timer? connectTimer;

final stompClient = StompClient(
    config: StompConfig(
        url: baseChatUrl,
        // url: 'ws://13.125.135.172:48081/chat',
        heartbeatIncoming: Duration(milliseconds: 10000),
        heartbeatOutgoing: Duration(milliseconds: 10000),
        stompConnectHeaders: {
          'Connection': 'upgrade',
          'Upgrade': 'websocket',
          'Sec-WebSocket-Key': Uuid().v1()
        },
        webSocketConnectHeaders: {
          'Connection': 'upgrade',
          'Upgrade': 'websocket',
          'Sec-WebSocket-Key': Uuid().v1()
        },
        onStompError: (error) {
          debugPrint("StompError : $error");
        },
        onConnect: (StompFrame frame) async {
          if (prefs != null &&
              prefs!.getString('userData').toString() != 'null') {
            UserData userData = UserData.fromJson(
                jsonDecode(prefs!.getString('userData').toString()));
            dataSaver.connectStomp = true;

            dataSaver.unsubscribe = stompClient.subscribe(
                destination: '/topic/chat/room/${userData.memberUuid}',
                callback: (frame) async {
                  dataSaver.chatRoom = null;
                  dataSaver.chatRoom =
                      ChatRoom.fromJson(jsonDecode(frame.body!));

                  if (dataSaver.chatRoom != null) {
                    if (dataSaver.chatRoom!.roomData.indexWhere(
                            (element) => element.chatRoomMember == null) !=
                        -1) {
                      int removeIndex = dataSaver.chatRoom!.roomData.indexWhere(
                              (element) => element.chatRoomMember == null) +
                          1;
                      for (int i = 0; i < removeIndex; i++) {
                        dataSaver.chatRoom!.roomData.removeAt(
                            dataSaver.chatRoom!.roomData.indexWhere(
                                (element) => element.chatRoomMember == null));
                      }
                    }
                    await prefs!.setString(
                        'chatData', jsonEncode(dataSaver.chatRoom!.toMap()));
                    await prefs!.reload();
                  }

                  if (connectTimer != null) {
                    connectTimer!.cancel();
                    connectTimer = null;
                  }
                  if (dataSaver.mainBloc != null) {
                    dataSaver.mainBloc!.add(ChatCountReloadEvent());
                  }
                  if (dataSaver.chatBloc != null) {
                    dataSaver.chatBloc!.add(ChatReloadEvent());
                  }
                });

            Map<String, dynamic> data = {};
            data.addAll({'memberUuid': userData.memberUuid});
            if (connectTimer == null) {
              connectTimer =
                  Timer.periodic(Duration(milliseconds: 2000), (timer) {
                if (dataSaver.chatRoom != null) {
                  if (connectTimer != null) {
                    connectTimer!.cancel();
                    connectTimer = null;
                  }
                }
                if (stompClient.connected) {
                  stompClient.send(
                      destination: '/app/chat/room', body: jsonEncode(data));
                }
              });
            }

            if (dataSaver.chatDetailBloc != null) {
              dataSaver.chatDetailBloc!.add(ChatDetailInitEvent(
                  chatRoomUuid: dataSaver.chatDetailBloc!.chatRoomUuid,
                  classUuid: dataSaver.chatDetailBloc!.classUuid));
              dataSaver.chatDetailBloc!.add(ChatDetailLoadingEndEvent());
            }
            debugPrint("StompConnect");
          }
        },
        onDebugMessage: (msg) {
          // debugPrint("DebugMessage : $msg");
        },
        onWebSocketError: (error) {
          if (errorTimer == null) {
            if (dataSaver.readSubscribe != null) {
              dataSaver.readSubscribe();
              dataSaver.readSubscribe = null;
            }
            if (dataSaver.chatSubscribe != null) {
              dataSaver.chatSubscribe();
              dataSaver.chatSubscribe = null;
            }

            errorTimer = Timer.periodic(Duration(milliseconds: 2000), (timer) {
              if (!stompClient.connected) {
                if (errorTimer != null) {
                  errorTimer!.cancel();
                  errorTimer = null;
                }
                stompClient.activate();
              }
            });
          }
          debugPrint("WebSocketError : $error");
        },
        onDisconnect: (disconnect) {
          // if (disconnectTimer == null && !stompClient.connected) {
          //   disconnectTimer =
          //       Timer.periodic(Duration(milliseconds: 2000), (timer) {
          //     if (!stompClient.connected) {
          //       if (disconnectTimer != null) {
          //         disconnectTimer!.cancel();
          //         disconnectTimer = null;
          //       }
          //       stompClient.activate();
          //     }
          //   });
          // }
          debugPrint("StompDisConnect");
        }));
