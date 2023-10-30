import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/data/class/class.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/gather/gather_bloc.dart';
import 'package:baeit/ui/gather/gather_detail_page.dart';
import 'package:baeit/ui/main/main_bloc.dart';
import 'package:baeit/ui/my_baeit/my_baeit_bloc.dart';
import 'package:baeit/ui/recent_or_bookmark/recent_or_bookmark_page.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GatherPage extends BlocStatefulWidget {
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return GatherState();
  }
}

class GatherState extends BlocState<GatherBloc, GatherPage> {
  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            color: AppColors.white,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: AppColors.white,
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        bloc.bookmarkClass == null ||
                                bloc.bookmarkClass!.totalRow == 0 ||
                                bloc.bookmarkClass!.classData.length == 0 ||
                                (bloc.bookmarkClass!.classData.length == 1 &&
                                    bloc.bookmarkClass!.classData[0].hide)
                            ? Container()
                            : bookmarkClassView(),
                        gatherClassList()
                      ],
                    ),
                  ),
                ),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  bookmarkClassView() {
    return Container(
      color: AppColors.primaryLight40,
      padding: EdgeInsets.only(top: 20, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText('내가 찜한\n클래스',
                    style: TextStyle(
                        color: AppColors.primaryDark10,
                        fontWeight: weightSet(textWeight: TextWeight.BOLD),
                        fontSize: fontSizeSet(textSize: TextSize.T16))),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    amplitudeEvent('gather_view_more', {'type': 'bookmark'});
                    pushTransition(
                            context,
                            RecentOrBookmarkPage(
                                type: 'BOOKMARK',
                                profileGet: dataSaver.profileGet!))
                        .then((value) {
                      dataSaver.myBaeitBloc!.add(UpdateDataEvent());
                      if (value != null && value == 0) {
                        dataSaver.mainBloc!.add(MenuChangeEvent(select: value));
                      } else if (value == 2) {
                        dataSaver.mainBloc!.add(MenuChangeEvent(select: value));
                      }
                    });
                  },
                  child: customText('더보기 >',
                      style: TextStyle(
                          color: AppColors.greenGray600.withOpacity(0.6),
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T12))),
                )
              ],
            ),
          ),
          spaceH(24),
          bookmarkClassList(),
        ],
      ),
    );
  }

  bookmarkClassList() {
    return Container(
      height: 238,
      child: ListView.builder(
        addRepaintBoundaries: false,
        addAutomaticKeepAlives: false,
        itemBuilder: (context, idx) {
          if (bloc.bookmarkClass!.classData[idx].hide) {
            return Container();
          } else {
            return bookmarkClassItem(idx);
          }
        },
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 14, right: 14),
        shrinkWrap: true,
        itemCount: bloc.bookmarkClass!.classData.length,
      ),
    );
  }

  bookmarkClassItem(int idx) {
    return Padding(
      padding: EdgeInsets.only(left: 6, right: 6, bottom: 28),
      child: Container(
        width: 148,
        height: 238,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 14,
              child: GestureDetector(
                onTap: () {
                  airbridgeEvent('class_view');
                  amplitudeEvent('totals_class_clicks', {
                    'themeType': 'bookmark',
                    'townSido': dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .sidoName,
                    'townSigungu': dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .sigunguName,
                    'townDongeupmyeon': dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .eupmyeondongName,
                    'costMin':
                        bloc.bookmarkClass!.classData[idx].content.minCost!,
                    'costType':
                        bloc.bookmarkClass!.classData[idx].content.costType ==
                                'HOUR'
                            ? 0
                            : 1,
                    'costSharing':
                        bloc.bookmarkClass!.classData[idx].content.shareType ??
                            '',
                    'classId': bloc.bookmarkClass!.classData[idx].classUuid,
                    'className':
                        bloc.bookmarkClass!.classData[idx].content.title,
                    'userId': dataSaver.nonMember
                        ? null
                        : dataSaver.profileGet!.memberUuid,
                    'userName': dataSaver.nonMember
                        ? null
                        : dataSaver.profileGet!.nickName,
                    'first_free': bloc.bookmarkClass!.classData[idx].content
                                .firstFreeFlag ==
                            0
                        ? false
                        : true,
                    'group':
                        bloc.bookmarkClass!.classData[idx].content.groupFlag ==
                                0
                            ? false
                            : true,
                    'group_cost': bloc
                        .bookmarkClass!.classData[idx].content.costOfPerson
                        .toString()
                  });
                  amplitudeEvent('gather_class_clicks', {
                    'themeType': 'bookmark',
                    'townSido': dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .sidoName,
                    'townSigungu': dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .sigunguName,
                    'townDongeupmyeon': dataSaver
                        .neighborHood[dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)]
                        .eupmyeondongName,
                    'costMin':
                        bloc.bookmarkClass!.classData[idx].content.minCost!,
                    'costType':
                        bloc.bookmarkClass!.classData[idx].content.costType ==
                                'HOUR'
                            ? 0
                            : 1,
                    'costSharing':
                        bloc.bookmarkClass!.classData[idx].content.shareType ??
                            '',
                    'classId': bloc.bookmarkClass!.classData[idx].classUuid,
                    'className':
                        bloc.bookmarkClass!.classData[idx].content.title,
                    'userId': dataSaver.nonMember
                        ? null
                        : dataSaver.profileGet!.memberUuid,
                    'userName': dataSaver.nonMember
                        ? null
                        : dataSaver.profileGet!.nickName,
                    'first_free': bloc.bookmarkClass!.classData[idx].content
                                .firstFreeFlag ==
                            0
                        ? false
                        : true,
                    'group':
                        bloc.bookmarkClass!.classData[idx].content.groupFlag ==
                                0
                            ? false
                            : true,
                    'group_cost': bloc
                        .bookmarkClass!.classData[idx].content.costOfPerson
                        .toString()
                  });
                  ClassDetailPage classDetailPage = ClassDetailPage(
                    heroTag: 'listImage$idx',
                    classUuid: bloc.bookmarkClass!.classData[idx].classUuid,
                    mainNeighborHood: dataSaver.neighborHood[
                        dataSaver.neighborHood.indexWhere(
                            (element) => element.representativeFlag == 1)],
                    bloc: bloc,
                    selectIndex: idx,
                    profileGet: dataSaver.profileGet!,
                    my: true,
                    inputPage: 'gather_bookmark',
                  );
                  dataSaver.keywordClassDetail = classDetailPage;
                  pushTransition(context, classDetailPage).then((value) {
                    bloc.add(BookmarkReloadEvent());
                  });
                },
                child: Container(
                  width: 148,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 18,
                          offset: Offset(6, 6))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      spaceH(12),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: bloc.bookmarkClass!.classData[idx].member
                                        .profile ==
                                    null
                                ? Image.asset(
                                    AppImages.dfProfile,
                                    width: 16,
                                    height: 16,
                                  )
                                : Container(
                                    width: 16,
                                    height: 16,
                                    child: CacheImage(
                                      placeholder: Image.asset(
                                        AppImages.dfProfile,
                                        width: 16,
                                        height: 16,
                                      ),
                                      imageUrl: bloc.bookmarkClass!
                                          .classData[idx].member.profile!,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          spaceW(4),
                          customText(
                              '${bloc.bookmarkClass!.classData[idx].member.nickName.length > 8 ? bloc.bookmarkClass!.classData[idx].member.nickName.substring(0, 8) + '...' : bloc.bookmarkClass!.classData[idx].member.nickName}',
                              style: TextStyle(
                                  color: AppColors.gray500,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.MEDIUM),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T11)))
                        ],
                      ),
                      spaceH(8),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 72,
                            child: CacheImage(
                              width: MediaQuery.of(context).size.width,
                              placeholder: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 72,
                                decoration: BoxDecoration(
                                    color: AppColors.gray200,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Image.asset(
                                  AppImages.dfClassMain,
                                  width: MediaQuery.of(context).size.width,
                                  height: 72,
                                ),
                              ),
                              imageUrl: bloc
                                  .bookmarkClass!.classData[idx].content.image!
                                  .toView(context: context,
                                  w: MediaQuery.of(context)
                                          .size
                                          .width
                                          .toInt()),
                              fit: BoxFit.cover,
                            ),
                          )
                          // CachedNetworkImage(
                          //   imageUrl: bloc
                          //       .bookmarkClass!.classData[idx].content.image!
                          //       .toView(
                          //           w: MediaQuery.of(context).size.width ~/
                          //               1.5),
                          //   errorWidget: (context, error, _) {
                          //     return CachedNetworkImage(
                          //       imageUrl: bloc.bookmarkClass!.classData[idx]
                          //           .content.image!
                          //           .toView(
                          //               w: MediaQuery.of(context).size.width ~/
                          //                   1.5,
                          //               image: false),
                          //       fit: BoxFit.cover,
                          //     );
                          //   },
                          //   placeholder: (context, a) {
                          //     return Container(
                          //       width: MediaQuery.of(context).size.width,
                          //       height: 72,
                          //       decoration: BoxDecoration(
                          //           color: AppColors.gray200,
                          //           borderRadius: BorderRadius.circular(4)),
                          //       child: Image.asset(
                          //         AppImages.dfClassMain,
                          //         width: MediaQuery.of(context).size.width,
                          //         height: 72,
                          //       ),
                          //     );
                          //   },
                          //   width: MediaQuery.of(context).size.width,
                          //   height: 72,
                          //   fit: BoxFit.cover,
                          // )
                          ),
                      spaceH(8),
                      customText(
                          '${bloc.bookmarkClass!.classData[idx].content.title}',
                          style: TextStyle(
                              color: AppColors.gray900,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.MEDIUM),
                              fontSize: fontSizeSet(textSize: TextSize.T14)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      spaceH(8),
                      bloc.bookmarkClass!.classData[idx].content.costType ==
                              'HOUR'
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    customTextSpan(
                                        text: '시간당 ',
                                        style: TextStyle(
                                            color: AppColors.gray900,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.MEDIUM),
                                            fontSize: fontSizeSet(
                                                textSize: TextSize.T12))),
                                    customTextSpan(
                                        text:
                                            '${numberFormatter(bloc.bookmarkClass!.classData[idx].content.minCost!)}원 ~',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: weightSet(
                                                textWeight: TextWeight.BOLD),
                                            fontSize: fontSizeSet(
                                                textSize: bloc
                                                            .bookmarkClass!
                                                            .classData[idx]
                                                            .content
                                                            .minCost!
                                                            .toString()
                                                            .length >
                                                        7
                                                    ? TextSize.T12
                                                    : TextSize.T14)))
                                  ])),
                            )
                          : customText('배움나눔',
                              style: TextStyle(
                                  color: AppColors.secondaryDark30,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T14)))
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 0,
                right: 10,
                child: Image.asset(
                  AppImages.iHeartClipC,
                  width: 30,
                  height: 30,
                ))
          ],
        ),
      ),
    );
  }

  gatherClassList() {
    return ListView.builder(
      addRepaintBoundaries: false,
      addAutomaticKeepAlives: false,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return gatherClassListItem(idx);
      },
      shrinkWrap: true,
      itemCount: bloc.classTheme.length,
    );
  }

  gatherClassListItem(int idx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        spaceH(24),
        GestureDetector(
          onTap: () {
            amplitudeEvent('gather_view_more',
                {'type': 'gather', 'themeType': bloc.classTheme[idx].title});
            pushTransition(
                context,
                GatherDetailPage(
                    curationThemeUuid: bloc.classTheme[idx].curationThemeUuid,
                    title: bloc.classTheme[idx].title));
          },
          child: Container(
            color: AppColors.white,
            child: Row(
              children: [
                spaceW(20),
                Container(
                  width: 18,
                  height: 18,
                  child: CacheImage(
                    fit: BoxFit.cover,
                    placeholder: Container(),
                    imageUrl: bloc.classTheme[idx].image.toView(context: context, ),
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                spaceW(6),
                Expanded(
                    child: customText('${bloc.classTheme[idx].title}',
                        style: TextStyle(
                            color: AppColors.gray900,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T16)),
                        overflow: TextOverflow.ellipsis)),
                spaceW(4),
                customText('더보기 >',
                    style: TextStyle(
                        color: AppColors.gray500,
                        fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                        fontSize: fontSizeSet(textSize: TextSize.T12))),
                spaceW(20)
              ],
            ),
          ),
        ),
        spaceH(20),
        Container(
          height: 208,
          child: ListView.builder(
            itemBuilder: (context, classIdx) {
              return gatherClassItem(
                  bloc.classTheme[idx].classList[classIdx], idx);
            },
            shrinkWrap: true,
            itemCount: bloc.classTheme[idx].classList.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 12, right: 12),
          ),
        ),
        spaceH(20),
        idx == bloc.classTheme.length - 1
            ? Container()
            : heightLine(height: 6, color: AppColors.gray100)
      ],
    );
  }

  gatherClassItem(Class classData, int themeIdx) {
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8),
      child: GestureDetector(
        onTap: () {
          airbridgeEvent('class_view');
          amplitudeEvent('totals_class_clicks', {
            'themeType': bloc.classTheme[themeIdx].title,
            'townSido': dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .sidoName,
            'townSigungu': dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .sigunguName,
            'townDongeupmyeon': dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .eupmyeondongName,
            'costMin': classData.content.minCost!,
            'costType': classData.content.costType == 'HOUR' ? 0 : 1,
            'costSharing': classData.content.shareType ?? '',
            'classId': classData.classUuid,
            'className': classData.content.title,
            'userId':
                dataSaver.nonMember ? null : dataSaver.profileGet!.memberUuid,
            'userName':
                dataSaver.nonMember ? null : dataSaver.profileGet!.nickName,
            'first_free': classData.content.firstFreeFlag == 0 ? false : true,
            'group': classData.content.groupFlag == 0 ? false : true,
            'group_cost': classData.content.costOfPerson.toString()
          });
          amplitudeEvent('gather_class_clicks', {
            'themeType': bloc.classTheme[themeIdx].title,
            'townSido': dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .sidoName,
            'townSigungu': dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .sigunguName,
            'townDongeupmyeon': dataSaver
                .neighborHood[dataSaver.neighborHood
                    .indexWhere((element) => element.representativeFlag == 1)]
                .eupmyeondongName,
            'costMin': classData.content.minCost!,
            'costType': classData.content.costType == 'HOUR' ? 0 : 1,
            'costSharing': classData.content.shareType ?? '',
            'classId': classData.classUuid,
            'className': classData.content.title,
            'userId':
                dataSaver.nonMember ? null : dataSaver.profileGet!.memberUuid,
            'userName':
                dataSaver.nonMember ? null : dataSaver.profileGet!.nickName,
            'first_free': classData.content.firstFreeFlag == 0 ? false : true,
            'group': classData.content.groupFlag == 0 ? false : true,
            'group_cost': classData.content.costOfPerson.toString()
          });
          dataSaver.themeType = bloc.classTheme[themeIdx].title;
          ClassDetailPage classDetailPage = ClassDetailPage(
            heroTag: 'listImage${classData.classUuid}',
            classUuid: classData.classUuid,
            mainNeighborHood: dataSaver.neighborHood[dataSaver.neighborHood
                .indexWhere((element) => element.representativeFlag == 1)],
            bloc: bloc,
            profileGet: dataSaver.nonMember ? null : dataSaver.profileGet,
            inputPage: 'gather_class',
          );
          dataSaver.keywordClassDetail = classDetailPage;
          pushTransition(context, classDetailPage).then((value) {
            if (value != null) {
              bloc.add(BookmarkReloadEvent());
            }
          });
        },
        child: Container(
          width: 128,
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 72,
                    child: CacheImage(
                      width: MediaQuery.of(context).size.width,
                      placeholder: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 72,
                        decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(4)),
                        child: Image.asset(
                          AppImages.dfClassMain,
                          width: MediaQuery.of(context).size.width,
                          height: 72,
                        ),
                      ),
                      imageUrl: classData.content.image!.toView(context: context, ),
                      fit: BoxFit.cover,
                    ),
                  )
                  // CachedNetworkImage(
                  //   imageUrl: classData.content.image!
                  //       .toView(w: MediaQuery.of(context).size.width ~/ 2),
                  //   memCacheWidth: MediaQuery.of(context).size.width ~/ 2,
                  //   memCacheHeight: 72,
                  //   width: MediaQuery.of(context).size.width / 2,
                  //   cacheKey: classData.classUuid,
                  //   key: Key('test'),
                  //   placeholder: (context, a) {
                  //     return Container(
                  //       width: MediaQuery.of(context).size.width,
                  //       height: 72,
                  //       decoration: BoxDecoration(
                  //           color: AppColors.gray200,
                  //           borderRadius: BorderRadius.circular(4)),
                  //       child: Image.asset(
                  //         AppImages.dfClassMain,
                  //         width: MediaQuery.of(context).size.width,
                  //         height: 72,
                  //       ),
                  //     );
                  //   },
                  //   errorWidget: (context, error, _) {
                  //     return CachedNetworkImage(
                  //       imageUrl: classData.content.image!.toView(
                  //           w: MediaQuery.of(context).size.width ~/ 1.5,
                  //           image: false),
                  //       width: MediaQuery.of(context).size.width,
                  //       height: 72,
                  //       fit: BoxFit.cover,
                  //     );
                  //   },
                  //   height: 72,
                  //   fit: BoxFit.cover,
                  // )
                  ),
              spaceH(8),
              customText(
                '${double.parse(classData.content.distance).toString().split('.')[0].length > 3 ? '${(double.parse(classData.content.distance) / 1000) > 20 ? '20km+' : '${(double.parse(classData.content.distance) / 1000).toStringAsFixed(1)}km'} ${classData.content.hangNames.split(',')[0]}' : '${double.parse(classData.content.distance).toString().split('.')[0].length == 3 ? (double.parse(classData.content.distance) / 100.ceil()).toString().split('.')[0] + "00" : double.parse(classData.content.distance).toString().split('.')[0]}m ${classData.content.hangNames.split(',')[0]}'}',
                style: TextStyle(
                    color: AppColors.greenGray500,
                    fontWeight: weightSet(textWeight: TextWeight.BOLD),
                    fontSize: fontSizeSet(textSize: TextSize.T12)),
                overflow: TextOverflow.ellipsis,
              ),
              spaceH(4),
              customText(classData.content.title!,
                  style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                      fontSize: fontSizeSet(textSize: TextSize.T14)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              spaceH(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: classData.member.profile == null
                        ? Image.asset(
                            AppImages.dfProfile,
                            width: 16,
                            height: 16,
                          )
                        : Container(
                            width: 16,
                            height: 16,
                            child: CacheImage(
                              placeholder: Image.asset(
                                AppImages.dfProfile,
                                width: 16,
                                height: 16,
                              ),
                              fit: BoxFit.cover,
                              imageUrl: classData.member.profile!,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                  ),
                  spaceW(4),
                  customText(
                      classData.member.nickName.length > 8
                          ? classData.member.nickName.substring(0, 8) + '...'
                          : classData.member.nickName,
                      style: TextStyle(
                          color: AppColors.gray500,
                          fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                          fontSize: fontSizeSet(textSize: TextSize.T11)))
                ],
              ),
              spaceH(16),
              Row(
                children: [
                  classData.content.groupFlag == 1
                      ? Row(
                          children: [
                            Container(
                              height: 20,
                              padding: EdgeInsets.only(left: 6, right: 6),
                              child: Center(
                                  child: customText('그룹할인',
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.BOLD),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T10)))),
                              decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            spaceW(6)
                          ],
                        )
                      : Container(),
                  classData.content.costType == 'HOUR'
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                customTextSpan(
                                    text:
                                        '${numberFormatter(classData.content.groupFlag == 0 ? classData.content.minCost! : classData.content.costOfPerson)}원 ~',
                                    style: TextStyle(
                                        color: AppColors.gray900,
                                        fontWeight: weightSet(
                                            textWeight: TextWeight.BOLD),
                                        fontSize: fontSizeSet(
                                            textSize: classData.content.minCost!
                                                        .toString()
                                                        .length >
                                                    7
                                                ? TextSize.T12
                                                : TextSize.T14)))
                              ])),
                        )
                      : customText('배움나눔',
                          style: TextStyle(
                              color: AppColors.secondaryDark30,
                              fontWeight:
                                  weightSet(textWeight: TextWeight.BOLD),
                              fontSize: fontSizeSet(textSize: TextSize.T14)))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is GatherInitState) {
      dataSaver.gatherBloc = bloc;
    }
  }

  @override
  GatherBloc initBloc() {
    return GatherBloc(context)..add(GatherInitEvent(loading: true));
  }
}
