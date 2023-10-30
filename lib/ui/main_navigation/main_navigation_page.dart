// import 'dart:async';
// import 'dart:isolate';
// import 'dart:ui';
//
// import 'package:baeit/config/base_bloc.dart';
// import 'package:baeit/config/base_service.dart';
// import 'package:baeit/config/common.dart';
// import 'package:baeit/config/push_config.dart';
// import 'package:baeit/data/common/repository/common_repository.dart';
// import 'package:baeit/data/common/return_data.dart';
// import 'package:baeit/data/neighborhood/neighborhood_list.dart';
// import 'package:baeit/data/neighborhood/repository/neighborhood_select_repository.dart';
// import 'package:baeit/resource/app_colors.dart';
// import 'package:baeit/resource/app_images.dart';
// import 'package:baeit/resource/app_strings.dart';
// import 'package:baeit/resource/app_text_style.dart';
// import 'package:baeit/ui/chat/chat_detail_page.dart';
// import 'package:baeit/ui/chat/chat_page.dart';
// import 'package:baeit/ui/class_detail/class_detail_page.dart';
// import 'package:baeit/ui/feedback/feedback_detail_page.dart';
// import 'package:baeit/ui/main_navigation/main_navigation_bloc.dart';
// import 'package:baeit/ui/my_baeit/my_baeit_page.dart';
// import 'package:baeit/ui/neighborhood_class/neighborhood_class_bloc.dart';
// import 'package:baeit/ui/neighborhood_class/neighborhood_class_page.dart';
// import 'package:baeit/ui/notice/notice_detail_page.dart';
// import 'package:baeit/ui/notification/notification_page.dart';
// import 'package:baeit/ui/request_class/request_class_bloc.dart';
// import 'package:baeit/ui/request_class/request_class_page.dart';
// import 'package:baeit/ui/request_detail/request_detail_page.dart';
// import 'package:baeit/ui/splash/splash_page.dart';
// import 'package:baeit/utils/data_saver.dart';
// import 'package:baeit/utils/event.dart';
// import 'package:baeit/utils/page_move.dart';
// import 'package:baeit/widgets/line.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:uni_links/uni_links.dart';
//
// class MainNavigationPage extends BlocStatefulWidget {
//   final List<NeighborHood>? neighborHood;
//   final int? viewIndex;
//   final bool keyword;
//
//   MainNavigationPage({this.neighborHood, this.viewIndex, this.keyword = false});
//
//   @override
//   BlocState<BaseBloc, BlocStatefulWidget> buildState() {
//     return MainNavigationState();
//   }
// }
//
// class MainNavigationState
//     extends BlocState<MainNavigationBloc, MainNavigationPage> {
//   setView() {
//     switch (bloc.viewIndex) {
//       case 0:
//         return NeighborHoodClassPage(
//             navigationBloc: bloc, keyword: widget.keyword);
//       case 1:
//         return RequestClassPage(navigationBloc: bloc, keyword: widget.keyword);
//       case 2:
//         return ChatPage();
//       case 3:
//         // return MyBaeitPage(mainNavigationBloc: bloc);
//     }
//   }
//
//   @override
//   Widget blocBuilder(BuildContext context, state) {
//     return BlocBuilder(
//         bloc: bloc,
//         builder: (context, state) {
//           return Container(
//             color: AppColors.white,
//             child: SafeArea(
//               child: Scaffold(
//                 backgroundColor: AppColors.white,
//                 bottomNavigationBar: bloc.bottomView
//                     ? SizedBox(
//                         height: 60,
//                         child: Column(
//                           children: [
//                             heightLine(color: AppColors.gray100, height: 1),
//                             SizedBox(
//                               height: 59,
//                               child: BottomNavigationBar(
//                                 currentIndex: bloc.viewIndex,
//                                 type: BottomNavigationBarType.fixed,
//                                 backgroundColor: AppColors.white,
//                                 elevation: 0,
//                                 enableFeedback: false,
//                                 selectedItemColor: AppColors.primary,
//                                 unselectedItemColor: AppColors.greenGray200,
//                                 selectedLabelStyle: TextStyle(
//                                     color: AppColors.primary,
//                                     fontWeight: weightSet(
//                                         textWeight: TextWeight.MEDIUM),
//                                     fontSize:
//                                         fontSizeSet(textSize: TextSize.T10)),
//                                 unselectedLabelStyle: TextStyle(
//                                     color: AppColors.greenGray200,
//                                     fontWeight: weightSet(
//                                         textWeight: TextWeight.MEDIUM),
//                                     fontSize:
//                                         fontSizeSet(textSize: TextSize.T10)),
//                                 onTap: (index) {
//                                   if (bloc.viewIndex != index) {
//                                     String view = '';
//
//                                     if (index == 0) {
//                                       view = 'class';
//                                     } else if (index == 1) {
//                                       view = 'request';
//                                     } else if (index == 2) {
//                                       view = 'chat';
//                                     } else if (index == 3) {
//                                       view = 'my_baeit';
//                                     }
//
//                                     amplitudeEvent('change_view', {'view': view});
//
//                                     bloc.add(ChangeViewEvent(viewIndex: index));
//                                   } else {
//                                     if (bloc.viewIndex == 0 &&
//                                         dataSaver.classBloc != null) {
//                                       dataSaver.classBloc!.add(ScrollUpEvent());
//                                     } else if (bloc.viewIndex == 1 &&
//                                         dataSaver.requestBloc != null) {
//                                       dataSaver.requestBloc!
//                                           .add(ScrollUpRequestEvent());
//                                     }
//                                   }
//                                 },
//                                 items: [
//                                   BottomNavigationBarItem(
//                                       icon: Image.asset(AppImages.iNavFindOff,
//                                           width: 24, height: 24),
//                                       activeIcon: Image.asset(
//                                           AppImages.iNavFindOn,
//                                           width: 24,
//                                           height: 24),
//                                       label: AppStrings.of(
//                                           StringKey.neighborhoodClass)),
//                                   BottomNavigationBarItem(
//                                       icon: Image.asset(
//                                           AppImages.iNavRequestOff,
//                                           width: 24,
//                                           height: 24),
//                                       activeIcon: Image.asset(
//                                           AppImages.iNavRequestOn,
//                                           width: 24,
//                                           height: 24),
//                                       label: AppStrings.of(
//                                           StringKey.requestClass)),
//                                   BottomNavigationBarItem(
//                                       icon: Stack(
//                                         children: [
//                                           Image.asset(AppImages.iNavChatOff,
//                                               width: 24, height: 24),
//                                           dataSaver.chatRoom == null
//                                               ? Positioned(
//                                                   top: 0,
//                                                   right: 0,
//                                                   child: Container())
//                                               : dataSaver.chatRoom!
//                                                           .totalUnreadCnt ==
//                                                       0
//                                                   ? Positioned(
//                                                       top: 0,
//                                                       right: 0,
//                                                       child: Container())
//                                                   : Positioned(
//                                                       top: 0,
//                                                       right: 0,
//                                                       child: Align(
//                                                         widthFactor: 0.5,
//                                                         heightFactor: 0.5,
//                                                         child: Container(
//                                                           height: 16,
//                                                           constraints:
//                                                               BoxConstraints(
//                                                                   minWidth: 16),
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   left: 4,
//                                                                   right: 4),
//                                                           decoration: BoxDecoration(
//                                                               color: AppColors
//                                                                   .error,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           18)),
//                                                           child: Center(
//                                                             child: customText(
//                                                               dataSaver.chatRoom!
//                                                                           .totalUnreadCnt >
//                                                                       99
//                                                                   ? '99+'
//                                                                   : dataSaver
//                                                                       .chatRoom!
//                                                                       .totalUnreadCnt
//                                                                       .toString(),
//                                                               style: TextStyle(
//                                                                   color:
//                                                                       AppColors
//                                                                           .white,
//                                                                   fontWeight: weightSet(
//                                                                       textWeight:
//                                                                           TextWeight
//                                                                               .BOLD),
//                                                                   fontSize: fontSizeSet(
//                                                                       textSize:
//                                                                           TextSize
//                                                                               .T10)),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ))
//                                         ],
//                                       ),
//                                       activeIcon: Stack(
//                                         children: [
//                                           Image.asset(AppImages.iNavChatOn,
//                                               width: 24, height: 24),
//                                           dataSaver.chatRoom == null
//                                               ? Positioned(
//                                                   top: 0,
//                                                   right: 0,
//                                                   child: Container())
//                                               : dataSaver.chatRoom!
//                                                           .totalUnreadCnt ==
//                                                       0
//                                                   ? Positioned(
//                                                       top: 0,
//                                                       right: 0,
//                                                       child: Container())
//                                                   : Positioned(
//                                                       top: 0,
//                                                       right: 0,
//                                                       child: Align(
//                                                         widthFactor: 0.5,
//                                                         heightFactor: 0.5,
//                                                         child: Container(
//                                                           height: 16,
//                                                           constraints:
//                                                               BoxConstraints(
//                                                                   minWidth: 16),
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                                   left: 4,
//                                                                   right: 4),
//                                                           decoration: BoxDecoration(
//                                                               color: AppColors
//                                                                   .error,
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           18)),
//                                                           child: Center(
//                                                             child: customText(
//                                                               dataSaver.chatRoom!
//                                                                           .totalUnreadCnt >
//                                                                       99
//                                                                   ? '99+'
//                                                                   : dataSaver
//                                                                       .chatRoom!
//                                                                       .totalUnreadCnt
//                                                                       .toString(),
//                                                               style: TextStyle(
//                                                                   color:
//                                                                       AppColors
//                                                                           .white,
//                                                                   fontWeight: weightSet(
//                                                                       textWeight:
//                                                                           TextWeight
//                                                                               .BOLD),
//                                                                   fontSize: fontSizeSet(
//                                                                       textSize:
//                                                                           TextSize
//                                                                               .T10)),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ))
//                                         ],
//                                       ),
//                                       label: AppStrings.of(StringKey.chatting)),
//                                   BottomNavigationBarItem(
//                                       icon: Image.asset(AppImages.iNavMyOff,
//                                           width: 24, height: 24),
//                                       activeIcon: Image.asset(
//                                           AppImages.iNavMyOn,
//                                           width: 24,
//                                           height: 24),
//                                       label: AppStrings.of(StringKey.myBaeit))
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : null,
//                 body: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                   child: bloc.setView ? setView() : Container(),
//                 ),
//               ),
//             ),
//           );
//         });
//   }
//
//   typeMovePage(type, data) {
//     if (type != null) {
//       amplitudeEvent('touch_push', {'type': type, 'content': data});
//     }
//     switch (type) {
//       case 'MANAGER_NOTIFICATION':
//         CommonRepository.pushClick(data['pushUuid']);
//         return pushTransition(context, NotificationPage());
//       case 'FEEDBACK':
//         return pushTransition(
//             context, FeedbackDetailPage(feedbackUuid: data['feedbackUuid']));
//       case 'MEMBER_STOP':
//         return;
//       case 'MEMBER_STOP_RELEASE':
//         return;
//       case 'CLASS_MADE_STOP':
//         return pushTransition(
//             context,
//             ClassDetailPage(
//                 profileGet: dataSaver.profileGet,
//                 classUuid: data['classUuid'],
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: true));
//       case 'CLASS_MADE_STOP_RELEASE':
//         return pushTransition(
//             context,
//             ClassDetailPage(
//                 profileGet: dataSaver.profileGet,
//                 classUuid: data['classUuid'],
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: true));
//       case 'CLASS_REQUEST_STOP':
//         return pushTransition(
//             context,
//             RequestDetailPage(
//               profileGet: dataSaver.profileGet,
//               classUuid: data['classUuid'],
//               mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                   .indexWhere((element) => element.representativeFlag == 1)],
//               my: true,
//             ));
//       case 'CLASS_REQUEST_STOP_RELEASE':
//         return pushTransition(
//             context,
//             RequestDetailPage(
//               profileGet: dataSaver.profileGet,
//               classUuid: data['classUuid'],
//               mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                   .indexWhere((element) => element.representativeFlag == 1)],
//               my: true,
//             ));
//       case 'CHEERING_DONE':
//         return;
//       case 'NOTICE':
//         return pushTransition(
//             context, NoticeDetailPage(noticeUuid: data['noticeUuid']));
//       case 'CHATTING':
//         if (data['chatRoomUuid'] != dataSaver.chatRoomUuid) {
//           bloc.add(ChangeViewEvent(viewIndex: 2));
//           return pushTransition(
//               context, ChatDetailPage(chatRoomUuid: data['chatRoomUuid']));
//         }
//     }
//   }
//
//   pushInteractive(payload) {
//     Map<String, dynamic> data = {};
//     if (payload != null && payload != '') {
//       data = jsonDecode(payload);
//     }
//
//     typeMovePage(data['messageType'], data);
//   }
//
//   void _configureSelectNotificationSubject(String payload) {
//     pushInteractive(payload);
//   }
//
//   @override
//   blocListener(BuildContext context, state) {
//     if (state is MainNavigationInitState) {
//       bloc.setView = true;
//       setState(() {});
//       dataSaver.iosBottom = MediaQuery.of(context).padding.bottom;
//       dataSaver.mainNavigationBloc = bloc;
//       String? pushNotificationOnLaunch =
//           PushConfig().getAndRemovePushNotificationOnLaunch();
//       if (pushNotificationOnLaunch != null) {
//         _configureSelectNotificationSubject(pushNotificationOnLaunch);
//       }
//     }
//
//     if (state is ChatCountReloadState) {
//       setState(() {});
//       if (dataSaver.chatRoom!.totalUnreadCnt == 0) {
//         flutterLocalNotificationsPlugin?.cancel(0);
//       }
//     }
//
//     if (state is StopState) {
//       pushAndRemoveUntil(
//           context,
//           SplashPage(
//             stopText: state.stopText,
//           ));
//     }
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   initDynamicLinks() async {
//     FirebaseDynamicLinks.instance.onLink(
//         onSuccess: (PendingDynamicLinkData? dynamicLink) async {
//       debugPrint(
//           "Dynamic Link : ${dynamicLink?.link.queryParameters}, ${dynamicLink?.link}");
//       Map<String, String>? data = dynamicLink?.link.queryParameters;
//       String? type = data!['type'];
//       String? classUuid = data['classUuid'];
//       String? memberUuid = data['memberUuid'];
//       if (!dataSaver.nonMember) {
//         if (type == 'MADE_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               ClassDetailPage(
//                 profileGet: dataSaver.profileGet,
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: dataSaver.userData!.memberUuid == memberUuid!
//                     ? true
//                     : false,
//               ));
//         } else if (type == 'REQUEST_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               RequestDetailPage(
//                 profileGet: dataSaver.profileGet,
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: dataSaver.userData!.memberUuid == memberUuid!
//                     ? true
//                     : false,
//               ));
//         }
//       } else {
//         if (type == 'MADE_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               ClassDetailPage(
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: false,
//               ));
//         } else if (type == 'REQUEST_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               RequestDetailPage(
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: false,
//               ));
//         }
//       }
//     }, onError: (OnLinkErrorException e) async {
//       debugPrint('Dynamic Link Error : ${e.message}');
//     });
//
//     final PendingDynamicLinkData? deeplinkData =
//         await FirebaseDynamicLinks.instance.getInitialLink();
//     final Uri? deepLink = deeplinkData?.link;
//     Map<String, String>? data = deepLink!.queryParameters;
//
//     String? type = data['type'] ?? '';
//     String? classUuid = data['classUuid'] ?? '';
//     String? memberUuid = data['memberUuid'] ?? '';
//     if (!dataSaver.nonMember) {
//       if (type == 'MADE_CLASS_DETAILS') {
//         pushTransition(
//             context,
//             ClassDetailPage(
//               profileGet: dataSaver.profileGet,
//               classUuid: classUuid,
//               mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                   .indexWhere((element) => element.representativeFlag == 1)],
//               my: dataSaver.userData!.memberUuid == memberUuid ? true : false,
//             ));
//       } else if (type == 'REQUEST_CLASS_DETAILS') {
//         pushTransition(
//             context,
//             RequestDetailPage(
//               profileGet: dataSaver.profileGet,
//               classUuid: classUuid,
//               mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                   .indexWhere((element) => element.representativeFlag == 1)],
//               my: dataSaver.userData!.memberUuid == memberUuid ? true : false,
//             ));
//       }
//     } else {
//       if (dataSaver.neighborHood.length == 0) {
//         ReturnData returnData =
//             await NeighborHoodSelectRepository.nonMemberArea();
//         dataSaver.neighborHood.add(NeighborHood.fromJson(returnData.data));
//
//         List<String> data = [];
//
//         for (int i = 0; i < dataSaver.neighborHood.length; i++) {
//           data.add(jsonEncode(dataSaver.neighborHood[i].toMapAll()));
//         }
//         await prefs!.setString('guestNeighborHood', jsonEncode(data));
//       }
//
//       if (type == 'MADE_CLASS_DETAILS') {
//         pushTransition(
//             context,
//             ClassDetailPage(
//               classUuid: classUuid,
//               mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                   .indexWhere((element) => element.representativeFlag == 1)],
//               my: false,
//             ));
//       } else if (type == 'REQUEST_CLASS_DETAILS') {
//         pushTransition(
//             context,
//             RequestDetailPage(
//               classUuid: classUuid,
//               mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                   .indexWhere((element) => element.representativeFlag == 1)],
//               my: false,
//             ));
//       }
//     }
//   }
//
//   static void downloadCallback(
//       String id, DownloadTaskStatus status, int progress) {
//     final SendPort? send =
//         IsolateNameServer.lookupPortByName('downloader_send_port');
//     send!.send([id, status, progress]);
//   }
//
//   StreamSubscription? _sub;
//
//   @override
//   void initState() {
//     super.initState();
//
//     FlutterDownloader.registerCallback(downloadCallback);
//
//     selectNotificationSubject.listen((String? payload) async {
//       _configureSelectNotificationSubject(payload!);
//     });
//
//     initDynamicLinks();
//     _handleIncomingLinks();
//     _handleInitialUri();
//   }
//
//   @override
//   MainNavigationBloc initBloc() {
//     // TODO: implement initBloc
//     return MainNavigationBloc(context)
//       ..add(MainNavigationInitEvent(viewIndex: widget.viewIndex));
//   }
//
//   void _handleIncomingLinks() {
//     _sub = uriLinkStream.listen((Uri? uri) {
//       if (!mounted) return;
//       Map<String, String>? data = uri?.queryParameters;
//       String? type = data!['type'];
//       String? classUuid = data['classUuid'];
//       String? memberUuid = data['memberUuid'];
//       if (!dataSaver.nonMember) {
//         if (type == 'MADE_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               ClassDetailPage(
//                 profileGet: dataSaver.profileGet,
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: dataSaver.userData!.memberUuid == memberUuid!
//                     ? true
//                     : false,
//               ));
//         } else if (type == 'REQUEST_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               RequestDetailPage(
//                 profileGet: dataSaver.profileGet,
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: dataSaver.userData!.memberUuid == memberUuid!
//                     ? true
//                     : false,
//               ));
//         }
//       } else {
//         if (type == 'MADE_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               ClassDetailPage(
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: false,
//               ));
//         } else if (type == 'REQUEST_CLASS_DETAILS') {
//           pushTransition(
//               context,
//               RequestDetailPage(
//                 classUuid: classUuid!,
//                 mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
//                     .indexWhere((element) => element.representativeFlag == 1)],
//                 my: false,
//               ));
//         }
//       }
//     }, onError: (Object err) {
//       if (!mounted) return;
//       print('got err: $err');
//     });
//   }
//
//   Future<void> _handleInitialUri() async {
//     if (!_initialUriIsHandled) {
//       _initialUriIsHandled = true;
//
//       try {
//         final uri = await getInitialUri();
//         if (uri == null) {
//           print('no initial uri');
//         } else {
//           Map<String, String>? data = uri.queryParameters;
//           String? type = data['type'];
//           String? classUuid = data['classUuid'];
//           String? memberUuid = data['memberUuid'];
//           if (!dataSaver.nonMember) {
//             if (type == 'MADE_CLASS_DETAILS') {
//               pushTransition(
//                   context,
//                   ClassDetailPage(
//                     profileGet: dataSaver.profileGet,
//                     classUuid: classUuid!,
//                     mainNeighborHood: dataSaver.neighborHood[
//                         dataSaver.neighborHood.indexWhere(
//                             (element) => element.representativeFlag == 1)],
//                     my: dataSaver.userData!.memberUuid == memberUuid!
//                         ? true
//                         : false,
//                   ));
//             } else if (type == 'REQUEST_CLASS_DETAILS') {
//               pushTransition(
//                   context,
//                   RequestDetailPage(
//                     profileGet: dataSaver.profileGet,
//                     classUuid: classUuid!,
//                     mainNeighborHood: dataSaver.neighborHood[
//                         dataSaver.neighborHood.indexWhere(
//                             (element) => element.representativeFlag == 1)],
//                     my: dataSaver.userData!.memberUuid == memberUuid!
//                         ? true
//                         : false,
//                   ));
//             }
//           } else {
//             if (type == 'MADE_CLASS_DETAILS') {
//               pushTransition(
//                   context,
//                   ClassDetailPage(
//                     classUuid: classUuid!,
//                     mainNeighborHood: dataSaver.neighborHood[
//                         dataSaver.neighborHood.indexWhere(
//                             (element) => element.representativeFlag == 1)],
//                     my: false,
//                   ));
//             } else if (type == 'REQUEST_CLASS_DETAILS') {
//               pushTransition(
//                   context,
//                   RequestDetailPage(
//                     classUuid: classUuid!,
//                     mainNeighborHood: dataSaver.neighborHood[
//                         dataSaver.neighborHood.indexWhere(
//                             (element) => element.representativeFlag == 1)],
//                     my: false,
//                   ));
//             }
//           }
//           print('got initial uri: $uri');
//         }
//       } on PlatformException {
//         print('failed to get initial uri');
//       } on FormatException catch (err) {
//         if (!mounted) return;
//         print('malformed initial uri : $err');
//       }
//     }
//   }
// }
//
// bool _initialUriIsHandled = false;
