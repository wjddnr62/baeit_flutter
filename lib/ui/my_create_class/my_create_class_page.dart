import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:baeit/config/base_bloc.dart';
import 'package:baeit/config/base_service.dart';
import 'package:baeit/config/config.dart';
import 'package:baeit/data/class/repository/class_repository.dart';
import 'package:baeit/data/common/return_data.dart';
import 'package:baeit/data/profile/profile.dart';
import 'package:baeit/resource/app_colors.dart';
import 'package:baeit/resource/app_images.dart';
import 'package:baeit/resource/app_strings.dart';
import 'package:baeit/resource/app_text_style.dart';
import 'package:baeit/ui/class_detail/class_detail_page.dart';
import 'package:baeit/ui/create_class/create_class_page.dart';
import 'package:baeit/ui/my_create_class/my_create_class_bloc.dart';
import 'package:baeit/utils/data_saver.dart';
import 'package:baeit/utils/event.dart';
import 'package:baeit/utils/number_format.dart';
import 'package:baeit/utils/page_move.dart';
import 'package:baeit/widgets/appbar.dart';
import 'package:baeit/widgets/line.dart';
import 'package:baeit/widgets/loading.dart';
import 'package:baeit/widgets/space.dart';
import 'package:baeit/widgets/stop_view.dart';
import 'package:baeit/widgets/toast.dart';
import 'package:baeit/utils/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class MyCreateClassPage extends BlocStatefulWidget {
  final ProfileGet? profile;
  final int? selectTap;

  MyCreateClassPage({this.profile, this.selectTap});

  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return MyCreateClassState();
  }
}

class MyCreateClassState
    extends BlocState<MyCreateClassBloc, MyCreateClassPage> {
  ScrollController? scrollController;

  tapText(index) {
    switch (index) {
      case 0:
        return AppStrings.of(StringKey.all);
      case 1:
        return AppStrings.of(StringKey.inOperation);
      case 2:
        return AppStrings.of(StringKey.temporarily);
      case 3:
        return AppStrings.of(StringKey.suspensionOfOperation);
    }
  }

  top() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      child: Row(
        children: [
          customText(
            '총 ${bloc.classList != null ? bloc.classList!.totalRow : 0} 건',
            style: TextStyle(
                color: AppColors.gray400,
                fontWeight: weightSet(textWeight: TextWeight.MEDIUM),
                fontSize: fontSizeSet(textSize: TextSize.T12)),
          ),
          Expanded(child: Container()),
          Container(
            height: 16,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    bloc.add(MyCreateTapChangeEvent(tap: index));
                  },
                  child: Row(
                    children: [
                      customText(
                        tapText(index),
                        style: TextStyle(
                            color: bloc.selectTap == index
                                ? AppColors.gray900
                                : AppColors.gray400,
                            fontWeight:
                                weightSet(textWeight: TextWeight.MEDIUM),
                            fontSize: fontSizeSet(textSize: TextSize.T12)),
                        textAlign: TextAlign.end,
                      ),
                      index != 3 ? spaceW(8) : Container(),
                      index != 3 ? widthOneLine(10) : Container(),
                      index != 3 ? spaceW(8) : Container()
                    ],
                  ),
                );
              },
              shrinkWrap: true,
              itemCount: 4,
              scrollDirection: Axis.horizontal,
            ),
          )
        ],
      ),
    );
  }

  statusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return AppColors.error;
      case 'TEMP':
        return AppColors.secondaryDark20;
      case 'STOP':
        return AppColors.gray600;
      default:
        return AppColors.black;
    }
  }

  statusText(String status) {
    switch (status) {
      case 'NORMAL':
        return AppStrings.of(StringKey.normal);
      case 'TEMP':
        return AppStrings.of(StringKey.temp);
      case 'STOP':
        return AppStrings.of(StringKey.stop);
      default:
        return '';
    }
  }

  classListItem(int index) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                // if (bloc.classList!.classData[index].status == 'TEMP') {
                //   pushTransition(
                //       context,
                //       CreateClassPage(
                //         profileGet: dataSaver.profileGet!,
                //         edit: true,
                //         temp: bloc.classList!.classData[index].status == 'TEMP'
                //             ? true
                //             : false,
                //         classUuid: bloc.classList!.classData[index].classUuid,
                //         ing: bloc.classList!.classData[index].status == 'NORMAL'
                //             ? true
                //             : false,
                //         stop: false,
                //         previousPage: 'connected_out_register',
                //       )).then((value) {
                //     bloc.add(MyCreateReloadEvent());
                //     if (value != null) {
                //       ClassDetailPage classDetailPage = ClassDetailPage(
                //         profileGet: widget.profile,
                //         heroTag: 'listImage$index',
                //         bloc: bloc,
                //         classUuid: bloc.classList!.classData[index].classUuid,
                //         mainNeighborHood: bloc.mainNeighborHood,
                //         my: true,
                //       );
                //       dataSaver.keywordClassDetail = classDetailPage;
                //       pushTransition(context, classDetailPage).then((value) {
                //         if (value != null && value) {
                //           bloc.add(MyCreateReloadEvent());
                //         }
                //       });
                //     }
                //   });
                // } else {
                ClassDetailPage classDetailPage = ClassDetailPage(
                  profileGet: widget.profile,
                  heroTag: 'listImage$index',
                  bloc: bloc,
                  classUuid: bloc.classList!.classData[index].classUuid,
                  mainNeighborHood: bloc.mainNeighborHood,
                  classMadeCheck: bloc.classMadeCheck,
                  my: true,
                );
                dataSaver.keywordClassDetail = classDetailPage;
                pushTransition(context, classDetailPage);
                // }
              },
              child: Container(
                color: AppColors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.3),
                            color: statusColor(
                                bloc.classList!.classData[index].status),
                          ),
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Center(
                            child: customText(
                              statusText(
                                  bloc.classList!.classData[index].status),
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight:
                                      weightSet(textWeight: TextWeight.BOLD),
                                  fontSize:
                                      fontSizeSet(textSize: TextSize.T10)),
                            ),
                          ),
                        ),
                        spaceW(8),
                        Center(
                          child: customText(
                            '${bloc.classList!.classData[index].content.hangNames.replaceAll(',', ', ')}',
                            style: TextStyle(
                                color: AppColors.greenGray500,
                                fontWeight:
                                    weightSet(textWeight: TextWeight.BOLD),
                                fontSize: fontSizeSet(textSize: TextSize.T12)),
                          ),
                        ),
                      ],
                    ),
                    spaceH(12),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                bloc.classList!.classData[index].content.image!
                                            .storedName ==
                                        null
                                    ? Container(
                                        width: 128,
                                        height: 72,
                                        decoration: BoxDecoration(
                                            color: AppColors.gray200,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: Image.asset(
                                          AppImages.dfClassMain,
                                          width: 128,
                                          height: 72,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container(
                                          width: 128,
                                          height: 72,
                                          child: CacheImage(
                                            imageUrl: bloc.classList!
                                                .classData[index].content.image!
                                                .toView(context: context, ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            fit: BoxFit.cover,
                                            placeholder: Container(
                                              width: 128,
                                              height: 72,
                                              decoration: BoxDecoration(
                                                  color: AppColors.gray200,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Image.asset(
                                                AppImages.dfClassMain,
                                                width: 128,
                                                height: 72,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                bloc.classList!.classData[index].content
                                            .firstFreeFlag ==
                                        1
                                    ? Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                            height: 20,
                                            padding: EdgeInsets.only(
                                                left: 6, right: 6),
                                            decoration: BoxDecoration(
                                                color: AppColors.black
                                                    .withOpacity(0.24),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Center(
                                              child: customText('첫회무료',
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontWeight: weightSet(
                                                          textWeight:
                                                              TextWeight.BOLD),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T10))),
                                            )),
                                      )
                                    : Container()
                              ],
                            ),
                            spaceW(16),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(children: [
                                            customTextSpan(
                                                text: bloc
                                                            .classList!
                                                            .classData[index]
                                                            .content
                                                            .title ==
                                                        null
                                                    ? '클래스 제목을 적어주세요\n'
                                                    : bloc
                                                            .classList!
                                                            .classData[index]
                                                            .content
                                                            .title! +
                                                        " ",
                                                style: TextStyle(
                                                    color: bloc
                                                                .classList!
                                                                .classData[
                                                                    index]
                                                                .content
                                                                .title ==
                                                            null
                                                        ? AppColors.gray500
                                                        : AppColors.gray900,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T14))),
                                            customTextSpan(
                                                text: bloc
                                                            .classList!
                                                            .classData[index]
                                                            .content
                                                            .category!
                                                            .name ==
                                                        null
                                                    ? '카테고리를 선택해주세요'
                                                    : bloc
                                                        .classList!
                                                        .classData[index]
                                                        .content
                                                        .category!
                                                        .name!,
                                                style: TextStyle(
                                                    color: AppColors.gray500,
                                                    fontWeight: weightSet(
                                                        textWeight:
                                                            TextWeight.MEDIUM),
                                                    fontSize: fontSizeSet(
                                                        textSize:
                                                            TextSize.T11))),
                                          ]),
                                        ),
                                      )
                                    ],
                                  ),
                                  spaceH(6),
                                  Container(
                                    height: 20,
                                    child: (bloc.classList!.classData[index]
                                                .content.minCost ==
                                            null)
                                        ? customText('비용을 적어주세요',
                                            style: TextStyle(
                                                color: AppColors.primaryLight30,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.BOLD),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T14)))
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              bloc.classList!.classData[index]
                                                          .content.groupFlag ==
                                                      1
                                                  ? Row(
                                                      children: [
                                                        Container(
                                                          height: 20,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 6,
                                                                  right: 6),
                                                          child: Center(
                                                              child: customText(
                                                                  '그룹할인',
                                                                  style: TextStyle(
                                                                      color: AppColors
                                                                          .white,
                                                                      fontWeight: weightSet(
                                                                          textWeight: TextWeight
                                                                              .BOLD),
                                                                      fontSize: fontSizeSet(
                                                                          textSize:
                                                                              TextSize.T10)))),
                                                          decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .accent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4)),
                                                        ),
                                                        spaceW(6)
                                                      ],
                                                    )
                                                  : Container(),
                                              customText(
                                                  bloc
                                                              .classList!
                                                              .classData[index]
                                                              .content
                                                              .costType ==
                                                          'HOUR'
                                                      ? '${numberFormatter(bloc.classList!.classData[index].content.groupFlag == 1 ? bloc.classList!.classData[index].content.costOfPerson : bloc.classList!.classData[index].content.minCost!)}원 ~'
                                                      : '배움나눔',
                                                  style: TextStyle(
                                                      color: bloc
                                                                  .classList!
                                                                  .classData[
                                                                      index]
                                                                  .content
                                                                  .costType ==
                                                              'HOUR'
                                                          ? AppColors.gray900
                                                          : AppColors
                                                              .secondaryDark30,
                                                      fontWeight: weightSet(
                                                          textWeight:
                                                              TextWeight.BOLD),
                                                      fontSize: fontSizeSet(
                                                          textSize:
                                                              TextSize.T14)))
                                            ],
                                          ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        bloc.classList!.classData[index].status == 'TEMP'
                            ? Container()
                            : spaceH(10),
                      ],
                    )
                  ],
                ),
              ),
            ),
            bloc.classList!.classData[index].managerStopFlag == 1
                ? Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        ClassDetailPage classDetailPage = ClassDetailPage(
                          profileGet: widget.profile,
                          heroTag: 'listImage$index',
                          bloc: bloc,
                          classUuid: bloc.classList!.classData[index].classUuid,
                          mainNeighborHood: bloc.mainNeighborHood,
                          classMadeCheck: bloc.classMadeCheck,
                          my: true,
                        );
                        dataSaver.keywordClassDetail = classDetailPage;
                        pushTransition(context, classDetailPage);
                      },
                      child: ListStop(
                        editPress: () {
                          pushTransition(
                              context,
                              CreateClassPage(
                                profileGet: dataSaver.profileGet!,
                                edit: true,
                                temp: bloc.classList!.classData[index].status ==
                                        'TEMP'
                                    ? true
                                    : false,
                                classUuid:
                                    bloc.classList!.classData[index].classUuid,
                                ing: bloc.classList!.classData[index].status ==
                                        'NORMAL'
                                    ? true
                                    : false,
                                stop: true,
                                previousPage: 'connected_in_register',
                              ));
                        },
                        whyRemove: bloc.classList!.classData[index]
                                .managerStopReasonText ??
                            '',
                      ),
                    ),
                  )
                : Container()
          ],
        ),
        bloc.classList!.classData[index].status == 'NORMAL'
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    amplitudeEvent('my_class_share', {
                      'user_name': dataSaver.profileGet!.nickName,
                      'class_name':
                          bloc.classList!.classData[index].content.title,
                      'cost_min':
                          bloc.classList!.classData[index].content.minCost,
                      'town_sido':
                          bloc.classList!.classData[index].content.areas == null
                              ? ''
                              : bloc.classList!.classData[index].content.areas!
                                  .map((e) => e.sidoName)
                                  .toList()
                                  .join(','),
                      'town_sigungu':
                          bloc.classList!.classData[index].content.areas == null
                              ? ''
                              : bloc.classList!.classData[index].content.areas!
                                  .map((e) => e.sigunguName)
                                  .toList()
                                  .join(','),
                      'town_dongeupmyeon':
                          bloc.classList!.classData[index].content.areas == null
                              ? ''
                              : bloc.classList!.classData[index].content.areas!
                                  .map((e) => e.eupmyeondongName)
                                  .toList()
                                  .join(','),
                      'costType':
                          bloc.classList!.classData[index].content.costType ==
                                  'HOUR'
                              ? 0
                              : 1,
                      'costSharing':
                          bloc.classList!.classData[index].content.shareType ??
                              '',
                      'type': 'made_class',
                      'first_free': bloc.classList!.classData[index].content
                                  .firstFreeFlag ==
                              0
                          ? false
                          : true,
                      'group':
                          bloc.classList!.classData[index].content.groupFlag ==
                                  0
                              ? false
                              : true,
                      'group_cost':bloc.classList!.classData[index].content.groupFlag ==
                          0
                          ? '' :
                          bloc.classList!.classData[index].content.costOfPerson
                    });
                    Share.share((await ClassRepository.getShareLink(
                                bloc.classList!.classData[index].classUuid)
                            as ReturnData)
                        .data);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.errorLight30,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: Center(
                    child: customText('내 클래스 소문내기',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T13))),
                  ),
                ),
              )
            : Container(),
        bloc.classList!.classData[index].status == 'NORMAL'
            ? spaceH(20)
            : Container(),
        bloc.classList!.classData[index].status == 'TEMP'
            ? spaceH(10)
            : Container(),
        bloc.classList!.classData[index].status == 'TEMP'
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    pushTransition(
                        context,
                        CreateClassPage(
                          profileGet: dataSaver.profileGet!,
                          edit: true,
                          temp:
                              bloc.classList!.classData[index].status == 'TEMP'
                                  ? true
                                  : false,
                          classUuid: bloc.classList!.classData[index].classUuid,
                          ing: bloc.classList!.classData[index].status ==
                                  'NORMAL'
                              ? true
                              : false,
                          stop: false,
                          previousPage: 'connected_out_register',
                        )).then((value) {
                      bloc.add(MyCreateReloadEvent());
                      if (value != null) {
                        ClassDetailPage classDetailPage = ClassDetailPage(
                          profileGet: widget.profile,
                          heroTag: 'listImage$index',
                          bloc: bloc,
                          classUuid: bloc.classList!.classData[index].classUuid,
                          mainNeighborHood: bloc.mainNeighborHood,
                          my: true,
                        );
                        dataSaver.keywordClassDetail = classDetailPage;
                        pushTransition(context, classDetailPage).then((value) {
                          if (value != null && value) {
                            bloc.add(MyCreateReloadEvent());
                          }
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.secondaryLight30,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: Center(
                    child: customText('이어서 작성하기',
                        style: TextStyle(
                            color: AppColors.secondaryDark30,
                            fontWeight: weightSet(textWeight: TextWeight.BOLD),
                            fontSize: fontSizeSet(textSize: TextSize.T13))),
                  ),
                ),
              )
            : Container(),
        bloc.classList!.classData[index].status == 'TEMP'
            ? spaceH(20)
            : Container(),
        bloc.classList!.classData[index].managerStopFlag == 1
            ? spaceH(20)
            : Container(),
      ],
    );
  }

  classList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (bloc.selectTap == 0) {
          return classListItem(index);
        } else if (bloc.selectTap == 1) {
          if (bloc.classList!.classData[index].status == 'NORMAL') {
            return classListItem(index);
          }
        } else if (bloc.selectTap == 2) {
          if (bloc.classList!.classData[index].status == 'TEMP') {
            return classListItem(index);
          }
        } else if (bloc.selectTap == 3) {
          if (bloc.classList!.classData[index].status == "STOP") {
            return classListItem(index);
          }
        }
        return Container();
      },
      shrinkWrap: true,
      itemCount: bloc.classList == null ? 0 : bloc.classList!.classData.length,
    );
  }

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
                  appBar: baseAppBar(
                      title: AppStrings.of(StringKey.myMadeClass),
                      context: context,
                      onPressed: () {
                        pop(context);
                      }),
                  backgroundColor: AppColors.white,
                  body: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          top(),
                          bloc.classList == null ||
                                  bloc.classList!.classData.length == 0
                              ? Column(
                                  children: [
                                    spaceH(100),
                                    Container(
                                      height: 160,
                                      child:
                                          Image.asset(AppImages.imgEmptyList),
                                    ),
                                    customText(
                                      bloc.selectTap == 0
                                          ? AppStrings.of(
                                              StringKey.myClassNotYet)
                                          : bloc.selectTap == 1
                                              ? '운영중인 클래스가 아직 없어요'
                                              : bloc.selectTap == 2
                                                  ? '임시저장된 클래스가 아직 없어요'
                                                  : '운영중지된 클래스가 아직 없어요',
                                      style: TextStyle(
                                          color: AppColors.gray900,
                                          fontWeight: weightSet(
                                              textWeight: TextWeight.MEDIUM),
                                          fontSize: fontSizeSet(
                                              textSize: TextSize.T14)),
                                    ),
                                    spaceH(20),
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(children: [
                                        customTextSpan(
                                            text: AppStrings.of(
                                                StringKey.neighborhoodClass),
                                            style: TextStyle(
                                                color: AppColors.accentLight20,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.REGULAR),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T14))),
                                        TextSpan(
                                            text: AppStrings.of(
                                                StringKey.madeClassCallStudent),
                                            style: TextStyle(
                                                color: AppColors.gray400,
                                                fontWeight: weightSet(
                                                    textWeight:
                                                        TextWeight.REGULAR),
                                                fontSize: fontSizeSet(
                                                    textSize: TextSize.T14)))
                                      ]),
                                    ),
                                  ],
                                )
                              : classList(),
                        ],
                      ),
                    ),
                  ),
                ),
                bloc.scrollEnd ? Container() : floatingActionButton(),
                loadingView(bloc.loading)
              ],
            ),
          );
        });
  }

  floatingActionButton() {
    return Positioned(
        bottom: 12 + MediaQuery.of(context).padding.bottom,
        right: 12,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          onEnd: () {
            setState(() {
              bloc.floatingAnimationEnd = true;
            });
          },
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(!bloc.scrollUp ? 48 : 24),
          ),
          padding: EdgeInsets.zero,
          width: !bloc.scrollUp ? 48 : 160,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (!bloc.classMadeCheck) {
                showToast(
                    context: context,
                    text: AppStrings.of(StringKey.addMaxClassToast));
              } else {
                amplitudeRevenue(productId: 'class_register', price: 3);
                amplitudeEvent(
                    'class_register', {'inflow_page': 'made_register'});
                if (production == 'prod-release' && kReleaseMode) {
                  Airbridge.event.send(ViewHomeEvent());
                  Airbridge.event.send(Event('class_register_start'));
                }
                pushTransition(
                    context,
                    CreateClassPage(
                      profileGet: widget.profile!,
                      floating: true,
                      previousPage: 'made_register',
                    )).then((value) {
                  if (value != null) {
                    ClassDetailPage classDetailPage = ClassDetailPage(
                      profileGet: widget.profile,
                      classUuid: value,
                      mainNeighborHood: bloc.mainNeighborHood,
                      my: true,
                    );
                    dataSaver.keywordClassDetail = classDetailPage;
                    pushTransition(context, classDetailPage).then((value) {
                      bloc.add(MyCreateReloadEvent());
                    });
                  }
                  bloc.add(MyCreateReloadEvent());
                });
              }
            },
            style: ElevatedButton.styleFrom(
                primary: AppColors.primary,
                elevation: 0,
                padding: !bloc.scrollUp
                    ? EdgeInsets.zero
                    : EdgeInsets.only(left: 12),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(!bloc.scrollUp ? 48 : 24))),
            child: Center(
              child: !bloc.scrollUp
                  ? Image.asset(
                      AppImages.iPlusW,
                      width: 24,
                      height: 24,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.iClassFab,
                          width: 24,
                          height: 24,
                        ),
                        spaceW(10),
                        Expanded(
                          child: bloc.floatingAnimationEnd
                              ? customText(
                                  '새 클래스 만들기',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: weightSet(
                                          textWeight: TextWeight.BOLD),
                                      fontSize:
                                          fontSizeSet(textSize: TextSize.T14)),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                )
                              : Container(),
                        )
                      ],
                    ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        if (bloc.classList != null && bloc.classList!.classData.length > 2) {
          if (bloc.scrollEnd) {
            bloc.scrollEnd = false;
            setState(() {});
          }
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < scrollController!.offset) &&
              scrollController!.offset >=
                  scrollController!.position.maxScrollExtent &&
              !scrollController!.position.outOfRange) {
            bloc.scrollUnder = true;
            bloc.bottomOffset = scrollController!.offset;
            bloc.add(ScrollEndEvent());
          }
          if (!bloc.scrollUnder &&
              (bloc.bottomOffset == 0 ||
                  bloc.bottomOffset < scrollController!.offset) &&
              scrollController!.offset >=
                  (scrollController!.position.maxScrollExtent * 0.7) &&
              !scrollController!.position.outOfRange) {
            bloc.add(GetDataEvent());
          }
          if (scrollController!.offset <=
                  scrollController!.position.minScrollExtent &&
              !scrollController!.position.outOfRange) {
            bloc.floatingAnimationEnd = true;
            bloc.add(ScrollEvent(scroll: true));
          }
          if (scrollController!.position.userScrollDirection ==
              ScrollDirection.forward) {
            bloc.bottomOffset = 0;
            bloc.scrollUnder = false;
            if (!bloc.upDownCheck) {
              bloc.upDownCheck = true;
              bloc.startPixels = scrollController!.offset;
            }
            // 스크롤 다운
          } else if (scrollController!.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (bloc.upDownCheck) {
              bloc.upDownCheck = false;
              bloc.startPixels = scrollController!.offset;
            }
            // 스크롤 업
          }

          if (bloc.startPixels.toInt() - scrollController!.offset.toInt() >
              30) {
            if (!bloc.scrollUp) {
              bloc.floatingAnimationEnd = false;
              bloc.add(ScrollEvent(scroll: true));
            }
          } else if (bloc.startPixels.toInt() -
                  scrollController!.offset.toInt() <
              -30) {
            if (bloc.scrollUp) {
              bloc.floatingAnimationEnd = false;
              bloc.add(ScrollEvent(scroll: false));
            }
          }
        }
      });
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  MyCreateClassBloc initBloc() {
    return MyCreateClassBloc(context)
      ..add(MyCreateClassInitEvent(selectTap: widget.selectTap));
  }
}
