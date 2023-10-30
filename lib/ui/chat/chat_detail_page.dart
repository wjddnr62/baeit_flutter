import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/data/chat/chat_help.dart';
import 'package:baeit/data/chat/talk.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/data/community/community_data.dart';
import 'package:baeit/data/review/repository/review_repository.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/chat/chat_detail_bloc.dart';
import 'package:baeit/ui/chat_report/chat_report_page.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/image_view/image_view_detail_page.dart';
import 'package:baeit/ui/review/create_review_page.dart';
import 'package:baeit/ui/review/review_detail_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_field_utils.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/bottom_button.dart';
import 'package:baeit/widgets/custom_dialog.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart'
as dpp;
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ChatDetailPage extends BlocStatefulWidget {
  final String? chatRoomUuid;
  final String? classUuid;
  final String? communityUuid;
  final bool classCheck;
  final bool communityCheck;
  final String? userName;
  final Content? content;
  final CommunityDetail? communityDetail;
  final bool detail;
  final ChatHelp? chatHelp;

  ChatDetailPage({this.chatRoomUuid,
    this.classUuid,
    this.communityUuid,
    this.classCheck = false,
    this.communityCheck = false,
    this.userName,
    this.content,
    this.communityDetail,
    this.detail = false,
    this.chatHelp});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ChatDetailState();
  }
}

class ChatDetailState extends BlocState<ChatDetailBloc, ChatDetailPage>
    with TickerProviderStateMixin {
  double keyboardHeight = 0;
  TextEditingController msgController = TextEditingController();
  FocusNode msgFocus = FocusNode();
  ScrollController? scrollController;
  KeyboardVisibilityController keyboardVisibilityController =
  KeyboardVisibilityController();
  ReceivePort _port = ReceivePort();

  AnimationController? controller;
  late Animation<double> animation;
  late Timer animationTimer;

  int currentLine = 1;

  List<String> videoType = [
    'mp4',
    'm4v',
    'avi',
    'asf',
    'wmv',
    'mkv',
    'ts',
    'mpg',
    'mpeg',
    'flv',
    'ogv'
  ];

  List<String> imageType = [
    'jpg',
    'jpeg',
    'gif',
    'bmp',
    'png',
    'tif',
    'tiff',
    'tga',
    'psd',
    'ai',
    'heic'
  ];

  List<String> imageViewType = [
    'jpg',
    'jpeg',
    'gif',
    'png',
    'heic',
    'mov',
    'heif'
  ];

  List<String> mediaType = [
    'mp3',
    'wav',
    'flac',
    'tta',
    'tak',
    'aac',
    'wma',
    'ogg',
    'm4a'
  ];
  List<String> docType = [
    'doc',
    'docx',
    'hwp',
    'txt',
    'rtf',
    'xml',
    'pdf',
    'wks',
    'xps',
    'md',
    'odf',
    'odt',
    'ods',
    'odp',
    'csv',
    'tsv',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'pages',
    'key',
    'numbers',
    'show',
    'ce'
  ];

  List<String> zipType = ['zip', 'gz', 'bz2', 'rar', '7z', 'lzh', 'alz'];

  int plusMenuHeight = 160;

  bool sendHelp = false;

  sortTalk() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        bloc.talkData.sort((a, b) => a.createDate.compareTo(b.createDate));
      });
    });
  }

  chat() {
    bloc.talkData = [];

    for (int i = 0; i < bloc.date.length; i++) {
      if (dataSaver.chatRoom!.roomData.indexWhere(
              (element) => element.chatRoomUuid == bloc.chatRoomUuid) !=
          -1 &&
          int.parse(dataSaver
              .chatRoom!
              .roomData[dataSaver.chatRoom!.roomData.indexWhere(
                  (element) => element.chatRoomUuid == bloc.chatRoomUuid)]
              .createDate
              .yearMonthDay
              .replaceAll('-', '')) <=
              int.parse(bloc.date[i].replaceAll('-', ''))) {
        bloc.talk.sort((a, b) => a.createDate.compareTo(b.createDate));
        bloc.talkData.addAll(bloc.talk
            .where((element) =>
        element.createDate.yearMonthDay == bloc.date[i] &&
            bloc.talkData.indexWhere((e) =>
            e.chatRoomMessageUuid == element.chatRoomMessageUuid) ==
                -1)
            .toList());
        bloc.add(ChatDetailReloadEvent());
      }
      bloc.add(ChatDetailReloadEvent());
    }

    sortTalk();

    bloc.add(ChatDetailReloadEvent());

    return ListView(
      controller: scrollController,
      children: [
        bloc.talk.length != 0 &&
            bloc.talk.indexWhere((e) => e.type == 'EVENT') != -1 &&
            bloc.talk[bloc.talk.indexWhere((e) => e.type == 'EVENT')]
                .memberUuid !=
                dataSaver.profileGet!.memberUuid
            ? spaceH(30)
            : Container(),
        bloc.talk.length != 0 &&
            bloc.talk.indexWhere((e) => e.type == 'EVENT') != -1 &&
            bloc.talk[bloc.talk.indexWhere((e) => e.type == 'EVENT')]
                .memberUuid !=
                dataSaver.profileGet!.memberUuid
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spaceW(20),
            GestureDetector(
              onTap: () {
                amplitudeEvent('profile_click', {
                  'click_user_uuid': bloc
                      .members[bloc.members.indexWhere((element) =>
                  element.member.memberUuid !=
                      dataSaver.userData!.memberUuid)]
                      .member
                      .memberUuid,
                  'classUuid': bloc.classUuid ?? '',
                  'click_type': 'profile_image',
                  'type': 'chat'
                });
                profileDialog(
                    context: context,
                    memberUuid: bloc
                        .members[bloc.members.indexWhere((element) =>
                    element.member.memberUuid !=
                        dataSaver.userData!.memberUuid)]
                        .member
                        .memberUuid);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 32,
                  height: 32,
                  child: bloc.members.length == 0 ||
                      bloc
                          .members[bloc.members.indexWhere(
                              (element) =>
                          element.member.memberUuid !=
                              dataSaver.userData!.memberUuid)]
                          .member
                          .profile ==
                          null
                      ? Image.asset(
                    AppImages.dfProfile,
                    width: 32,
                    height: 32,
                  )
                      : CacheImage(
                    imageUrl: bloc
                        .members[bloc.members.indexWhere(
                            (element) =>
                        element.member.memberUuid !=
                            dataSaver.userData!.memberUuid)]
                        .member
                        .profile!,
                    fit: BoxFit.cover,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                  ),
                ),
              ),
            ),
            spaceW(10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryLight40,
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
              EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
              child: customText(
                  bloc
                      .talk[bloc.talk
                      .indexWhere((e) => e.type == 'EVENT')]
                      .message ??
                      '',
                  style: TextStyle(
                      color: AppColors.secondaryDark30,
                      fontWeight:
                      weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T14))),
            ),
          ],
        )
            : Container(),
        ListView.builder(
          physics: ClampingScrollPhysics(),
          itemBuilder: (context, idx) {
            return Column(
              children: [
                idx == 0 ? spaceH(20) : Container(),
                Row(
                  children: [
                    Expanded(child: heightLine(height: 1)),
                    spaceW(9),
                    customText(
                      bloc.date[idx],
                      style: TextStyle(
                          color: AppColors.gray400,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12)),
                    ),
                    spaceW(9),
                    Expanded(child: heightLine(height: 1)),
                  ],
                ),
                spaceH(16),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (bloc.date[idx] ==
                        bloc.talkData[index].createDate.yearMonthDay) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bloc.talkData[index].memberUuid ==
                                  dataSaver.userData!.memberUuid &&
                                  bloc.talkData[index].type != 'NOTICE' &&
                                  bloc.talkData[index].type != 'EVENT'
                                  ? Container(
                                width: bloc.talkData[index].type == 'TALK'
                                    ? MediaQuery
                                    .of(context)
                                    .size
                                    .width *
                                    0.3
                                    : MediaQuery
                                    .of(context)
                                    .size
                                    .width /
                                    3 -
                                    bloc.talkData[index].files
                                        .length ==
                                    0
                                    ? 0
                                    : ((imageViewType.indexWhere(
                                        (element) =>
                                        bloc
                                            .talkData[index]
                                            .files
                                            .first
                                            .storedName
                                            .toLowerCase()
                                            .contains(
                                            '.$element')) ==
                                    -1)
                                    ? 40
                                    : 80),
                              )
                                  : Container(),
                              bloc.talkData[index].memberUuid !=
                                  dataSaver.userData!.memberUuid &&
                                  bloc.talkData[index].type != 'NOTICE' &&
                                  bloc.talkData[index].type != 'EVENT'
                                  ? Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: bloc.talkData[index]
                                        .memberUuid !=
                                        dataSaver.userData!.memberUuid
                                        ? 20
                                        : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      amplitudeEvent('profile_click', {
                                        'click_user_uuid': bloc
                                            .talkData[index].memberUuid,
                                        'classUuid': bloc.classUuid ?? '',
                                        'click_type': 'profile_image',
                                        'type': 'chat'
                                      });
                                      profileDialog(
                                          context: context,
                                          memberUuid: bloc.talkData[index]
                                              .memberUuid);
                                    },
                                    child: bloc.talkData.indexWhere((element) =>
                                    (element.createDate
                                        .yearMonthDayHourMinute ==
                                        bloc
                                            .talkData[
                                        index]
                                            .createDate
                                            .yearMonthDayHourMinute) &&
                                        (element.send ==
                                            true) &&
                                        (element.memberUuid !=
                                            dataSaver
                                                .profileGet!
                                                .memberUuid)) ==
                                        index ||
                                        index == 1
                                        ? bloc
                                        .members[bloc.members
                                        .indexWhere(
                                            (element) =>
                                        element.member.memberUuid !=
                                            dataSaver.userData!.memberUuid)]
                                        .member
                                        .profile ==
                                        null
                                        ? Image.asset(
                                      AppImages.dfProfile,
                                      width: 32,
                                      height: 32,
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(
                                          32),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        child: CacheImage(
                                          imageUrl: bloc
                                              .members[bloc
                                              .members
                                              .indexWhere((element) =>
                                          element
                                              .member
                                              .memberUuid !=
                                              dataSaver
                                                  .userData!
                                                  .memberUuid)]
                                              .member
                                              .profile!,
                                          width: MediaQuery
                                              .of(
                                              context)
                                              .size
                                              .width /
                                              2,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                        : Container(
                                      width: 32,
                                    ),
                                  ),
                                ),
                              )
                                  : Container(),
                              bloc.talkData[index].type == 'TALK' ||
                                  bloc.talkData[index].type == 'FILE'
                                  ? Flexible(
                                child: Row(
                                  mainAxisAlignment: bloc.talkData[index]
                                      .memberUuid !=
                                      dataSaver.userData!.memberUuid
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  children: [
                                    bloc.talkData[index].memberUuid !=
                                        dataSaver.userData!.memberUuid
                                        ? Container()
                                        : Container(
                                      width: 28,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          !bloc.talkData[index]
                                              .send &&
                                              !bloc
                                                  .talkData[
                                              index]
                                                  .loading
                                              ? Container()
                                              : bloc.talkData[index]
                                              .loading
                                              ? Image.asset(
                                            AppImages
                                                .iChatBufferG,
                                            width: 24,
                                            height: 24,
                                          )
                                              : bloc.talkData[index]
                                              .unreadCnt >
                                              0
                                              ? Align(
                                            alignment:
                                            Alignment
                                                .bottomRight,
                                            child:
                                            customText(
                                              '${bloc.talkData[index]
                                                  .unreadCnt}',
                                              style: TextStyle(
                                                  color:
                                                  AppColors.accentLight20,
                                                  fontWeight: weightSet(
                                                      textWeight: TextWeight
                                                          .BOLD),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T10)),
                                            ),
                                          )
                                              : Container(),
                                          bloc.talkData[index]
                                              .loading
                                              ? Container()
                                              : bloc.talkData.lastIndexWhere((
                                              element) =>
                                          (element.createDate
                                              .yearMonthDayHourMinute ==
                                              bloc
                                                  .talkData[
                                              index]
                                                  .createDate
                                                  .yearMonthDayHourMinute) &&
                                              (element.send ==
                                                  true) &&
                                              (element.memberUuid ==
                                                  dataSaver
                                                      .profileGet!
                                                      .memberUuid)) ==
                                              index
                                              ? Align(
                                            alignment:
                                            Alignment
                                                .bottomCenter,
                                            child:
                                            customText(
                                              '${bloc.talkData.lastIndexWhere((
                                                  element) =>
                                              (element.createDate
                                                  .yearMonthDayHourMinute ==
                                                  bloc.talkData[index]
                                                      .createDate
                                                      .yearMonthDayHourMinute) &&
                                                  (element.send == true) &&
                                                  (element.memberUuid ==
                                                      dataSaver.profileGet!
                                                          .memberUuid)) == index
                                                  ? '${bloc.talkData[index]
                                                  .createDate.hour
                                                  .toString()
                                                  .length == 1 ? '0${bloc
                                                  .talkData[index].createDate
                                                  .hour}' : bloc.talkData[index]
                                                  .createDate.hour}:${bloc
                                                  .talkData[index]
                                                  .createDate.minute
                                                  .toString()
                                                  .length == 1 ? '0${bloc
                                                  .talkData[index].createDate
                                                  .minute}' : bloc
                                                  .talkData[index].createDate
                                                  .minute}'
                                                  : ''}',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .gray600,
                                                  fontWeight: weightSet(
                                                      textWeight: TextWeight
                                                          .MEDIUM),
                                                  fontSize:
                                                  fontSizeSet(
                                                      textSize: TextSize.T10)),
                                            ),
                                          )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    bloc.talkData[index].memberUuid !=
                                        dataSaver.userData!.memberUuid
                                        ? spaceW(10)
                                        : spaceW(4),
                                    bloc.talkData[index].type == 'TALK'
                                        ? Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: bloc
                                              .talkData[
                                          index]
                                              .memberUuid !=
                                              dataSaver
                                                  .userData!
                                                  .memberUuid
                                              ? 0
                                              : 20,
                                        ),
                                        child: InkWell(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10),
                                          onLongPress: () async {
                                            ClipboardData data =
                                            ClipboardData(
                                                text: bloc
                                                    .talkData[
                                                index]
                                                    .message!);
                                            await Clipboard.setData(
                                                data);
                                            showToast(
                                                context: context,
                                                text: '복사되었어요',
                                                toastGravity:
                                                ToastGravity
                                                    .CENTER);
                                          },
                                          child: Container(
                                              padding:
                                              EdgeInsets.only(
                                                  left: 12,
                                                  right: 12,
                                                  top: 8,
                                                  bottom: 8),
                                              decoration: BoxDecoration(
                                                  color: bloc.talkData[index]
                                                      .memberUuid !=
                                                      dataSaver
                                                          .userData!
                                                          .memberUuid
                                                      ? AppColors
                                                      .white
                                                      : AppColors
                                                      .primaryLight50,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10),
                                                  border: bloc.talkData[index]
                                                      .memberUuid !=
                                                      dataSaver
                                                          .userData!
                                                          .memberUuid
                                                      ? Border.all(
                                                      color: AppColors
                                                          .gray200)
                                                      : Border.all(
                                                      color: AppColors
                                                          .transparent)),
                                              child: Linkify(
                                                onOpen:
                                                    (link) async {
                                                  await launch(
                                                      link.url)
                                                      .then(
                                                          (value) {
                                                        systemColorSetting();
                                                      });
                                                },
                                                text: bloc
                                                    .talkData[
                                                index]
                                                    .message ??
                                                    '',
                                                style: TextStyle(
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                        TextSize
                                                            .T14),
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                        TextWeight
                                                            .MEDIUM),
                                                    color: bloc
                                                        .talkData[
                                                    index]
                                                        .memberUuid !=
                                                        dataSaver
                                                            .userData!
                                                            .memberUuid
                                                        ? AppColors
                                                        .gray600
                                                        : !bloc.talkData[index]
                                                        .send &&
                                                        !bloc
                                                            .talkData[
                                                        index]
                                                            .loading
                                                        ? AppColors
                                                        .primaryLight10
                                                        : AppColors
                                                        .primaryDark10),
                                              )
                                            // Wrap(
                                            //   children:
                                            //       bloc.talkData[index]
                                            //           .message!
                                            //           .split(' ')
                                            //           .map(
                                            //             (e) =>
                                            //                 SelectableText(
                                            //               e,
                                            //               style: TextStyle(
                                            //                   fontSize: fontSizeSet(
                                            //                       textSize: TextSize
                                            //                           .T14),
                                            //                   fontWeight: weightSet(
                                            //                       textWeight: TextWeight
                                            //                           .MEDIUM),
                                            //                   color: bloc.talkData[index].memberUuid !=
                                            //                           bloc
                                            //                               .userData.memberUuid
                                            //                       ? AppColors
                                            //                           .gray600
                                            //                       : AppColors
                                            //                           .primaryDark10),
                                            //               enableInteractiveSelection:
                                            //                   false,
                                            //             ),
                                            //           )
                                            //           .toList(),
                                            // )
                                          ),
                                        ),
                                      ),
                                    )
                                        : bloc.talkData.isEmpty ||
                                        bloc.talkData[index].files
                                            .length ==
                                            0
                                        ? Container()
                                        : (imageViewType.indexWhere(
                                            (element) =>
                                            bloc
                                                .talkData[
                                            index]
                                                .files
                                                .first
                                                .storedName
                                                .toLowerCase()
                                                .contains(
                                                '.$element')) ==
                                        -1)
                                        ? Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right: bloc
                                                  .talkData[
                                              index]
                                                  .memberUuid !=
                                                  dataSaver
                                                      .userData!
                                                      .memberUuid
                                                  ? 0
                                                  : 20),
                                          child:
                                          GestureDetector(
                                            onTap: () async {
                                              if (bloc
                                                  .talkData[
                                              index]
                                                  .path ==
                                                  null) {
                                                final dir = Platform.isAndroid
                                                    ? await dpp
                                                    .DownloadsPathProvider
                                                    .downloadsDirectory
                                                    : Directory(
                                                    (await getApplicationDocumentsDirectory())
                                                        .absolute
                                                        .path);
                                                bool
                                                hasExisted =
                                                await dir!
                                                    .exists();
                                                if (!hasExisted) {
                                                  dir.create();
                                                }
                                                final url =
                                                    '${bloc.talkData[index]
                                                    .files.first
                                                    .prefixUrl}/${bloc
                                                    .talkData[index].files.first
                                                    .path}/${bloc
                                                    .talkData[index].files.first
                                                    .storedName}';
                                                bloc.savePath = (Platform
                                                    .isAndroid
                                                    ? dir
                                                    .path
                                                    : dir
                                                    .path) +
                                                    "/" +
                                                    bloc
                                                        .talkData[
                                                    index]
                                                        .files
                                                        .first
                                                        .storedName;
                                                bloc.dataIndex = bloc
                                                    .talk
                                                    .indexWhere((element) =>
                                                element
                                                    .chatRoomMessageUuid ==
                                                    bloc.talkData[index]
                                                        .chatRoomMessageUuid);
                                                bloc.loading =
                                                true;
                                                setState(() {});
                                                await FlutterDownloader.enqueue(
                                                    url: url,
                                                    savedDir: dir
                                                        .path,
                                                    showNotification:
                                                    true,
                                                    openFileFromNotification:
                                                    true);
                                              } else {
                                                final result =
                                                await OpenFile
                                                    .open(
                                                    '${bloc.talkData[index]
                                                        .path}');
                                                if (result
                                                    .type !=
                                                    ResultType
                                                        .done) {
                                                  if (result
                                                      .type ==
                                                      ResultType
                                                          .fileNotFound) {
                                                    bloc.dataIndex =
                                                        bloc.talk.indexWhere((
                                                            element) =>
                                                        element
                                                            .chatRoomMessageUuid ==
                                                            bloc.talkData[index]
                                                                .chatRoomMessageUuid);
                                                    bloc
                                                        .talk[bloc
                                                        .dataIndex]
                                                        .path = null;
                                                    bloc.add(
                                                        ReloadChatDetailEvent(
                                                            save:
                                                            true));
                                                  } else if (result
                                                      .type ==
                                                      ResultType
                                                          .noAppToOpen) {
                                                    showToast(
                                                        context:
                                                        context,
                                                        text:
                                                        '해당 파일을 열 프로그램을 찾지 못했어요.');
                                                  } else {
                                                    showToast(
                                                        context:
                                                        context,
                                                        text:
                                                        '파일을 여는 중 실패했어요.');
                                                  }
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding:
                                              EdgeInsets
                                                  .all(14),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      10),
                                                  color: bloc.talkData[index]
                                                      .memberUuid !=
                                                      dataSaver
                                                          .userData!
                                                          .memberUuid
                                                      ? AppColors
                                                      .white
                                                      : AppColors
                                                      .primaryLight50,
                                                  border: bloc.talkData[index]
                                                      .memberUuid !=
                                                      dataSaver
                                                          .userData!
                                                          .memberUuid
                                                      ? Border.all(
                                                      color:
                                                      AppColors.gray200)
                                                      : null),
                                              child: Row(
                                                children: [
                                                  ClipOval(
                                                    child:
                                                    Container(
                                                      width: 48,
                                                      height:
                                                      48,
                                                      color: bloc
                                                          .talkData[index]
                                                          .memberUuid !=
                                                          dataSaver
                                                              .userData!
                                                              .memberUuid
                                                          ? AppColors
                                                          .gray50
                                                          : AppColors
                                                          .white,
                                                      child: Center(
                                                          child: Image.asset(
                                                            AppImages
                                                                .iChatAttachG,
                                                            width:
                                                            24,
                                                            height:
                                                            24,
                                                          )),
                                                    ),
                                                  ),
                                                  spaceW(10),
                                                  Flexible(
                                                    child:
                                                    Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              child: customText(
                                                                bloc
                                                                    .talkData[index]
                                                                    .files.first
                                                                    .originName
                                                                    .split(path
                                                                    .extension(
                                                                    bloc
                                                                        .talkData[index]
                                                                        .files
                                                                        .first
                                                                        .originName))[0],
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    color: bloc
                                                                        .talkData[index]
                                                                        .memberUuid !=
                                                                        dataSaver
                                                                            .userData!
                                                                            .memberUuid
                                                                        ? AppColors
                                                                        .gray600
                                                                        : AppColors
                                                                        .primaryDark10,
                                                                    fontWeight: weightSet(
                                                                        textWeight: TextWeight
                                                                            .MEDIUM),
                                                                    fontSize: fontSizeSet(
                                                                        textSize: TextSize
                                                                            .T14)),
                                                                overflow: TextOverflow
                                                                    .ellipsis,
                                                              ),
                                                            ),
                                                            customText(
                                                              path.extension(
                                                                  bloc
                                                                      .talkData[index]
                                                                      .files
                                                                      .first
                                                                      .originName),
                                                              style: TextStyle(
                                                                  color: bloc
                                                                      .talkData[index]
                                                                      .memberUuid !=
                                                                      dataSaver
                                                                          .userData!
                                                                          .memberUuid
                                                                      ? AppColors
                                                                      .gray600
                                                                      : AppColors
                                                                      .primaryDark10,
                                                                  fontWeight: weightSet(
                                                                      textWeight: TextWeight
                                                                          .MEDIUM),
                                                                  fontSize: fontSizeSet(
                                                                      textSize: TextSize
                                                                          .T14)),
                                                            )
                                                          ],
                                                        ),
                                                        spaceH(
                                                            4),
                                                        customText(
                                                          filesize(bloc
                                                              .talkData[index]
                                                              .files.first.size)
                                                              .replaceAll(
                                                              ' ',
                                                              ''),
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .gray400,
                                                              fontWeight: weightSet(
                                                                  textWeight: TextWeight
                                                                      .MEDIUM),
                                                              fontSize: fontSizeSet(
                                                                  textSize: TextSize
                                                                      .T10)),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                        : Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: bloc
                                                .talkData[
                                            index]
                                                .memberUuid !=
                                                dataSaver
                                                    .userData!
                                                    .memberUuid
                                                ? 0
                                                : 20),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              10),
                                          child: bloc
                                              .talkData[
                                          index]
                                              .files
                                              .length ==
                                              1
                                              ? GestureDetector(
                                            onTap:
                                                () {
                                              pushTransition(
                                                  context,
                                                  ImageViewDetailPage(
                                                    idx: 0,
                                                    images: bloc.talkData[index]
                                                        .files,
                                                    heroTag: 'TAG',
                                                    download: true,
                                                  )).then((value) {
                                                WidgetsBinding
                                                    .instance
                                                    .addPostFrameCallback((
                                                    timeStamp) {
                                                  if (scrollController!
                                                      .hasClients &&
                                                      bloc.scrollUnder) {
                                                    scrollController!.jumpTo(
                                                        scrollController!
                                                            .position
                                                            .maxScrollExtent);
                                                  }
                                                });
                                                setState(
                                                        () {});
                                              });
                                            },
                                            child:
                                            Container(
                                              height:
                                              128,
                                              child:
                                              CacheImage(
                                                imageUrl:
                                                '${bloc.talkData[index].files[0]
                                                    .toView(context: context,
                                                    image: bloc
                                                        .talkData[index]
                                                        .files[0]
                                                        .storedName.contains(
                                                        '.MOV')
                                                        ? false
                                                        : true)}',
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width,
                                                placeholder:
                                                Container(
                                                  width:
                                                  MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width,
                                                  height:
                                                  128,
                                                  decoration:
                                                  BoxDecoration(
                                                      color: AppColors.gray200,
                                                      borderRadius: BorderRadius
                                                          .circular(4)),
                                                  child:
                                                  Image.asset(
                                                    AppImages.dfClassMain,
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    height: 128,
                                                  ),
                                                ),
                                                fit: BoxFit
                                                    .cover,
                                              ),
                                            ),
                                          )
                                              : StaggeredGridView
                                              .countBuilder(
                                            physics:
                                            NeverScrollableScrollPhysics(),
                                            shrinkWrap:
                                            true,
                                            crossAxisCount:
                                            2,
                                            itemBuilder:
                                                (BuildContext context,
                                                int idx) {
                                              return GestureDetector(
                                                onTap:
                                                    () {
                                                  pushTransition(
                                                      context,
                                                      ImageViewDetailPage(
                                                        idx: idx,
                                                        images: bloc
                                                            .talkData[index]
                                                            .files,
                                                        heroTag: 'TAG',
                                                        download: true,
                                                      ));
                                                },
                                                child:
                                                Container(
                                                  height:
                                                  128,
                                                  child:
                                                  CacheImage(
                                                    imageUrl: '${bloc
                                                        .talkData[index]
                                                        .files[idx].toView(
                                                        context: context,
                                                        image: bloc
                                                            .talkData[index]
                                                            .files[idx]
                                                            .originName
                                                            .contains('.MOV')
                                                            ? false
                                                            : true)}',
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    placeholder: Container(
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width,
                                                      height: 128,
                                                      decoration: BoxDecoration(
                                                          color: AppColors
                                                              .gray200,
                                                          borderRadius: BorderRadius
                                                              .circular(4)),
                                                      child: Image.asset(
                                                        AppImages.dfClassMain,
                                                        width: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width,
                                                        height: 128,
                                                      ),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              );
                                            },
                                            itemCount: bloc.talkData.length ==
                                                0
                                                ? 0
                                                : bloc
                                                .talkData[index]
                                                .files
                                                .length,
                                            staggeredTileBuilder: (int idx) =>
                                                StaggeredTile.count(
                                                    bloc.talkData[index].files
                                                        .length % 2 == 0
                                                        ? 1
                                                        : idx == (bloc.talkData
                                                        .isEmpty ||
                                                        bloc.talkData[index]
                                                            .files.length == 0
                                                        ? 0
                                                        : bloc.talkData[index]
                                                        .files.length - 1)
                                                        ? 2
                                                        : 1,
                                                    bloc.talkData[index].files
                                                        .length % 2 == 0
                                                        ? 1
                                                        : idx == (bloc.talkData
                                                        .isEmpty ||
                                                        bloc.talkData[index]
                                                            .files.length == 0
                                                        ? 0
                                                        : bloc.talkData[index]
                                                        .files.length - 1)
                                                        ? 2
                                                        : 1),
                                            mainAxisSpacing:
                                            1,
                                            crossAxisSpacing:
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    bloc.talkData[index].memberUuid !=
                                        dataSaver.userData!.memberUuid
                                        ? spaceW(4)
                                        : Container(),
                                    bloc.talkData[index].memberUuid !=
                                        dataSaver.userData!.memberUuid
                                        ? Container(
                                      width: 27,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          bloc.talkData[index]
                                              .loading
                                              ? Image.asset(
                                            AppImages
                                                .iChatBufferG,
                                            width: 24,
                                            height: 24,
                                          )
                                              : bloc.talkData[index]
                                              .unreadCnt >
                                              0
                                              ? Align(
                                            alignment:
                                            Alignment
                                                .bottomRight,
                                            child:
                                            customText(
                                              '${bloc.talkData[index]
                                                  .unreadCnt}',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .accentLight20,
                                                  fontWeight: weightSet(
                                                      textWeight: TextWeight
                                                          .BOLD),
                                                  fontSize:
                                                  fontSizeSet(
                                                      textSize: TextSize.T10)),
                                            ),
                                          )
                                              : Container(),
                                          bloc.talkData[index]
                                              .loading
                                              ? Container()
                                              : bloc.talkData.lastIndexWhere((
                                              element) =>
                                          (element.createDate
                                              .yearMonthDayHourMinute ==
                                              bloc
                                                  .talkData[
                                              index]
                                                  .createDate
                                                  .yearMonthDayHourMinute) &&
                                              (element.send ==
                                                  true) &&
                                              (element.memberUuid !=
                                                  dataSaver
                                                      .profileGet!
                                                      .memberUuid)) ==
                                              index
                                              ? Align(
                                            alignment:
                                            Alignment
                                                .bottomCenter,
                                            child:
                                            customText(
                                              '${bloc.talkData.lastIndexWhere((
                                                  element) =>
                                              (element.createDate
                                                  .yearMonthDayHourMinute ==
                                                  bloc.talkData[index]
                                                      .createDate
                                                      .yearMonthDayHourMinute) &&
                                                  (element.send == true) &&
                                                  (element.memberUuid !=
                                                      dataSaver.profileGet!
                                                          .memberUuid)) == index
                                                  ? '${bloc.talkData[index]
                                                  .createDate.hour
                                                  .toString()
                                                  .length == 1 ? '0${bloc
                                                  .talkData[index].createDate
                                                  .hour}' : bloc.talkData[index]
                                                  .createDate.hour}:${bloc
                                                  .talkData[index]
                                                  .createDate.minute
                                                  .toString()
                                                  .length == 1 ? '0${bloc
                                                  .talkData[index].createDate
                                                  .minute}' : bloc
                                                  .talkData[index].createDate
                                                  .minute}'
                                                  : ''}',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .gray600,
                                                  fontWeight: weightSet(
                                                      textWeight: TextWeight
                                                          .MEDIUM),
                                                  fontSize:
                                                  fontSizeSet(
                                                      textSize: TextSize.T10)),
                                            ),
                                          )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                        : Container(),
                                  ],
                                ),
                              )
                                  : bloc.talkData[index].type == 'NOTICE'
                                  ? Container(
                                width:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                child: Center(
                                  child: customText(
                                    bloc.talkData[index].message!,
                                    style: TextStyle(
                                        color: AppColors.gray400,
                                        fontWeight: weightSet(
                                            textWeight:
                                            TextWeight.MEDIUM),
                                        fontSize: fontSizeSet(
                                            textSize: TextSize.T12)),
                                  ),
                                ),
                              )
                                  : bloc.talkData[index].type == 'FILE'
                                  ? (imageViewType.indexWhere(
                                      (element) =>
                                      bloc
                                          .talkData[index]
                                          .files
                                          .first
                                          .storedName
                                          .toLowerCase()
                                          .contains(
                                          '.$element')) ==
                                  -1)
                                  ? Container(
                                child: customText(bloc
                                    .talkData[index]
                                    .files
                                    .length
                                    .toString()),
                              )
                                  : Container()
                                  : Container(),
                              bloc.talkData[index].memberUuid !=
                                  dataSaver.userData!.memberUuid &&
                                  bloc.talkData[index].type != 'NOTICE' &&
                                  bloc.talkData[index].type != 'EVENT'
                                  ? Container(
                                width: bloc.talkData[index].type == 'TALK'
                                    ? MediaQuery
                                    .of(context)
                                    .size
                                    .width *
                                    0.3 -
                                    42
                                    : MediaQuery
                                    .of(context)
                                    .size
                                    .width /
                                    3 -
                                    bloc.talkData[index].files
                                        .length ==
                                    0
                                    ? 0
                                    : ((imageViewType.indexWhere(
                                        (element) =>
                                        bloc
                                            .talkData[index]
                                            .files
                                            .first
                                            .storedName
                                            .toLowerCase()
                                            .contains(
                                            '.$element')) ==
                                    -1)
                                    ? 40
                                    : 80),
                              )
                                  : Container(),
                            ],
                          ),
                          !bloc.talkData[index].send &&
                              !bloc.talkData[index].loading
                              ? spaceH(10)
                              : Container(),
                          !bloc.talkData[index].send &&
                              !bloc.talkData[index].loading
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              customText(
                                  bloc.talkData[index].type == 'TALK'
                                      ? '메세지 전송이 실패했습니다'
                                      : (imageViewType.indexWhere(
                                          (element) =>
                                          bloc
                                              .talkData[index]
                                              .files
                                              .first
                                              .storedName
                                              .toLowerCase()
                                              .contains(
                                              '.$element')) ==
                                      -1)
                                      ? '파일 전송이 실패했습니다'
                                      : '이미지 전송이 실패했습니다',
                                  style: TextStyle(
                                      color: AppColors.gray400,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.MEDIUM),
                                      fontSize: fontSizeSet(
                                          textSize: TextSize.T14))),
                              spaceW(10),
                              Container(
                                  width: 32,
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      failMessageDialog(
                                          0, bloc.talkData[index]);
                                    },
                                    child: Center(
                                      child: Image.asset(
                                        AppImages.iRefreshW,
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: AppColors.accent,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                32))),
                                  )),
                              spaceW(10),
                              Container(
                                  width: 32,
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      failMessageDialog(
                                          1, bloc.talkData[index]);
                                    },
                                    child: Center(
                                      child: Image.asset(
                                        AppImages.iTrashG,
                                        width: 16,
                                        height: 16,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: AppColors.errorLight10,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                32))),
                                  )),
                              spaceW(20)
                            ],
                          )
                              : Container(),
                          index == bloc.talkData.length - 1
                              ? Container()
                              : spaceH(16),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                  shrinkWrap: true,
                  itemCount: bloc.talkData.length,
                ),
                spaceH(16)
              ],
            );
          },
          shrinkWrap: true,
          itemCount: bloc.date.length,
        ),
      ],
    );
  }

  failMessageDialog(int type, Talk talkData) {
    String msg = type == 0 ? '재전송하실껀가요?' : '삭제하실껀가요?';

    return customDialog(
        context: context,
        barrier: false,
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spaceH(48),
            customText(msg,
                style: TextStyle(
                    color: AppColors.gray600,
                    fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                    fontSize: fontSizeSet(textSize: TextSize.T13))),
            spaceH(44),
            Row(
              children: [
                spaceW(12),
                Expanded(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        popDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                  width: 1, color: AppColors.primary))),
                      child: Center(
                        child: customText('취소',
                            style: TextStyle(
                                color: AppColors.primaryDark10,
                                fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T13))),
                      ),
                    ),
                  ),
                ),
                spaceW(12),
                Expanded(
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        popDialog(context);
                        if (type == 0) {
                          bloc.add(ChatReSendEvent(talkData: talkData));
                        } else if (type == 1) {
                          bloc.add(ChatRemoveEvent(talkData: talkData));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      child: Center(
                        child: customText(type == 0 ? '재전송' : '삭제',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                                fontSize: fontSizeSet(textSize: TextSize.T13))),
                      ),
                    ),
                  ),
                ),
                spaceW(12)
              ],
            ),
            spaceH(12)
          ],
        ));
  }

  List<String> menus = ['앨범', '파일'];

  menuColor(String text) {
    switch (text) {
      case '앨범':
        return AppColors.accentLight50;
      case '파일':
        return AppColors.secondaryLight20;
    }
  }

  menuIcon(String text) {
    switch (text) {
      case '앨범':
        return AppImages.iCameraW;
      case '파일':
        return AppImages.iChatAttachY;
    }
  }

  Future<dynamic> getFile(text) async {
    FilePickerResult? result;
    switch (text) {
      case '앨범':
        List<Asset> resultList = [];
        resultList = await MultiImagePicker.pickImages(
            maxImages: 10, enableCamera: false, selectedAssets: resultList);
        List<File> files = [];
        for (int i = 0; i < resultList.length; i++) {
          await resultList[i].getByteData(quality: 100).then((value) async {
            Directory tempDir = await getTemporaryDirectory();
            String tempPath = tempDir.path;
            var filePath = tempPath +
                '/${Uuid().v4()}.${resultList[i].name!.split(".")[1]}';
            File file = await File(filePath).writeAsBytes(value.buffer
                .asUint8List(value.offsetInBytes, value.lengthInBytes));
            files.add(file);
          });
        }
        if (files.length == 0) {
          return null;
        } else {
          return files;
        }
      case '파일':
        result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: []..addAll(videoType)..addAll(mediaType)..addAll(
                docType)..addAll(zipType),
            allowMultiple: false);
        if (result != null) {
          List<File> files = result.paths.map((path) => File(path!)).toList();
          List<String> tag = []..addAll(videoType)..addAll(mediaType)..addAll(
              docType)..addAll(zipType);
          bool check = false;
          if (tag.indexWhere(
                  (element) => files.single.path.contains('.$element')) ==
              -1) {
            check = true;
          }

          if (check) {
            showToast(context: context, text: '지원하지 않는 파일 형식입니다.');
            return null;
          } else {
            return files;
          }
        } else {
          return null;
        }
    }
  }

  plusMenu(text) {
    return Container(
      height: plusMenuHeight.toDouble(),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!bloc.networkNone) {
                          if (Platform.isAndroid
                              ? await Permission.storage.isGranted
                              : await Permission.photos.isGranted ||
                              await Permission.photos.isLimited) {
                            getFile(text).then((value) async {
                              if (value != null) {
                                List<File> files = value;
                                bloc.type = 'FILE';
                                bloc.add(
                                    SendFileEvent(type: text, files: files));
                              }
                            });
                          } else if (Platform.isAndroid
                              ? await Permission.storage.isDenied ||
                              await Permission.storage.isPermanentlyDenied
                              : await Permission.photos.isDenied ||
                              await Permission.photos.isPermanentlyDenied) {
                            decisionDialog(
                                context: context,
                                barrier: false,
                                text: Platform.isAndroid
                                    ? AppStrings.of(StringKey.storageCheckText)
                                    : AppStrings.of(StringKey.photoCheckText),
                                allowText: AppStrings.of(StringKey.check),
                                disallowText: AppStrings.of(StringKey.cancel),
                                allowCallback: () async {
                                  popDialog(context);
                                  await openAppSettings();
                                },
                                disallowCallback: () {
                                  popDialog(context);
                                });
                          }
                        } else {
                          showToast(context: context, text: '네트워크 연결을 확인해주세요');
                        }
                      },
                      child: Center(
                        child: Image.asset(
                          menuIcon(text),
                          width: 24,
                          height: 24,
                          color: text == '앨범' ? AppColors.accentLight20 : null,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: menuColor(text),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48)),
                          padding: EdgeInsets.zero,
                          elevation: 0),
                    ),
                  ),
                  spaceH(8),
                  customText(
                    text,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: AppColors.gray600,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T14)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    if (MediaQuery
        .of(context)
        .viewInsets
        .bottom > 0) {
      keyboardHeight =
          MediaQuery
              .of(context)
              .viewInsets
              .bottom - dataSaver.iosBottom;
      if (scrollController!.hasClients && bloc.scrollUnder) {
        scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
      }
    }
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              bloc.add(SettingControlEvent(control: false));
              if (bloc.menuOpen) {
                bloc.add(MenuOpenEvent());
                return Future.value(false);
              } else {
                if (bloc.chatSubscribe != null) {
                  bloc.chatSubscribe();
                  bloc.chatSubscribe = null;
                }
                if (bloc.readSubscribe != null) {
                  bloc.readSubscribe();
                  bloc.readSubscribe = null;
                }
                dataSaver.chatRoomUuid = null;
                if (connectivity != null) await connectivity!.cancel();
                if (onChangeSub != null) await onChangeSub!.cancel();
                dataSaver.chatDetailBloc = null;

                if (bloc.chatRoomUuid != null) {
                  await prefs!.setString(
                      'text${bloc.chatRoomUuid}', msgController.text);
                }
                return Future.value(true);
              }
            },
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (bloc.menuOpen) {
                  bloc.add(MenuOpenEvent());
                }
                bloc.add(SettingControlEvent(control: false));
              },
              child: Container(
                color: AppColors.white,
                child: Stack(
                  children: [
                    Scaffold(
                      backgroundColor: AppColors.white,
                      appBar: AppBar(
                        backgroundColor: AppColors.white,
                        elevation: 0,
                        toolbarHeight: 60,
                        leadingWidth: 0,
                        leading: Container(),
                        titleSpacing: 0,
                        title: Row(
                          children: [
                            spaceW(20),
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  if (bloc.chatSubscribe != null) {
                                    bloc.chatSubscribe();
                                    bloc.chatSubscribe = null;
                                  }
                                  if (bloc.readSubscribe != null) {
                                    bloc.readSubscribe();
                                    bloc.readSubscribe = null;
                                  }
                                  dataSaver.chatRoomUuid = null;

                                  if (connectivity != null)
                                    await connectivity!.cancel();
                                  if (onChangeSub != null)
                                    await onChangeSub!.cancel();
                                  dataSaver.chatDetailBloc = null;
                                  if (bloc.chatRoomUuid != null) {
                                    await prefs!.setString(
                                        'text${bloc.chatRoomUuid}',
                                        msgController.text);
                                  }
                                  pop(context);
                                },
                                icon: Image.asset(
                                  AppImages.iChevronPrev,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                            spaceW(20),
                            GestureDetector(
                              onTap: () {
                                amplitudeEvent('profile_click', {
                                  'click_user_uuid': bloc
                                      .members[bloc.members.indexWhere(
                                          (element) =>
                                      element.member.memberUuid !=
                                          dataSaver.userData!.memberUuid)]
                                      .member
                                      .memberUuid,
                                  'classUuid': bloc.classUuid ?? '',
                                  'click_type': 'appbar',
                                  'type': 'chat'
                                });
                                profileDialog(
                                    context: context,
                                    memberUuid: bloc
                                        .members[bloc.members.indexWhere(
                                            (element) =>
                                        element.member.memberUuid !=
                                            dataSaver.userData!.memberUuid)]
                                        .member
                                        .memberUuid);
                              },
                              child: customText(
                                widget.classUuid != null
                                    ? widget.userName!
                                    : bloc.members.length == 0
                                    ? ''
                                    : bloc
                                    .members[bloc.members.indexWhere(
                                        (element) =>
                                    element.member.memberUuid !=
                                        dataSaver
                                            .userData!.memberUuid)]
                                    .member
                                    .nickName,
                                style: TextStyle(
                                    color: AppColors.gray900,
                                    fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                    fontSizeSet(textSize: TextSize.T15)),
                              ),
                            )
                          ],
                        ),
                        actions: [
                          Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: IconButton(
                                onPressed: () {
                                  bloc.add(SettingControlEvent(control: true));
                                },
                                icon: Image.asset(
                                  AppImages.iMore,
                                  width: 24,
                                  height: 24,
                                )),
                          )
                        ],
                      ),
                      body: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height -
                            (MediaQuery
                                .of(context)
                                .padding
                                .top +
                                dataSaver.iosBottom +
                                60 +
                                (bloc.menuOpen
                                    ? plusMenuHeight
                                    : msgFocus.hasFocus
                                    ? keyboardHeight
                                    : 0)),
                        child: Column(
                          children: [
                            bloc.communityInfo == null &&
                                widget.communityDetail == null
                                ? Container()
                                : Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              padding:
                              EdgeInsets.only(left: 20, right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.detail) {
                                    pop(context);
                                  } else {
                                    pushTransition(
                                        context,
                                        CommunityDetailPage(
                                          communityUuid: bloc
                                              .communityInfo!
                                              .communityUuid,
                                          chatDetail: true,
                                        )).then((value) {
                                      bloc.add(ChatDetailInitEvent(
                                          communityUuid:
                                          widget.communityUuid,
                                          chatRoomUuid:
                                          widget.chatRoomUuid));
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: AppColors.gray100,
                                    padding: EdgeInsets.zero,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10))),
                                child: Row(
                                  children: [
                                    spaceW(14),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          spaceH(10),
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            height: 20,
                                            child: customText(
                                              widget.communityDetail == null
                                                  ? bloc.communityInfo!
                                                  .contentText
                                                  : widget
                                                  .communityDetail!
                                                  .content
                                                  .contentText!,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color:
                                                  AppColors.gray600,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                      TextWeight
                                                          .MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize:
                                                      TextSize.T14)),
                                            ),
                                          ),
                                          spaceH(2),
                                          customText(
                                            widget.communityDetail == null
                                                ? bloc.communityInfo!
                                                .hangNames
                                                .replaceAll(',', ', ')
                                                : widget.communityDetail!
                                                .content.areas
                                                .map(
                                                    (e) => e.hangName)
                                                .toList()
                                                .join(',')
                                                .replaceAll(
                                                ',', ', '),
                                            style: TextStyle(
                                                color: AppColors.gray500,
                                                fontWeight: weightSet(
                                                    textWeight: TextWeight
                                                        .MEDIUM),
                                                fontSize: fontSizeSet(
                                                    textSize:
                                                    TextSize.T10)),
                                          ),
                                          spaceH(2),
                                          Row(
                                            children: [
                                              widget.communityDetail ==
                                                  null
                                                  ? bloc.communityInfo!
                                                  .status ==
                                                  'DONE'
                                                  ? Container(
                                                height: 16,
                                                padding: EdgeInsets
                                                    .only(
                                                    left: 5,
                                                    right:
                                                    5),
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .greenGray50,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        3)),
                                                child: Center(
                                                  child: customText(
                                                      '완료',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .greenGray600,
                                                          fontWeight:
                                                          weightSet(
                                                              textWeight: TextWeight
                                                                  .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T10))),
                                                ),
                                              )
                                                  : Container()
                                                  : widget.communityDetail!
                                                  .status ==
                                                  'DONE'
                                                  ? Container(
                                                height: 16,
                                                padding: EdgeInsets
                                                    .only(
                                                    left: 5,
                                                    right:
                                                    5),
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .greenGray50,
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        3)),
                                                child: Center(
                                                  child: customText(
                                                      '완료',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .greenGray600,
                                                          fontWeight:
                                                          weightSet(
                                                              textWeight: TextWeight
                                                                  .MEDIUM),
                                                          fontSize: fontSizeSet(
                                                              textSize: TextSize
                                                                  .T10))),
                                                ),
                                              )
                                                  : Container(),
                                              widget.communityDetail ==
                                                  null
                                                  ? bloc.communityInfo!
                                                  .status ==
                                                  'DONE'
                                                  ? spaceW(4)
                                                  : Container()
                                                  : widget.communityDetail!
                                                  .status ==
                                                  'DONE'
                                                  ? spaceW(4)
                                                  : Container(),
                                              customText(
                                                  widget.communityDetail ==
                                                      null
                                                      ? communityType(
                                                      communityTypeIdx(bloc
                                                          .communityInfo!
                                                          .category))
                                                      : communityType(
                                                      communityTypeIdx(widget
                                                          .communityDetail!
                                                          .content
                                                          .category)),
                                                  style: widget
                                                      .communityDetail ==
                                                      null
                                                      ? bloc.communityInfo!
                                                      .status ==
                                                      'DONE'
                                                      ? TextStyle(
                                                      color: AppColors
                                                          .greenGray600,
                                                      fontWeight: weightSet(
                                                          textWeight:
                                                          TextWeight.MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize: TextSize
                                                              .T10))
                                                      : TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize: TextSize
                                                              .T10))
                                                      : (widget.communityDetail!
                                                      .status == 'DONE'
                                                      ? TextStyle(
                                                      color: AppColors
                                                          .greenGray600,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize: TextSize
                                                              .T10))
                                                      : TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: weightSet(
                                                          textWeight: TextWeight
                                                              .MEDIUM),
                                                      fontSize: fontSizeSet(
                                                          textSize: TextSize
                                                              .T10))))
                                            ],
                                          ),
                                          spaceH(10)
                                        ],
                                      ),
                                    ),
                                    spaceW(10),
                                    Image.asset(
                                      AppImages.iGoToTrans,
                                      width: 18,
                                      height: 18,
                                    ),
                                    spaceW(14)
                                  ],
                                ),
                              ),
                            ),
                            bloc.classInfo == null && widget.content == null
                                ? Container()
                                : Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              padding:
                              EdgeInsets.only(left: 20, right: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (widget.detail) {
                                    pop(context);
                                  } else {
                                    if (bloc.classInfo!.type == 'MADE') {
                                      ClassDetailPage classDetailPage =
                                      ClassDetailPage(
                                        classUuid:
                                        bloc.classInfo!.classUuid,
                                        mainNeighborHood: dataSaver
                                            .neighborHood[
                                        dataSaver.neighborHood
                                            .indexWhere((element) =>
                                        element
                                            .representativeFlag ==
                                            1)],
                                        profileGet: dataSaver.profileGet,
                                        chatDetail: true,
                                      );
                                      dataSaver.keywordClassDetail =
                                          classDetailPage;
                                      pushTransition(
                                          context, classDetailPage)
                                          .then((value) {
                                        bloc.add(ChatDetailInitEvent(
                                            classUuid: widget.classUuid,
                                            chatRoomUuid:
                                            widget.chatRoomUuid));
                                      });
                                    } else {}
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: AppColors.gray100,
                                    padding: EdgeInsets.zero,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10))),
                                child: Row(
                                  children: [
                                    bloc.classInfo == null &&
                                        widget.content == null ||
                                        (bloc.classInfo == null
                                            ? false
                                            : bloc.classInfo!.type ==
                                            'REQUEST') ||
                                        (widget.content != null &&
                                            widget.content!.images!
                                                .length ==
                                                0)
                                        ? Container()
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.only(
                                          topLeft:
                                          Radius.circular(
                                              10),
                                          bottomLeft:
                                          Radius.circular(
                                              10)),
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        child: CacheImage(
                                          imageUrl: widget
                                              .content ==
                                              null
                                              ? '${bloc.classInfo!.image!
                                              .toView(context: context,)}'
                                              : '${widget.content!.images![0]
                                              .toView(context: context,)}',
                                          width:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    spaceW(14),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          spaceH(10),
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width,
                                            height: 20,
                                            child: customText(
                                              widget.content == null
                                                  ? bloc.classInfo!.title
                                                  : widget
                                                  .content!.title!,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color:
                                                  AppColors.gray600,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                      TextWeight
                                                          .MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize:
                                                      TextSize.T14)),
                                            ),
                                          ),
                                          spaceH(2),
                                          customText(
                                            widget.content == null
                                                ? bloc
                                                .classInfo!.hangNames
                                                .replaceAll(',', ', ')
                                                : widget.content!.areas!
                                                .map(
                                                    (e) => e.hangName)
                                                .toList()
                                                .join(',')
                                                .replaceAll(
                                                ',', ', '),
                                            style: TextStyle(
                                                color: AppColors.gray500,
                                                fontWeight: weightSet(
                                                    textWeight: TextWeight
                                                        .MEDIUM),
                                                fontSize: fontSizeSet(
                                                    textSize:
                                                    TextSize.T10)),
                                          ),
                                          spaceH(2),
                                          (widget.content == null
                                              ? bloc.classInfo!
                                              .costType
                                              : widget.content!
                                              .costType) ==
                                              'HOUR'
                                              ? Row(
                                            children: [
                                              customText(
                                                numberFormat.format(widget
                                                    .content ==
                                                    null
                                                    ? bloc
                                                    .classInfo!
                                                    .minCost
                                                    : widget
                                                    .content!
                                                    .minCost) +
                                                    '원',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .gray500,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                        TextWeight
                                                            .MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                        TextSize
                                                            .T10)),
                                              ),
                                            ],
                                          )
                                              : customText('배움나눔',
                                              style: TextStyle(
                                                  color: AppColors
                                                      .secondaryDark30,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                      TextWeight
                                                          .BOLD),
                                                  fontSize: fontSizeSet(
                                                      textSize:
                                                      TextSize
                                                          .T11))),
                                          spaceH(10),
                                        ],
                                      ),
                                    ),
                                    spaceW(10),
                                    Image.asset(
                                      AppImages.iGoToTrans,
                                      width: 18,
                                      height: 18,
                                    ),
                                    spaceW(14)
                                  ],
                                ),
                              ),
                            ),
                            bloc.classInfo == null && widget.content == null ||
                                bloc.members.isEmpty
                                ? Container()
                                : bloc
                                .members[bloc.members.indexWhere(
                                    (element) =>
                                element.member.memberUuid ==
                                    dataSaver
                                        .userData!.memberUuid)]
                                .classWriterFlag ==
                                1
                                ? (bloc.members.length == 2 &&
                                (bloc.members[0].messageCnt != null &&
                                    bloc.members[0].messageCnt > 0) &&
                                (bloc.members[1].messageCnt != null &&
                                    bloc.members[1].messageCnt > 0))
                                ? Container(
                              height: 24,
                              padding: EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  if (bloc.roomData!.classReviewSaveFlag == 1) {
                                    if (dataSaver.reviewDetailBloc != null) {
                                      pop(context);
                                      return;
                                    }

                                    if (bloc.chatSubscribe != null) {
                                      bloc.chatSubscribe();
                                      bloc.chatSubscribe = null;
                                    }
                                    if (bloc.readSubscribe != null) {
                                      bloc.readSubscribe();
                                      bloc.readSubscribe = null;
                                    }
                                    dataSaver.chatRoomUuid = null;
                                    if (connectivity !=
                                        null) await connectivity!.cancel();
                                    if (onChangeSub != null) await onChangeSub!
                                        .cancel();
                                    dataSaver.chatDetailBloc = null;

                                    amplitudeEvent('review_chat_check',
                                        bloc.classInfo!.toMap());

                                    pushTransition(context, ReviewDetailPage(
                                      classUuid: bloc.classInfo != null
                                          ? bloc.classInfo!.classUuid
                                          : bloc.classUuid!,
                                      myClass: bloc.members[bloc.members
                                          .indexWhere((element) =>
                                      element.member.memberUuid ==
                                          dataSaver.profileGet!.memberUuid)]
                                          .classWriterFlag == 0
                                          ? false
                                          : true,
                                      nickName: bloc.members[bloc.members
                                          .indexWhere((element) =>
                                      element.member.memberUuid !=
                                          dataSaver.userData!.memberUuid)]
                                          .member.nickName,)).then((value) {
                                      bloc.add(ChatDetailInitEvent(
                                          chatRoomUuid: widget.chatRoomUuid,
                                          classUuid: widget.classUuid));
                                    });
                                    return;
                                  }

                                  if (bloc.roomData!
                                      .classReviewNotiFlag ==
                                      0) {
                                    amplitudeEvent('review_chat_notice',
                                        bloc.classInfo!.toMap());
                                    await ReviewRepository
                                        .sendReviewAlarm(bloc
                                        .chatRoomUuid!)
                                        .then((value) {
                                      bloc.roomData!
                                          .classReviewNotiFlag = 1;
                                    });
                                  } else {
                                    showToast(text: '이미 알림 요청을 완료했어요',
                                        context: context,
                                        toastGravity: ToastGravity.CENTER);
                                  }
                                },
                                child: FadeTransition(
                                  opacity: animation,
                                  child: Row(
                                    children: [
                                      customText(
                                          bloc.roomData!
                                              .classReviewSaveFlag ==
                                              0
                                              ? '알림은 한 번만 보낼 수 있어요!'
                                              : '${bloc.members[bloc.members
                                              .indexWhere((element) =>
                                          element.member.memberUuid !=
                                              dataSaver.userData!.memberUuid)]
                                              .member
                                              .nickName}님이 후기를 남겨주셨어요 :)',
                                          style: TextStyle(
                                              color:
                                              AppColors.gray400,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                  TextWeight
                                                      .MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize
                                                      .T12))),
                                      spaceW(8),
                                      customText(
                                          bloc.roomData!
                                              .classReviewSaveFlag ==
                                              0
                                              ? '후기 알림주기 >'
                                              : '후기 보러가기 >'
                                          ,
                                          style: TextStyle(
                                              color:
                                              AppColors.primary,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                  TextWeight
                                                      .BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize
                                                      .T11)))
                                    ],
                                  ),
                                ),
                              ),
                            )
                                : Container()
                                :
                            bloc.members != null &&
                                (bloc.members.length == 2 &&
                                    (bloc.members[0].messageCnt != null &&
                                        bloc.members[0].messageCnt >
                                            0) &&
                                    (bloc.members[1].messageCnt != null &&
                                        bloc.members[1].messageCnt >
                                            0))
                                ? Container(
                              height: 24,
                              padding: EdgeInsets.only(left: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  if (bloc.roomData!
                                      .classReviewSaveFlag ==
                                      0) {
                                    amplitudeEvent('review_chat_register',
                                        bloc.classInfo!.toMap());
                                    if (bloc.chatSubscribe != null) {
                                      bloc.chatSubscribe();
                                      bloc.chatSubscribe = null;
                                    }
                                    if (bloc.readSubscribe != null) {
                                      bloc.readSubscribe();
                                      bloc.readSubscribe = null;
                                    }
                                    dataSaver.chatRoomUuid = null;
                                    if (connectivity !=
                                        null) await connectivity!.cancel();
                                    if (onChangeSub != null) await onChangeSub!
                                        .cancel();
                                    dataSaver.chatDetailBloc = null;

                                    pushTransition(context,
                                        CreateReviewPage(
                                          classUuid: bloc.classInfo != null
                                              ? bloc.classInfo!.classUuid
                                              : bloc.classUuid!,
                                          nickName: bloc.members[bloc.members
                                              .indexWhere((element) =>
                                          element.member.memberUuid !=
                                              dataSaver.userData!.memberUuid)]
                                              .member.nickName,))
                                        .then((value) {
                                      bloc.add(ChatDetailInitEvent(
                                          chatRoomUuid: widget.chatRoomUuid,
                                          classUuid: widget.classUuid));
                                      if (value != null && value) {
                                        bloc.roomData!.classReviewSaveFlag = 1;
                                        setState(() {});
                                      }
                                    });
                                  } else {
                                    if (dataSaver.reviewDetailBloc != null) {
                                      pop(context);
                                      return;
                                    }

                                    if (bloc.chatSubscribe != null) {
                                      bloc.chatSubscribe();
                                      bloc.chatSubscribe = null;
                                    }
                                    if (bloc.readSubscribe != null) {
                                      bloc.readSubscribe();
                                      bloc.readSubscribe = null;
                                    }
                                    dataSaver.chatRoomUuid = null;
                                    if (connectivity !=
                                        null) await connectivity!.cancel();
                                    if (onChangeSub != null) await onChangeSub!
                                        .cancel();
                                    dataSaver.chatDetailBloc = null;

                                    amplitudeEvent('review_chat_check',
                                        bloc.classInfo!.toMap());

                                    pushTransition(context, ReviewDetailPage(
                                      classUuid: bloc.classInfo != null
                                          ? bloc.classInfo!.classUuid
                                          : bloc.classUuid!,
                                      myClass: bloc.members[bloc.members
                                          .indexWhere((element) =>
                                      element.member.memberUuid ==
                                          dataSaver.profileGet!.memberUuid)]
                                          .classWriterFlag == 0
                                          ? false
                                          : true,
                                      nickName: bloc.members[bloc.members
                                          .indexWhere((element) =>
                                      element.member.memberUuid !=
                                          dataSaver.userData!.memberUuid)]
                                          .member.nickName,)).then((value) {
                                      bloc.add(ChatDetailInitEvent(
                                          chatRoomUuid: widget.chatRoomUuid,
                                          classUuid: widget.classUuid));
                                    });
                                  }
                                },
                                child: FadeTransition(
                                  opacity: animation,
                                  child: Row(
                                    children: [
                                      customText(
                                          '${widget.classUuid != null ? widget
                                              .userName! : bloc.members
                                              .length ==
                                              0 ? '' : bloc.members[bloc.members
                                              .indexWhere((element) =>
                                          element.member.memberUuid !=
                                              dataSaver.userData!.memberUuid)]
                                              .member.nickName}${bloc.roomData!
                                              .classReviewSaveFlag == 1
                                              ? '님께 후기를 남겼어요!'
                                              : '님의 클래스 들으셨다면'}',
                                          style: TextStyle(
                                              color:
                                              AppColors.gray400,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                  TextWeight
                                                      .MEDIUM),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize
                                                      .T12))),
                                      spaceW(8),
                                      customText(
                                          bloc.roomData!
                                              .classReviewSaveFlag ==
                                              0
                                              ? '후기 남기기 >'
                                              : '후기 보러가기 >',
                                          style: TextStyle(
                                              color:
                                              AppColors.primary,
                                              fontWeight: weightSet(
                                                  textWeight:
                                                  TextWeight
                                                      .BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize
                                                      .T11)))
                                    ],
                                  ),
                                ),
                              ),
                            )
                                : Container(),
                            Expanded(
                              child: Stack(
                                children: [
                                  bloc.talk.length == 0
                                      ? Container()
                                      : Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      bottom: ((currentLine > 2)
                                          ? 100
                                          : currentLine == 2
                                          ? 80
                                          : 60),
                                      child: Stack(
                                        children: [
                                          Container(
                                            child: chat(),
                                          ),
                                          bloc.chatJump
                                              ? Container()
                                              : Positioned.fill(
                                              child: Container(
                                                color: AppColors.white,
                                              ))
                                        ],
                                      )),
                                  Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        width:
                                        MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        height: ((currentLine > 2)
                                            ? 100
                                            : currentLine == 2
                                            ? 80
                                            : 60),
                                        color: AppColors.white,
                                        padding: EdgeInsets.only(
                                            left: 12, right: 12, bottom: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                    MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(8),
                                                        border: Border.all(
                                                            color: AppColors
                                                                .gray200)),
                                                  ),
                                                  Positioned(
                                                    left: 10,
                                                    top: 0,
                                                    bottom: 0,
                                                    child: Align(
                                                      alignment:
                                                      Alignment.centerLeft,
                                                      child: Container(
                                                        width: 24,
                                                        height: 24,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            if (!bloc
                                                                .menuOpen) {
                                                              FocusScope.of(
                                                                  context)
                                                                  .unfocus();
                                                            } else {
                                                              FocusScope.of(
                                                                  context)
                                                                  .requestFocus(
                                                                  msgFocus);
                                                            }
                                                            bloc.add(
                                                                SettingControlEvent(
                                                                    control:
                                                                    false));
                                                            bloc.add(
                                                                MenuOpenEvent());
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                              primary: bloc
                                                                  .menuOpen
                                                                  ? AppColors
                                                                  .errorLight10
                                                                  : AppColors
                                                                  .accentLight20,
                                                              elevation: 0,
                                                              padding:
                                                              EdgeInsets
                                                                  .zero,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      4))),
                                                          child: Center(
                                                            child: Image.asset(
                                                              bloc.menuOpen
                                                                  ? AppImages.iX
                                                                  : AppImages
                                                                  .iPlusW,
                                                              color: AppColors
                                                                  .white,
                                                              width: 16,
                                                              height: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 48,
                                                    top: 0,
                                                    bottom: 0,
                                                    right: 10,
                                                    child: LayoutBuilder(
                                                        builder:
                                                            (context, size) {
                                                          final span = TextSpan(
                                                              text: msgController
                                                                  .text,
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .gray900,
                                                                  fontWeight: weightSet(
                                                                      textWeight:
                                                                      TextWeight
                                                                          .MEDIUM),
                                                                  fontSize: fontSizeSet(
                                                                      textSize:
                                                                      TextSize
                                                                          .T14)));
                                                          final tp = TextPainter(
                                                              text: span,
                                                              textDirection:
                                                              TextDirection
                                                                  .ltr);
                                                          tp.layout(
                                                              maxWidth:
                                                              size.maxWidth -
                                                                  36);

                                                          return TextFormField(
                                                              maxLines: null,
                                                              // autofocus: true,
                                                              onTap: () {
                                                                if (bloc
                                                                    .menuOpen) {
                                                                  bloc.add(
                                                                      MenuOpenEvent());
                                                                }
                                                                bloc.add(
                                                                    SettingControlEvent(
                                                                        control:
                                                                        false));
                                                              },
                                                              controller:
                                                              msgController,
                                                              focusNode: msgFocus,
                                                              keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                              textInputAction:
                                                              TextInputAction
                                                                  .newline,
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .gray900,
                                                                  fontWeight: weightSet(
                                                                      textWeight:
                                                                      TextWeight
                                                                          .MEDIUM),
                                                                  fontSize: fontSizeSet(
                                                                      textSize: TextSize
                                                                          .T14)),
                                                              onChanged: (
                                                                  text) {
                                                                currentLine = tp
                                                                    .computeLineMetrics()
                                                                    .length;
                                                                blankCheck(
                                                                    text: text,
                                                                    controller:
                                                                    msgController,
                                                                    multiline:
                                                                    true);
                                                                setState(() {});
                                                              },
                                                              decoration: InputDecoration(
                                                                  isDense: false,
                                                                  isCollapsed:
                                                                  false,
                                                                  contentPadding:
                                                                  EdgeInsets
                                                                      .only(
                                                                      top: 0,
                                                                      bottom:
                                                                      0),
                                                                  hintText:
                                                                  '메시지를 입력하세요',
                                                                  hintStyle: TextStyle(
                                                                      color: AppColors
                                                                          .gray400,
                                                                      fontWeight:
                                                                      weightSet(
                                                                          textWeight: TextWeight
                                                                              .REGULAR),
                                                                      fontSize: fontSizeSet(
                                                                          textSize: TextSize
                                                                              .T13)),
                                                                  border: InputBorder
                                                                      .none));
                                                        }),
                                                  )
                                                ],
                                              ),
                                            ),
                                            spaceW(10),
                                            Container(
                                              width: 48,
                                              height: 48,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (!bloc.sendDisable &&
                                                      !bloc.lock &&
                                                      !bloc.loading) {
                                                    bloc.sendDisable = true;
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 300),
                                                            () {
                                                          bloc.sendDisable =
                                                          false;
                                                        });
                                                    if (msgController
                                                        .text.length !=
                                                        0) {
                                                      bloc.type = 'TALK';
                                                      bloc.add(SendMessageEvent(
                                                          msg: msgController
                                                              .text));
                                                      currentLine = 0;
                                                      msgController.text = '';
                                                    }
                                                  }
                                                },
                                                child: Center(
                                                  child: Image.asset(
                                                    AppImages.iChatSendingW,
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                    primary: AppColors.primary,
                                                    elevation: 0,
                                                    padding: EdgeInsets.zero,
                                                    shape:
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            8))),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bloc.menuOpen
                        ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0 + dataSaver.iosBottom,
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: plusMenuHeight.toDouble(),
                        color: AppColors.accentLight60.withOpacity(0.6),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: ListView.builder(
                          itemBuilder: (context, idx) {
                            return plusMenu(menus[idx]);
                          },
                          shrinkWrap: true,
                          itemCount: menus.length,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    )
                        : Container(),
                    bloc.members.length != 0
                        ? Positioned(
                        top: 40,
                        right: 20,
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.16),
                                  blurRadius: 6,
                                  offset: Offset(0, 0))
                            ],
                          ),
                          duration: Duration(milliseconds: 300),
                          width: bloc.settingOpen ? 180 : 0,
                          padding: EdgeInsets.only(top: 10, bottom: 8),
                          child: Column(
                            children: [
                              // settingMenu(0),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                height: 40,
                                padding:
                                EdgeInsets.only(left: 20, right: 20),
                                child: Row(
                                  children: [
                                    customText('채팅 알림',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight:
                                                TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14))),
                                    Expanded(child: Container()),
                                    FlutterSwitch(
                                      width: 46,
                                      height: 24,
                                      onToggle: (value) {
                                        bloc.add(ReceiveEvent(
                                            noticeReceiveFlag: bloc
                                                .members[bloc
                                                .members
                                                .indexWhere((element) =>
                                            element
                                                .member
                                                .memberUuid ==
                                                dataSaver
                                                    .userData!
                                                    .memberUuid)]
                                                .noticeReceiveFlag ==
                                                0
                                                ? 1
                                                : 0));
                                      },
                                      padding: 2,
                                      borderRadius: 49,
                                      duration: Duration(milliseconds: 100),
                                      activeColor: AppColors.accent,
                                      inactiveColor: AppColors.gray100,
                                      value: bloc
                                          .members[bloc.members
                                          .indexWhere((element) =>
                                      element.member
                                          .memberUuid ==
                                          dataSaver
                                              .userData!
                                              .memberUuid)]
                                          .noticeReceiveFlag ==
                                          0
                                          ? false
                                          : true,
                                      toggleSize: 20,
                                      inactiveIcon: ClipOval(
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                            child: Image.asset(
                                              AppImages.iAlarmKillG,
                                              width: 14,
                                              height: 14,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 1,
                                                  offset: Offset(0, 1)),
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2))
                                            ],
                                          ),
                                        ),
                                      ),
                                      activeIcon: ClipOval(
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                            child: Image.asset(
                                              AppImages.iAlarm,
                                              width: 14,
                                              height: 14,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 1,
                                                  offset: Offset(0, 1)),
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2))
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              spaceH(10),
                              heightLine(
                                  height: 1, color: AppColors.gray200),
                              spaceH(10),
                              settingMenu(1),
                              settingMenu(2),
                              settingMenu(3),
                            ],
                          ),
                        ))
                        : Container(),
                    // loadingView(bloc.loading)
                  ],
                ),
              ),
            ),
          );
        });
  }

  settingIcon(int set) {
    switch (set) {
      case 0:
        return bloc
            .members[bloc.members.indexWhere((element) =>
        element.member.memberUuid ==
            dataSaver.userData!.memberUuid)]
            .noticeReceiveFlag ==
            1
            ? AppImages.iAlarmKillG
            : AppImages.iAlarm;
      case 1:
        return AppImages.iWarningCe;
      case 2:
        return AppImages.iBlockLeaveA;
      case 3:
        return AppImages.iDoorP;
    }
  }

  settingText(int set) {
    switch (set) {
      case 0:
        return bloc
            .members[bloc.members.indexWhere((element) =>
        element.member.memberUuid ==
            dataSaver.userData!.memberUuid)]
            .noticeReceiveFlag ==
            1
            ? '알림 끄기'
            : '알림 켜기';
      case 1:
        return '신고하기';
      case 2:
        return '차단하고 나가기';
      case 3:
        return '채팅방 나가기';
    }
  }

  AnimationController? exitController;

  exit(int flag) {
    return ListView(
      shrinkWrap: true,
      children: [
        spaceH(28),
        SizedBox(
          width: 135,
          height: 135,
          child: Center(
            child: Lottie.asset(
                flag == 0 ? AppImages.chatOut : AppImages.chatBlockOut,
                controller: exitController, onLoaded: (composition) {
              setState(() {
                exitController!.reset();
                exitController!
                  ..duration = composition.duration;
                exitController!.forward();
              });
            }),
          ),
        ),
        Container(
          height: 24,
          child: customText(
            flag == 0 ? '채팅방을 나갈까요?' : '차단하고 나갈까요?',
            style: TextStyle(
                color: AppColors.gray900,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T17)),
            textAlign: TextAlign.center,
          ),
        ),
        spaceH(20),
        customText(
          flag == 0
              ? '채팅방을 나가면,\n대화 내용도 함께 삭제돼요'
              : '차단하면 채팅방을 나가면서\n대화 내용도 삭제돼요',
          style: TextStyle(
              color: AppColors.gray600,
              fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
              fontSize: fontSizeSet(textSize: TextSize.T12)),
          textAlign: TextAlign.center,
        ),
        spaceH(60),
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.primary))),
                    child: Center(
                      child: customText(
                        AppStrings.of(StringKey.cancel),
                        style: TextStyle(
                            color: AppColors.primaryDark10,
                            fontWeight:
                            weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14)),
                      ),
                    ),
                  ),
                ),
              ),
              spaceW(12),
              Expanded(
                  child: bottomButton(
                      context: context,
                      text: flag == 0 ? '나가기' : '차단하기',
                      onPress: () {
                        if (flag == 0) {
                          bloc.add(ExitEvent());
                        } else {
                          bloc.add(ExitBlockEvent());
                        }
                      }))
            ],
          ),
        )
      ],
    );
  }

  settingMenu(int set) {
    return GestureDetector(
      onTap: () {
        bloc.add(SettingControlEvent(control: false));
        if (set == 0) {
          bloc.add(ReceiveEvent(
              noticeReceiveFlag: bloc
                  .members[bloc.members.indexWhere((element) =>
              element.member.memberUuid ==
                  dataSaver.userData!.memberUuid)]
                  .noticeReceiveFlag ==
                  0
                  ? 1
                  : 0));
        } else if (set == 1) {
          pushTransition(
              context,
              ChatReportPage(
                chatRoomUuid: bloc.chatRoomUuid!,
                defendantUuid: bloc
                    .members[bloc.members.indexWhere((element) =>
                element.member.memberUuid !=
                    dataSaver.userData!.memberUuid)]
                    .member
                    .memberUuid,
              ));
        } else if (set == 2) {
          customDialog(context: context, barrier: false, widget: exit(1));
        } else if (set == 3) {
          customDialog(context: context, barrier: false, widget: exit(0));
        }
      },
      child: Container(
        height: 40,
        color: AppColors.white,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Flexible(
              child: Image.asset(
                set == 0
                    ? AppImages.iAlarmKillG
                    : set == 1
                    ? AppImages.iWarningCe
                    : set == 2
                    ? AppImages.iBlockLeaveA
                    : AppImages.iDoorP,
                width: 16,
                height: 16,
              ),
            ),
            spaceW(8),
            customText(
              bloc.members.length == 0 ? '' : settingText(set),
              style: TextStyle(
                  decoration: TextDecoration.none,
                  color: AppColors.gray900,
                  fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                  fontSize: fontSizeSet(textSize: TextSize.T14)),
            )
          ],
        ),
      ),
    );
  }

  StreamSubscription? onChangeSub;
  StreamSubscription? connectivity;

  bool opacityAnimationRun = false;

  runAnimation() {
    if (!opacityAnimationRun) {
      opacityAnimationRun = true;
      animationTimer = Timer(Duration(milliseconds: 1200), () async {
        await controller!.forward();
        await controller!.reverse();
        await controller!.forward();
        await controller!.reverse();
      });
    }
  }

  bool mobileNone = false;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = Tween(begin: 1.0, end: 0.0).animate(controller!);
    super.initState();
    dataSaver.chatDetailContext = context;
    connectivity = Connectivity().onConnectivityChanged.listen((event) async {
      if (event == ConnectivityResult.none) {
        bloc.networkNone = true;
        mobileNone = true;
      } else {
        bloc.networkNone = false;
      }
      if (bloc.chatSubscribe != null) {
        await bloc.chatSubscribe();
        bloc.chatSubscribe = null;
      }

      if (bloc.readSubscribe != null) {
        await bloc.readSubscribe();
        bloc.readSubscribe = null;
      }

      if (mobileNone)
        bloc.add(ChatDetailInitEvent(
            chatRoomUuid: widget.chatRoomUuid, classUuid: widget.classUuid));
    });

    exitController = AnimationController(vsync: this);
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        if (bloc.chatSubscribe != null) {
          await bloc.chatSubscribe();
          bloc.chatSubscribe = null;
        }

        if (bloc.readSubscribe != null) {
          await bloc.readSubscribe();
          bloc.readSubscribe = null;
        }

        bloc.add(ChatDetailInitEvent(
            chatRoomUuid: widget.chatRoomUuid, classUuid: widget.classUuid));
      } else if (msg == AppLifecycleState.inactive.toString()) {
        if (bloc.chatSubscribe != null) {
          bloc.chatSubscribe();
          bloc.chatSubscribe = null;
        }
        if (bloc.readSubscribe != null) {
          bloc.readSubscribe();
          bloc.readSubscribe = null;
        }
      }
    });

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      int progress = data[2];
      if (progress == 100) {
        bloc.talk[bloc.dataIndex].path = bloc.savePath;
        bloc.loading = false;
        bloc.add(ReloadChatDetailEvent(save: true));
      }
    });

    onChangeSub = keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible && dataSaver.chatDetailBloc != null) {
        FocusScope.of(context).unfocus();
      }
    });

    scrollController = ScrollController()
      ..addListener(() {
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < scrollController!.offset) &&
            scrollController!.offset >=
                scrollController!.position.maxScrollExtent &&
            !scrollController!.position.outOfRange) {
          bloc.scrollUnder = true;
          bloc.bottomOffset = scrollController!.offset;
        }

        if (scrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
        }

        if (scrollController!.offset <=
            scrollController!.position.minScrollExtent +
                scrollController!.position.maxScrollExtent * 0.3 &&
            !scrollController!.position.outOfRange) {
          bloc.add(GetDataEvent());
        }
      });
  }

  check() async {
    if (bloc.chatSubscribe != null) {
      await bloc.chatSubscribe();
      bloc.chatSubscribe = null;
    }
    if (bloc.readSubscribe != null) {
      await bloc.readSubscribe();
      bloc.readSubscribe = null;
    }
  }

  @override
  void dispose() {
    dataSaver.chatDetailContext = null;
    animationTimer.cancel();
    if (controller!.isAnimating) {
      controller!.stop();
    }
    controller!.dispose();
    exitController!.dispose();
    check();
    onChangeSub?.cancel();
    connectivity?.cancel();
    dataSaver.chatDetailBloc = null;
    dataSaver.chatRoomUuid = null;
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    SystemChannels.lifecycle.setMessageHandler((message) async {});
    super.dispose();
  }

  @override
  blocListener(BuildContext context, state) async {
    if (bloc.members.length == 2 &&
        (bloc.members[0].messageCnt != null &&
            bloc.members[0].messageCnt > 0) &&
        (bloc.members[1].messageCnt != null &&
            bloc.members[1].messageCnt > 0)) {
      runAnimation();
    }

    if (state is ChatDetailReloadState) {
      setState(() {});
    }

    if (state is ChatCacheSendState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients && bloc.scrollUnder) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is ChatDetailBlocSetState) {
      dataSaver.chatDetailBloc = bloc;
    }

    if (state is ChatDetailInitState) {
      dataSaver.chatDetailBloc = bloc;
      if (bloc.roomData!
          .classReviewSaveFlag ==
          0) runAnimation();
      if (state.unread) {
        if (bloc.talkData.length != 0) {
          for (int i = 0; i < bloc.talkData.length; i++) {
            if (bloc.talkData[i].unreadCnt == 1) {
              bloc.talkData[i].unreadCnt = 0;
            }
          }
        }
        if (bloc.talk.length != 0) {
          for (int i = 0; i < bloc.talk.length; i++) {
            if (bloc.talk[i].unreadCnt == 1) {
              bloc.talk[i].unreadCnt = 0;
            }
          }
          List<String> talkBackUp =
          bloc.talk.map((e) => jsonEncode(e.toMap())).toList();
          await prefs!.setString(bloc.chatRoomUuid!, jsonEncode(talkBackUp));
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });

      if (msgController.text == '')
        msgController.text = prefs!.getString('text${bloc.chatRoomUuid}') ?? '';

      if (widget.chatHelp != null && !sendHelp) {
        sendHelp = true;
        bloc.type = 'TALK';
        bloc.add(SendMessageEvent(
            msg: widget.chatHelp!.msg, subType: widget.chatHelp!.subType));
      }

      setState(() {});
    }

    if (state is ReadUpdateState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients && bloc.scrollUnder) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is ReadMessageState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients && bloc.scrollUnder) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is SendMessageState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is MenuOpenState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients && bloc.scrollUnder) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is ReloadChatDetailState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is SendFileState) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (scrollController!.hasClients) {
          scrollController!.jumpTo(scrollController!.position.maxScrollExtent);
          bloc.chatJump = true;
        }
      });
      setState(() {});
    }

    if (state is ExitState) {
      if (bloc.chatSubscribe != null) {
        bloc.chatSubscribe();
        bloc.chatSubscribe = null;
      }
      if (bloc.readSubscribe != null) {
        bloc.readSubscribe();
        bloc.readSubscribe = null;
      }
      dataSaver.chatRoomUuid = null;
      popDialog(context);
      pop(context);
    }

    if (state is ExitBlockState) {
      if (bloc.chatSubscribe != null) {
        bloc.chatSubscribe();
        bloc.chatSubscribe = null;
      }
      if (bloc.readSubscribe != null) {
        bloc.readSubscribe();
        bloc.readSubscribe = null;
      }
      dataSaver.chatRoomUuid = null;
      popDialog(context);
      popWithResult(context, 'BLOCK');
    }

    if (state is FileSizeOverState) {
      showToast(context: context, text: '용량은 10MB 이하로 업로드 가능해요');
    }

    if (state is ReceiveState) {
      setState(() {});
    }
  }

  @override
  ChatDetailBloc initBloc() {
    return ChatDetailBloc(context)
      ..add(ChatDetailInitEvent(
          chatRoomUuid: widget.chatRoomUuid,
          classUuid: widget.classUuid,
          communityUuid: widget.communityUuid,
          classCheck: widget.classCheck,
          communityCheck: widget.communityCheck));
  }
}
