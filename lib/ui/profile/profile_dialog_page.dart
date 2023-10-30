import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/common.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/community_detail/community_detail_bloc.dart';
import 'package:baeit/ui/community_detail/community_detail_page.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/ui/learn/learn_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/profile/profile_dialog_bloc.dart';
import 'package:baeit/ui/profile/profile_page.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/extensions.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/utils/text_hint.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDialogPage extends BlocStatefulWidget {
  final String memberUuid;

  ProfileDialogPage({required this.memberUuid});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return ProfileDialogState();
  }
}

class ProfileDialogState
    extends BlocState<ProfileDialogBloc, ProfileDialogPage> {
  ScrollController? classScrollController;
  ScrollController? communityScrollController;

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              setState(() {
                bloc.moreView = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))),
              child: Container(
                height: MediaQuery.of(context).size.height - 60,
                child: Stack(
                  children: [
                    bloc.profileGet != null
                        ? Positioned.fill(
                            left: 0,
                            right: 0,
                            top: 60,
                            bottom: 0,
                            child: SingleChildScrollView(
                              controller: bloc.viewTap == 0
                                  ? classScrollController!
                                  : communityScrollController!,
                              child: Column(
                                children: [
                                  memberProfile(),
                                  selectViewTap(),
                                  IndexedStack(
                                    index: bloc.viewTap,
                                    children: [
                                      Stack(
                                        children: [
                                          noClassView(),
                                          bloc.viewTap == 0
                                              ? classList()
                                              : Container()
                                        ],
                                      ),
                                      Stack(
                                        children: [
                                          noCommunityView(),
                                          bloc.viewTap == 1
                                              ? communityList()
                                              : Container()
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: controlTap(),
                    ),
                    Positioned(
                        top: 16,
                        right: 60,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          width: bloc.moreView ? 180 : 0,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.black.withOpacity(0.16),
                                  blurRadius: 6,
                                  offset: Offset(0, 0))
                            ],
                          ),
                          child: Column(
                            children: [
                              spaceH(10),
                              ElevatedButton(
                                onPressed: () {
                                  amplitudeEvent('user_block', {
                                    'block_member': widget.memberUuid,
                                    'member': dataSaver.profileGet!.memberUuid
                                  });
                                  bloc.add(UserBlockEvent(
                                      memberUuid: widget.memberUuid));
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: AppColors.white,
                                    padding: EdgeInsets.zero,
                                    elevation: 0),
                                child: Row(
                                  children: [
                                    spaceW(20),
                                    Image.asset(
                                      AppImages.iBlockLeaveA,
                                      width: 16,
                                      height: 16,
                                    ),
                                    spaceW(8),
                                    customText('차단하기',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T14)))
                                  ],
                                ),
                              ),
                              spaceH(10)
                            ],
                          ),
                        )),
                    loadingView(bloc.loading)
                  ],
                ),
              ),
            ),
          );
        });
  }

  controlTap() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: Row(
        children: [
          Expanded(child: Container()),
          dataSaver.profileGet != null &&
                  bloc.profileGet?.memberUuid ==
                      dataSaver.profileGet?.memberUuid
              ? Container()
              : IconButton(
                  onPressed: () {
                    setState(() {
                      bloc.moreView = true;
                    });
                  },
                  padding: EdgeInsets.zero,
                  icon: Image.asset(
                    AppImages.iMore,
                    width: 24,
                    height: 24,
                  ),
                ),
          spaceW(16),
          GestureDetector(
            onTap: () {
              popDialog(context);
            },
            child: Container(
              width: 24,
              height: 24,
              color: AppColors.white,
              child: Image.asset(
                AppImages.iX,
                width: 24,
                height: 24,
              ),
            ),
          ),
          spaceW(20)
        ],
      ),
    );
  }

  noClassView() {
    return bloc.classList == null || bloc.classList!.classData.length == 0
        ? Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                spaceH(40),
                Image.asset(
                  AppImages.imgEmptyList,
                  height: 160,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    customTextSpan(
                        text: bloc.profileGet!.nickName + " ",
                        style: TextStyle(
                            color: AppColors.accentLight20,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14))),
                    customTextSpan(
                        text: '님의 클래스가\n지금 없어요',
                        style: TextStyle(
                            color: AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14))),
                  ]),
                )
              ],
            ),
          )
        : Container();
  }

  noCommunityView() {
    return bloc.communityList == null ||
            bloc.communityList!.communityData.length == 0
        ? Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                spaceH(40),
                Image.asset(
                  AppImages.imgEmptyRequest,
                  height: 160,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    customTextSpan(
                        text: bloc.profileGet!.nickName + " ",
                        style: TextStyle(
                            color: AppColors.accentLight20,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14))),
                    customTextSpan(
                        text: '님의 게시글이\n지금 없어요',
                        style: TextStyle(
                            color: AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T14))),
                  ]),
                )
              ],
            ),
          )
        : Container();
  }

  memberProfile() {
    return Column(
      children: [
        spaceH(10),
        Align(
          alignment: Alignment.center,
          child: bloc.profileGet!.profile == null
              ? Image.asset(
                  AppImages.dfProfileC,
                  width: 80,
                  height: 80,
                )
              : Container(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: CacheImage(
                      imageUrl: bloc.profileGet!.profile!,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      placeholder: Image.asset(
                        AppImages.dfProfile,
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                ),
        ),
        spaceH(24),
        customText(
          bloc.profileGet!.nickName,
          style: TextStyle(
              color: AppColors.gray900,
              fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
              fontSize: fontSizeSet(textSize: TextSize.T17)),
          textAlign: TextAlign.center,
        ),
        dataSaver.profileGet != null &&
                bloc.profileGet!.memberUuid == dataSaver.profileGet!.memberUuid
            ? spaceH(10)
            : Container(),
        dataSaver.profileGet != null &&
                bloc.profileGet!.memberUuid == dataSaver.profileGet!.memberUuid
            ? Container(
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    amplitudeEvent('profile_set_enter', {});
                    pushTransition(
                        context,
                        ProfilePage(
                          profile: dataSaver.profileGet,
                          type: dataSaver.profileGet!.type,
                        )).then((value) {
                      dataSaver.myBaeitBloc!.add(UpdateDataEvent());
                      if (value != null && value) {
                        bloc.add(ProfileDialogInitEvent(
                            memberUuid: widget.memberUuid));
                        dataSaver.myBaeitBloc!.add(UpdateProfileEvent());
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.secondaryLight30,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      padding: EdgeInsets.only(left: 10, right: 12),
                      elevation: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppImages.iEditUnderSd,
                        width: 16,
                        height: 16,
                        color: AppColors.secondaryDark30,
                      ),
                      spaceW(4),
                      customText('프로필 수정',
                          style: TextStyle(
                              color: AppColors.secondaryDark30,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T12)))
                    ],
                  ),
                ),
              )
            : Container(),
        bloc.profileGet!.introText == null ? Container() : spaceH(20),
        bloc.profileGet!.introText == null
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: 80, right: 80),
                child: Linkify(
                  onOpen: (link) async {
                    await launch(link.url).then((value) {
                      systemColorSetting();
                    });
                  },
                  style: TextStyle(
                      color: AppColors.gray600,
                      fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                      fontSize: fontSizeSet(textSize: TextSize.T13)),
                  linkStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: weightSet(textWeight: TextWeight.REGULAR),
                      fontSize: fontSizeSet(textSize: TextSize.T13)),
                  text: bloc.profileGet!.introText ?? '',
                  textAlign: TextAlign.start,
                  options: LinkifyOptions(humanize: true),
                ),
              ),
        spaceH(40)
      ],
    );
  }

  selectViewTap() {
    return Row(
      children: [
        spaceW(20),
        Expanded(
            child: Container(
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              bloc.add(ViewTapChangeEvent(index: 0));
            },
            style: ElevatedButton.styleFrom(
                primary:
                    bloc.viewTap == 0 ? AppColors.primary : AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)),
                    side: BorderSide(
                        width: bloc.viewTap == 0 ? 0 : 1,
                        color: AppColors.gray200))),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(
                    '클래스',
                    style: TextStyle(
                        color: bloc.viewTap == 0
                            ? AppColors.white
                            : AppColors.gray400,
                        fontWeight: weightSet(
                            textWeight: bloc.viewTap == 0
                                ? TextWeight.BOLD
                                : TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                  bloc.classList == null || bloc.classList!.totalRow == 0
                      ? Container()
                      : spaceW(4),
                  bloc.classList == null || bloc.classList!.totalRow == 0
                      ? Container()
                      : Container(
                          height: 16,
                          padding: EdgeInsets.only(left: 16 / 3, right: 16 / 3),
                          decoration: BoxDecoration(
                              color: bloc.viewTap == 0
                                  ? AppColors.secondaryLight10
                                  : AppColors.primaryLight20,
                              borderRadius: BorderRadius.circular(16 / 6)),
                          child: Center(
                            child: customText(
                                bloc.classList == null
                                    ? 0.toString()
                                    : bloc.classList!.totalRow.toString(),
                                style: TextStyle(
                                    color: bloc.viewTap == 1
                                        ? AppColors.white
                                        : AppColors.primaryDark10,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T10))),
                          ),
                        )
                ],
              ),
            ),
          ),
        )),
        Expanded(
            child: Container(
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              bloc.add(ViewTapChangeEvent(index: 1));
            },
            style: ElevatedButton.styleFrom(
                primary:
                    bloc.viewTap == 1 ? AppColors.primary : AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    side: BorderSide(
                        width: bloc.viewTap == 1 ? 0 : 1,
                        color: AppColors.gray200))),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(
                    '게시글',
                    style: TextStyle(
                        color: bloc.viewTap == 1
                            ? AppColors.white
                            : AppColors.gray400,
                        fontWeight: weightSet(
                            textWeight: bloc.viewTap == 1
                                ? TextWeight.BOLD
                                : TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T13)),
                  ),
                  bloc.communityList == null ||
                          bloc.communityList!.totalRow == 0
                      ? Container()
                      : spaceW(4),
                  bloc.communityList == null ||
                          bloc.communityList!.totalRow == 0
                      ? Container()
                      : Container(
                          height: 16,
                          padding: EdgeInsets.only(left: 16 / 3, right: 16 / 3),
                          decoration: BoxDecoration(
                              color: bloc.viewTap == 1
                                  ? AppColors.secondaryLight10
                                  : AppColors.primaryLight20,
                              borderRadius: BorderRadius.circular(16 / 6)),
                          child: Center(
                            child: customText(
                                bloc.communityList == null
                                    ? 0.toString()
                                    : bloc.communityList!.totalRow.toString(),
                                style: TextStyle(
                                    color: bloc.viewTap == 1
                                        ? AppColors.primaryDark10
                                        : AppColors.white,
                                    fontWeight:
                                        weightSet(textWeight: TextWeight.BOLD),
                                    fontSize:
                                        fontSizeSet(textSize: TextSize.T10))),
                          ),
                        )
                ],
              ),
            ),
          ),
        )),
        spaceW(20)
      ],
    );
  }

  classList() {
    return Column(
      children: [
        spaceH(20),
        ListView.builder(
          itemBuilder: (context, idx) {
            return GestureDetector(
              onTap: () {
                if (dataSaver.chatDetailBloc != null &&
                    dataSaver.chatDetailBloc!.classInfo != null) {
                  if (dataSaver.chatDetailBloc!.classInfo!.classUuid ==
                      bloc.classList!.classData[idx].classUuid) {
                    ClassDetailPage classDetailPage = ClassDetailPage(
                      heroTag: 'listImage$idx',
                      classUuid: bloc.classList!.classData[idx].classUuid,
                      mainNeighborHood: dataSaver.neighborHood[
                          dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1)],
                      bloc: bloc,
                      selectIndex: idx,
                      profileGet: dataSaver.nonMember ? null : bloc.profileGet,
                      inputPage: 'main',
                      chatDetail: true,
                      profileDialogCheck: true,
                    );
                    dataSaver.keywordClassDetail = classDetailPage;
                    pushTransition(context, classDetailPage).then((value) {
                      if (value != null) {
                        if (value == 'closeDialog') {
                          popDialog(context);
                        }
                        dataSaver.learnBloc!.add(ReloadClassEvent());
                      }
                      bloc.add(ProfileDialogInitEvent(
                          memberUuid: widget.memberUuid));
                    });
                  } else {
                    ClassDetailPage classDetailPage = ClassDetailPage(
                      heroTag: 'listImage$idx',
                      classUuid: bloc.classList!.classData[idx].classUuid,
                      mainNeighborHood: dataSaver.neighborHood[
                          dataSaver.neighborHood.indexWhere(
                              (element) => element.representativeFlag == 1)],
                      bloc: bloc,
                      selectIndex: idx,
                      profileGet: dataSaver.nonMember ? null : bloc.profileGet,
                      inputPage: 'main',
                    );
                    dataSaver.keywordClassDetail = classDetailPage;
                    pushTransition(context, classDetailPage).then((value) {
                      bloc.add(ProfileDialogInitEvent(
                          memberUuid: widget.memberUuid));
                      if (value != null) {
                        dataSaver.learnBloc!.add(ReloadClassEvent());
                      }
                    });
                  }
                } else {
                  if (bloc.classList!.classData[idx].mineFlag == 0) {
                    classEvent(
                        'totals_class_clicks',
                        bloc.classList!.classData[idx].classUuid,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .lati!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .longi!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .sidoName!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .sigunguName!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .eupmyeondongName!,
                        firstFree: bloc.classList!.classData[idx].content
                                    .firstFreeFlag ==
                                0
                            ? false
                            : true,
                        group:
                            bloc.classList!.classData[idx].content.groupFlag ==
                                    0
                                ? false
                                : true,
                        groupCost: bloc
                            .classList!.classData[idx].content.costOfPerson
                            .toString());
                    classEvent(
                        'class_clicks',
                        bloc.classList!.classData[idx].classUuid,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .lati!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .longi!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .sidoName!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .sigunguName!,
                        dataSaver
                            .neighborHood[dataSaver.neighborHood.indexWhere(
                                (element) => element.representativeFlag == 1)]
                            .eupmyeondongName!,
                        firstFree: bloc.classList!.classData[idx].content
                                    .firstFreeFlag ==
                                0
                            ? false
                            : true,
                        group:
                            bloc.classList!.classData[idx].content.groupFlag ==
                                    0
                                ? false
                                : true,
                        groupCost: bloc
                            .classList!.classData[idx].content.costOfPerson
                            .toString());
                  }
                  ClassDetailPage classDetailPage = ClassDetailPage(
                    heroTag: 'listImage$idx',
                    classUuid: bloc.classList!.classData[idx].classUuid,
                    mainNeighborHood: dataSaver.neighborHood[
                        dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)],
                    bloc: bloc,
                    selectIndex: idx,
                    profileGet: dataSaver.nonMember ? null : bloc.profileGet,
                    inputPage: 'main',
                  );
                  dataSaver.keywordClassDetail = classDetailPage;
                  pushTransition(context, classDetailPage).then((value) {
                    bloc.add(
                        ProfileDialogInitEvent(memberUuid: widget.memberUuid));
                    if (value != null) {
                      dataSaver.learnBloc!.add(ReloadClassEvent());
                    }
                  });
                }
              },
              child: Container(
                color: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 128,
                              height: 72,
                              child: bloc.classList!.classData[idx].content
                                          .image ==
                                      null
                                  ? Image.asset(
                                      AppImages.dfClassMain,
                                      width: 128,
                                      height: 72,
                                    )
                                  : CacheImage(
                                      imageUrl: bloc.classList!.classData[idx]
                                          .content.image!
                                          .toView(context: context,
                                          w: MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .toInt()),
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                      placeholder: Image.asset(
                                        AppImages.dfClassMain,
                                        width: 128,
                                        height: 72,
                                      ),
                                    ),
                            ),
                          ),
                          spaceW(16),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        text: TextSpan(children: [
                                          customTextSpan(
                                              text: bloc
                                                      .classList!
                                                      .classData[idx]
                                                      .content
                                                      .title! +
                                                  " ",
                                              style: TextStyle(
                                                  color: AppColors.gray900,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T14))),
                                          customTextSpan(
                                              text: bloc
                                                  .classList!
                                                  .classData[idx]
                                                  .content
                                                  .category!
                                                  .name!,
                                              style: TextStyle(
                                                  color: AppColors.gray500,
                                                  fontWeight: weightSet(
                                                      textWeight:
                                                          TextWeight.MEDIUM),
                                                  fontSize: fontSizeSet(
                                                      textSize: TextSize.T11))),
                                        ]),
                                      ),
                                    )
                                  ],
                                ),
                                spaceH(6),
                                Container(
                                  height: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      bloc.classList!.classData[idx].content
                                                  .groupFlag ==
                                              1
                                          ? Row(
                                              children: [
                                                Container(
                                                  height: 20,
                                                  padding: EdgeInsets.only(
                                                      left: 6, right: 6),
                                                  child: Center(
                                                      child: customText('그룹할인',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .white,
                                                              fontWeight: weightSet(
                                                                  textWeight:
                                                                      TextWeight
                                                                          .BOLD),
                                                              fontSize: fontSizeSet(
                                                                  textSize:
                                                                      TextSize
                                                                          .T10)))),
                                                  decoration: BoxDecoration(
                                                      color: AppColors.accent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                ),
                                                spaceW(6)
                                              ],
                                            )
                                          : Container(),
                                      bloc.classList!.classData[idx].content
                                                  .groupFlag ==
                                              1
                                          ? spaceW(2)
                                          : Container(),
                                      customText(
                                          bloc.classList!.classData[idx].content
                                                      .costType ==
                                                  'HOUR'
                                              ? '${numberFormatter(bloc.classList!.classData[idx].content.groupFlag == 1 ? bloc.classList!.classData[idx].content.costOfPerson : bloc.classList!.classData[idx].content.minCost!)}원 ~'
                                              : '배움나눔',
                                          style: TextStyle(
                                              color: bloc
                                                          .classList!
                                                          .classData[idx]
                                                          .content
                                                          .costType ==
                                                      'HOUR'
                                                  ? AppColors.gray900
                                                  : AppColors.secondaryDark30,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T14)))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      spaceH(20)
                    ],
                  ),
                ),
              ),
            );
          },
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount:
              bloc.classList == null ? 0 : bloc.classList!.classData.length,
        ),
      ],
    );
  }

  communityList() {
    return Column(
      children: [
        spaceH(20),
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, idx) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: GestureDetector(
                      onTap: () {
                        if (bloc.communityList!.communityData[idx].mineFlag ==
                            0) {
                          amplitudeEvent('community_clicks', {
                            'type': communityTypeCreate(communityTypeIdx(bloc
                                .communityList!
                                .communityData[idx]
                                .content
                                .category)),
                            'bookmark_count':
                                bloc.communityList!.communityData[idx].likeCnt,
                            'chat_count':
                                bloc.communityList!.communityData[idx].chatCnt,
                            'share_count':
                                bloc.communityList!.communityData[idx].shareCnt,
                            'view_count':
                                bloc.communityList!.communityData[idx].readCnt,
                            'comment_count': bloc
                                .communityList!.communityData[idx].commentCnt,
                            'user_id': bloc.communityList!.communityData[idx]
                                .member.memberUuid,
                            'user_name': bloc.communityList!.communityData[idx]
                                .member.nickName,
                            'community_id': bloc.communityList!
                                .communityData[idx].communityUuid,
                            'distance': bloc.communityList!.communityData[idx]
                                .content.distance,
                            'status':
                                bloc.communityList!.communityData[idx].status,
                            'hang_name': bloc.communityList!.communityData[idx]
                                .content.hangNames
                          });
                        }
                        pushTransition(
                            context,
                            CommunityDetailPage(
                              communityUuid: bloc.communityList!
                                  .communityData[idx].communityUuid,
                              profileDialogCheck: true,
                            ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: AppColors.gray200, width: 1)),
                        padding: EdgeInsets.only(top: 12, bottom: 12),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  customText(
                                      bloc.communityList!.communityData[idx]
                                          .content.contentText!,
                                      style: TextStyle(
                                          color: AppColors.gray900,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.REGULAR),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T14)),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis),
                                  spaceH(20),
                                  Row(
                                    children: [
                                      customText(
                                          bloc
                                                      .communityList!
                                                      .communityData[idx]
                                                      .content
                                                      .hangNames
                                                      .length >
                                                  12
                                              ? '${bloc.communityList!.communityData[idx].content.hangNames.substring(0, 12)}...'
                                              : bloc
                                                  .communityList!
                                                  .communityData[idx]
                                                  .content
                                                  .hangNames,
                                          style: TextStyle(
                                              color: AppColors.greenGray500,
                                              fontWeight: weightSet(
                                                  textWeight: TextWeight.BOLD),
                                              fontSize: fontSizeSet(
                                                  textSize: TextSize.T12))),
                                      spaceW(8),
                                      Container(
                                        width: 1,
                                        height: 10,
                                        color: AppColors.gray300,
                                      ),
                                      spaceW(8),
                                      customText(
                                        DateTime.now()
                                                    .difference(bloc
                                                        .communityList!
                                                        .communityData[idx]
                                                        .content
                                                        .createDate)
                                                    .inMinutes >
                                                14400
                                            ? bloc
                                                .communityList!
                                                .communityData[idx]
                                                .content
                                                .createDate
                                                .yearMonthDay
                                            : timeCalculationText(DateTime.now()
                                                .difference(bloc
                                                    .communityList!
                                                    .communityData[idx]
                                                    .content
                                                    .createDate)
                                                .inMinutes),
                                        style: TextStyle(
                                            color: AppColors.gray500,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T11)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            spaceH(12),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 1,
                              color: AppColors.gray200,
                            ),
                            spaceH(12),
                            Padding(
                              padding: EdgeInsets.only(left: 12, right: 12),
                              child: Row(
                                children: [
                                  bloc.communityList!.communityData[idx]
                                              .status ==
                                          'DONE'
                                      ? Container(
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20 / 6),
                                            color: AppColors.gray200,
                                          ),
                                          padding: EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Center(
                                            child: customText('완료',
                                                style: TextStyle(
                                                    color: AppColors.gray500,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.BOLD),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T10))),
                                          ),
                                        )
                                      : Container(),
                                  bloc.communityList!.communityData[idx]
                                              .status ==
                                          'DONE'
                                      ? spaceW(6)
                                      : Container(),
                                  customText(
                                      communityType(communityTypeIdx(bloc
                                          .communityList!
                                          .communityData[idx]
                                          .content
                                          .category)),
                                      style: TextStyle(
                                          color: bloc
                                                      .communityList!
                                                      .communityData[idx]
                                                      .status ==
                                                  'DONE'
                                              ? AppColors.gray500
                                              : AppColors.primary,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.BOLD),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12))),
                                  Expanded(child: Container()),
                                  customText(
                                      '조회 ${bloc.communityList!.communityData[idx].readCnt}',
                                      style: TextStyle(
                                          color: AppColors.gray600,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12))),
                                  spaceW(10),
                                  Image.asset(
                                    AppImages.iChatG,
                                    width: 16,
                                    height: 16,
                                  ),
                                  spaceW(4),
                                  customText(
                                      bloc.communityList!.communityData[idx]
                                                  .commentCnt ==
                                              0
                                          ? '댓글달기 >'
                                          : bloc.communityList!
                                              .communityData[idx].commentCnt
                                              .toString(),
                                      style: TextStyle(
                                          color: AppColors.gray600,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T12)))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  spaceH(20)
                ],
              );
            },
            shrinkWrap: true,
            itemCount: bloc.communityList == null
                ? 0
                : bloc.communityList!.communityData.length),
      ],
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is ProfileDialogInitState) {
      dataSaver.profileDialogBloc = bloc;
    }

    if (state is UserBlockState) {
      if (dataSaver.learnBloc != null) {
        dataSaver.learnBloc!.add(ReloadClassEvent());
        dataSaver.learnBloc!.add(CommunityReloadEvent());
      }
      if (dataSaver.communityDetailBloc != null) {
        popDialog(context);
        if (dataSaver.communityDetailBloc!.communityDetail!.member.memberUuid ==
            bloc.memberUuid) {
          dataSaver.communityDetailBloc!.add(CommunityBlockUserEvent());
        }
        dataSaver.communityDetailBloc!.add(CommunityDetailInitEvent(
            communityUuid: dataSaver.communityDetailBloc!.communityUuid));
      }
      if (dataSaver.gatherBloc != null) {
        dataSaver.gatherBloc!.add(GatherInitEvent());
      }
    }
  }

  @override
  ProfileDialogBloc initBloc() {
    return ProfileDialogBloc(context)
      ..add(ProfileDialogInitEvent(memberUuid: widget.memberUuid));
  }

  @override
  void initState() {
    super.initState();

    classScrollController = ScrollController()
      ..addListener(() {
        if (classScrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.bottomOffset = 0;
          bloc.scrollUnder = false;
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < classScrollController!.offset) &&
            classScrollController!.offset >=
                classScrollController!.position.maxScrollExtent &&
            !classScrollController!.position.outOfRange) {
          bloc.scrollUnder = true;
          bloc.bottomOffset = classScrollController!.offset;
        }
        if (!bloc.scrollUnder &&
            (bloc.bottomOffset == 0 ||
                bloc.bottomOffset < classScrollController!.offset) &&
            classScrollController!.offset >=
                (classScrollController!.position.maxScrollExtent * 0.7) &&
            !classScrollController!.position.outOfRange) {
          bloc.add(NewMemberClassDataEvent());
        }
      });

    communityScrollController = ScrollController()
      ..addListener(() {
        if (communityScrollController!.position.userScrollDirection ==
            ScrollDirection.forward) {
          bloc.communityBottomOffset = 0;
          bloc.communityScrollUnder = false;
        }
        if (!bloc.communityScrollUnder &&
            (bloc.communityBottomOffset == 0 ||
                bloc.communityBottomOffset <
                    communityScrollController!.offset) &&
            communityScrollController!.offset >=
                communityScrollController!.position.maxScrollExtent &&
            !communityScrollController!.position.outOfRange) {
          bloc.communityScrollUnder = true;
          bloc.communityBottomOffset = communityScrollController!.offset;
        }
        if (!bloc.communityScrollUnder &&
            (bloc.communityBottomOffset == 0 ||
                bloc.communityBottomOffset <
                    communityScrollController!.offset) &&
            communityScrollController!.offset >=
                (communityScrollController!.position.maxScrollExtent * 0.7) &&
            !communityScrollController!.position.outOfRange) {
          bloc.add(NewMemberClassDataEvent());
        }
      });
  }
}
